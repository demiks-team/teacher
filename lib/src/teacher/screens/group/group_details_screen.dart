import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teacher/l10n/app_localizations.dart';

import '../../../authentication/models/user_model.dart';
import '../../../shared/helpers/colors/hex_color.dart';
// import '../../../shared/helpers/colors/material_color.dart';
import '../../../shared/models/group_model.dart';
// import '../../../shared/no_data.dart';
import '../../../shared/secure_storage.dart';
import '../../../shared/services/group_service.dart';
import '../../../shared/theme/colors/app_colors.dart';
import 'widgets/group_details_tab/group_details_tab.dart';

class GroupDetailsScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  GroupModel? groupModel;
  final GroupService groupService = GroupService();
  UserModel? currentUser;
  int? type;
  bool completedTasks = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await initializeTheData();
      completedTasks = true;
    });
    super.initState();
  }

  Future<void> initializeTheData() async {
    await getCurrentUser();
    await loadClass();
    if (groupModel!.schoolId == currentUser!.schoolId) {
      setState(() {
        type = 2;
      });
    } else {
      setState(() {
        type = 1;
      });
    }
  }

  Future<void> loadClass() async {
    Future<GroupModel> futureClass = groupService.getGroup(widget.groupId);
    await futureClass.then((cm) {
      setState(() {
        groupModel = cm;
      });
    });
  }

  Future<void> getCurrentUser() async {
    await SecureStorage.getCurrentUser().then((u) => setState(() {
          currentUser = u;
        }));
  }

  Future<void> initializeTheBase() async {}

  @override
  Widget build(BuildContext context) {
    if (groupModel != null) {
      return Scaffold(
          body: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(groupModel!.title.toString()),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: HexColor.fromHex(AppColors.accentColor)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  iconTheme: IconThemeData(
                      color: HexColor.fromHex(AppColors.accentColor)),
                  bottom: TabBar(
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    indicatorColor: HexColor.fromHex(AppColors.primaryColor),
                    labelColor: Colors.grey,
                    tabs: <Widget>[
                      Tab(text: AppLocalizations.of(context)!.details),
                      Tab(text: AppLocalizations.of(context)!.students),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    if (type == 1)
                      GroupDetailsTab(groupModel: groupModel!)
                    else
                      Text("Edit Mode"),
                    Text("Students"),
                  ],
                ),
              )));
    } else {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: HexColor.fromHex(AppColors.accentColor),
        ),
      );
    }
  }
}
