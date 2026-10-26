# SonicMaster Audio

SonicMaster Audio is a Flutter-based Android music player with a premium dark interface and local audio playback.

## Brand direction
- Product name: **SonicMaster Audio**
- Tagline: **Feel Every Beat.**
- Visual identity: AMOLED-friendly dark surfaces with cyan, blue, violet, and magenta accents.
- Audio controls: equalizer, bass boost, and surround/virtualizer effects where supported by the Android device.
- Local library: choose audio files or scan a folder for supported media.

## Build
```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`.

## Release signing
For signed release builds, store the keystore and credentials only in GitHub Actions Secrets. Never commit `.jks`, private keys, or passwords to this public repository. Keep the same signing identity for updates to an existing app listing.
