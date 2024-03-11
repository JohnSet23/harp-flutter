import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harp/constants/color.dart';
import 'package:harp/global.dart';
import 'package:harp/pages/loading_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  if (Platform.isAndroid) {
    HttpOverrides.global = MyHttpOverrides();
  }

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Harp',
    androidNotificationOngoing: true,
  );
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

 

  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      navigatorObservers: [routeObserver],
      title: 'Harp',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
            color: AppColor.appBarColor,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.primaryColor,
          primary: AppColor.primaryColor,
          secondary: AppColor.primaryColorDark,
        ),
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}
