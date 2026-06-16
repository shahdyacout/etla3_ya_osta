const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

const PAYMOB_API_KEY = 'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRFNE1UZ3pPQ3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS53LTNFVVdFU0M0ZjNPYUpRaExTdzJ4Z2VwQXEyN3BqMGwtNFJfc2ZNaXRrNkd3LVlTdVRLZ0VQM1NQWkxKS2xXXy15NlVkZE9ucnhveFNUTXduV0VDZw==';
const HMAC_SECRET = '6C6544C2F1D34FF923587FDCA9B369EF';
const CARD_INTEGRATION_ID = 5731424;
const CASH_INTEGRATION_ID = 5732402;

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
      apartment: 'NA',
      floor: 'NA',
      street: 'NA',
      building: 'NA',
      shipping_method: 'NA',
      postal_code: 'NA',
      city: 'Cairo',
      country: 'EG',
      state: 'Cairo'
    },
    currency: 'EGP',
    integration_id: integrationId
  });
  return res.data.token;
}

app.post('/createPaymentIntent', async (req, res) => {
  try {
    const { bookingId, amount, paymentMethod, travelerName, travelerPhone } = req.body;
    const integrationId = paymentMethod === 'card' ? CARD_INTEGRATION_ID : CASH_INTEGRATION_ID;

    const authToken = await getAuthToken();
    const orderId = await registerOrder(authToken, amount, bookingId);
    const paymentKey = await getPaymentKey(authToken, orderId, amount, integrationId, travelerName, travelerPhone);

    const checkoutUrl = `https://accept.paymob.com/api/acceptance/iframes/1052844?payment_token=${paymentKey}`;

    res.json({ success: true, checkoutUrl, paymentKey });
  } catch (error) {
    console.error(error?.response?.data || error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.post('/webhook', (req, res) => {
  console.log('Webhook received:', req.body);
  res.sendStatus(200);
});

app.get('/', (req, res) => res.send('Masar Payment Server Running ✅'));

const PORT = process.env.PORT || 10000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
