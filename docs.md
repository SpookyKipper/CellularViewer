# flutter_cell_info

A Flutter plugin that provides **cell tower / radio information** and **SIM information** on Android by bridging to an embedded/forked version of **NetMonster Core** (built over Android Telephony SDK).

> Repository: https://github.com/sumanrajpathak/flutter_cell_info  
> Current pubspec version: **0.0.6**  
> Dart SDK: **>=2.12.0 <4.0.0** (null safety)  
> Platforms declared: **Android + iOS** (but see “Platform support” notes below)

---

## Table of contents

- [Features](#features)
- [Platform support](#platform-support)
- [Installation](#installation)
- [Android setup](#android-setup)
  - [Required permissions](#required-permissions)
  - [Android 10+ / 11+ / 12+ permission notes](#android-10--11--12-permission-notes)
  - [ProGuard / R8 (release builds)](#proguard--r8-release-builds)
- [iOS support notes](#ios-support-notes)
- [Usage](#usage)
  - [Get cell info (JSON)](#get-cell-info-json)
  - [Get SIM info (JSON)](#get-sim-info-json)
  - [Read last cached response (shared preference)](#read-last-cached-response-shared-preference)
  - [Decode JSON into Dart models](#decode-json-into-dart-models)
  - [Polling / updating periodically](#polling--updating-periodically)
- [API reference (Dart)](#api-reference-dart)
- [Returned data format](#returned-data-format)
- [Troubleshooting](#troubleshooting)
- [Background & credits](#background--credits)
- [License](#license)

---

## Features

This plugin exposes 3 high-level calls:

1. **Cell info**: fetches current serving and neighboring cells (Android).
2. **SIM info**: fetches SIM/subscription information (Android).
3. **Shared preference**: reads a stored JSON value (Android).

Under the hood it uses **NetMonster Core** to:
- Merge and validate cell data from Android telephony sources.
- Provide richer and more consistent cell identity/signal information than many “legacy” implementations.
- Backport access to some fields across Android API levels where possible.

---

## Platform support

### Android
✅ **Supported** (this is where the real functionality lives)

The Android implementation uses NetMonster Core and Android Telephony APIs.

### iOS
⚠️ **Not functionally supported for cell info**

The iOS plugin class exists, but it only implements a default template method (`getPlatformVersion`) and **does not implement** `cell_info`, `sim_info`, or `shared_preference`.

If you call `CellInfo.getCellInfo` on iOS, you should expect a `MissingPluginException` / “not implemented” behavior.

---

## Installation

Add dependency in `pubspec.yaml`:

```yaml
dependencies:
  flutter_cell_info: ^0.0.6
```

Then run:

```bash
flutter pub get
```

Import:

```dart
import 'package:flutter_cell_info/flutter_cell_info.dart';
```

---

## Android setup

### Required permissions

To read cell/network information, Android typically requires location and/or phone state permissions depending on API level and the specific fields:

Add these to your `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Commonly required to access cell info on most Android versions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

<!-- Sometimes needed depending on what the library reads -->
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

Also ensure your app requests runtime permissions (Android 6.0+).

### Android 10 / 11 / 12+ permission notes

- On many devices, **cell info is gated by location permission** and location services being enabled.
- If results are empty or null-like, verify:
  - Location permission granted
  - Location services enabled
  - SIM inserted and radio active
  - Device is not in airplane mode

### ProGuard / R8 (release builds)

This library uses many model classes (Android side) and JSON serialization; in release builds, obfuscation might break reflection/serialization on some setups.

If you see missing fields or crashes only in release builds, consider adding keep rules for the plugin package.

---

## iOS support notes

iOS does not provide public APIs to access low-level cell tower details comparable to Android Telephony APIs. This repository’s iOS code is the default plugin template and **does not implement cell info**.

If you need iOS support, you’ll likely need to:
- Provide a different iOS approach (usually not possible with App Store-safe public APIs), or
- Document iOS as “unsupported”.

---

## Usage

### Get cell info (JSON)

```dart
final String? json = await CellInfo.getCellInfo;
print(json);
```

This calls the method channel:
- Channel name: `cell_info`
- Method name: `cell_info`

### Get SIM info (JSON)

```dart
final String? json = await CellInfo.getSIMInfo;
print(json);
```

This calls the method channel:
- Channel name: `sim_info`
- Method name: `sim_info`

### Read last cached response (shared preference)

```dart
final String? cachedJson = await CellInfo.sharedPreference;
print(cachedJson);
```

This calls the method channel:
- Channel name: `shared_preference`
- Method name: `shared_preference`

On Android, this returns the stored value under the key:
- `cells_info_response`

### Decode JSON into Dart models

The example app imports:

- `package:flutter_cell_info/cell_response.dart`
- `package:flutter_cell_info/sim_info_response.dart`

Typical pattern:

```dart
import 'dart:convert';
import 'package:flutter_cell_info/cell_response.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';

final raw = await CellInfo.getCellInfo;
if (raw != null) {
  final map = jsonDecode(raw);
  final cells = CellsResponse.fromJson(map); // depends on your model implementation
}
```

> Exact model constructors depend on the Dart files in `lib/`. If you want, tell me which Dart model files you use (or share them), and I can write the exact parsing snippet that matches your generated classes.

### Polling / updating periodically

```dart
Timer? timer;

@override
void initState() {
  super.initState();
  timer = Timer.periodic(const Duration(seconds: 2), (_) async {
    final json = await CellInfo.getCellInfo;
    // parse + setState
  });
}

@override
void dispose() {
  timer?.cancel();
  super.dispose();
}
```

---

## API reference (Dart)

The public Dart API is a single class:

### `CellInfo`

#### `CellInfo.getCellInfo -> Future<String?>`
Returns a JSON string containing cell information (Android).  
Method channel: `cell_info` / method: `cell_info`.

#### `CellInfo.getSIMInfo -> Future<String?>`
Returns a JSON string containing SIM/subscription information (Android).  
Method channel: `sim_info` / method: `sim_info`.

#### `CellInfo.sharedPreference -> Future<String?>`
Returns a JSON string previously stored in shared preferences under `cells_info_response` (Android).  
Method channel: `shared_preference` / method: `shared_preference`.

---

## Returned data format

The plugin returns **JSON strings**, not strongly-typed Dart objects by default.

On Android, the native side constructs responses such as:
- `CellsResponse` with:
  - `createdAt`
  - `primaryCellList`
  - `neighboringCellList`
  - `cellDataList`

Cell types include (based on Android-side code structure):
- NR (5G)
- LTE (4G)
- WCDMA (3G)
- GSM (2G)
- TD-SCDMA (regional/legacy)
- CDMA (where applicable)

Because device support and permissions vary widely, treat fields as optional and null-safe when decoding.

---

## Troubleshooting

**1) `MissingPluginException` on iOS**  
Expected: iOS does not implement `cell_info`/`sim_info`.

**2) Empty / null results on Android**
- Ensure runtime permission granted:
  - `ACCESS_FINE_LOCATION` (most common requirement)
  - `READ_PHONE_STATE` (sometimes needed)
- Turn on location services.
- Test on a real device (emulators often lack telephony data).

**3) Works in debug but not release**
- Add R8/ProGuard keep rules for model/JSON classes.
- Confirm no reflection-based serialization is broken.

---

## Background & credits

- Includes and builds upon **NetMonster Core** concepts:
  - Validation of telephony data
  - Merging multiple sources
  - Richer signal/identity access across Android versions

- Originally forked from: https://github.com/eslamfaisal/FlutterCellInfo  
  Credit: @eslamfaisal

---

## License

Check the repository’s `LICENSE` file in GitHub for exact terms.
