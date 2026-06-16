const express = require('express');
const axios = require('axios');
const cors = require('cors');
const crypto = require('crypto');

const app = express();
app.use(express.json());
app.use(cors());

const PAYMOB_API_KEY = process.env.PAYMOB_API_KEY;
const HMAC_SECRET = process.env.HMAC_SECRET;
const CARD_INTEGRATION_ID = parseInt(process.env.CARD_INTEGRATION_ID || '5731424');
const CASH_INTEGRATION_ID = parseInt(process.env.CASH_INTEGRATION_ID || '5732402');
const CARD_IFRAME_ID = process.env.CARD_IFRAME_ID || '1052844';

async function getAuthToken() {
  const res = await axios.post('https://accept.paymob.com/api/auth/tokens', {
    api_key: PAYMOB_API_KEY
  });
  return res.data.token;
}

async function registerOrder(token, amount, bookingId) {
  const res = await axios.post('https://accept.paymob.com/api/ecommerce/orders', {
    auth_token: token,
    delivery_needed: false,
    amount_cents: Math.round(amount * 100),
    currency: 'EGP',
    merchant_order_id: bookingId,
    items: []
  });
  return res.data.id;
}

async function getPaymentKey(token, orderId, amount, integrationId, travelerName, travelerPhone) {
  const res = await axios.post('https://accept.paymob.com/api/acceptance/payment_keys', {
    auth_token: token,
    amount_cents: Math.round(amount * 100),
    expiration: 3600,
    order_id: orderId,
    billing_data: {
      first_name: travelerName || 'Traveler',
      last_name: 'User',
      email: 'traveler@masar.app',
      phone_number: travelerPhone || '+201000000000',
      apartment: 'NA', floor: 'NA', street: 'NA',
      building: 'NA', shipping_method: 'NA', postal_code: 'NA',
      city: 'Cairo', country: 'EG', state: 'Cairo'
    },
    currency: 'EGP',
    integration_id: integrationId
  });
  return res.data.token;
}

function verifyHmac(body) {
  const obj = body.obj || {};
  const orderId = obj.order?.id ?? '';
  const str = [
    obj.amount_cents, obj.created_at, obj.currency, obj.error_occured,
    obj.has_parent_transaction, obj.id, obj.integration_id, obj.is_3d_secure,
    obj.is_auth, obj.is_capture, obj.is_refunded, obj.is_standalone_payment,
    obj.is_voided, orderId, obj.owner, obj.pending,
    obj.source_data_pan, obj.source_data_sub_type, obj.source_data_type, obj.success
  ].join('');
  const hmac = crypto.createHmac('sha512', HMAC_SECRET).update(str).digest('hex');
  return hmac === body.hmac;
}

app.get('/', (req, res) => res.send('Masar Payment Server Running'));

app.post('/createPaymentIntent', async (req, res) => {
  try {
    const { bookingId, amount, paymentMethod, travelerName, travelerPhone } = req.body;

    if (!bookingId || !amount || !paymentMethod) {
      return res.status(400).json({ success: false, error: 'Missing required fields' });
    }

    const integrationId = paymentMethod === 'card' ? CARD_INTEGRATION_ID : CASH_INTEGRATION_ID;

    const authToken = await getAuthToken();
    const orderId = await registerOrder(authToken, amount, bookingId);
    const paymentKey = await getPaymentKey(authToken, orderId, amount, integrationId, travelerName, travelerPhone);
    const checkoutUrl = `https://accept.paymob.com/api/acceptance/iframes/${CARD_IFRAME_ID}?payment_token=${paymentKey}`;

    console.log('Payment intent created: bookingId=' + bookingId + ', amount=' + amount + ', method=' + paymentMethod);
    res.json({ success: true, checkoutUrl, paymentKey, orderId });

  } catch (error) {
    console.error('createPaymentIntent error:', error?.response?.data || error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/webhook', async (req, res) => {
  try {
    console.log('Webhook received:', JSON.stringify(req.body, null, 2));

    if (HMAC_SECRET && !verifyHmac(req.body)) {
      console.log('Invalid HMAC - ignoring webhook');
      return res.sendStatus(200);
    }

    const obj = req.body.obj;
    if (!obj) return res.sendStatus(200);

    const isSuccess = obj.success === true;
    const bookingId = obj.order?.merchant_order_id;
    const amountPaid = obj.amount_cents / 100;
    const transactionId = obj.id;

    if (isSuccess && bookingId) {
      console.log('PAYMENT CONFIRMED: booking=' + bookingId + ', amount=' + amountPaid + ' EGP, txId=' + transactionId);
    } else if (obj.pending) {
      console.log('PAYMENT PENDING: booking=' + bookingId);
    } else {
      console.log('PAYMENT FAILED: booking=' + bookingId);
    }

    res.sendStatus(200);
  } catch (error) {
    console.error('Webhook error:', error.message);
    res.sendStatus(200);
  }
});

app.get('/paymentStatus/:bookingId', async (req, res) => {
  try {
    const { bookingId } = req.params;
    const authToken = await getAuthToken();
    const response = await axios.get(
      'https://accept.paymob.com/api/ecommerce/orders?merchant_order_id=' + bookingId,
      { headers: { Authorization: 'Bearer ' + authToken } }
    );
    res.json({ success: true, data: response.data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, '0.0.0.0', () => console.log('Server running on port ' + PORT));
