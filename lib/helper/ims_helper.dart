import 'package:cellular_viewer/helper/netinfo.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';

class imsHelper {
  static Future<String> getNetworkType(CellData _cellData) async {
    final String rawImsNetType = await ImsService.getNetworkType();

    final bool isImsRegistered = _cellData.isImsRegistered;
    if (rawImsNetType == "VoLTE" || rawImsNetType == "VoNR") {
      if (isImsRegistered) {
        return rawImsNetType;
      } else {
        if (rawImsNetType == "VoLTE") {
          return "No Voice or CSFB";
        } else if (rawImsNetType == "VoNR") {
          return "No Voice or VoLTE or CSFB";
        }
      }
    }
    return rawImsNetType;
  }
}