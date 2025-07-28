import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:teacher/src/authentication/models/login_model.dart';
import 'package:teacher/src/authentication/services/authentication_service.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';

import 'package:teacher/src/shared/models/enums.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:teacher/src/site/screens/password_screen.dart';
import 'package:teacher/src/teacher/shared-widgets/menu/bottom_navigation.dart';

class VerifyScreen extends StatefulWidget {
  final String identifier;
  final String? tempToken;
  final VerificationRequestType requestType;
  final VerificationResultType? verificationResultType;

  const VerifyScreen(
      {Key? key,
      required this.identifier,
      this.tempToken,
      required this.requestType,
      this.verificationResultType})
      : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _pinController = TextEditingController();
  final authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.12;

    final defaultPinTheme = PinTheme(
      width: boxWidth.clamp(40.0, 70.0),
      height: boxWidth.clamp(48.0, 80.0),
      textStyle: TextStyle(
        fontSize: 20,
        color: HexColor.fromHex(AppColors.backgroundColorGray),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
    );

    final totalPinWidth = boxWidth.clamp(40.0, 70.0) * 6 + 40;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.verificationCode),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: HexColor.fromHex(AppColors.accentColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color: HexColor.fromHex(AppColors.accentColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 80),
            SizedBox(
              width: totalPinWidth,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.verificationCodeDescription,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: totalPinWidth,
              child: Pinput(
                length: 6,
                controller: _pinController,
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) async {
                  var loginModel = LoginModel();
                  loginModel.email = widget.identifier;
                  loginModel.tempToken = widget.tempToken;
                  loginModel.code = pin;

                  if (widget.requestType == VerificationRequestType.login) {
                    await authenticationService
                        .verifyLoginIdentifier(loginModel)
                        .then((result) {
                      if (result) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BottomNavigation()));
                      }
                    }).onError((error, stackTrace) {
                      return;
                    });
                  } else {
                    await authenticationService
                        .verifySignupIdentifier(
                            loginModel.email!, loginModel.code!)
                        .then((result) {
                      if (result) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PasswordScreen(
                                      identifier: loginModel.email!,
                                      verificationResultType:
                                          widget.verificationResultType,
                                      verificationCode: loginModel.code,
                                    )));
                      }
                    }).onError((error, stackTrace) {
                      return;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
