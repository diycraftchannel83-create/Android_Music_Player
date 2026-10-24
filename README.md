# Android Music Player

A dark, premium-style Flutter Android music player concept focused on powerful audio controls, a vivid animated equalizer aesthetic, and Super Bass.

## Design direction
- AMOLED-friendly dark interface with cyan, blue, violet, and magenta accents.
- Home library with songs, albums, artists, playlists, and favourites.
- Now Playing screen with artwork, progress, and transport controls.
- Dedicated Equalizer screen with adjustable frequency bands and audio presets.
- Super Bass and sound-effects controls, designed to map to Android audio effects in the playback implementation.
- Responsive Material 3 components.

## Current status
This commit establishes the Android Music Player branding and UI direction. It is a design foundation, not yet a complete audio engine: local media scanning, real playback/background controls, and DSP-backed equalizer/bass processing must be implemented and tested before describing those effects as active.

## Build
```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
``

APK output: `build/app/outputs/flutter-apk/app-release.apk`.
