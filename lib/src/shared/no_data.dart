import 'package:flutter/material.dart';
import 'package:teacher/l10n/app_localizations.dart';

class NoData extends StatelessWidget {
  const NoData({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.comment),
        Text(
          AppLocalizations.of(context)!.noData,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Image.asset('assets/images/arrow.jpg')
      ],
    );
  }
}
