import 'package:flutter/material.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/switch_account_widget.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';
import 'package:teacher/src/teacher/shared-widgets/sign_out_dialog_widget.dart';

class ConfigurationScreen extends StatelessWidget {
  final bool? canSelectOnCurrentSchool;

  const ConfigurationScreen({super.key, this.canSelectOnCurrentSchool = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.pickOption,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: SwitchAccountWidget(canSelectOnCurrentSchool: true),
              ),

              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!.signOut,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(
                        MediaQuery.of(context).size.height * 0.1,
                      ),
                      backgroundColor: HexColor.fromHex(
                        AppColors.backgroundColorGray,
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => SignOutDialogWidget(
                        title: AppLocalizations.of(context)!.signOut,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
