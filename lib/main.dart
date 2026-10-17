import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/wallpaper_bloc.dart';
import 'blocs/wallpaper_intent.dart';
import 'repositories/wallpaper_repository.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive status bar colors for full-screen video experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final repository = WallpaperRepository(prefs: prefs);

  runApp(LiveWallpaperApp(repository: repository));
}

class LiveWallpaperApp extends StatelessWidget {
  final WallpaperRepository repository;

  const LiveWallpaperApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WallpaperBloc(repository: repository)
        ..add(LoadFeedIntent())
        ..add(CheckWallpaperStatusIntent()),
      child: MaterialApp(
        title: 'Wallora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF5722),
            secondary: Color(0xFFFFC107),
            surface: Color(0xFF121214),
          ),
          textTheme: ThemeData.dark().textTheme.apply(
                fontFamily: 'sans-serif',
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
