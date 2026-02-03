import 'dart:developer';

import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spookyservices/widgets/widgets.dart';

class OverlaySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log(MediaQuery.viewPaddingOf(context).top.toString());
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Button(
                text: "Show Overlay",
                onPressed: () async {
                  final bool statusPerm =
                      await FlutterOverlayWindow.isPermissionGranted();
                  if (!statusPerm) {
                    final bool? statusPermReq =
                        await FlutterOverlayWindow.requestPermission();
                    if (!statusPermReq!) {
                      // Permission denied, handle accordingly.
                      return;
                    } 
                  }
                  
                  
                  await FlutterOverlayWindow.showOverlay(height: 50, enableDrag: true, alignment: OverlayAlignment.center, startPosition: OverlayPosition(0, 0));
                  // await FlutterOverlayWindow.resizeOverlay(20, 20, true);
                },
              ),
              SizedBox(width: 20),
              Button(
                text: "Go to Debug Page",
                onPressed: () async {
                  context.push('/debug');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
