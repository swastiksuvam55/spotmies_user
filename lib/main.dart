import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotmies/controllers/login_controller/splash_screen_controller.dart';
import 'package:spotmies/providers/getOrdersProvider.dart';
import 'package:spotmies/providers/getResponseProvider.dart';
import 'package:spotmies/providers/mapsProvider.dart';
import 'package:spotmies/providers/orderOverviewProvider.dart';
import 'package:spotmies/providers/timer_provider.dart';
import 'package:spotmies/providers/userDetailsProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider<TimeProvider>(create: (context) => TimeProvider()),
      ChangeNotifierProvider<UserDetailsProvider>(
          create: (context) => UserDetailsProvider()),
      ChangeNotifierProvider<GetOrdersProvider>(
          create: (context) => GetOrdersProvider()),
       ChangeNotifierProvider<OrderOverViewProvider>(
          create: (context) => OrderOverViewProvider()),
       ChangeNotifierProvider<MapsProvider>(
          create: (context) => MapsProvider()),
      ChangeNotifierProvider<GetResponseProvider>(
          create: (context) => GetResponseProvider()),
    ], child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// class LocationService {
//   Future<LocationData> getLocation() async {
//     Location location = new Location();
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//     LocationData _locationData;

//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         throw Exception();
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         throw Exception();
//       }
//     }

//     _locationData = await location.getLocation();
//     return _locationData;
//   }
// }
