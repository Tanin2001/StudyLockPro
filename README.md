# Study Lock Pro — Flutter Cloud Build

This is a Flutter project with native Android screen-state detection and a foreground service.

## Cloud build
Codemagic can connect to this repository and use the included `codemagic.yaml`. The workflow runs `flutter build apk --debug` and exposes the generated APK as an artifact.

## Core behavior
START begins a session. Only periods while the Android display is OFF are accumulated. Turning the display ON pauses accumulation; turning it OFF resumes it.

For a release/Play Store build, Android signing credentials are required.
