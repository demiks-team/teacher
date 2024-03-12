import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/helpers/colors/hex_color.dart';
import '../../../shared/theme/colors/app_colors.dart';
import '../../screens/group/group_list_screen.dart';
import '../../screens/group/today_group_list_screen.dart';
import '../../screens/more/more_screen.dart';
import '../../screens/student/student_list_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List<Widget> _tabs = const <Widget>[
    TodayGroupListScreen(),
    StudentListScreen(),
    Text("Calendar"),
    Text("Availability"),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: HexColor.fromHex('#fafafa'),
            activeColor: HexColor.fromHex(AppColors.accentColor),
            inactiveColor: HexColor.fromHex(AppColors.backgroundColorGray),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard),
                label: AppLocalizations.of(context)!.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.assignment_ind),
                label: AppLocalizations.of(context)!.students,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.date_range),
                label: AppLocalizations.of(context)!.calendar,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.event_available),
                label: AppLocalizations.of(context)!.availability,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.widgets),
                label: AppLocalizations.of(context)!.more,
              ),
            ],
          ),
          tabBuilder: (BuildContext context, index) {
            return CupertinoTabView(
              builder: (BuildContext context) {
                return _tabs[index];
              },
            );
          }),
    );
  }
}
