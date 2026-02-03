import 'dart:convert';
import 'dart:developer';

import 'package:cellular_viewer/helper/bandCalc.dart';
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
  });

  @override
  String toString() {
    return 'CellData(networkType: $networkType, lteCcCount: $lteCcCount, lteCcBands: $lteCcBands, nrCcCount: $nrCcCount, nrCcBands: $nrCcBands, rsrp: $rsrp, sinr: $sinr, ta: $ta)';
  }
}

Future<CellData> getCellInfo() async {
  try {
    String? cellInfo = await CellInfo.getCellInfo;
    if (cellInfo == null) return Future.error("No cell info available");
    // log(cellInfo);

    Map<String, dynamic> parsedCellInfo = jsonDecode(cellInfo);

    if (parsedCellInfo.isEmpty) {
      return Future.error("Parsed cell info is empty");
    }

    List<dynamic> cellDataList = parsedCellInfo['cellDataList'];
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

    if (cellDataList.isEmpty) return Future.error("Cell data list is empty");

    bool usingCa = await ServiceStateService.searchServiceState(
      "isUsingCarrierAggregation=true",
    );
    // if (!usingCa) {
    //   log("Carrier Aggregation not in use, skipping CA band processing.");
    // } else {
    //   log("Carrier Aggregation in use, processing CA bands.");
    // }

    final List<double> bandwidths = await ServiceStateService.getBandwidths();

    String type = cellDataList[0]['type'];
    if (type == 'LTE') {
      // 4G or 4G + 5G NSA
      return processLteCellInfo(
        parsedCellInfo,
        data,
        "a",
        usingCa,
        cpu,
        bandwidths,
      );
    } else if (type == 'NR') {
      // 5G SA
      return processNrCellInfo(
        parsedCellInfo,
        data,
        "a",
        usingCa,
        cpu,
        bandwidths,
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
  String? detailedNetworkType,
  bool usingCa,
  String cpu,
  List<double> bandwidths,
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
  ;
  // if (dataConnStatus == 0) {
  //   // If RRC is IDLE, no CA bands are available, no NSA bands either
  //   secondaryCellList = [];
  // } else {
  //   secondaryCellList = data['neighboringCellList'];
  // }
  int maxCcCount = bandwidths.length;
  if (usingCa == true && maxCcCount < 2) {
    maxCcCount = 999; // No limit if CA is used but bandwidth info is unreliable
  }

  for (var cell in secondaryCellList) {
    if (usingCa && cell['type'] == 'LTE') {
      // Collect LTE CA bands from secondary cells, no need to check if CA is not used by ServiceState
      final cellData = cell['lte'];
      if (!cellData['connectionStatus'].contains('SecondaryConnection') &&
          cpu !=
              'qcom') // Qualcomm reports NoneConnection even when connected, now solely reling on usingCa for qcom
        continue;
      // Check if this cell is the same as the primary cell
      if (cellData['bandLTE']['downlinkEarfcn'].toString() == primaryEarfcn)
        continue;

      // Check for duplicates in the collected list using explicit value comparison
      // (List.contains fails with non-const Map literals in Dart)
      if (lteCaBands.any(
        (e) =>
            e['NAME'] == cellData['bandLTE']['name'] &&
            e['EARFCN'] == cellData['bandLTE']['downlinkEarfcn'].toString(),
      ))
        continue;

      if (cellData['bandLTE']['name'] == "")
        continue; // Skip invalid bands (probably an NR  band)
      lteCaBands.add({
        'NAME': cellData['bandLTE']['name'],
        'EARFCN': cellData['bandLTE']['downlinkEarfcn'].toString(),
      });
    } else if (cell['type'] == 'NR') {
      // Limit NR CA bands to remaining CCs (LTE CC Count is reliable on qcom and Exynos)
      // Collect NR NSA CA bands from secondary cells
      final cellData = cell['nr'];
      // log(cellData['bandNR'].toString());
      if (!cellData['connectionStatus'].contains('SecondaryConnection'))
        continue;
      // Check validity and duplicate for NR bands
      String nrName = getNrBandName(cellData['bandNR']['downlinkFrequency']);
      String nrArfcn = cellData['bandNR']['downlinkArfcn'].toString();

      if (nrCaBands.any((e) => e['NAME'] == nrName && e['ARFCN'] == nrArfcn))
        continue;

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

  if (lteCcBands.length > maxCcCount) {
    // Sanity check, should not happen
    // log(
    //     "Warning: LTE CC Count (${lteCcBands.length}) exceeds max CC Count ($maxCcCount). Truncating to max CC Count.");
    lteCcBands.removeRange(maxCcCount, lteCcBands.length);
  }

  // Calculate max allowed NR CCs based on remaining bandwidth budget
  final int maxNrCcCount =
      maxCcCount - lteCcBands.length; // Remaining CCs for NR

  if (nrCcBands.length > maxNrCcCount) {
    // log(
    //     "Warning: NR CC Count (${nrCcBands.length}) exceeds max NR CC Count ($maxNrCcCount). Truncating to max NR CC Count.");
    nrCcBands.removeRange(maxNrCcCount, nrCcBands.length);
  }

  int nrCcCount = nrCcBands.length;
  // Heuristic: If we see few NR bands, but LTE CA suggests we are connected (>=2 CCs),
  // and there is room in the bandwidth list (maxNrCcCount > 0),
  // assume the "missing" bandwidth slots are occupied by unreported NR bands.
  // This compensates for unreliable NR CA reporting in some APIs.
  // NRCCCount 0 or 1 means NRCA cannot be reliably detected
  if ((nrCcCount == 0 || nrCcCount == 1) &&
      lteCcBands.length >=
          2 && // LTECC >=2 means RRC Connected and CA can be reliably detected
      maxNrCcCount > 0 &&
      maxNrCcCount < 100) { // avoid overflow from unreliable bandwidth info
    // Heuristic for NR NSA without reported NR CCs
    nrCcCount = maxNrCcCount;
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

    // detailedNetworkType: detailedNetworkType,
  );
}

CellData processNrCellInfo(
  Map<String, dynamic> data,
  int dataConnStatus,
  String detailedNetworkType,
  bool usingCa,
  String cpu,
  List<double> bandwidths,
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

  List<dynamic> secondaryCellList = data['neighboringCellList'];
  ;
  // if (dataConnStatus == 0 && usingCa == false) {
  //   // If RRC is IDLE, no CA bands are available, no NSA bands either
  //   secondaryCellList = [];
  // } else {
  //   secondaryCellList = data['neighboringCellList'];
  // }
  for (var cell in secondaryCellList) {
    if (cell['type'] == 'NR') {
      // minus 1 for main band
      final cellData = cell['nr'];
      if (!cellData['connectionStatus'].contains('SecondaryConnection') &&
          cpu !=
              'qcom') // Qualcomm reports NoneConnection even when connected, now solely reling on usingCa for qcom
        continue;
      if (cellData['bandNR']['downlinkArfcn'].toString() == primaryArfcn)
        continue;

      // Check for duplicates using explicit comparison (List.contains fails for Map literals)
      if (nrCaBands.any(
        (e) =>
            e['NAME'] ==
                getNrBandName(cellData['bandNR']['downlinkFrequency']) &&
            e['ARFCN'] == cellData['bandNR']['downlinkArfcn'].toString(),
      ))
        continue;

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
  );
}
