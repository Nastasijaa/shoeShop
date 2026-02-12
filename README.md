# skriptarnica

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Stripe test payment setup

Checkout now uses Stripe Payment Sheet (card number, expiry, CVC) and creates
an order only after a successful Stripe confirmation.

1. Start local Stripe backend:

```bash
cd stripe_backend
cp .env.example .env
```

PowerShell alternative:

```powershell
cd stripe_backend
Copy-Item .env.example .env
```

Set `STRIPE_SECRET_KEY` in `.env` to your Stripe `sk_test_...` key, then run:

```bash
npm install
npm start
```

Backend runs on `http://localhost:8787`.

2. Start app with Stripe config:

```bash
flutter run \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx \
  --dart-define=STRIPE_PAYMENT_INTENT_URL=http://YOUR_PC_LAN_IP:8787/payment-intent \
  --dart-define=STRIPE_MERCHANT_IDENTIFIER=merchant.com.example.shoeshop
```

If app runs on a physical phone, `YOUR_PC_LAN_IP` should be your computer LAN IP
(example `192.168.0.23`), not `localhost`.
On Windows you can find it with `ipconfig` (IPv4 Address).

3. Backend endpoint (`STRIPE_PAYMENT_INTENT_URL`) must create a Stripe
   `PaymentIntent` and return JSON:

```json
{
  "clientSecret": "pi_..._secret_...",
  "paymentIntentId": "pi_..."
}
```

4. Stripe test card example:
`4242 4242 4242 4242`, any future date, any CVC, any ZIP/postal.

Security note: never put `sk_test_...` or `sk_live_...` keys in Flutter app code.
