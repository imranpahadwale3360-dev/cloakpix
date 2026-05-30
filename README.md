# CloakPix

CloakPix is a production-oriented Flutter Android private photo/video vault scaffold with camouflage mode, encrypted local storage, encrypted cloud backup, and security-event logging.

## Security Model

- PINs are stored only as PBKDF2 salted hashes.
- Vault media is encrypted with AES-256-GCM before it is written to app-private storage.
- The master encryption key is generated on device and stored only in `flutter_secure_storage`.
- Cloud sync uploads encrypted media blobs and encrypted metadata only. It must never upload plaintext files, raw PINs, PIN hashes for authentication, or encryption keys.
- SQL metadata uses `sqflite_sqlcipher`; the database passphrase is stored in secure storage.
- Decryption is designed for in-memory viewing/export flows only. Do not write decrypted vault files to public folders.

## Termux Setup

```bash
pkg update
pkg install git openjdk-17
git clone <your-repo-url> cloakpix
cd cloakpix
```

Flutter is not officially distributed through Termux. For Android device-only builds, use GitHub Actions below. For local development, install Flutter on Windows, macOS, or Linux, then run:

```bash
flutter pub get
flutter run
```

## GitHub APK Build

Push this repository to GitHub. The workflow at `.github/workflows/android-apk.yml` builds a debug APK and uploads `app-debug.apk` as an artifact.

## Firebase Setup

1. Create a Firebase project.
2. Add an Android app with package name `com.cloakpix.vault`.
3. Download `google-services.json`.
4. Place it at `android/app/google-services.json`.
5. Add `id "com.google.gms.google-services"` to the `plugins` block in `android/app/build.gradle`.
6. Enable Firebase Auth providers needed by your restore flow.
7. Create Firebase Storage and Firestore rules that require authenticated users and only allow per-user paths.
8. Keep encryption client-side. Firebase must only receive encrypted vault files and encrypted/sanitized metadata.

## Android Camouflage Alias

`android/app/src/main/AndroidManifest.xml` includes notes and a disabled `activity-alias` stub for a future Calculator launcher label/icon. Runtime icon switching should be implemented carefully with `PackageManager.setComponentEnabledSetting`, user disclosure where required, and regression tests across Android launcher vendors.
