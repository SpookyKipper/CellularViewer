import 'dart:async';
import 'dart:developer';

import 'package:cellular_viewer/helper/netinfo.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spookyservices/widgets/widgets.dart';

class DebugPage extends StatefulWidget {
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  @override
  void initState() {
    super.initState();
    _initPermissionsAndTimer(); 
  }

  String _debugMessage = "Initializing...";

Timer? _timer;
  Future<void> _initPermissionsAndTimer() async {
    // 1. Request Permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
    ].request();

    if (statuses[Permission.location]!.isGranted &&
        statuses[Permission.phone]!.isGranted) {
      // 2. Start Loop
      _timer = Timer.periodic(const Duration(milliseconds: 650), (timer) async {
        String debugValue = await getDebugValue();
        if (!mounted) return;
        setState(() {
          _debugMessage = debugValue;
        });
      });
    } else {
      setState(() => _debugMessage = "Permissions Denied");
    }
  }

  void copyDebugValue() async {
    // Implementation for copying debug value
    String debugValue = await getDebugValue();

    try {
      await FlutterClipboard.copy(debugValue);
      Fluttertoast.showToast(
        msg: "Debug Value copied!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        // backgroundColor: Colors.black,
        // textColor: Colors.white,
        fontSize: 16.0,
      );
    } on ClipboardException catch (e) {
      Fluttertoast.showToast(
        msg: "Debug Value copy FAILED!\n${e.message}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<String> getCellRawInfo() async {
    try {
      String? cellInfo = await CellInfo.getCellInfo;
      if (cellInfo == null) return Future.error("No cell info available");
      return cellInfo;
      
    } catch (e) {
      print("Error fetching cell info: $e");
    }
    return Future.error("Failed to fetch cell info");
  }



  Future<String> getDebugValue() async {
    final info = await PackageInfo.fromPlatform();
    String debugValue =
        '''App Name: ${info.appName}
Package Name: ${info.packageName}
Version: ${info.version}
Build Number: ${info.buildNumber}

============================================

''';

    final bool usingCa = await ServiceStateService.searchServiceState("isUsingCarrierAggregation=true");


    final String cellRawInfo = await getCellRawInfo();
    final CellData cellInfo = await getCellInfo();
    final String dataStatus = await RrcService.getRrcStatus();
    final String imsStatus = await ImsServiceDebug.getNetworkType();
    final List<double> bandwidths = await ServiceStateService.getBandwidths();
    final String rrcStatus = cellInfo.lteCcCount > 1 ? "Connected" : cellInfo.lteCcCount == bandwidths.length ? "Connected no CA" : "Idle";

    debugValue +=
        '''DATA Status: $dataStatus

============================================

Override Network Type (not used): ${await CellService.getOverrideNetworkType()}
Using Carrier Aggregation: ${usingCa ? "YES" : "NO"}
NRStatus (NSA): ${cellInfo.nsaStatus}

============================================

Bandwidth Info: 
${bandwidths.toString()}
${bandwidths.length} total bands

LTE CC Count: ${cellInfo.lteCcCount}
RRC State (Guess): $rrcStatus
NR CC Count (From Raw Cell Info): ${cellInfo.nrCcCount}

BW - LTE CC Count: ${bandwidths.length - cellInfo.lteCcCount}
NR CC Count (Calculated from BW Info): ${rrcStatus.contains("Connected") ? (bandwidths.length - cellInfo.lteCcCount) : 0}

============================================

Processed Cell Info: $cellInfo

============================================

Raw Cell Info: ${cellRawInfo ?? "N/A"}

============================================

IMS Network Type: $imsStatus''';

    return debugValue;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              Center(
                child: Button(onPressed: copyDebugValue, text: "Copy Debug Value"),
              ),
              Text(_debugMessage),
            ],
          ),
        );
      }
    );
  }
}
