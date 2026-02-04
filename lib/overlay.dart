import 'dart:async';

import 'package:cellular_viewer/helper/display.dart';
import 'package:cellular_viewer/helper/netinfo.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spookyservices/widgets/widgets.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class SmartInvert extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const SmartInvert({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return ColorFiltered(
      // 2. Rotate Hue by 180 degrees to restore original colors
      colorFilter: ColorFilter.matrix(_hueRotationMatrix(180)),
      child: ColorFiltered(
        // 1. Invert the colors (Negative)
        colorFilter: const ColorFilter.matrix([
          -1,
          0,
          0,
          0,
          255,
          0,
          -1,
          0,
          0,
          255,
          0,
          0,
          -1,
          0,
          255,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: child,
      ),
    );
  }

  /// Generates a matrix to rotate hue by [degrees].
  static List<double> _hueRotationMatrix(double degrees) {
    final rad = degrees * (pi / 180);
    final cosVal = cos(rad);
    final sinVal = sin(rad);

    // Standard luminance coefficients
    const lumR = 0.213;
    const lumG = 0.715;
    const lumB = 0.072;

    return [
      lumR + cosVal * (1 - lumR) + sinVal * (-lumR),
      lumG + cosVal * (-lumG) + sinVal * (-lumG),
      lumB + cosVal * (-lumB) + sinVal * (1 - lumB),
      0,
      0,

      lumR + cosVal * (-lumR) + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.140,
      lumB + cosVal * (-lumB) + sinVal * -0.283,
      0,
      0,

      lumR + cosVal * (-lumR) + sinVal * -(1 - lumR),
      lumG + cosVal * (-lumG) + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0,
      0,

      0,
      0,
      0,
      1,
      0,
    ];
  }
}

class OverlayApp extends StatefulWidget {
  const OverlayApp({super.key});

  @override
  State<OverlayApp> createState() => _OverlayAppState();
}

class _OverlayAppState extends State<OverlayApp> {
  double calcTopPadding(BuildContext context) {
    final padding = MediaQuery.paddingOf(context).top;
    return padding > 2 ? padding - 1 : 0;
  }

  // Timer for 1.25s updates
  Timer? _timer;

  CellData? _cellData;
  String? imsStatus;

  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  Future<void> _initTimer() async {
    _timer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      _fetchNetworkInfo();
      _fetchImsStatus();
    });
  }

  Future<void> _fetchImsStatus() async {
    try {
      String imsInfo = await ImsService.getNetworkType().timeout(const Duration(milliseconds: 500));
      // print("IMS Info: $imsInfo");
      if (imsInfo == "PERMISSION_DENIED") {
        setState(() => imsStatus = null);
        return;
      }
      // log("IMS Info: $imsInfo");
      if (mounted) setState(() => imsStatus = imsInfo);
    } catch (e) {
      if (mounted) setState(() => imsStatus = "Error fetching IMS info: $e");
    }
  }

  Future<void> _fetchNetworkInfo() async {
    try {
      // 1. Get raw cell list from the plugin
      CellData cells = await getCellInfo().timeout(const Duration(milliseconds: 500));

      // 2. Process data manually
      // _processCells(cells);
      // print("Cells");
      // print(cells.toString());
      if (mounted) {
        setState(() {
          _cellData = cells;
          _statusMessage = cells.toString();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // log(MediaQuery.paddingOf(context).top.toString());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(height: calcTopPadding(context)),
            Container(
              height: 17,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // Define the colors for the gradient
                  colors: [
                    Colors.transparent,
                    const Color.fromARGB(57, 0, 0, 0),
                    const Color.fromARGB(57, 0, 0, 0),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
                  // Optional: Define where the gradient starts and ends
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 10),

                  if (_cellData != null && _cellData!.networkType == "4G") ...[
                    SmartInvert(
                      child: Image.asset(
                        getNetworkIcon4G(_cellData, overlay: true),
                        fit: BoxFit.cover,
                        height: 12,
                      ),
                    ),

                    SizedBox(width: 5),
                    Text(
                      _cellData != null
                          ? "${_cellData!.lteCcBands.join(" + ")} (${_cellData!.lteCcCount}CC)"
                          : "Loading...",
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ), 
                    Transform.scale(
                      scale: 1.5,
                      child: Text(
                        "  •  ",
                        style: TextStyle(color: Colors.white, fontSize: 11.5),
                      ),
                    ),
                  ],
                  if (_cellData != null &&
                      (_cellData!.networkType == "SA" ||
                          (_cellData!.networkType == "4G" &&
                              _cellData!.nrCcCount > 0))) ...[
                    SmartInvert(
                      child: Image.asset(
                        getNetworkIcon5G(_cellData),
                        fit: BoxFit.cover,
                        height: 12,
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      _cellData != null
                          ? "${_cellData!.nrCcBands.join(" + ")} (${_cellData!.nrCcCount}CC)"
                          : "Loading...",
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                    Transform.scale(
                      scale: 1.5,
                      child: Text(
                        "  •  ",
                        style: TextStyle(color: Colors.white, fontSize: 11.5),
                      ),
                    ),
                  ],

                  // if (_cellData != null &&
                  //     _cellData!.networkType == "4G" &&
                  //     _cellData!.overrideNetworkType == "NR_NSA" &&
                  //     _cellData!.nrCcCount == 0) ...[
                  //   SmartInvert(
                  //     child: Image.asset(
                  //       "assets/images/NetworkIcons/5GNSA.png",
                  //       fit: BoxFit.cover,
                  //       height: 12,
                  //     ),
                  //   ),
                  //   SizedBox(width: 3),
                  //   Text(
                  //     "5G NOT CONNECTED",
                  //     style: TextStyle(color: Colors.white, fontSize: 11.5),
                  //   ),
                  // ],
                  SmartInvert(
                    child: Image.asset(
                      getImsIcon(imsStatus, overlay: true),
                      fit: BoxFit.cover,
                      height: 12,
                    ),
                  ),
                  // SizedBox(width: 3),
                  // Text(
                  //   imsStatus != null
                  //       ? imsStatus!.replaceFirst("VoWiFi", "Wi-Fi Calling")
                  //       : "No IMS info",
                  //   style: TextStyle(color: Colors.white, fontSize: 11.5),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
