import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/authentication/models/identity_verification_model.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/models/enums.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';
import 'package:teacher/src/site/screens/password_screen.dart';
import 'package:teacher/src/site/screens/verify_screen.dart';

import '../../authentication/services/authentication_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final authenticationService = AuthenticationService();
  final _formKey = GlobalKey<FormState>();

  String _userEmail = '';

  bool submitted = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _formKey.currentState!.validate();
      });
    });
  }

  void _submitSignUp() async {
    final bool? isValid = _formKey.currentState?.validate();

    if (isValid == true) {
      setState(() {
        submitted = true;
      });

      var identityVerification = IdentityVerificationModel();
      identityVerification.identifier = _userEmail;
      identityVerification.communicationMethod = CommunicationMethod.email;
      identityVerification.requestType = VerificationRequestType.signUp;

      await authenticationService
          .sendVerificationMessage(identityVerification)
          .then((result) {
            if (result.verificationResultType != null) {
              if (result.verificationResultType ==
                  VerificationResultType.existUser) {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PasswordScreen(
                      identifier: _userEmail,
                      requestType: VerificationRequestType.login,
                    ),
                  ),
                );
              } else if (result.verificationResultType ==
                  VerificationResultType.existEmail) {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VerifyScreen(
                      identifier: _userEmail,
                      requestType: VerificationRequestType.signUp,
                      verificationResultType: result.verificationResultType,
                    ),
                  ),
                );
              }
            }
          })
          .whenComplete(() {
            setState(() {
              submitted = false;
            });
          })
          .onError((error, stackTrace) {
            setState(() {
              submitted = false;
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 2,
                      right: 2,
                      bottom: 0,
                      top: 100,
                    ),
                    width: 150,
                    height: 50,
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(35),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              top: 5,
                              left: 15,
                              right: 15,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 25,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.createAnAccount,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: HexColor.fromHex(
                                          AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: HexColor.fromHex(
                                          AppColors.backgroundColorGray,
                                        ),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: HexColor.fromHex(
                                          AppColors.backgroundColorGray,
                                        ),
                                      ),
                                    ),
                                    helperText: ' ',
                                    hintText: AppLocalizations.of(
                                      context,
                                    )!.email,
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '';
                                    }
                                    if (!RegExp(
                                      r'\S+@\S+\.\S+',
                                    ).hasMatch(value)) {
                                      return '';
                                    }

                                    return null;
                                  },
                                  onChanged: (value) => _userEmail = value,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 25,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.beforeEmailValidation,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(60),
                                    backgroundColor: HexColor.fromHex(
                                      AppColors.primaryColor,
                                    ),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  onPressed: _formKey.currentState != null
                                      ? _formKey.currentState!.validate() &&
                                                !submitted
                                            ? _submitSignUp
                                            : null
                                      : null,
                                  child: Text(
                                    AppLocalizations.of(context)!.signUp,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.haveAccount} ",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 3),
                                      child: InkWell(
                                        child: Text(
                                          AppLocalizations.of(context)!.login,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //     margin: const EdgeInsets.only(
                          //         top: 30, left: 15, right: 15),
                          //     child: Column(children: [
                          //       Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.center,
                          //         children: [
                          //           Expanded(
                          //             child: Center(
                          //               child: Text(
                          //                 AppLocalizations.of(context)!
                          //                     .signUpWithSocialNetworks,
                          //                 style: const TextStyle(
                          //                     fontSize: 20),
                          //               ),
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //       Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.center,
                          //         children: [
                          //           Container(
                          //             margin: const EdgeInsets.only(
                          //                 top: 15),
                          //             child: ElevatedButton.icon(
                          //               icon: Container(
                          //                   margin:
                          //                       const EdgeInsets.all(2),
                          //                   width: 20,
                          //                   height: 20,
                          //                   child: Image.asset(
                          //                       'assets/images/google-login-icon.png')),
                          //               style: ButtonStyle(
                          //                 padding:
                          //                     MaterialStateProperty.all(
                          //                         const EdgeInsets.only(
                          //                             top: 10,
                          //                             bottom: 10,
                          //                             left: 5,
                          //                             right: 5)),
                          //               ),
                          //               label: Text(AppLocalizations.of(
                          //                       context)!
                          //                   .signUpWithGoogle),
                          //               onPressed: () async {
                          //                 var response =
                          //                     await authenticationService
                          //                         .signUpGoogle();
                          //                 if (response != null &&
                          //                     response) {
                          //                   Navigator.push(
                          //                       context,
                          //                       MaterialPageRoute(
                          //                           builder: (_) =>
                          //                               const BottomNavigation()));
                          //                 }
                          //               },
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //     ])),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Container(
          //   height: 50,
          //   decoration: BoxDecoration(
          //       border: Border(
          //     top: BorderSide(
          //       color: HexColor.fromHex(AppColors.backgroundColorAlto),
          //     ),
          //   )),
          //   child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             Text(
          //               AppLocalizations.of(context)!.haveAccount + " ",
          //               style: const TextStyle(
          //                   color: Colors.black,
          //                   fontSize: 12,
          //                   fontWeight: FontWeight.w300),
          //             ),
          //             Container(
          //                 margin: const EdgeInsets.only(bottom: 3),
          //                 child: InkWell(
          //                   child: Text(
          //                     AppLocalizations.of(context)!.login,
          //                     style: const TextStyle(
          //                         color: Colors.black, fontSize: 18),
          //                   ),
          //                   onTap: () {
          //                     Navigator.of(context).pop();
          //                   },
          //                 ))
          //           ],
          //         ),
          //       ]),
          // )
        ],
      ),
    );
  }
}

void showAlertDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Text(AppLocalizations.of(context)!.passwordComplexity),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
