import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/authentication/services/authentication_service.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/models/user_school_model.dart';
import 'package:teacher/src/shared/services/user_service.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';
import 'package:teacher/src/teacher/shared-widgets/menu/bottom_navigation.dart';

class SwitchAccountWidget extends StatefulWidget {
  final bool? canSelectOnCurrentSchool;

  const SwitchAccountWidget({super.key, this.canSelectOnCurrentSchool = false});

  @override
  State<SwitchAccountWidget> createState() => _SwitchAccountWidgetState();
}

class _SwitchAccountWidgetState extends State<SwitchAccountWidget> {
  final userService = UserService();
  final authService = AuthenticationService();

  List<UserSchoolModel> schools = [];
  bool loading = true;
  bool switching = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  Future<void> loadSchools() async {
    schools = await userService.getUserSchools();

    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> switchAccount(int schoolId) async {
    setState(() => switching = true);

    await authService.switchAccount(schoolId);

    if (!mounted) return;

    setState(() => switching = false);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BottomNavigation()),
      (route) => false,
    );
  }

  String getLogoUrl(UserSchoolModel school) {
    if (school.logoImageName == null) return "";
    return "${dotenv.env['demiks']}images/schools/logo/${school.logoImageName}";
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: schools.length,
      itemBuilder: (_, i) {
        final school = schools[i];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),

            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: school.logoImageName != null
                  ? NetworkImage(getLogoUrl(school))
                  : null,
              child: school.logoImageName == null
                  ? const Icon(Icons.school, size: 30, color: Colors.white)
                  : null,
            ),

            title: Text("${AppLocalizations.of(context)!.joinSchool} ${school.name!}"),

            trailing: school.isCurrentSchool == true
                ? Icon(
                    Icons.check_circle,
                    color: HexColor.fromHex(AppColors.primaryColor),
                  )
                : null,

            onTap: (widget.canSelectOnCurrentSchool != true && school.isCurrentSchool == true) || switching
                ? null
                : () => switchAccount(school.id),
          ),
        );
      },
    );
  }
}
