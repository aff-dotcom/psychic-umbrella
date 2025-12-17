import 'package:flutter/services.dart';

class MapStyleHelper {
  static const MethodChannel _channel = MethodChannel('com.example.map_style');

  static Future<void> setMapStyle() async {
    try {
      await _channel.invokeMethod('setMapStyle');
    } on PlatformException catch (e) {
      print("Failed to set map style: '${e.message}'.");
    }
  }
}
