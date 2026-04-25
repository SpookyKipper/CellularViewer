import 'package:cellular_viewer/boxes/network_operator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:spookyservices/widgets/widgets.dart';

class SyncNetOpPage extends StatefulWidget {
  @override
  State<SyncNetOpPage> createState() => _SyncNetOpPageState();
}

class _SyncNetOpPageState extends State<SyncNetOpPage> {
  void updateNetworkOperators() async {
    bool syncStatus = await HiveNetworkOperatorService()
        .syncOperatorsDatabase();
    if (syncStatus) {
      Fluttertoast.showToast(
        msg: "Updated Successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Update Failed!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        fontSize: 16.0,
      );
    }
    // ignore: use_build_context_synchronously
    context.go('/');
  }

  @override
  void initState() {
    super.initState();
    updateNetworkOperators();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            "Syncing Network Operator Data...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
