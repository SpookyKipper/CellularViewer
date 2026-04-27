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

<table style="width: 700px;" border="1">
<tbody>
<tr style="height: 41px;">
<td style="height: 41px; width: 85px;"><strong>Modem</strong></td>
<td style="height: 41px; width: 162px;"><strong>Samsung Exynos 5G</strong></td>
<td style="height: 41px; width: 132px;"><strong>Xiaomi Qualcomm 5G</strong></td>
<td style="height: 41px; width: 134.75px;"><strong>Samsung Qualcomm 5G</strong></td>
<td style="height: 41px; width: 111.25px;"><strong>Sony Qualcomm 4G</strong></td>
<td style="height: 41px; width: 72px;"><strong>MediaTek</strong></td>
</tr>
<tr style="height: 41px;">
<td style="height: 41px; width: 85px;"><strong>Test Device</strong></td>
<td style="height: 41px; width: 162px;"><strong>Samsung A56 5G</strong></td>
<td style="height: 41px; width: 132px;"><strong>POCO F8 Pro</strong></td>
<td style="height: 41px; width: 134.75px;"><strong>Samsung S23+ (Friend)</strong></td>
<td style="height: 41px; width: 111.25px;"><strong>Sony Xperia XZ</strong></td>
<td style="height: 41px; width: 72px;">---</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">4G LTE</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;✅ Good</td>
<td style="height: 40px; width: 134.75px;">✅ Good</td>
<td style="height: 40px; width: 111.25px;"><details><summary>❌ Broken</summary> - Only broken in newer versions, older ones work<br /> - Likely due to old Android APIs not being called in newer versions for optimization instead of a chip imcompatiblity<br /> - Fix planned but no ETA, not high priority (https://github.com/SpookyKipper/CellularViewer/issues/4)</details></td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">LTE CA</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;✅ Good</td>
<td style="height: 40px; width: 134.75px;">✅ Good</td>
<td style="height: 40px; width: 111.25px;">❓ Untested</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">5G NR (SA)</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;✅ Good</td>
<td style="height: 40px; width: 134.75px;">❓ Untested</td>
<td style="height: 40px; width: 111.25px;">---</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">NR CA (SA)</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;"><details><summary>❗ Limited</summary> - Yes/no only<br />- no band info &amp; CC count</summary></details></td>
<td style="height: 40px; width: 134.75px;">❓ Untested</td>
<td style="height: 40px; width: 111.25px;">---</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">5G NR (NSA)</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">✅ Good</td>
<td style="height: 40px; width: 134.75px;"><details><summary>❗ Limited</summary>- No band info</summary></details></td>
<td style="height: 40px; width: 111.25px;">---</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 120px;">
<td style="height: 120px; width: 85px;">NR CA (NSA)</td>
<td style="height: 120px; width: 162px;"><details><summary>❗ Limited</summary>- No band info, guess CC Count<br /> - Sometimes it can grab a secondary band, but disappears quickly. In these cases it will be displayed while available.<br /> - Accuracy of it is unknown but it seems to be mostly correct</details></td>
<td style="height: 120px; width: 132px;">&nbsp;❓ Untested</td>
<td style="height: 120px; width: 134.75px;">❌ Unsupported</td>
<td style="height: 120px; width: 111.25px;">---</td>
<td style="height: 120px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 20px;">
<td style="height: 20px; width: 85px;">mmWave</td>
<td style="height: 20px; width: 612px;" colspan="5">❓ Untested, not supported by test device</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">Carrier Info</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;✅ Good</td>
<td style="height: 40px; width: 134.75px;">✅ Good</td>
<td style="height: 40px; width: 111.25px;">❓ Untested</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">Roaming Status</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;❓ Untested</td>
<td style="height: 40px; width: 134.75px;">❓ Untested</td>
<td style="height: 40px; width: 111.25px;"><details><summary>✅ Good</summary>Indepdent on &amp; can be reliably detected even without 4G info</details></td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">VoWiFi</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;✅ Good</td>
<td style="height: 40px; width: 134.75px;">✅ Good</td>
<td style="height: 40px; width: 111.25px;">❓ Untested</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">VoLTE</td>
<td style="height: 40px; width: 162px;">✅ Good</td>
<td style="height: 40px; width: 132px;">&nbsp;✅ Good</td>
<td style="height: 40px; width: 134.75px;">✅ Good</td>
<td style="height: 40px; width: 111.25px;">❓ Untested</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
<tr style="height: 40px;">
<td style="height: 40px; width: 85px;">VoNR</td>
<td style="height: 40px; width: 162px;"><details><summary>✅ Good</summary>Cannot detect half-baked deployments where it will actually fallback to VoLTE when connecting to call</details></td>
<td style="height: 40px; width: 132px;">✅ Good</td>
<td style="height: 40px; width: 134.75px;">❓ Untested</td>
<td style="height: 40px; width: 111.25px;">---</td>
<td style="height: 40px; width: 72px;">❓ Untested</td>
</tr>
</tbody>
</table>
<p>&nbsp;</p>



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
