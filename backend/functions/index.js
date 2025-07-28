const { onRequest, onCall, HttpsError } = require('firebase-functions/v2/https');
const { onInit } = require('firebase-functions/v2');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

// Firestore reference
const db = admin.firestore();

// Stripe variable (lazy-initialized)
let stripe = null;

// Stripe initialization moved into onInit()
onInit(() => {
  const stripeSecret = process.env.STRIPE_SECRET || (process.env.FUNCTIONS_EMULATOR ? 'sk_test_...' : null); // fallback for emulator

  if (!stripeSecret) {
    console.warn('Stripe secret key not found in environment variables.');
  } else {
    stripe = require('stripe')(stripeSecret);
    console.log('✅ Stripe initialized in onInit');
  }
});

// ✅ Test endpoint (still v2)
exports.test = onRequest((req, res) => {
  res.send("Hello from Ubuntu Interiors!");
});

// ✅ Create Payment Intent
exports.createPaymentIntent = onCall(async (request) => {
  try {
    const context = request.context;
    const data = request.data;

    if (!context.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { amount = 10, currency = 'usd', artworkId = '', artistId = '' } = data;

    if (amount < 0.5) {
      throw new HttpsError('invalid-argument', 'Amount too small');
    }

    if (!stripe) {
      throw new HttpsError('internal', 'Stripe not initialized');
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency,
      metadata: {
        userId: context.auth.uid,
        artworkId,
        artistId,
        appName: 'Ubuntu Interior',
      },
      automatic_payment_methods: { enabled: true },
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    console.error('❌ Payment Intent Error:', error);
    throw new HttpsError('internal', 'Payment creation failed: ' + error.message);
  }
});

// ✅ Confirm Payment
exports.confirmPayment = onCall(async (request) => {
  try {
    const context = request.context;
    const data = request.data;

    if (!context.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { paymentIntentId } = data;
    if (!paymentIntentId) {
      throw new HttpsError('invalid-argument', 'Payment Intent ID required');
    }

    if (!stripe) {
      throw new HttpsError('internal', 'Stripe not initialized');
    }

    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'succeeded') {
      await db.collection('orders').add({
        userId: context.auth.uid,
        paymentIntentId,
        amount: paymentIntent.amount / 100,
        currency: paymentIntent.currency,
        artworkId: paymentIntent.metadata.artworkId || '',
        artistId: paymentIntent.metadata.artistId || '',
        status: 'completed',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, status: paymentIntent.status };
    }

    return { success: false, status: paymentIntent.status };
  } catch (error) {
    console.error('❌ Confirm Payment Error:', error);
    throw new HttpsError('internal', 'Payment confirmation failed: ' + error.message);
  }
});
