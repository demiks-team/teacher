import 'package:flutter/material.dart';

import 'package:teacher/l10n/app_localizations.dart';

import '../../shared-widgets/sign_out_dialog_widget.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.more),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 10),
          children: <Widget>[
            ListTile(
                onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SignOutDialogWidget(
                            title: AppLocalizations.of(context)!.signOut);
                      },
                    ),
                title: Text(AppLocalizations.of(context)!.signOut),
                minLeadingWidth: 10,
                leading: const Icon(Icons.logout)),
            const Divider(),
          ],
        )
        // )
        );
  }
}
