import 'package:Sea_Sm/views/screens/home_scanner_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
// import 'packagfe:camera/camera.dart';
//gng late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // cameras= await availableCameras();jh
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterSizer(
      builder: (BuildContext, Orientation, ScreenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Image Upload',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomeScannerPage(),
        );
      },
    );
  }
}
