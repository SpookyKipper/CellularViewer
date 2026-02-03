import 'package:flutter/material.dart' hide AppBar;
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spookyservices/widgets/widgets.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            
            children: [
              Button(
                text: "View Licenses",
                onPressed: () async {
                  final info = await PackageInfo.fromPlatform();
                  final _buildNumber = info.buildNumber;
                  final _version = info.version;
                  showLicensePage(
                    context: context,
                    applicationName: 'HKJC Updater',
                    applicationVersion: "$_version ($_buildNumber)",
                    applicationIcon: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 100),
                      child: Image.asset("assets/images/icon.png"),
                    ),
            
                    applicationLegalese: "© Spooky Services",
                  );
                },
              ),
              SizedBox(height: 5),
              Button(
                text: "Go to Debug Page",
                onPressed: () async {
                  context.push('/debug');  
                },
              ),
              SizedBox(height: 5),
              Button(
                text: "Configure Overlay Settings",
                onPressed: () async {
                  context.push('/overlay');  
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
