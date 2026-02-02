# <img src="assets/images/icon.png" height="40"> Cellular Viewer

This app allows you to view detailed 4G/5G cellular network information on your Android device, including cell towers, signal strength, and carrier aggregation status. 

## All Features
- 4G LTE
- 5G NR (NSA/SA)
- Carrier Aggregation information (LTE)
- Signal strength metrics (RSRP, RSRQ, SINR, TA - 4G only) with color-coded indicators
- Debug mode to view raw data from the device

## Tested devices
- Modern Exynos Modem devices under LTE/NSA/SA with Carrier Aggregation (Samsung A56 5G) - Heavily tested
- 4G Qualcomm Modem devices (Sony Xperia XZ) - Lightly tested
- 5G Qualcomm Modem devices under LTE/NSA (Samsung S23+) - Very lightly tested by friend

#### Known limitations
- ⚠️ All devices (incl. Exynos) support on NR Carrier Aggregation is limited.
- ⚠️ Qualcomm devices support on Carrier Aggregation is limited.
- ⚠️ MediaTek devices support are very limited.


## Installing Cellular Viewer
### Method 1: F-Droid (Recommended)
You may get this app from the F-Droid Repo: https://fdroid.spookysrv.com/fdroid/repo/<br>
Updates will be delivered automatically through F-Droid.<br>
Note: This is not the official F-Droid repository. Anti-Features may not be fully accurate with official definition.
### Method 2: APK Sideload
You may download the latest APK from the Releases page: https://github.com/SpookyKipper/CellularViewer/releases 


## Contributing
- Please change the `flutter_cell_info` package source in `pubspec.yml` to the GitHub Repository provided, or else you will not be able to build the app. 
- The modified `flutter_cell_info` package is open source but subject to a different license than CelluarViewer, please refer to the [package license](https://github.com/SpookyKipper/flutter_cell_info/blob/master/LICENSE) for more information. While being a fork with the same license, it is not planned to be contributed back to the upstream.
- Please change the `spookyservices` package source in `pubspec.yml` to the GitHub Repository provided, or else you will not be able to build the app. 
- Please note that the `spookyservices` package is NOT open source and just subject to a different license than CellularViewer, please refer to the [package license](https://github.com/SpookyKipper/SpookyServicesFlutter/blob/master/LICENSE.md) for more information. 
- When creating a pull request, please make sure the `spookyservices` and `flutter_cell_info` package source in `pubspec.yml` points to the original local path.
