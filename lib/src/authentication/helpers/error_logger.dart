import 'package:teacher/src/infrastructure/notification.dart';
import 'package:teacher/src/shared/helpers/navigation_service/navigation_service.dart';
import 'package:teacher/src/shared/services/general_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorLogger {
  dynamic currentContext;

  ErrorLogger() {
    currentContext = NavigationService.navigatorKey.currentContext!;
  }

  Future<void> logError(String errorMessage, StackTrace stackTrace) async {
    final generalService = GeneralService();
    final notificationService = NotificationService();

    try {
      var result =
          "From Teacher Mobile App: " + errorMessage + stackTrace.toString();
      generalService.logError(result);
      notificationService
          .showError(AppLocalizations.of(currentContext)!.generalError);
    } catch (e) {
      // Handle any errors that occur while trying to log the error
      // print('Error logging failed: $e');
    }
  }
}
