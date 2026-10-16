# Ubuntu Interiors

A marketplace app for African-inspired interior art and textiles. Buyers browse and order. Artists upload and sell.

## Structure

| Folder | Contents |
|--------|----------|
| `frontend/` | Flutter app: onboarding, login, product browsing, cart, checkout, artist upload |
| `backend/` | Firebase config: Firestore rules, Storage rules, Cloud Functions (Node 20, Stripe) |
| `docs/` | Entity relationship diagram and report |

## Stack

Flutter, Firebase Auth, Cloud Firestore, Cloud Storage, Cloud Functions v2, Stripe, Google Maps.

## Run the app

```bash
cd frontend
flutter pub get
flutter run
```

## Deploy the backend

```bash
cd backend/functions
npm install
firebase functions:secrets:set STRIPE_SECRET
cd ..
firebase deploy
```

## Security rules

- Users read and write only their own `users/{uid}` document and cart.
- Anyone reads artworks. Only users with `role == 'artist'` write them.
- Users read only their own orders. Orders are written by the `confirmPayment` function.
- Artists read and write only their own Storage folder.

## Known gaps

- `createPaymentIntent` trusts the amount sent by the client. Look up the price from Firestore before production use.
- The checkout screen does not call the payment functions yet.
