import 'dart:convert';
import 'package:cellular_viewer/helper/band_calc.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';

///////////////////////////////////////////////////////////
//////////////// NOTE ON CONSTANT 2683662 /////////////////
/// This constant value (2683662) is used to represent
/// unavailable or invalid signal metrics in the
/// FlutterCellInfo plugin. If a signal metric (like RSRP,
/// RSRQ, SINR) returns this value, it indicates that the
/// information is not available from the device.
///////////////////////////////////////////////////////////
class CellData {
  final String networkType; // 3G/4G/SAc
  // final String detailedNetworkType; // e.g. 2G/3G/LTE/LTE-NRANCHOR/LTE-A/LTE-A-NRARCHOR/NR-NSA/NR-NSA-CA/NR-SA/NR-SA-CA
  final int lteCcCount;
  final List<String> lteCcBands; // e.g. 700, 2600
  final int nrCcCount;
  final List<String> nrCcBands; // e.g. 3500, 4900
  final double rsrp;
  final double rsrq;
  final double sinr; // or SNR for 4G
  final double nsaRsrp;
  final double nsaRsrq;
  final double nsaSinr;
  final double ta; // 4G only
  final int dataConnStatus; // -1: unknown, 0: idle, 1: connecting, 2: connected
  final String nsaStatus; // no, anchor, connected
  final String mccmnc;
  final String carrierName;
  final String mvnoName;
  final bool isImsRegistered;
  final String imsStatus;

  CellData({
    required this.networkType,
    // required this.detailedNetworkType,
    this.lteCcCount = 0,
    this.lteCcBands = const [],
    this.nrCcCount = 0,
    this.nrCcBands = const [],
    required this.rsrp,
    required this.sinr,
    required this.rsrq,
    this.ta = 2683662,
    this.nsaRsrp = 2683662,
    this.nsaRsrq = 2683662,
    this.nsaSinr = 2683662,
    required this.dataConnStatus,
    required this.nsaStatus,
    required this.mccmnc,
    required this.carrierName,
    required this.mvnoName,
    required this.isImsRegistered,
    required this.imsStatus,
  });

  @override
  String toString() {
    return 'CellData(networkType: $networkType, lteCcCount: $lteCcCount, lteCcBands: $lteCcBands, nrCcCount: $nrCcCount, nrCcBands: $nrCcBands, rsrp: $rsrp, rsrq: $rsrq, sinr: $sinr, nsaRsrp: $nsaRsrp, nsaRsrq: $nsaRsrq, nsaSinr: $nsaSinr, ta: $ta, dataConnStatus: $dataConnStatus, nsaStatus: $nsaStatus)';
  }
}

Future<CellData> getCellInfo() async {
  try {
    String? cellInfo = await CellInfo
        .getCellInfo; //.timeout(const Duration(milliseconds: 500), onTimeout: () => "timeout");
    if (cellInfo == null) return Future.error("Cell info is null");
    // log(cellInfo);

    Map<String, dynamic> parsedCellInfo = jsonDecode(cellInfo);

    if (parsedCellInfo.isEmpty) {
      return Future.error("Parsed cell info is empty");
    }

    final List<dynamic> cellDataList = parsedCellInfo['cellDataList'];
    final Map serviceStateInfo =
        await ServiceStateService.getAllInfoFromSerivceState();

    if (cellDataList.isEmpty) {
      return CellData(
        networkType: "N/A",
        rsrp: 2683662,
        sinr: 2683662,
        rsrq: 2683662,
        dataConnStatus: -1,
        nsaStatus: "no",
        mccmnc: "00000",
        carrierName: "N/A",
        mvnoName: "N/A",
        isImsRegistered: false,
        imsStatus: serviceStateInfo['voiceTechnology'],
      );
    }

    // if (cellDataList.isEmpty) return Future.error("Cell data list is empty");

    final String mccmnc = "${cellDataList[0]["mcc"]}${cellDataList[0]["mnc"]}";

    String cpu;
    if (cellDataList[0]["HARDWARE"] == "qcom") {
      cpu = "qcom";
    } else {
      cpu = "unknown";
    }

    // final String detailedNetworkType = await CellService.getDetailedNetworkType();
    final String dataConnStatus = await RrcService.getRrcStatus();
    if (dataConnStatus.isEmpty) {
      return Future.error("DATA status is empty");
    }
    int data;
    if (dataConnStatus == 'DATA_DISCONNECTED') {
      data = 0;
    } else if (dataConnStatus == 'DATA_CONNECTING') {
      data = 1;
    } else if (dataConnStatus == 'DATA_CONNECTED') {
      data = 2;
    } else {
      data = -1;
    }

    final bool usingCa = serviceStateInfo["usingCa"];
    // if (!usingCa) {
    //   log("Carrier Aggregation not in use, skipping CA band processing.");
    // } else {
    //   log("Carrier Aggregation in use, processing CA bands.");
    // }

    final List<double> bandwidths = serviceStateInfo["bandwidths"];
    final bool lteAnchor = serviceStateInfo["lteAnchor"];
    final bool nrNsa = serviceStateInfo["nrNsa"];
    final String carrierName = serviceStateInfo["carrierName"];
    final String mvnoName = serviceStateInfo["mvnoName"];
    final bool isImsRegistered = serviceStateInfo["imsRegistered"];
    String nsaStatus;
    if (nrNsa) {
      nsaStatus = "connected";
    } else if (lteAnchor) {
      nsaStatus = "anchor";
    } else {
      nsaStatus = "no";
    }

    // final String nsaStatus =
    //     await CellService.getOverrideNetworkType();
    String type = cellDataList[0]['type'];
    if (type == 'LTE') {
      // 4G or 4G + 5G NSA
      return processLteCellInfo(
        parsedCellInfo,
        data,
        usingCa,
        cpu,
        bandwidths,
        mccmnc,
        carrierName,
        mvnoName,
        isImsRegistered,
        serviceStateInfo['voiceTechnology'],
        nsaStatus,
      );
    } else if (type == 'NR') {
      // 5G SA
      return processNrCellInfo(
        parsedCellInfo,
        data,
        usingCa,
        cpu,
        bandwidths,
        mccmnc,
        carrierName,
        mvnoName,
        isImsRegistered,
        serviceStateInfo['voiceTechnology']
      );
    } else {
      return Future.error("Unsupported cell type: $type");
    }
  } catch (e) {
    print("Error fetching cell info: $e");
  }
  return Future.error("Failed to fetch cell info");
}

CellData processLteCellInfo(
  Map<String, dynamic> data,
  int dataConnStatus,
  bool usingCa,
  String cpu,
  List<double> bandwidths,
  String mccmnc,
  String carrierName,
  String mvnoName,
  bool isImsRegistered,
  String imsStatus,
  String nsaStatus,
) {
  Map<String, dynamic> cellDataList = data['primaryCellList'][0]['lte'];

  // log(cellDataList.toString());

  String bandName = cellDataList['bandLTE']['name'];
  String primaryEarfcn = cellDataList['bandLTE']['downlinkEarfcn'].toString();
  double rsrp = cellDataList['signalLTE']['rsrp'].toDouble();
  double rsrq = cellDataList['signalLTE']['rsrq'].toDouble();
  double snr = cellDataList['signalLTE']['snr'].toDouble();
  double ta = cellDataList['signalLTE']['timingAdvance'].toDouble();

  List<Map<String, String>> lteCaBands = []; // e.g. [{NAME, EARFCN}, ...]
  List<Map<String, String>> nrCaBands = []; // e.g. [{NAME, ARFCN}, ...]

  double nsaRsrp = 2683662;
  double nsaRsrq = 2683662;
  double nsaSinr = 2683662;

  // Collect LTE CA bands from secondary cells
  List<dynamic> secondaryCellList = data['neighboringCellList'];

  // if (dataConnStatus == 0) {
  //   // If RRC is IDLE, no CA bands are available, no NSA bands either
  //   secondaryCellList = [];
  // } else {
  //   secondaryCellList = data['neighboringCellList'];
  // }
  int maxCcCount = bandwidths.length;
  if (usingCa == true &&
      (maxCcCount < 2 ||
          (cpu == 'qcom' && bandwidths.any((double bw) => bw == 0)))) {
    // qcom sometimes reports bandwidth as 0Hz, trating as unreliable
    maxCcCount =
        2683662; // No limit if CA is used but bandwidth info is unreliable
  }

  List<double> lteBandwidths = bandwidths;
  lteBandwidths.retainWhere((bw) => bw <= 20); // No single LTE BW > 20MHz
  final int maxLteCcCount = lteBandwidths.length;

  for (var cell in secondaryCellList) {
    if (usingCa && cell['type'] == 'LTE') {
      // Collect LTE CA bands from secondary cells, no need to check if CA is not used by ServiceState
      final cellData = cell['lte'];
      if (!cellData['connectionStatus'].contains('SecondaryConnection') &&
          cpu !=
              'qcom') {
        // Qualcomm reports NoneConnection even when connected, now solely reling on usingCa for qcom
        continue;
      }
      // Check if this cell is the same as the primary cell
      if (cellData['bandLTE']['downlinkEarfcn'].toString() == primaryEarfcn) {
        continue;
      }

      // Check for duplicates in the collected list using explicit value comparison
      // (List.contains fails with non-const Map literals in Dart)
      if (lteCaBands.any(
        (e) =>
            e['NAME'] == cellData['bandLTE']['name'] &&
            e['EARFCN'] == cellData['bandLTE']['downlinkEarfcn'].toString(),
      )) {
        continue;
      }

      if (cellData['bandLTE']['name'] == "") {
        continue; // Skip invalid bands (probably an NR  band)
      }
      lteCaBands.add({
        'NAME': cellData['bandLTE']['name'],
        'EARFCN': cellData['bandLTE']['downlinkEarfcn'].toString(),
      });
    } else if (cell['type'] == 'NR' && (usingCa || nrCaBands.isEmpty)) {
      // Collect NR NSA CA bands from secondary cells
      final cellData = cell['nr'];
      // log(cellData['bandNR'].toString());
      if (!cellData['connectionStatus'].contains('SecondaryConnection')) {
        continue;
      }
      // Check validity and duplicate for NR bands
      String nrName = getNrBandName(cellData['bandNR']['downlinkFrequency']);
      String nrArfcn = cellData['bandNR']['downlinkArfcn'].toString();

      if (nrCaBands.any((e) => e['NAME'] == nrName && e['ARFCN'] == nrArfcn)) {
        continue;
      }

      if (nrName == "???" && nrCaBands.isNotEmpty) {
        continue; // ??? means invalid band if previous band can be detected correctly
      }

      if (nsaRsrp == 2683662) {
        nsaRsrp = cellData['signalNR']['ssRsrp'].toDouble();
      }
      if (nsaRsrq == 2683662) {
        nsaRsrq = cellData['signalNR']['ssRsrq'].toDouble();
      }
      if (nsaSinr == 2683662) {
        nsaSinr = cellData['signalNR']['ssSinr'].toDouble();
      }
      nrCaBands.add({'NAME': nrName, 'ARFCN': nrArfcn});
    }
  }

  final List<String> lteCcBands = lteCaBands.map((e) => e['NAME']!).toList();
  lteCcBands.insert(0, bandName);

  final List<String> nrCcBands = nrCaBands.map((e) => e['NAME']!).toList();
  nrCcBands.removeWhere((e) => e.isEmpty);

  if (lteCcBands.length > maxLteCcCount) {
    // Sanity check, should not happen
    // log(
    //     "Warning: LTE CC Count (${lteCcBands.length}) exceeds max CC Count ($maxCcCount). Truncating to max CC Count.");
    lteCcBands.removeRange(maxLteCcCount, lteCcBands.length);
  }

  // Calculate max allowed NR CCs based on remaining bandwidth budget
  final int maxNrCcCount =
      maxCcCount - lteCcBands.length; // Remaining CCs for NR

  if (nrCcBands.length > maxNrCcCount && cpu != 'qcom') {
    // qcom does not include NR in bandwidth info
    if (maxNrCcCount == 0) {
      // if no max NRCC is allowed, but has valid NSA signal info, keep it.
      if ((nsaRsrq == 2683662 && nsaRsrp == 2683662)) {
        // only remove if no valid NSA signal info (sometimes Exynos misses the NSA band in BW)
        nrCcBands.removeRange(maxNrCcCount, nrCcBands.length);
      }
    } else {
      nrCcBands.removeRange(maxNrCcCount, nrCcBands.length);
    }
  }

  int nrCcCount = nrCcBands.length;
  // Heuristic: If we see few NR bands, but LTE CA suggests we are connected (>=2 CCs),
  // and there is room in the bandwidth list (maxNrCcCount > 0),
  // assume the "missing" bandwidth slots are occupied by unreported NR bands.
  // This compensates for unreliable NR CA reporting in some APIs.
  // NRCCCount 1 means NRCA cannot be reliably detected
  if ((nrCcCount == 1) &&
      lteCcBands.length >=
          2 && // LTECC >=2 means RRC Connected and CA can be reliably detected
      maxNrCcCount > 0 &&
      maxNrCcCount < 100) {
    // avoid overflow from unreliable bandwidth info
    // Heuristic for NR NSA without reported NR CCs
    nrCcCount = maxNrCcCount;
  }

  int lteCcCount = lteCcBands.length;
  if (cpu == 'qcom' &&
      lteCcCount >= 2 &&
      maxCcCount > lteCcCount &&
      maxCcCount != 2683662) {
    lteCcCount =
        maxCcCount; // Can assume qcom BW is all LTE CAs because sometimes misses some and recovers only at a later time.
  }
  return CellData(
    networkType: "4G",
    lteCcCount: lteCcBands.length,
    lteCcBands: lteCcBands,
    nrCcCount: nrCcCount,
    nrCcBands: nrCcBands,
    rsrp: rsrp,
    sinr: snr,
    rsrq: rsrq,
    nsaRsrp: nsaRsrp,
    nsaRsrq: nsaRsrq,
    nsaSinr: nsaSinr,
    ta: ta,
    dataConnStatus: dataConnStatus,
    mccmnc: mccmnc,
    carrierName: carrierName,
    mvnoName: mvnoName,
    isImsRegistered: isImsRegistered,
    imsStatus: imsStatus,
    nsaStatus: nsaStatus,

    // detailedNetworkType: detailedNetworkType,
  );
}

CellData processNrCellInfo(
  Map<String, dynamic> data,
  int dataConnStatus,
  bool usingCa,
  String cpu,
  List<double> bandwidths,
  String mccmnc,
  String carrierName,
  String mvnoName,
  bool isImsRegistered,
  String imsStatus,
) {
  Map<String, dynamic> cellDataList = data['primaryCellList'][0]['nr'];

  // log(cellDataList.toString());

  String bandName = getNrBandName(cellDataList['bandNR']['downlinkFrequency']);
  String primaryArfcn = cellDataList['bandNR']['downlinkArfcn'].toString();
  double rsrp = cellDataList['signalNR']['ssRsrp'].toDouble();
  double rsrq = cellDataList['signalNR']['ssRsrq'].toDouble();
  double sinr = cellDataList['signalNR']['ssSinr'].toDouble();

  List<Map<String, String>> nrCaBands = []; // e.g. [{NAME, EARFCN}, ...]
  int maxCcCount = bandwidths.length;
  if (usingCa == true && maxCcCount < 2) {
    // No limit if CA is used but bandwidth info is unreliable
    maxCcCount = 999;
  }

  List<dynamic> secondaryCellList;

  if (usingCa == false) {
    secondaryCellList = [];
  } else {
    secondaryCellList = data['neighboringCellList'];
  }
  for (var cell in secondaryCellList) {
    if (cell['type'] == 'NR') {
      // minus 1 for main band
      final cellData = cell['nr'];
      if (!cellData['connectionStatus'].contains('SecondaryConnection') &&
          cpu !=
              'qcom') {
        // Qualcomm reports NoneConnection even when connected, now solely reling on usingCa for qcom
        continue;
      }
      if (cellData['bandNR']['downlinkArfcn'].toString() == primaryArfcn) {
        continue;
      }

      // Check for duplicates using explicit comparison (List.contains fails for Map literals)
      if (nrCaBands.any(
        (e) =>
            e['NAME'] ==
                getNrBandName(cellData['bandNR']['downlinkFrequency']) &&
            e['ARFCN'] == cellData['bandNR']['downlinkArfcn'].toString(),
      )) {
        continue;
      }

      nrCaBands.add({
        'NAME': getNrBandName(cellData['bandNR']['downlinkFrequency']),
        'ARFCN': cellData['bandNR']['downlinkArfcn'].toString(),
      });
    }
  }

  final List<String> nrCcBands = nrCaBands.map((e) => e['NAME']!).toList();
  nrCcBands.insert(0, bandName);

  if (nrCcBands.length > maxCcCount) {
    // Sanity check, should not happen
    // log(
    //     "Warning: NR CC Count (${nrCcBands.length}) exceeds max CC Count ($maxCcCount). Truncating to max CC Count.");
    nrCcBands.removeRange(maxCcCount, nrCcBands.length);
  }
  return CellData(
    networkType: "SA",
    nrCcCount: nrCcBands.length,
    nrCcBands: nrCcBands,
    rsrp: rsrp,
    sinr: sinr,
    rsrq: rsrq,
    dataConnStatus: dataConnStatus,
    // detailedNetworkType: detailedNetworkType,
    mccmnc: mccmnc,
    carrierName: carrierName,
    mvnoName: mvnoName,
    isImsRegistered: isImsRegistered,
    imsStatus: imsStatus,
    nsaStatus: "no",
  );
}
