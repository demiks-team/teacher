import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:teacher/src/authentication/models/social_login_model.dart';

import '../../shared/secure_storage.dart';
import '../helpers/dio/dio_api.dart';

class AuthenticationService {
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //     scopes: ['email'],
  //     clientId:
  //         "913000033507-geun2f6l7vbg29udkbi1gmlhhoeph6ld.apps.googleusercontent.com");

  Future<String?> login(String email, String password) async {
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() + "security/login",
          data: json.encode(
              {"email": email, "password": password, "studentLanguage": 1}),
        );
    if (response.statusCode == 200 && response.data != null) {
      await SecureStorage.setCurrentUser(json.encode(response.data).toString());
    }
    return json.encode(response.data).toString();
  }

  Future<String?> signUp(String email, String password) async {
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() + "security/signup",
          data: json.encode({"email": email, "password": password}),
        );
    if (response.statusCode == 200 && response.data != null) {
      await SecureStorage.setCurrentUser(json.encode(response.data).toString());
    }
    return json.encode(response.data).toString();
  }

  Future<void> refreshToken(String token) async {
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() + "security/refresh",
          data: json.encode({"token": token, "userId": 0}),
        );
    if (response.statusCode == 200 && response.data != null) {
      await SecureStorage.setCurrentUser(json.encode(response.data).toString());
    } else {
      SecureStorage.removeCurrentUser();
    }
  }

  // Future<bool?> signInGoogle() async {
  //   bool loginSuccess = false;

  //   var result = await _googleSignIn.signIn();
  //   SocialLoginModel socialLoginModel = SocialLoginModel();
  //   socialLoginModel.id = result!.id;
  //   socialLoginModel.image = result.photoUrl;
  //   socialLoginModel.name = result.displayName;
  //   socialLoginModel.email = result.email;
  //   socialLoginModel.provider = "GOOGLE";

  //   await result.authentication.then((value) {
  //     socialLoginModel.idToken = value.idToken;
  //     socialLoginModel.token = value.accessToken;
  //   });
  //   try {
  //     var response = await DioApi().dio.post(
  //           dotenv.env['api'].toString() + "security/sociallogin",
  //           data: socialLoginModel.toJson(),
  //         );

  //     if (response.statusCode == 200 && response.data != null) {
  //       await SecureStorage.setCurrentUser(
  //           json.encode(response.data).toString());
  //       loginSuccess = true;
  //       return true;
  //     }
  //   } catch (e) {
  //     loginSuccess = false;
  //   }

  //   if (!loginSuccess) {
  //     try {
  //       var response = await DioApi().dio.post(
  //             dotenv.env['api'].toString() + "security/socialsignup",
  //             data: socialLoginModel.toJson(),
  //           );

  //       if (response.statusCode == 200 && response.data != null) {
  //         await SecureStorage.setCurrentUser(
  //             json.encode(response.data).toString());
  //         loginSuccess = true;
  //         return true;
  //       }
  //     } catch (e) {
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  // Future<bool?> signUpGoogle() async {
  //   try {
  //     var result = await _googleSignIn.signIn();
  //     SocialLoginModel socialLoginModel = SocialLoginModel();
  //     socialLoginModel.id = result!.id;
  //     socialLoginModel.image = result.photoUrl;
  //     socialLoginModel.name = result.displayName;
  //     socialLoginModel.email = result.email;
  //     socialLoginModel.provider = "GOOGLE";

  //     await result.authentication.then((value) {
  //       socialLoginModel.idToken = value.idToken;
  //       socialLoginModel.token = value.accessToken;
  //     });

  //     var response = await DioApi().dio.post(
  //           dotenv.env['api'].toString() + "security/socialsignup",
  //           data: socialLoginModel.toJson(),
  //         );

  //     if (response.statusCode == 200 && response.data != null) {
  //       await SecureStorage.setCurrentUser(
  //           json.encode(response.data).toString());
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     throw Exception('Unable to signup.');
  //   }
  // }

  // void signOutGoogle() {
  //   _googleSignIn.disconnect();
  // }
}
