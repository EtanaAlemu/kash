# Kash

Offline-first, privacy-focused expense tracker for Android (and iOS).

Your transactions, categories, and budgets stay on your device in an encrypted local database. Optional PIN / biometric lock, security-question PIN recovery, daily reminders, and local backups.

## Store legal pages (GitHub Pages)

- Website: https://etanaalemu.github.io/kash/
- Privacy Policy: https://etanaalemu.github.io/kash/privacy.html
- Terms of Use: https://etanaalemu.github.io/kash/terms.html

## Build

```bash
flutter pub get
flutter run
flutter build appbundle --release
```

Release signing uses `android/key.properties` and a local keystore (not committed).

## Privacy in one line

Expense data stays on-device; network is used for crash diagnostics (Firebase Crashlytics) in release builds.
