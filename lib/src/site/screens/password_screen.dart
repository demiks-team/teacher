import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:teacher/src/authentication/models/login_model.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/models/enums.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';
import 'package:teacher/src/site/screens/verify_screen.dart';

import '../../authentication/services/authentication_service.dart';
import '../../teacher/shared-widgets/menu/bottom_navigation.dart';

class PasswordScreen extends StatefulWidget {
  final String identifier;
  final VerificationRequestType? requestType;
  final VerificationResultType? verificationResultType;
  final String? verificationCode;
  final String? password;

  const PasswordScreen(
      {Key? key,
      required this.identifier,
      this.requestType = VerificationRequestType.signUp,
      this.verificationResultType,
      this.verificationCode,
      this.password})
      : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authenticationService = AuthenticationService();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  String _userEmail = '';
  String _password = '';

  bool submitted = false;

  @override
  void initState() {
    super.initState();
    _userEmail = widget.identifier;
    _emailController.text = widget.identifier;
    _emailController.addListener(() {
      setState(() {
        _formKey.currentState!.validate();
      });
    });
    _passwordController.addListener(() {
      if (_formKey.currentState != null) {
        setState(() {
          _formKey.currentState!.validate();
        });
      }
    });
  }

  void _submit() async {
    final bool? isValid = _formKey.currentState?.validate();

    if (isValid == true) {
      setState(() {
        submitted = true;
      });

      var loginModel = LoginModel();
      loginModel.email = _userEmail;
      loginModel.password = _password;
      loginModel.code = widget.verificationCode;

      if (widget.requestType == VerificationRequestType.login) {
        var response = await authenticationService
            .login(_userEmail, _password)
            .whenComplete(() {
          setState(() {
            submitted = false;
          });
        }).onError((error, stackTrace) {
          setState(() {
            submitted = false;
          });
          return;
        });

        if (response != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => VerifyScreen(
                        identifier: _userEmail,
                        tempToken: response.tempToken,
                        requestType: VerificationRequestType.login,
                      )));
        }
      } else if (widget.requestType == VerificationRequestType.signUp) {
        var response = await authenticationService
            .signUp(loginModel)
            .whenComplete(() => setState(() {
                  submitted = false;
                }))
            .onError((error, stackTrace) {
          setState(() {
            submitted = false;
          });
          return;
        });
        if (response != null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BottomNavigation()));
        }
      }
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
                              left: 2, right: 2, bottom: 0, top: 100),
                          width: 150,
                          height: 50,
                          child: Image.asset('assets/images/logo.png')),
                    )),
                Container(
                  alignment: Alignment.center,
                  child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(35),
                        child: Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            key: _formKey,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 5, left: 15, right: 15),
                                    child: Column(children: [
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //   children: [
                                      //     Expanded(
                                      //         child: Container(
                                      //       margin: const EdgeInsets.only(
                                      //           bottom: 25),
                                      //       child: Text(
                                      //         AppLocalizations.of(context)!
                                      //             .createAnAccount,
                                      //         style:
                                      //             const TextStyle(fontSize: 20),
                                      //       ),
                                      //     )),
                                      //   ],
                                      // ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor.fromHex(
                                                    AppColors.primaryColor)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor.fromHex(
                                                    AppColors
                                                        .backgroundColorGray)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor.fromHex(
                                                    AppColors
                                                        .backgroundColorGray)),
                                          ),
                                          helperText: ' ',
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .email,
                                        ),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: _emailController,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return '';
                                          }
                                          if (!RegExp(r'\S+@\S+\.\S+')
                                              .hasMatch(value)) {
                                            return '';
                                          }

                                          return null;
                                        },
                                        onChanged: (value) =>
                                            _userEmail = value,
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          errorMaxLines: 6,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor.fromHex(
                                                    AppColors.primaryColor)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor.fromHex(
                                                    AppColors
                                                        .backgroundColorGray)),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: HexColor.fromHex(
                                                    AppColors
                                                        .backgroundColorGray)),
                                          ),
                                          helperText: ' ',
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .password,
                                          suffixIcon: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  Icons.info_outline,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  showAlertDialog(context);
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _passwordVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  color: Theme.of(context)
                                                      .primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _passwordVisible =
                                                        !_passwordVisible;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: _passwordController,
                                        obscureText: !_passwordVisible,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return '';
                                          }
                                          if (!RegExp(
                                                  r'^((?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])|(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[^a-zA-Z0-9])|(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9])|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9])).{8,}$')
                                              .hasMatch(value)) {
                                            return '';
                                          }

                                          return null;
                                        },
                                        onChanged: (value) => _password = value,
                                      ),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(60),
                                              backgroundColor: HexColor.fromHex(
                                                  AppColors.primaryColor),
                                              padding:
                                                  const EdgeInsets.all(20)),
                                          onPressed:
                                              _formKey.currentState != null
                                                  ? _formKey.currentState!
                                                              .validate() &&
                                                          !submitted
                                                      ? _submit
                                                      : null
                                                  : null,
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .continueCapital,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20))),
                                    ]),
                                  ),
                                ]))),
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
        ));
  }
}

showAlertDialog(BuildContext context) {
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
