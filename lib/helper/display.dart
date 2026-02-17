import 'package:cellular_viewer/helper/netinfo.dart';
import 'package:spookyservices/widgets/widgets.dart';

String getNetworkIcon(CellData? cellData) {
  if (cellData == null) {
    return 'assets/images/icon.png';
  }
  if (cellData.lteCcCount == 0 && cellData.nrCcCount == 0) {
    return "assets/images/NetworkIcons/NoSignal.png";
  } 
  switch (cellData.networkType) {
    case '3G':
      return 'assets/images/NetworkIcons/3G.png';
    case '4G':

      // Start NSA checks
      if (cellData.nrCcCount > 0) {
        // NR NSA
        if (cellData.lteCcCount > 1) {
          // LTE CA
          if (cellData.nrCcCount > 1) {
            // LTE CA + NR NSA CA
            return 'assets/images/NetworkIcons/5GPlusNSA_With_4GPlus.png';
          }
          // LTE CA + NR NSA
          return 'assets/images/NetworkIcons/5GNSA_With_4GPlus.png';
        }

        if (cellData.nrCcCount > 1) {
          // NR NSA CA without LTE CA
          return 'assets/images/NetworkIcons/5GPlusNSA.png';
        }

        // NR NSA without LTE CA
        return 'assets/images/NetworkIcons/5GNSA.png';
      }
      // End NSA checks

      // Start Anchor Band checks
      if (cellData.nsaStatus != 'no') {
        if (cellData.lteCcCount > 1) {
          // LTE CA Anchor
          return 'assets/images/NetworkIcons/4GPlus_NSAAnchor.png';
        }
        // Standard LTE Anchor
        return 'assets/images/NetworkIcons/4G_NSAAnchor.png';
      }
      // End Anchor Band checks

      if (cellData.lteCcCount > 1) {
        // LTE CA only
        return 'assets/images/NetworkIcons/4GPlus.png';
      }

      // Standard 4G
      return 'assets/images/NetworkIcons/4G.png';
    case 'SA':
      if (cellData.nrCcCount > 1) {
        // NR SA CA
        return 'assets/images/NetworkIcons/5GPlusSA.png';
      }

      // Standard NR SA
      return 'assets/images/NetworkIcons/5GSA.png';
    default:
      return 'assets/images/icon.png';
  }
}

String getDescription(CellData? cellData) {
  if (cellData == null) {
    return 'Unable to fetch cell data';
  }
  if (cellData.lteCcCount == 0 && cellData.nrCcCount == 0) {
    return "No Signal";
  } 
  switch (cellData.networkType) {
    case '3G':
      return 'Connected to a 3G Network';
    case '4G':

      // Start NSA checks
      if (cellData.nrCcCount > 0) {
        // NR NSA
        if (cellData.lteCcCount > 1) {
          // LTE CA
          if (cellData.nrCcCount > 1) {
            // LTE CA + NR NSA CA
            return 'Connected to a 5G NSA network with 4G & 5G CA.';
          }
          // LTE CA + NR NSA
          return 'Connected to a 5G NSA network with 4G CA.';
        }

        if (cellData.nrCcCount > 1) {
          // NR NSA CA without LTE CA
          return 'Connected to a 5G NSA network with 5G CA.';
        }

        // NR NSA without LTE CA
        return 'Connected to a 5G NSA network.';
      }
      // End NSA checks

      if (cellData.lteCcCount > 1) {
        // || cellData.overrideNetworkType == 'LTE_CA'
        // LTE CA only
        return 'Connected to a 4G network with CA.';
      }

      // Standard 4G
      return 'Connected to a 4G network.';
    case 'SA':
      if (cellData.nrCcCount > 1) {
        // NR SA CA
        return 'Connected to a 5G SA network with CA.';
      }

      // Standard NR SA
      return 'Connected to a 5G SA network.';
    default:
      return 'Unable to fetch cell data!';
  }
}

String getNetworkIcon4G(CellData? cellData, {bool overlay = false}) {
  if (cellData == null) {
    return 'assets/images/icon.png';
  }
  if (cellData.lteCcCount == 0) {
    return "assets/images/NetworkIcons/NoSignal.png";
  } 

  if (overlay) {
    if (cellData.nsaStatus == 'connected' && cellData.nrCcCount == 0) {
      return 'assets/images/NetworkIcons/4GPlus_NSAAnchor_Overlay.png';
    }
    if (cellData.nsaStatus == 'anchor' && cellData.nrCcCount == 0) {
      return 'assets/images/NetworkIcons/4G_NSAAnchor_Overlay.png';
    }
  }

  if (cellData.lteCcCount > 1) {
    return 'assets/images/NetworkIcons/4GPlus.png';
  } else if (cellData.lteCcCount == 1) {
    return 'assets/images/NetworkIcons/4G.png';
  }
  return 'assets/images/icon.png';
}

String getNetworkIcon5G(CellData? cellData) {
  if (cellData == null) {
    return 'assets/images/icon.png';
  }

  if (cellData.nrCcCount == 0) {
    return "assets/images/NetworkIcons/NoSignal.png";
  } 

  if (cellData.nrCcCount > 1) {
    return 'assets/images/NetworkIcons/5GPlus.png';
  } else if (cellData.nrCcCount == 1) {
    return 'assets/images/NetworkIcons/5G.png';
  }
  return 'assets/images/icon.png';
}

String getImsIcon(String? imsStatus, {overlay = false}) {
  if (imsStatus == null) {
    return 'assets/images/icon.png';
  }

  switch (imsStatus) {
    case 'No Voice or CSFB':
      return 'assets/images/NetworkIcons/CSFB.png';
    case 'No Voice or VoLTE or CSFB':
      return 'assets/images/NetworkIcons/CSFB.png';
    case 'VoLTE':
      return 'assets/images/NetworkIcons/VoLTE.png';
    case 'VoNR':
      return 'assets/images/NetworkIcons/VoNR.png';
    case 'VoWiFi':
      if (overlay) {
        return 'assets/images/NetworkIcons/VoWiFi_Overlay.png';
      }
      return 'assets/images/NetworkIcons/VoWiFi.png';
    case '3G' || 'UMTS' || 'HSPA' || 'HSDPA':
      return 'assets/images/NetworkIcons/3G.png';
    case '2G' || 'GSM' || 'GPRS' || 'EDGE':
      return 'assets/images/NetworkIcons/2G.png';
    default:
      return 'assets/images/NetworkIcons/NoVoice.png';
  }
}

Widget getRsrpDisplay(double rsrp) {
  if (rsrp == 2683662) {
    return Text("-", style: TextStyle(color: Colors.grey));
  }
  Color color;
  if (rsrp < -115) {
    // < -115 dBm
    color = Colors.red;
  } else if (rsrp < -105) {
    // -115 to -105 dBm
    color = Colors.orange;
  } else if (rsrp < -90) {
    // -105 to -90 dBm
    color = Colors.yellow;
  } else if (rsrp < -80) {
    // -90 to -80 dBm
    color = Colors.lightGreen;
  } else if (rsrp < -75) {
    // -80 to -75 dBm
    color = Colors.greenAccent;
  } else {
    // > -75 dBm
    color = const Color.fromARGB(255, 110, 209, 255);
  }
  final String displayText = "${rsrp.toInt()} dBm";
  return Text(displayText, style: TextStyle(color: color));
}

Widget getSinrDisplay(double sinr) {
  if (sinr == 2683662) {
    return Text("-", style: TextStyle(color: Colors.grey));
  }
  Color color;
  if (sinr < -15) {
    // < -15 dB
    color = Colors.red;
  } else if (sinr < -5) {
    // -15 to -5 dB
    color = Colors.deepOrange;
  } else if (sinr < 0) {
    // -5 to 0 dB
    color = Colors.orange;
  } else if (sinr < 13) {
    // 0 to 13 dB
    color = Colors.yellow;
  } else if (sinr < 20) {
    // 13 to 20 dB
    color = Colors.lightGreen;
  } else if (sinr < 26) {
    // 20 to 26 dB
    color = Colors.greenAccent;
  } else {
    // > 26 dB
    color = const Color.fromARGB(255, 110, 209, 255);
  }
  return Text("${sinr.toInt()} dB", style: TextStyle(color: color));
}

Widget getRsrqDisplay(double rsrq) {
  if (rsrq == 2683662) {
    return Text("-", style: TextStyle(color: Colors.grey));
  }
  Color color;
  if (rsrq < -25) {
    // < -25 dB
    color = Colors.red;
  } else if (rsrq < -19) {
    // -25 to -19 dB
    color = Colors.orange;
  } else if (rsrq < -15) {
    // -19 to -15 dB
    color = Colors.yellow;
  } else if (rsrq < -11) {
    // -15 to -11 dB
    color = Colors.lightGreen;
  } else if (rsrq < -8) {
    // -11 to -8 dB
    color = Colors.greenAccent;
  } else {
    // > -8 dB
    color = const Color.fromARGB(255, 110, 209, 255);
  }
  return Text("${rsrq.toInt()} dB", style: TextStyle(color: color));
}

Widget getTaDisplay(double ta) {
  if (ta == 2683662) {
    return Text("-", style: TextStyle(color: Colors.grey));
  }
  Color color;
  if (ta > 192) {
    // > 192
    color = Colors.red;
  } else if (ta > 65) {
    // 193 to 65
    color = Colors.orange;
  } else if (ta > 26) {
    // 66 to 26
    color = Colors.yellow;
  } else if (ta > 7) {
    // 27 to 7
    color = Colors.lightGreen;
  } else if (ta > 4) {
    // 8 to 4
    color = Colors.greenAccent;
  } else {
    // <= 4
    color = const Color.fromARGB(255, 110, 209, 255);
  }
  return Text(
    "${ta.toInt()} (${ta.toInt() * 78} m)",
    style: TextStyle(color: color),
  );
}
