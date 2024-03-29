import 'package:camera_app/camera_page.dart';
import 'package:camera_app/media_provider.dart';
import 'package:camera_app/multiprovider_example/multiprovider_example.dart';
import 'package:camera_app/multiprovider_example/multiprovider_example_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

List<CameraDescription>? cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MediaProvider()),
        ChangeNotifierProvider(create: (context) => CounterProvider())
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter camera app demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: CameraPage(cameras: cameras),
          // home: MultiproviderExampleScreen(),
        );
      },
    );
  }
}
