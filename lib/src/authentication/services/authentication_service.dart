import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/src/authentication/models/confirm_identity_verification_model.dart';
import 'package:teacher/src/authentication/models/identity_verification_model.dart';
import 'package:teacher/src/authentication/models/login_model.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:teacher/src/authentication/models/social_login_model.dart';

import '../../shared/secure_storage.dart';
import '../helpers/dio/dio_api.dart';

class AuthenticationService {
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //     scopes: ['email'],
  //     clientId:
  //         "913000033507-geun2f6l7vbg29udkbi1gmlhhoeph6ld.apps.googleusercontent.com");

  Future<ConfirmIdentityVerificationModel?> login(
      String email, String password) async {
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() + "security/login",
          data: json.encode(
              {"email": email, "password": password, "studentLanguage": 1}),
        );

    Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));

    if (response.statusCode == 200) {
      return ConfirmIdentityVerificationModel.fromJson(decodedList);
    } else {
      throw Exception('Unable to login.');
    }
    // if (response.statusCode == 200 && response.data != null) {
    //   await SecureStorage.setCurrentUser(json.encode(response.data).toString());
    // }
    // return json.encode(response.data).toString();
  }

  Future<bool> verifyLoginIdentifier(LoginModel loginModel) async {
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() + "security/login/verify-code",
          data: jsonEncode(loginModel.toJson()),
        );

    if (response.statusCode == 200 && response.data != null) {
      await SecureStorage.setCurrentUser(json.encode(response.data).toString());
      return true;
    }
    return false;
  }

  Future<String?> signUp(LoginModel loginModel) async {
    print(loginModel);
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() + "security/sign-up",
          data: jsonEncode(loginModel.toJson()),
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

  Future<ConfirmIdentityVerificationModel> sendVerificationMessage(
      IdentityVerificationModel identityVerification) async {
    var response = await DioApi().dio.post(
          dotenv.env['api'].toString() +
              "security/sign-up/verification-code/send",
          data: json.encode(identityVerification.toJson()),
        );

    Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));

    if (response.statusCode == 200) {
      return ConfirmIdentityVerificationModel.fromJson(decodedList);
    } else {
      throw Exception('Unable to retrieve verification info.');
    }

    // if (response.statusCode == 200 && response.data != null) {
    //   await SecureStorage.setCurrentUser(json.encode(response.data).toString());
    //   return true;
    // }
    // return false;
  }

  Future<bool> verifySignupIdentifier(String identifier, String code) async {
    var response = await DioApi().dio.get(
          dotenv.env['api'].toString() +
              'security/sign-up/identifier/' +
              identifier +
              '/code/' +
              code +
              '/verify'
        );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
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
