import 'dart:async';

import 'package:cellular_viewer/helper/display.dart';
import 'package:cellular_viewer/helper/netinfo.dart';
import 'package:flutter_cell_info/flutter_cell_info.dart';
import 'package:flutter_cell_info/ims/info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spookyservices/functions/theme.dart';
import 'package:spookyservices/spookyservices.dart';
import 'package:spookyservices/widgets/widgets.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Timer for 1.25s updates
  Timer? _timer;

  CellData? _cellData;
  String? imsStatus;

  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initPermissionsAndTimer();
  }

  Future<void> _initPermissionsAndTimer() async {
    // 1. Request Permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
    ].request();

    if (statuses[Permission.location]!.isGranted &&
        statuses[Permission.phone]!.isGranted) {
      // 2. Start Loop
      _timer = Timer.periodic(const Duration(milliseconds: 650), (timer) {
        _fetchNetworkInfo();
        _fetchImsStatus();
      });
    } else {
      if (mounted) setState(() => _statusMessage = "Permissions Denied");
    }
  }

  Future<void> _fetchImsStatus() async {
    try {
      String imsInfo = await ImsService.getNetworkType();
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
      CellData cells = await getCellInfo();

      // 2. Process data manually
      // _processCells(cells);
      // print("Cells");
      // log(cells.toString());
      if (mounted) {
        setState(() {
          _cellData = cells;
          _statusMessage = cells.toString();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = "Error: $e");
    }

    // } on PlatformException catch (e) {
    //   setState(() => _statusMessage = "Error: ${e.message}");
    // } catch (e) {
    //   setState(() => _statusMessage = "Error: $e");
    // }
  }

  @override
  Widget build(BuildContext context) {
    // print("Brightness: ${Theme.of(context).brightness}");
    if (Theme.of(context).brightness == Brightness.dark) {
      setDarkMode(true); //for spookyservices
      // Theme.of( context).copyWith(
      //   colorScheme: Theme.of(context).colorScheme.copyWith(
      //     brightness: Brightness.light,
      //   ),
      // );
    } else {
      setDarkMode(false); //for spookyservices
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              if (_cellData == null || _cellData!.dataConnStatus == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 25, left: 25, right: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cLD(
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.onPrimary,
                      ), // Color must be inside BoxDecoration
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Apply rounded corners
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 50,
                        right: 50,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        "Data service is DISCONNECTED\nInfo may be inaccurate.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer, // Color must be inside BoxDecoration
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Apply rounded corners
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            getNetworkIcon(_cellData),
                            width: 100,
                            height: 100,
                          ),
                          Image.asset(
                            getImsIcon(imsStatus),
                            width: 70,
                            height: 70,
                          ),
                        ],
                      ),
                      Text(getDescription(_cellData)),
                      if (_cellData != null &&
                          _cellData!.overrideNetworkType == "NR_NSA" &&
                          _cellData!.nrCcCount == 0) ...[ // LTE Anchor Band aka fake 5G logo
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                textAlign: TextAlign.center,
                                "[5G NSA] Connected to a 4G anchor band.\nIt is 5G on display for marketing, but the actual 5G connection has not been established yet.",
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 10),
                      Column(
                        children: [
                          Text(
                            "Connecting Bands and Frequencies",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (_cellData != null && _cellData!.lteCcCount >= 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  getNetworkIcon4G(_cellData),
                                  width: 35,
                                  height: 28,
                                ),
                                Text(
                                  _cellData != null
                                      ? "${_cellData!.lteCcBands.join(" + ")} (${_cellData!.lteCcCount}CC)"
                                      : "Loading...",
                                ),
                              ],
                            ),
                          if (_cellData != null && _cellData!.nrCcCount >= 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  getNetworkIcon5G(_cellData),
                                  width: 35,
                                  height: 28,
                                ),
                                Text(
                                  _cellData != null
                                      ? "${_cellData!.nrCcBands.join(" + ")} (${_cellData!.nrCcCount}CC)"
                                      : "Loading...",
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "IMS Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    getImsIcon(imsStatus),
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text(
                                    imsStatus != null
                                        ? imsStatus!.replaceFirst(
                                            "VoWiFi",
                                            "Wi-Fi Calling",
                                          )
                                        : "No IMS info",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Column(
                        children: [
                          Text(
                            "Signal Strength",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    _cellData != null &&
                                            _cellData!.networkType == "4G"
                                        ? "RSRP"
                                        : "SS RSRP",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  getRsrpDisplay(
                                    _cellData != null ? _cellData!.rsrp : 0,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    _cellData != null &&
                                            _cellData!.networkType == "4G"
                                        ? "RSRQ"
                                        : "SS RSRQ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  getRsrqDisplay(
                                    _cellData != null
                                        ? _cellData!.rsrq
                                        : 2683662,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    _cellData != null &&
                                            _cellData!.networkType == "4G"
                                        ? "SNR"
                                        : "SS SINR",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  getSinrDisplay(
                                    _cellData != null
                                        ? _cellData!.sinr
                                        : 2683662,
                                  ),
                                ],
                              ),
                              if (_cellData != null &&
                                  _cellData!.networkType == "4G")
                                Column(
                                  children: [
                                    Text(
                                      "TA",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    getTaDisplay(
                                      _cellData != null
                                          ? _cellData!.ta
                                          : 2683662,
                                    ),
                                  ],
                                ),
                              if (_cellData != null &&
                                  _cellData!.networkType != "4G")
                                Column(
                                  children: [
                                    Text(
                                      "SS RSRQ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    getRsrqDisplay(
                                      _cellData != null
                                          ? _cellData!.rsrq
                                          : 2683662,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          if (_cellData != null &&
                              _cellData!.networkType == "4G" &&
                              _cellData!.nrCcCount >= 1) ...[
                            SizedBox(height: 5),
                            Text(
                              "NSA Signal Strength",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "SS RSRP",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    getRsrpDisplay(
                                      _cellData != null
                                          ? _cellData!.nsaRsrp
                                          : 0,
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Text(
                                      "SS RSRQ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    getRsrqDisplay(
                                      _cellData != null
                                          ? _cellData!.nsaRsrq
                                          : 2683662,
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Text(
                                      "SS SINR",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    getSinrDisplay(
                                      _cellData != null
                                          ? _cellData!.nsaSinr
                                          : 2683662,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      // SizedBox(height: 10),
                      // Column(
                      //   children: [
                      //     Text(
                      //       "Detailed Network Type",
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //     Text(_cellData != null
                      //         ? _cellData!.detailedNetworkType
                      //         : "Loading..."),
                      //   ],
                      // ),
                      // SizedBox(height: 10),
                      // Column(
                      //   children: [
                      //     Text(
                      //       "Debug",
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 16,
                      //       ),
                      //     ),
                      //     Text(_statusMessage),
                      //   ],
                      // ),
                      SizedBox(height: 13),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
