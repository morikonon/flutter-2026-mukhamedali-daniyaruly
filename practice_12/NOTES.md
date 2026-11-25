# Practice 12 — Survive a Restart

## Level 1 — Package verdicts (publisher → last release → platforms → pub points → issues vs commits → dependencies → licence)

> Check the month/points on pub.dev before the defence — they change.

- **shared_preferences** — verified publisher flutter.dev, updated in recent months, all six platforms, 160 pub points, issues tracked in flutter/flutter with active commits, depends only on its own platform implementations, BSD-3.
- **flutter_secure_storage** — publisher steenbakker.dev (verified, community maintainer, not Google), active releases, all six platforms, 160 points, many open issues but regular commits, depends on Keychain/Keystore platform packages, BSD-3.
- **path_provider** — verified publisher flutter.dev, recent release, all six platforms, 160 points, flutter/flutter tracker with active commits, only its platform implementations, BSD-3.
- **image_picker** — verified publisher flutter.dev, recent release, Android/iOS/Web/macOS/Windows/Linux, 160 points, flutter/flutter tracker, only platform implementations, Apache-2.0/BSD-3.
- **permission_handler** — verified publisher baseflow.com (company), regular releases, Android/iOS/Windows/Web, 160 points, many open issues but active commits, only its platform implementations, MIT.
- **url_launcher** — verified publisher flutter.dev, recent release, all six platforms, 160 points, flutter/flutter tracker, only platform implementations, BSD-3.

All six were added with one command:
`flutter pub add shared_preferences flutter_secure_storage path_provider image_picker permission_handler url_launcher`

### Carets and the lock
- `http: ^1.2.0` accepts `>=1.2.0 <2.0.0` (1.2.1, 1.6.0 …) — minor and patch updates are non-breaking by semver. It refuses `1.1.x` (too old) and `2.0.0`+ (a major = breaking change).
- `pubspec.lock` holds the exact version pub resolved (`http` resolved to **1.6.0**). For an **app** it is committed so every teammate, CI and the release build get exactly the same versions. (A library does not commit it — its users resolve versions.)
- Break on purpose: `http: 1.2.0` (no caret) → `flutter pub get` pins exactly 1.2.0, `pub outdated` shows newer versions as unavailable. Caret put back.
- `flutter pub outdated`: `cross_file` is 0.3.5+5 while 0.4.0 exists — it is a transitive dependency of `image_picker`, whose own constraint (`^0.3.x`) still refuses the new 0.x "major", so pub cannot upgrade it until image_picker does. (`cupertino_icons` 2.0.0 is a major bump our `^1.0.8` refuses on purpose.)

## Level 3 — Where the token must NOT go
- `prefs.setString('token', …)` would put it into a plain XML file on Android (`/data/data/<app>/shared_prefs/FlutterSharedPreferences.xml`) or a plist on iOS (`Library/Preferences/<bundle>.plist`) — readable from a backup, on a rooted/jailbroken device, or over a cable with debug tools.
- **iOS surprise:** Keychain items can survive an uninstall — after reinstall the old token may still be there (clear it on first launch if needed).
- **Android surprise:** when the user removes the lock screen, Keystore keys can be invalidated → stored values can no longer be decrypted; `read` fails/returns null → treat as signed out.

## Level 5 — Permissions
- **Android:** 1st "Don't allow" → `denied`; 2nd "Don't allow" → `permanentlyDenied`; 3rd tap → no system dialog, our own dialog → "Open settings".
- **iOS:** the system asks **only once**. One "Don't allow" → `permanentlyDenied` straight away; every further request returns it without a dialog → `openAppSettings()`.
- The fourth Photos state on iOS is **limited** (`PermissionStatus.limited`, "Select Photos…").
- `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme → `false`, nothing opens; with `https://` the browser opens.

## Three places to keep things
- settings → `shared_preferences`
- anything that lets someone be you → `flutter_secure_storage`
- data → a file in `getApplicationDocumentsDirectory()`; Temporary is temporary.
