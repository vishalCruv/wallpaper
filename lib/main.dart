import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("count", 0);
  runApp(MyApp());
}

const simplePeriodic1HourTask = "changingWallpaper";
Future<void> setWallpaper(int wallpaperType, String url) async {
  print(
      "-------------------------SETTING WALLPAPER-------------------------- ");
  const platform = MethodChannel('wallpaper');
  var file = await DefaultCacheManager().getSingleFile(url);
  try {
    final int result =
        await platform.invokeMethod('setWallpaper', [file.path, wallpaperType]);
    print('Wallpaer Updated.... $result');
  } on PlatformException catch (e) {
    print("Failed to Set Wallpaer: '${e.message}'.");
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    List<String> images = [
      "https://images.pexels.com/photos/9308054/pexels-photo-9308054.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"
      "https://images.pexels.com/photos/10069890/pexels-photo-10069890.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://images.pexels.com/photos/7037125/pexels-photo-7037125.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://images.pexels.com/photos/8803905/pexels-photo-8803905.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://images.pexels.com/photos/9556451/pexels-photo-9556451.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://images.pexels.com/photos/10050591/pexels-photo-10050591.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://images.pexels.com/photos/9000160/pexels-photo-9000160.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "https://images.pexels.com/photos/9676202/pexels-photo-9676202.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500", 
    ];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var index = prefs.getInt("count");
    String url = images[index!];
    print("Wallpaper URL: $url");
    int count = (index + 1) % images.length;
    prefs.setInt("count", count);
    print("Doing $taskName, wallpaper changing no.: $index");
    var file = await DefaultCacheManager().getSingleFile(url);
    String path = file.path;
    int location = WallpaperManager.HOME_SCREEN;
    final bool result =
        await WallpaperManager.setWallpaperFromFile(path, location);

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleTextStyle: const TextStyle(color: Colors.black),
          elevation: 0,
          title: const Text("Flutter WorkManager Example"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              TextButton(
                  child: const Text("Periodic Task"),
                  onPressed: () async {
                    bool perForWall =
                        await Permission.manageExternalStorage.isGranted;
                    Permission.storage.request().then((value) async {
                      if (value.isGranted || perForWall) {
                        Workmanager().registerPeriodicTask(
                          "5",
                          simplePeriodic1HourTask,
                          inputData: {
                            "date":DateTime.now().toString(),
                          },
                          constraints: Constraints(networkType: NetworkType.connected),
                        );
                        // SystemNavigator.pop();
                        // _setWallpaper(1, "https://images.pexels.com/photos/10069890/pexels-photo-10069890.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")
                      }
                    });
                  }),
              TextButton(
                child: const Text("Cancel All"),
                onPressed: () async {
                  await Workmanager().cancelAll();
                  print('Cancel all tasks completed');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
