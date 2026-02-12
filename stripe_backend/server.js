require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Stripe = require('stripe');
const admin = require('firebase-admin');

const app = express();
app.use(cors());
app.use(express.json());

const port = Number(process.env.PORT || 8787);
const stripeSecretKey = process.env.STRIPE_SECRET_KEY;

if (!stripeSecretKey) {
  console.error('Missing STRIPE_SECRET_KEY in stripe_backend/.env');
  process.exit(1);
}

const stripe = new Stripe(stripeSecretKey);
const firestore = initFirestoreAdmin();

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.post('/payment-intent', async (req, res) => {
  try {
    const { amount, currency, customerEmail, customerName } = req.body || {};

    if (!Number.isInteger(amount) || amount <= 0) {
      return res.status(400).json({ error: 'Invalid amount. Must be integer > 0.' });
    }
    if (!currency || typeof currency !== 'string') {
      return res.status(400).json({ error: 'Invalid currency.' });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency: currency.toLowerCase(),
      receipt_email: typeof customerEmail === 'string' && customerEmail.length > 0
        ? customerEmail
        : undefined,
      metadata: {
        customerName: typeof customerName === 'string' ? customerName : '',
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return res.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    const message =
      error && typeof error.message === 'string'
        ? error.message
        : 'Stripe payment-intent creation failed.';
    return res.status(500).json({ error: message });
  }
});

app.post('/decrease-stock', async (req, res) => {
  if (!firestore) {
    return res.status(503).json({
      error:
        'Firebase Admin nije konfigurisan na backendu. Podesi FIREBASE_SERVICE_ACCOUNT_JSON ili FIREBASE_SERVICE_ACCOUNT_PATH.',
    });
  }

  try {
    const { items } = req.body || {};
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'Invalid items payload.' });
    }

    const aggregated = new Map();
    for (const rawItem of items) {
      const productId =
        rawItem && typeof rawItem.productId === 'string'
          ? rawItem.productId.trim()
          : '';
      const size = Number(rawItem?.size);
      const quantity = Number(rawItem?.quantity);
      const title =
        rawItem && typeof rawItem.title === 'string' ? rawItem.title : 'Proizvod';

      if (!productId || productId.startsWith('assets/')) {
        continue;
      }
      if (!Number.isInteger(size) || !Number.isInteger(quantity) || quantity <= 0) {
        return res.status(400).json({ error: 'Invalid product size/quantity.' });
      }

      const key = `${productId}-${size}`;
      const prev = aggregated.get(key);
      if (prev) {
        prev.quantity += quantity;
      } else {
        aggregated.set(key, {
          productId,
          size,
          quantity,
          title,
          label: `${title} (broj ${size})`,
        });
      }
    }

    if (aggregated.size === 0) {
      return res.status(200).json({ ok: true, updated: 0 });
    }

    await firestore.runTransaction(async (tx) => {
      for (const entry of aggregated.values()) {
        const stockRef = firestore
          .collection('products')
          .doc(entry.productId)
          .collection('stocks')
          .doc(String(entry.size));
        const snap = await tx.get(stockRef);
        if (!snap.exists) {
          throw new Error(`${entry.label} nije dostupan na stanju.`);
        }

        const currentQty = Number(snap.get('qty') || 0);
        if (currentQty < entry.quantity) {
          throw new Error(
            `Nema dovoljno na stanju za ${entry.label}. Dostupno: ${currentQty}, trazeno: ${entry.quantity}.`
          );
        }

        tx.update(stockRef, { qty: currentQty - entry.quantity });
      }
    });

    return res.status(200).json({ ok: true, updated: aggregated.size });
  } catch (error) {
    const message =
      error && typeof error.message === 'string'
        ? error.message
        : 'Stock decrement failed.';
    return res.status(500).json({ error: message });
  }
});

app.listen(port, () => {
  console.log(`Stripe backend running on http://localhost:${port}`);
});

function initFirestoreAdmin() {
  try {
    if (admin.apps.length > 0) {
      return admin.firestore();
    }

    const serviceAccount = getServiceAccountFromEnv();
    if (serviceAccount) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      return admin.firestore();
    }

    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      admin.initializeApp({
        credential: admin.credential.applicationDefault(),
      });
      return admin.firestore();
    }

    console.warn(
      'Firebase Admin nije konfigurisan. /decrease-stock endpoint ce vracati 503.'
    );
    return null;
  } catch (e) {
    console.warn(`Firebase Admin init failed: ${e.message}`);
    return null;
  }
}

function getServiceAccountFromEnv() {
  const inline = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (inline && inline.trim()) {
    return JSON.parse(inline);
  }

  const base64 = process.env.FIREBASE_SERVICE_ACCOUNT_BASE64;
  if (base64 && base64.trim()) {
    const decoded = Buffer.from(base64, 'base64').toString('utf8');
    return JSON.parse(decoded);
  }

  const path = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
  if (path && path.trim()) {
    const fs = require('fs');
    const content = fs.readFileSync(path, 'utf8');
    return JSON.parse(content);
  }

  return null;
}
