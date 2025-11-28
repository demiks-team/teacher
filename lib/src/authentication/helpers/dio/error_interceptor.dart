import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/infrastructure/notification.dart';
import 'package:teacher/src/shared/helpers/navigation_service/navigation_service.dart';

import '../../../shared/secure_storage.dart';
import '../../../site/screens/login_screen.dart';
import '../../services/authentication_service.dart';

// reference : https://medium.com/dreamwod-tech/flutter-dio-framework-best-practices-668985fc75b7

class ErrorsInterceptor extends Interceptor {
  final Dio dio;
  dynamic currentContext;
  NotificationService notificationService = NotificationService();
  final authService = AuthenticationService();

  ErrorsInterceptor(this.dio) {
    currentContext = NavigationService.navigatorKey.currentContext!;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    switch (err.type) {
      case DioExceptionType.badResponse:
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      //   throw DeadlineExceededException(err.requestOptions);
      case DioExceptionType.connectionError:
        switch (err.response?.statusCode) {
          case 400:
            Map<dynamic, dynamic>? decodedList;
            try {
              decodedList = jsonDecode(json.encode(err.response?.data));
            } catch (e) {
              decodedList = null;
            }
            if (decodedList != null) {
              var errorCode = decodedList["code"] as String;
              switch (errorCode) {
                case 'authFailed':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!.authFailed);
                  break;
                case 'passwordComplexity':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!.passwordComplexity);
                  break;
                case 'tempRegistrationPath':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!
                          .tempRegistrationPath);
                  break;
                case 'duplicateEmail':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!.duplicateEmail);
                  break;
                case 'verificationDoesNotMatch':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!
                          .verificationDoesNotMatch);
                  break;
                case 'verificationCodeExpired':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!
                          .verificationCodeExpired);
                  break;
                case 'validationError':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!
                          .validationError);
                  break; 
                case 'noUserFound':
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!
                          .noUserFound);
                  break;                                    
                default:
                  notificationService.showError(
                      AppLocalizations.of(currentContext)!.generalError);
              }
            } else {
              notificationService.showError(err.response?.data);
            }
            return handler.next(BadRequestException(err.requestOptions));
          case 401:
            var user = await SecureStorage.getCurrentUser();
            SecureStorage.removeCurrentUser();
            if (user != null) {
              await authService.refreshToken(user.refresh!);

              final opts = Options(
                  method: err.requestOptions.method,
                  headers: err.requestOptions.headers);
              final cloneReq = await dio.request(err.requestOptions.path,
                  options: opts,
                  data: err.requestOptions.data,
                  queryParameters: err.requestOptions.queryParameters);
              return handler.resolve(cloneReq);
            } else {
              Navigator.of(currentContext, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              return handler.next(UnauthorizedException(err.requestOptions));
            }
          case 498:
            SecureStorage.removeCurrentUser();
            Navigator.of(currentContext, rootNavigator: true)
                .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            return;
          case 500:
            notificationService
                .showError(AppLocalizations.of(currentContext)!.generalError);
            return handler
                .next(InternalServerErrorException(err.requestOptions));
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        if (kDebugMode) {
          print('Other workssss');
        }
      // throw NoInternetConnectionException(err.requestOptions);
    }

    return handler.next(err);
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}
