import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hreader/config/shared_preference_provider.dart';
import 'package:hreader/dao/database.dart';
import 'package:hreader/page/home_page.dart';
import 'package:hreader/page/home_page/bookshelf_page.dart';
import 'package:hreader/service/book_player/book_player_server.dart';
import 'package:hreader/utils/error/common.dart';
import 'package:hreader/utils/get_path/get_base_path.dart';
import 'package:hreader/utils/log/common.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Prefs().initPrefs();
  HLog.init();
  HError.init();

  await DBHelper().initDB();
  Server().start();
  initBasePath();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => Prefs()),
          // provider.ChangeNotifierProvider(create: (_) => Prefs()),
        ],
        child:
            provider.Consumer<Prefs>(builder: (context, prefsNotifier, child) {
          return MaterialApp(
            navigatorObservers: [FlutterSmartDialog.observer],
            builder: FlutterSmartDialog.init(),
            navigatorKey: navigatorKey,
            locale: prefsNotifier.locale,
            title: 'Hxl',
            themeMode: prefsNotifier.themeMode,
            home: const BookshelfPage(),
          );
        }));
  }
}
