import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spookyservices/widgets/widgets.dart';
import 'package:spookyservices/widgets/modal.dart';

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
              SizedBox(height: 5),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    text: "View Licenses",
                    onPressed: () async {
                      final info = await PackageInfo.fromPlatform();
                      final buildNumber = info.buildNumber;
                      final version = info.version;
                      showLicensePage(
                        // ignore: use_build_context_synchronously
                        context: context,
                        applicationName: 'CellularViewer',
                        applicationVersion: "$version ($buildNumber)",
                        applicationIcon: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100),
                          child: Image.asset("assets/images/icon.png"),
                        ),

                        applicationLegalese:
                            "© Spooky Kipper (Spooky Services)",
                      );
                    },
                  ),
                  SizedBox(width: 5),

                  Button(
                    text: "View Copyright Info",
                    onPressed: () async {
                      showModal(
                        context,
                        "Copyright Information",
                        '''App originally created by Spooky Kipper (Spooky Services)
Copyright © 2026
Licensed under GNU GPLv3.
https://github.com/SpookyKipper/CellularViewer/
                                                      
This app uses open source libraries.
Click "View licenses" for more information.
This app uses a modified version of flutter_cell_info. Source: https://github.com/SpookyKipper/flutter_cell_info
''',
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }
}
