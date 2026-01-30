# <img src="assets/images/icon.png" height="40"> HKJC Updater 香港賽馬會應用程式更新助手
我有長輩使用 HKJC 應用程式，而當 App 需要更新時，均為強制性更新。由於 App 不在 Google Play 商店，更新流程較為複雜，所以製作了此更新助手以簡化更新程序。

## 下載及安裝更新助手
### 方法一： F-Droid
可於此 F-Droid 軟體庫取得程式: https://fdroid.spookysrv.com/fdroid/repo/<br>
本更新助手的後續更新可於 F-Droid Client 輕易取得。<br>
註：此並非 F-Droid 官方軟體庫，「Anti-Features」可能會於官方解釋有差別，敬請見諒。
### 方法二： APK Sideload
在 GitHub Releases 取得新版本APK檔案：https://github.com/SpookyKipper/HKJC_Updater/releases<br>
每次更新需手動取得APK檔案然後更新，目前並未有新版本通知系統，請自行定時檢查新版本。

## Contributing
- Please change the `spookyservices` package source in `pubspec.yml` to the GitHub Repository provided, or else you will not be able to build the app. 
- Please note that the `spookyservices` package is NOT open source and just subject to a different license than HKJC Updater, please refer to the [package license](https://github.com/SpookyKipper/SpookyServicesFlutter/blob/master/LICENSE.md) for more information. 
- When creating a pull request, please make sure the `spookyservices` package source in `pubspec.yml` points to the original local path.
