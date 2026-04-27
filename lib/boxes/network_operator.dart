import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveNetworkOperatorService {
  static const String _boxName = 'operatorsBox';
  static const String _aospUrl =
      'https://android.googlesource.com/device/sample/+/main/etc/apns-full-conf.xml?format=TEXT';

  // Define your exact custom overrides here
  static const Map<String, String> _customOverrides = {
    'Hutchison HK': '3HK',
    'csl': 'csl.',
    // Add more specific mapping overrides as needed
  };

  /// Cleans and formats the carrier name based on specific rules
  String _cleanCarrierName(String rawName) {
    String name = rawName.trim();

    // Remove the exact suffixes if they appear at the end of the string
    name = name.replaceAll(RegExp(r'\s+Data$'), '');
    name = name.replaceAll(RegExp(r'\s+UT$'), '');
    name = name.replaceAll(RegExp(r'\s+MMS$'), '');
    name = name.replaceAll(RegExp(r'\s+IMS$'), '');
    name = name.replaceAll(RegExp(r'\s+HOS$'), '');
    name = name.replaceAll(RegExp(r'\s+NET$'), '');
    name = name.replaceAll(RegExp(r'\s+WAP$'), '');
    name = name.replaceAll(RegExp(r'\s+Gateway$'), '');
    name = name.replaceAll(RegExp(r'\s+Internet$'), '');
    name = name.replaceAll(RegExp(r'\s+INTERNET$'), '');
    name = name.replaceAll(RegExp(r'\s+&amp;MMS$'), '');
    name = name.replaceAll(RegExp(r'\s+&amp; MMS$'), '');
    name = name.replaceAll(RegExp(r'\s+&MMS$'), '');
    name = name.replaceAll(RegExp(r'\s+&Postpaid$'), '');
    name = name.replaceAll(RegExp(r'\s+&Prepaid$'), '');
    name = name.replaceAll(RegExp(r'\s+\(Internet\)$'), '');
    name = name.replaceAll(RegExp(r'\s+\(Prepaid\)$'), '');
    name = name.replaceAll(RegExp(r'\s+\(IMS\)$'), '');
    name = name.replaceAll(RegExp(r'\s+\(XCAP\)$'), '');
    name = name.replaceAll(RegExp(r'\s+\(UT\)$'), '');
    name = name.replaceAll(RegExp(r'\s+\(MMS\)$'), '');

    // Apply exact matches from the custom overrides map
    if (_customOverrides.containsKey(name)) {
      name = _customOverrides[name]!;
    }

    return name;
  }

  /// Fetches XML, parses, cleans names, and updates the Hive box
  Future<bool> syncOperatorsDatabase() async {
    try {
      final response = await http.get(Uri.parse(_aospUrl));

      if (response.statusCode == 200) {
        final decodedBytes = base64.decode(response.body);
        final xmlString = utf8.decode(decodedBytes);

        final document = XmlDocument.parse(xmlString);
        final box = Hive.box<String>(_boxName);

        // We collect them in a map first to handle putIfAbsent logic,
        // ensuring we only keep the first occurrence of a carrier per PLMN
        final Map<String, String> networkMap = {};

        for (final element in document.findAllElements('apn')) {
          final mcc = element.getAttribute('mcc');
          final mnc = element.getAttribute('mnc');
          final rawCarrier = element.getAttribute('carrier');

          if (mcc != null && mnc != null && rawCarrier != null) {
            final key = '$mcc$mnc';

            networkMap.putIfAbsent(key, () {
              return _cleanCarrierName(rawCarrier);
            });
          }
        }

        // Put all parsed and cleaned entries into Hive
        await box.putAll(networkMap);
        print('Successfully synced ${networkMap.length} networks to Hive.');
        return true;
      } else {
        print('Failed to fetch from AOSP: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing operator data: $e');
    }
    return false;
  }

  /// Synchronously fetches the friendly name from the Hive box
  /// Returns null if the MCC+MNC combination is not found
  String? getFriendlyName(String plmn) {
    // We can confidently access the box synchronously since we opened it in main()
    if (!Hive.isBoxOpen(_boxName)) {
      return null; // Or return a placeholder like 'Loading...'
    }
    final box = Hive.box<String>(_boxName);

    // Look up the combined key (e.g., "45400" -> "csl")
    return box.get(plmn);
  }
}
