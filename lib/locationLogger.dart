import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class locationLogger {
  static Future<bool> getLocationPermission() async {
        bool serviceEnabled;
        LocationPermission permission;

        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return Future.error('Location services are disabled.');
        }

        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            return Future.error('Location permissions are denied');
          }
        }
        
        if (permission == LocationPermission.deniedForever) {
          return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
        } 

        return true;
  }
  
  static Future<void> locationUpdate() async {
    Position _locationData;
  
    if (await getLocationPermission()) {
      print('Location permission ready !');
      _locationData = await Geolocator.getCurrentPosition().catchError((err) { print(err); });
      print(_locationData);
      updateZinzLocation(_locationData);
  
      // location.onLocationChanged.listen((LocationData currentLocation) {
      //   print(currentLocation);
      //   updateZinzLocation(currentLocation);
      // });
    }
  }

  static Future<void> updateZinzLocation(Position locationData) async {
    double? latitude = locationData.latitude;
    double? longitude = locationData.longitude;
  
    await http.post(
      Uri.parse("https://random-tests.lancelot.life/location/lancelot?latitude=$latitude&longitude=$longitude"),
    );
  }
}
