# <img src="assets/images/icon.png" height="40"> Cellular Viewer

This app allows you to view detailed 4G/5G cellular network information on your Android device, including cell towers, signal strength, and carrier aggregation status. 
It uses a modified version of [flutter_cell_info](https://github.com/SpookyKipper/flutter_cell_info), which makes use of [NetMonster Core](https://github.com/mroczis/netmonster-core) and also [Android ServiceState](https://android.googlesource.com/platform/frameworks/base/+/0e2d281/telephony/java/android/telephony/ServiceState.java).

## All Features
- 4G LTE
- 5G NR (SA/NSA)
- IMS Status (VoLTE/VoNR/WiFi Calling)
- Carrier Aggregation information
- Signal strength metrics (RSRP, RSRQ, SINR, TA - 4G only) with color-coded indicators
- Roaming Status
- Overlay mode for continuous band info monitoring while on other apps
- Debug mode to view raw data from the device
- ⚠️ This app does NOT work under 2G and 3G networks

- <details><summary>⚠️ Newer versions of the app does NOT work on legacy Android devices, though exact versions unknown, fixed planned</summary>Track it in https://github.com/SpookyKipper/CellularViewer/issues/4</details>

## Tested Systems

<table border="1">
  <tbody>
    <tr>
      <td><strong>Modem</strong></td>
      <td><strong>Modern 5G Exynos</strong></td>
      <td><strong>Modern 5G Qualcomm</strong></td>
      <td><strong>Legacy 4G Qualcomm</strong></td>
      <td><strong>MediaTek</strong></td>
    </tr>
    <tr>
      <td><strong>Test Device</strong></td>
      <td><strong>Samsung A56 5G</strong></td>
      <td><strong>Samsung S23+ (Friend)</strong></td>
      <td><strong>Sony Xperia XZ</strong></td>
      <td>---</td>
    </tr>
    <tr>
      <td>4G LTE</td>
      <td>✅ Good</td>
      <td>✅ Good</td>
      <td><details><summary>❌ Broken</summary> - Only broken in newer versions, older ones work<br> - Likely due to old Android APIs not being called in newer versions for optimization instead of a chip imcompatiblity<br> - Fix planned but no ETA, not high priority (https://github.com/SpookyKipper/CellularViewer/issues/4)</details></td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>LTE CA</td>
      <td>✅ Good</td>
      <td>✅ Good</td>
      <td>❓ Untested</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>5G NR (SA/NSA)</td>
      <td>✅ Good</td>
      <td>❗ No band info; SA untested</td>
      <td>---</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>NR CA (SA)</td>
      <td><details><summary>🆗 Supported, minor issues</summary> - Might report CA as available when assigned but not actually connected (RRC IDLE) <br>
        - Tested up to 2CA<br>
        - Accurate Band Info</details></td>
      <td>❓ Untested</td>
      <td>---</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>NR CA (NSA)</td>
      <td><details><summary>❗ No band info, guess CC Count</summary> - Sometimes it can grab a secondary band, but disappears quickly. In these cases it will be displayed while available.<br> - Accuracy of it is unknown but it seems to be mostly correct</details></td>
      <td>❌ Unsupported</td>
      <td>---</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>mmWave</td>
      <td colspan="4">❓ Untested, not supported by test device</td>
    </tr>
    <tr>
      <td>Carrier Info</td>
      <td>✅ Good</td>
      <td>✅ Good</td>
      <td>❓ Untested</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>Roaming Status</td>
      <td>✅ Good</td>
      <td>❓ Untested</td>
      <td><details><summary>✅ Good</summary>Indepdent on & can be reliably detected even without 4G info</details></td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>IMS: VoWiFi</td>
      <td>✅ Good</td>
      <td>✅ Good</td>
      <td>❓ Untested</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>IMS: VoLTE</td>
      <td>✅ Good</td>
      <td>✅ Good</td>
      <td>❓ Untested</td>
      <td>❓ Untested</td>
    </tr>
    <tr>
      <td>IMS: VoNR</td>
      <td><details><summary>✅ Good</summary>Cannot detect half-baked deployments where it will actually fallback to VoLTE when connecting to call</details></td>
      <td>❓ Untested</td>
      <td>---</td>
      <td>❓ Untested</td>
    </tr>
    
  </tbody>
</table>



## Installing Cellular Viewer
### Method 1: F-Droid (Recommended)
You may get this app from the F-Droid Repo: https://repo.spookysrv.com/fdroid/repo/<br>
Updates will be delivered automatically through F-Droid.<br>
Note: This is not the official F-Droid repository. Anti-Features may not be fully accurate with official definition.
### Method 2: APK Sideload
You may download the latest APK from the Releases page: https://github.com/SpookyKipper/CellularViewer/releases 


## Contributing
- Please change the `flutter_cell_info` package source in `pubspec.yml` to the GitHub Repository provided, or else you will not be able to build the app. 
- The modified `flutter_cell_info` package is open source but subject to a different license than CelluarViewer, please refer to the [package license](https://github.com/SpookyKipper/flutter_cell_info/blob/master/LICENSE) for more information. While being a fork with the same license, it is not planned to be contributed back to the upstream.
- Please change the `spookyservices` package source in `pubspec.yml` to the GitHub Repository provided, or else you will not be able to build the app. 
- Please note that the `spookyservices` package is open source and just subject to a different license than CellularViewer, please refer to the [package license](https://github.com/SpookyKipper/SpookyServicesFlutter/blob/master/LICENSE) for more information. 
- When creating a pull request, please make sure the `spookyservices` and `flutter_cell_info` package source in `pubspec.yml` points to the original local path.
