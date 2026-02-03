// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cellular_viewer/pages/debug.dart';
import 'package:cellular_viewer/pages/overlay.dart';
import 'package:dynamik_theme/dynamik_theme.dart';
import 'package:cellular_viewer/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cellular_viewer/pages/settings.dart';
import 'package:spookyservices/theme/colors.dart' as theme;
import 'package:spookyservices/theme/RouteDesign.dart';

// Define the snackbarKey for ScaffoldMessenger
// final GlobalKey<ScaffoldMessengerState> snackbarKey =
//     GlobalKey<ScaffoldMessengerState>();

final Map<String, ShellConfig> routeConfig = {
  '/': ShellConfig(
    title: "Cellular Viewer",
    icon: Icons.home,
    actions: [
      ShellAction(
        icon: Icons.settings,
        onPressed: (context) => context.push('/settings'),
      ),
    ],
  ),
  '/settings': ShellConfig(title: "Settings", icon: Icons.settings),
  '/debug': ShellConfig(title: "Debug", icon: Icons.bug_report),
  '/overlay': ShellConfig(title: "Overlay", icon: Icons.window),
};

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          state: state,
          routeConfig: routeConfig, // <--- Injecting the config
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => buildPageWithTransition(
            context: context,
            state: state,
            routeConfig: routeConfig,
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => buildPageWithTransition(
            context: context,
            state: state,
            routeConfig: routeConfig,
            child: SettingsPage(),
          ),
        ),
        GoRoute(
          path: '/overlay',
          pageBuilder: (context, state) => buildPageWithTransition(
            context: context,
            state: state,
            routeConfig: routeConfig,
            child: OverlaySettingsPage(),
          ),
        ),
        GoRoute(
          path: '/debug',
          pageBuilder: (context, state) => buildPageWithTransition(
            context: context,
            state: state,
            routeConfig: routeConfig,
            child: DebugPage(),
          ),
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(const OverlayApp());
}

class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    log(MediaQuery.paddingOf(context).top.toString());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: const Color.fromARGB(98, 0, 0, 0),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.paddingOf(context).top),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/NetworkIcons/4G.png", width: 100, height: 100),
              Icon(Icons.signal_cellular_4_bar, color: Colors.white),
              SizedBox(width: 5),
              Text("Overlay Active", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamikTheme(
      config: ThemeConfig(
        useMaterial3: true,
        // You can also generate color schemes from:
        // https://m3.material.io/theme-builder#/custom
        lightScheme: theme.MaterialTheme.lightScheme(),
        darkScheme: theme.MaterialTheme.darkScheme(),
        defaultThemeState: ThemeState(
          themeMode: ThemeMode.system,
          colorMode: ColorMode.custom,
        ),
        builder: (themeData) {
          // Add more customization on ThemeData.
          return themeData.copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                // Set the predictive back transitions for Android.
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              },
            ),
          );
        },
      ),
      builder: (theme, darkTheme, themeMode) {
        return MaterialApp.router(
          themeMode: themeMode,
          theme: theme,
          darkTheme: darkTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
