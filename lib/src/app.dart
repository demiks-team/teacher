import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teacher/l10n/app_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';


import 'shared/helpers/colors/material_color.dart';
import 'shared/helpers/navigation_service/navigation_service.dart';
import 'shared/secure_storage.dart';
import 'site/screens/login_screen.dart';
import 'teacher/shared-widgets/menu/bottom_navigation.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? isUserLoggedIn;

  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  Future<void> checkUserLoggedIn() async {
    var currentUser = await SecureStorage.getCurrentUser();
    if (currentUser != null) {
      setState(() {
        isUserLoggedIn = true;
      });
    } else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('es'),
        Locale('fr'),
      ],
      theme: ThemeData(
        primarySwatch: buildMaterialColor(const Color(0xffffffff)),
      ),
      home: isUserLoggedIn == null
          ? const LoginScreen()
          : isUserLoggedIn!
          ? const BottomNavigation()
          : const LoginScreen(),
      navigatorKey: NavigationService.navigatorKey,
    );
  }
}
