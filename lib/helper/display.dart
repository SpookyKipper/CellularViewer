import 'package:cellular_viewer/helper/netinfo.dart';

String getNetworkIcon(CellData? cellData) {
  if (cellData == null) {
    return 'assets/images/icon.png';
  }
  switch (cellData.networkType) {
    case '3G':
      return 'assets/images/NetworkIcons/3G.png';
    case '4G':
      if (cellData.lteCcCount > 1) {
        return 'assets/images/NetworkIcons/4GPlus.png';
      }
      return 'assets/images/NetworkIcons/4G.png';
    case 'NSA':
      return 'assets/images/icons/5g_nsa_icon.png';
    case 'SA':
      return 'assets/images/5g_sa_icon.png';
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