# Ubuntu Interiors (Flutter app)

Flutter client for the Ubuntu Interiors marketplace. Buyers browse artworks and textiles and add items to a cart. Artists upload artworks. The backend has Stripe payment functions that the checkout screen does not call yet.

## Run

```bash
flutter pub get
flutter run
```

Requires Flutter with Dart SDK 3.8.1 or later.

## Firebase

The app uses Firebase Auth, Cloud Firestore, Cloud Storage, and Cloud Functions. Project settings are in `lib/firebase_options.dart` and `android/app/google-services.json`. To use your own project, run `flutterfire configure`.

The backend lives in `../backend`.

## Test

```bash
flutter test
```
