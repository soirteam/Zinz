import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'locationLogger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseMessagingInit();
  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  await locationLogger.locationUpdate();
  
  print("Location updated");
}


Future<void> firebaseMessagingInit() async {
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Zinz v0.0.0'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mapController = MapController();
  List<LatLng> _positions = [];

  void _initMarker() async {
    await locationLogger.getLocationPermission();
    LatLng? locationData = await locationLogger.locationUpdate();
    LatLng? getUserLocation = await locationLogger.getUserLocation("user1");
    String? token = await FirebaseMessaging.instance.getToken();

    print(getUserLocation);
      if (locationData != null && getUserLocation != null) {
        setState(() {
          _positions = [locationData, getUserLocation];
        });
      }
  }


  @override
  Widget build(BuildContext context) {
    List<Marker> markers = _positions.map((position) => Marker(
      width: 80.0,
      height: 80.0,
      point: position,
      builder: (ctx) => Container(
        child: Transform.translate(
            offset: Offset(0, -30),
            child: Icon(
              Icons.location_history,
              color: Colors.black,
              size: 60,
            ),
        )
      ),
    )).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              center: LatLng(0, 0),
              zoom: 9.2,
          ),
          children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'wtf.soir.zinz',
              ),
              MarkerLayer(markers: markers),
          ],
      ),
      floatingActionButton:
          FloatingActionButton(
              onPressed: _initMarker,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
          ),
    );
  }
}
