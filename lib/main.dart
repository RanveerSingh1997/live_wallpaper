import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/wallpaper_bloc.dart';
import 'blocs/wallpaper_intent.dart';
import 'core/core.dart';
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
  ServiceLocator.registerSingleton<LocalCacheService>(repository.cache);
  ServiceLocator.registerSingleton<LruStorageManager>(repository.lruManager);
  ServiceLocator.registerSingleton<NetworkConnectivityService>(repository.connectivity);
  ServiceLocator.registerSingleton<FeedPrefetchManager>(repository.feedPrefetchManager);
  ServiceLocator.registerSingleton<WallpaperFacadeRepository>(repository);

  runApp(LiveWallpaperApp(repository: repository));
}

class LiveWallpaperApp extends StatefulWidget {
  final WallpaperFacadeRepository repository;

  const LiveWallpaperApp({super.key, required this.repository});

  @override
  State<LiveWallpaperApp> createState() => _LiveWallpaperAppState();
}

class _LiveWallpaperAppState extends State<LiveWallpaperApp> {
  late final WallpaperBloc _bloc;
  StreamSubscription<String>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = WallpaperBloc(repository: widget.repository)
      ..add(LoadFeedIntent())
      ..add(CheckWallpaperStatusIntent());

    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final initialLink = await widget.repository.getInitialDeepLink();
    if (initialLink != null && initialLink.isNotEmpty) {
      _bloc.add(HandleDeepLinkIntent(initialLink));
    }

    _deepLinkSubscription = widget.repository.onDeepLinkReceived.listen((uri) {
      _bloc.add(HandleDeepLinkIntent(uri));
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SplashScreen(),
      ),
    );
  }
}
