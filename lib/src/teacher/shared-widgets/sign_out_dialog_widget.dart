import 'package:flutter/material.dart';
import 'package:teacher/l10n/app_localizations.dart';
import '../../shared/helpers/colors/hex_color.dart';
import '../../shared/secure_storage.dart';
import '../../shared/theme/colors/app_colors.dart';
import '../../site/screens/login_screen.dart';


class SignOutDialogWidget extends StatelessWidget {
  const SignOutDialogWidget({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(AppLocalizations.of(context)!.areYouSure),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
              backgroundColor: HexColor.fromHex(AppColors.accentColor)),
          onPressed: () {
            SecureStorage.removeCurrentUser();
            Navigator.of(context, rootNavigator: true)
                .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          child: Text(AppLocalizations.of(context)!.yes),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
