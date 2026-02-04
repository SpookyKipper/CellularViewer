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

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  double calcTopPadding(BuildContext context) {
    final padding = MediaQuery.paddingOf(context).top;
    return padding > 2 ? padding - 2 : 0;
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
                children: [
                  SizedBox(width: 10),
                  SmartInvert(
                    child: Image.asset(
                      "assets/images/NetworkIcons/4G.png",
                      fit: BoxFit.cover,
                      height: 12,
                    ),
                  ),

                  SizedBox(width: 5),
                  Text(
                    "1800 + 2100",
                    style: TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: Text(
                      "  •  ",
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                  SmartInvert(
                    child: Image.asset(
                      "assets/images/NetworkIcons/5GPlus.png",
                      fit: BoxFit.cover,
                      height: 12,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    "1800 + 2100",
                    style: TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                  Transform.scale(
                    scale: 1.5,
                    child: Text(
                      "  •  ",
                      style: TextStyle(color: Colors.white, fontSize: 11.5),
                    ),
                  ),
                  SmartInvert(
                    child: Image.asset(
                      "assets/images/NetworkIcons/VoLTE.png",
                      fit: BoxFit.cover,
                      height: 12,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    "VoLTE",
                    style: TextStyle(color: Colors.white, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
