import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void configureGoogleMapsForWeb() {
  final platform = GoogleMapsPlatform.instance;
  if (platform is WebGoogleMapsPlatform) {
    platform.initializeWithHtmlId('google_map');
  }
}
