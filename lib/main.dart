import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/src/app.dart';
import 'package:teacher/src/authentication/helpers/error_logger.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    if (kReleaseMode) {
      await dotenv.load(fileName: "assets/environments/.env.production");
    } else {
      await dotenv.load(fileName: "assets/environments/.env.development");
    }
    runApp(const App());
  }, (error, stackTrace) async {
    var errorLogger = ErrorLogger();
    await errorLogger.logError(error.toString(), stackTrace);
    // return true;
  });

  FlutterError.onError = (FlutterErrorDetails details) {
    var errorLogger = ErrorLogger();
    errorLogger.logError(details.exceptionAsString(), details.stack!);
  };
}
