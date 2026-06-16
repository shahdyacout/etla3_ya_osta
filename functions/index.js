const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const axios = require("axios");
const crypto = require("crypto");

// Secrets
const PAYMOB_SECRET_KEY = defineSecret("PAYMOB_SECRET_KEY");
const PAYMOB_CARD_INTEGRATION_ID = defineSecret("PAYMOB_CARD_INTEGRATION_ID");
const PAYMOB_CASH_INTEGRATION_ID = defineSecret("PAYMOB_CASH_INTEGRATION_ID");
const PAYMOB_HMAC = defineSecret("PAYMOB_HMAC");

// ============================================
// Function 1: Create Payment Intent
// ============================================
exports.createPaymentIntent = onRequest(
  { secrets: [PAYMOB_SECRET_KEY, PAYMOB_CARD_INTEGRATION_ID, PAYMOB_CASH_INTEGRATION_ID] },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Methods", "POST");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      res.status(204).send("");
      return;
    }

    try {
      const { amount, currency = "EGP", paymentMethod, bookingId, travelerName, travelerEmail, travelerPhone } = req.body;

      // Step 1: Get auth token
      const authResponse = await axios.post("https://accept.paymob.com/api/auth/tokens", {
        api_key: PAYMOB_SECRET_KEY.value(),
      });
      const authToken = authResponse.data.token;

      // Step 2: Create order
      const orderResponse = await axios.post("https://accept.paymob.com/api/ecommerce/orders", {
        auth_token: authToken,
        delivery_needed: false,
        amount_cents: Math.round(amount * 100),
        currency: currency,
        merchant_order_id: bookingId,
        items: [],
      });
      const orderId = orderResponse.data.id;

      // Step 3: Get payment key
      const integrationId = paymentMethod === "card"
        ? PAYMOB_CARD_INTEGRATION_ID.value()
        : PAYMOB_CASH_INTEGRATION_ID.value();

      const paymentKeyResponse = await axios.post("https://accept.paymob.com/api/acceptance/payment_keys", {
        auth_token: authToken,
        amount_cents: Math.round(amount * 100),
        expiration: 3600,
        order_id: orderId,
        billing_data: {
          first_name: travelerName || "Traveler",
          last_name: ".",
          email: travelerEmail || "traveler@masar.app",
          phone_number: travelerPhone || "+201000000000",
          country: "EG",
          city: "Cairo",
          street: "NA",
          floor: "NA",
          building: "NA",
          apartment: "NA",
        },
        currency: currency,
        integration_id: parseInt(integrationId),
      });

      const paymentToken = paymentKeyResponse.data.token;
      const checkoutUrl = `https://accept.paymob.com/api/acceptance/iframes/1051221?payment_token=${paymentToken}`;

      res.status(200).json({
        success: true,
        checkoutUrl: checkoutUrl,
        orderId: orderId,
        paymentToken: paymentToken,
      });
    } catch (error) {
      console.error("Payment error:", error.response?.data || error.message);
      res.status(500).json({ success: false, error: error.message });
    }
  }
);

// ============================================
// Function 2: Paymob Webhook
// ============================================
exports.paymobWebhook = onRequest(
  { secrets: [PAYMOB_HMAC] },
  async (req, res) => {
    try {
      const hmacSecret = PAYMOB_HMAC.value();
      const receivedHmac = req.query.hmac;

      // Verify HMAC
      const obj = req.body.obj;
      const hmacString = [
        obj.amount_cents, obj.created_at, obj.currency,
        obj.error_occured, obj.has_parent_transaction, obj.id,
        obj.integration_id, obj.is_3d_secure, obj.is_auth,
        obj.is_capture, obj.is_refunded, obj.is_standalone_payment,
        obj.is_voided, obj.order?.id, obj.owner,
        obj.pending, obj.source_data?.pan, obj.source_data?.sub_type,
        obj.source_data?.type, obj.success,
      ].join("");

      const calculatedHmac = crypto
        .createHmac("sha512", hmacSecret)
        .update(hmacString)
        .digest("hex");

      if (calculatedHmac !== receivedHmac) {
        console.error("HMAC mismatch!");
        res.status(401).send("Unauthorized");
        return;
      }

      // Payment success?
      if (req.body.type === "TRANSACTION" && obj.success === true) {
        const bookingId = obj.order?.merchant_order_id;
        const admin = require("firebase-admin");
        if (!admin.apps.length) admin.initializeApp();
        const db = admin.firestore();

        // Update booking
        await db.collection("bookings").doc(bookingId).update({
          deposit_status: "paid",
          paymob_order_id: obj.order?.id,
          paid_at: new Date().toISOString(),
        });

        // Update driver wallet
        const bookingDoc = await db.collection("bookings").doc(bookingId).get();
        const booking = bookingDoc.data();
        if (booking?.driverId) {
          const driverRef = db.collection("wallets").doc(booking.driverId);
          await driverRef.update({
            balance: admin.firestore.FieldValue.increment(booking.depositAmount || 0),
          });
        }
      }

      res.status(200).send("OK");
    } catch (error) {
      console.error("Webhook error:", error);
      res.status(500).send("Error");
    }
  }
);