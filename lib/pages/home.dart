import 'package:go_router/go_router.dart';
import 'package:spookyservices/spookyservices.dart';
import 'package:spookyservices/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Brightness: ${Theme.of(context).brightness}");
    if (Theme.of(context).brightness == Brightness.dark) {
      setDarkMode(true); //for spookyservices
    } else {
      setDarkMode(false); //for spookyservices
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
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
                            'assets/images/NetworkIcons/5GNSA.png',
                            width: 100,
                            height: 100,
                          ),
                          Image.asset(
                            'assets/images/NetworkIcons/5GPlus_With_4GPlus.png',
                            width: 100,
                            height: 100,
                          ),
                          Image.asset(  
                                'assets/images/NetworkIcons/VoNR.png',
                                width: 80,
                                height: 80,
                              ),
                        ],
                      ),
                      Text("Connected to 5G NSA Network with 4G&5G CA"),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            "Connecting Bands and Frequencies",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/NetworkIcons/4GPlus.png',
                                width: 35,
                                height: 28,
                              ),
                              Text("900, 1800, 2600"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/NetworkIcons/5G.png',
                                width: 35,
                                height: 28,
                              ),
                              Text("700, 2100, 3500, 4900"),
                            ],
                          ),
                          
                        ],
                      ),
                      SizedBox(height: 10),
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
                              Image.asset(  
                                'assets/images/NetworkIcons/VoLTE.png',
                                width: 35,
                                height: 35,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "TA (4G Only)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Text("1 (78m)"),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                                    "RSRP",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("-95 dBm (Good)"),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "SINR",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("20 dB (Excellent)"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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
