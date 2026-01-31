import 'package:cellular_viewer/helper/netinfo.dart';

String getNetworkIcon(CellData? cellData) {
  if (cellData == null) {
    return 'assets/images/icon.png';
  }
  switch (cellData.networkType) {
    case '3G':
      return 'assets/images/NetworkIcons/3G.png';
    case '4G':
      if (cellData.nrCcCount > 0) {
        // 4G + 5G NSA
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

      if (cellData.lteCcCount > 1) { // LTE CA only
        return 'assets/images/NetworkIcons/4GPlus.png';
      }

      // Standard 4G
      return 'assets/images/NetworkIcons/4G.png';
    case 'SA':
      if (cellData.nrCcCount > 1) { // NR SA CA
        return 'assets/images/NetworkIcons/5GPlusSA.png';
      }

      // Standard NR SA
      return 'assets/images/NetworkIcons/5GSA.png';
    default:
      return 'assets/images/icon.png';
  }
}

String getNetworkIcon4G(CellData? cellData) {
  if (cellData == null) {
    return 'assets/images/icon.png';
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

  if (cellData.nrCcCount > 1) {
    return 'assets/images/NetworkIcons/5GPlus.png';
  } else if (cellData.nrCcCount == 1) {
    return 'assets/images/NetworkIcons/5G.png';
  }
  return 'assets/images/icon.png';
}

String getRsrpDisplay(double rsrp) {
  if (rsrp == 0) {
    return "-";
  }
  String rating;
  if (rsrp < -140) {
    rating = "Very Poor";
  } else if (rsrp < -120) {
    rating = "Poor";
  } else if (rsrp < -100) {
    rating = "Fair";
  } else if (rsrp < -80) {
    rating = "Good";
  } else if (rsrp < -60) {
    rating = "Excellent";
  } else {
    rating = "Outstanding";
  }
  return "${rsrp.toInt()} dBm ($rating)";
}

String getSinrDisplay(double sinr) {
  if (sinr == 0) {
    return "-";
  }
  String rating;
  if (sinr < 0) {
    rating = "Very Poor";
  } else if (sinr < 5) {
    rating = "Poor";
  } else if (sinr < 10) {
    rating = "Fair";
  } else if (sinr < 15) {
    rating = "Good";
  } else if (sinr < 20) {
    rating = "Excellent";
  } else {
    rating = "Outstanding";
  }
  return "${sinr.toInt()} dB ($rating)";
}

String getRsrqDisplay(double rsrq) {
  if (rsrq == 0) {
    return "-";
  }
  String rating;
  if (rsrq < -20) {
    rating = "Very Poor";
  } else if (rsrq < -15) {
    rating = "Poor";
  } else if (rsrq < -10) {
    rating = "Fair";
  } else if (rsrq < -5) {
    rating = "Good";
  } else if (rsrq < 0) {
    rating = "Excellent";
  } else {
    rating = "Outstanding";
  }
  return "${rsrq.toInt()} dB ($rating)";
}
