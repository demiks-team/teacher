import 'package:flutter/material.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/switch_account_widget.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';

class SwitchAccountScreen extends StatelessWidget {
  const SwitchAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.switchAccount),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Flexible(child: SwitchAccountWidget())],
          ),
        ),
      ),
    );
  }
}
