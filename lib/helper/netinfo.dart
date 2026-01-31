import 'dart:convert';
import 'dart:developer';

import 'package:flutter_cell_info/flutter_cell_info.dart';

class CellData {
  final String networkType; // 3G/4G/NSA/SA
  final int lteCcCount;
  final List<String> lteCcBands; // e.g. 700, 2600
  final int nrCcCount;
  final List<String> nrCcBands; // e.g. 3500, 4900
  final double rsrp;
  final double rsrq;
  final double rssi;
  final double sinr; // or SNR for 4G
  final String ta; // 4G only

  CellData({
    required this.networkType,
    required this.lteCcCount,
    this.lteCcBands = const [],
    this.nrCcCount = 0,
    this.nrCcBands = const [],
    required this.rsrp,
    required this.sinr,
    required this.rsrq,
    required this.rssi,
    this.ta = '-',
  });

  @override
  String toString() {
    return 'CellInfo(networkType: $networkType, lteCcCount: $lteCcCount, lteCcBands: $lteCcBands, nrCcCount: $nrCcCount, nrCcBands: $nrCcBands, rsrp: $rsrp, sinr: $sinr, ta: $ta)';
  }
}

Future<CellData> getCellInfo() async {
  try {
    String? cellInfo = await CellInfo.getCellInfo;
    if (cellInfo == null) return Future.error("No cell info available");
    // log(jsonDecode(cellInfo).toString());

    Map<String, dynamic> parsedCellInfo = jsonDecode(cellInfo);

    if (parsedCellInfo.isEmpty) {
      return Future.error("Parsed cell info is empty");
    }

    List<dynamic> cellDataList = parsedCellInfo['cellDataList'];
    if (cellDataList.isEmpty) return Future.error("Cell data list is empty");
    String type = cellDataList[0]['type'];
    if (type == 'LTE') {
      
      return processLteCellInfo(parsedCellInfo);
    } else if (type == 'NR') {
      return Future.error("5G NR processing not implemented yet");
      // processNrCellInfo(parsedCellInfo);
    } else {
      return Future.error("Unsupported cell type: $type");
    }
  } catch (e) {
    print("Error fetching cell info: $e");
  }
  return Future.error("Failed to fetch cell info");
}

CellData processLteCellInfo(Map<String, dynamic> data) {

  Map<String, dynamic> cellDataList = data['primaryCellList'][0]['lte'];

  log(cellDataList.toString());

  
  String bandName = cellDataList['bandLTE']['name'];
  double rsrp = cellDataList['signalLTE']['rsrp'].toDouble();
  double rsrq =cellDataList['signalLTE']['rsrq'].toDouble();
  double rssi = cellDataList['signalLTE']['rssi'].toDouble();
  double snr = cellDataList['signalLTE']['snr'].toDouble();
  String ta =
      "${cellDataList['signalLTE']['timingAdvance']} (${cellDataList['signalLTE']['timingAdvance'] * 78} m)";

  List<dynamic> secondaryCellList = data['neighboringCellList'];
  int lteCcCount = 1;
  List<Map<String,String>> lteCaBands = []; // e.g. [{NAME, EARFCN}, ...]
  secondaryCellList.forEach((cell) {
    if (cell['type'] == 'LTE') {
      final cellData = cell['lte'];
      if (!cellData['connectionStatus'].contains('SecondaryConnection')) return;
      if (lteCaBands.contains({
        'NAME': cellData['bandLTE']['name'],
        'EARFCN': cellData['bandLTE']['earfcn'].toString(),
      })) return;      
      lteCaBands.add({
        'NAME': cellData['bandLTE']['name'],
        'EARFCN': cellData['bandLTE']['earfcn'].toString(),
      });
    }
  });

  final List<String> lteCcBands = lteCaBands.map((e) =>e['NAME']!).toList();
  lteCcBands.insert(0, bandName);
  final List<String> lteCCBandsClean = lteCcBands.toSet().toList(); // Remove duplicates
  return CellData(
    networkType: "4G",
    lteCcCount: lteCCBandsClean.length,
    lteCcBands: lteCCBandsClean,
    rsrp: rsrp,
    sinr: snr,
    rsrq: rsrq,
    rssi: rssi,
    ta: ta,
  );
}
