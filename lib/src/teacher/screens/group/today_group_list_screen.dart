import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:teacher/src/shared/helpers/general_helpers.dart';
import 'package:teacher/src/shared/models/attendance_settings_model.dart';
import 'package:teacher/src/shared/models/dashboard_group_model.dart';
import 'package:teacher/src/shared/models/enums.dart';
import 'package:teacher/src/shared/services/school_service.dart';
import 'package:teacher/src/teacher/screens/group/attendance_screen.dart';

import '../../../shared/helpers/colors/hex_color.dart';
import '../../../shared/models/attendance_q_model.dart';
import '../../../shared/models/group_session_model.dart';
import '../../../shared/no_data.dart';
import '../../../shared/services/group_service.dart';
import '../../../shared/theme/colors/app_colors.dart';

class TodayGroupListScreen extends StatefulWidget {
  const TodayGroupListScreen({Key? key}) : super(key: key);

  @override
  State<TodayGroupListScreen> createState() => _TodayGroupListScreenState();
}

class _TodayGroupListScreenState extends State<TodayGroupListScreen>
    with AutomaticKeepAliveClientMixin {
  AttendanceSettingsModel? attendanceSettings;
  List<DashboardGroupModel>? classList;
  final SchoolService schoolService = SchoolService();
  final GroupService groupService = GroupService();
  bool completedTasks = false;

  AttendanceQModel createAttendanceQModel(GroupSessionModel groupSession) {
    var attendanceQModel = AttendanceQModel();
    attendanceQModel.group = groupSession.group;
    attendanceQModel.groupSession = groupSession;
    return attendanceQModel;
  }

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      await initializeTheData();
      completedTasks = true;
    });

    super.initState();
  }

  initializeTheData() async {
    await getAttendanceSettings();
    await getClasses();
  }

  getAttendanceSettings() async {
    var attendanceSettingsFuture = schoolService.getAttendanceSettings();
    await attendanceSettingsFuture.then((a) {
      setState(() {
        attendanceSettings = a;
      });
    });
  }

  getClasses() async {
    var classesFuture = groupService.getListOfTodaysGroups();
    await classesFuture.then((a) {
      setState(() {
        classList = a;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;

  bool canRecordAttendance(GroupSessionModel groupSession) {
    if (attendanceSettings != null) {
      if (attendanceSettings!.blockAttendanceNumberOfHours != null) {
        if (attendanceSettings!.blockAttendanceNumberOfHours! > 0) {
          final now = DateTime.now();
          final startThreshold = DateTime.parse(groupSession.startDate!)
              .subtract(Duration(
                  hours: attendanceSettings!.blockAttendanceNumberOfHours!));
          final endThreshold = DateTime.parse(groupSession.endDate!).add(
              Duration(
                  hours: attendanceSettings!.blockAttendanceNumberOfHours!));

          if (now.isBefore(startThreshold) || now.isAfter(endThreshold)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  canOpenAttendanceScreen(GroupSessionModel groupSession) {
    var result = false;
    if ((groupSession.sessionStatus != GroupSessionStatus.cancelled &&
            groupSession.sessionStatus != GroupSessionStatus.requested) &&
        canRecordAttendance(groupSession)) {
      result = true;
    }
    return result;
  }

  getColorCard(GroupSessionModel groupSession) {
    if (canOpenAttendanceScreen(groupSession)) {
      return HexColor.fromHex(AppColors.backgroundColorMintTulip);
    } else {
      return HexColor.fromHex(AppColors.backgroundColorAlto);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.listOfTodaysClasses),
          automaticallyImplyLeading: false,
        ),
        body: RefreshIndicator(
          color: HexColor.fromHex(AppColors.accentColor),
          backgroundColor: Theme.of(context).primaryColor,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            setState(() {
              completedTasks = false;
            });
            await getClasses();
            setState(() {
              completedTasks = true;
            });
          },
          child: completedTasks
              ? _buildBody(context)
              : GeneralHelpers.getCircularProgressIndicator(),
        ));
  }

  String getGroupTimeString(GroupSessionModel groupSession) {
    DateTime startDate = DateTime.parse(groupSession.startDate!).toLocal();
    DateTime endDate = DateTime.parse(groupSession.endDate!).toLocal();

    String formattedStartTime = formatDateTime(startDate, 'jm');
    String formattedEndTime = formatDateTime(endDate, 'jm');

    var result = formattedStartTime + "-" + formattedEndTime;
    return result;
  }

  String formatDateTime(DateTime dateTime, String format) {
    final formatter = DateFormat(format);
    return formatter.format(dateTime);
  }

  String getNoteString(GroupSessionModel groupSession) {
    var result = "";

    if (groupSession.teacherNotes != null) {
      if (groupSession.teacherNotes!.isNotEmpty) {
        result = groupSession.teacherNotes!;
      }
    } else if (groupSession.privateNote != null) {
      if (groupSession.privateNote!.isNotEmpty) {
        result = groupSession.privateNote!;
      }
    } else if (groupSession.note != null) {
      if (groupSession.note!.isNotEmpty) {
        result = groupSession.note!;
      }
    }

    return result;
  }

  String getSessionStatusString(
      GroupSessionModel groupSession, BuildContext context) {
    var result = "";
    if (groupSession.sessionStatus == GroupSessionStatus.cancelled) {
      result = AppLocalizations.of(context)!.cancelled;
    } else if (groupSession.sessionStatus == GroupSessionStatus.requested) {
      result = AppLocalizations.of(context)!.requested;
    }

    return result;
  }

  String getSessionNumbersString(GroupSessionModel groupSession) {
    var result = "";
    if (groupSession.sessionNumber != null &&
        groupSession.group!.numberOfSessions != null) {
      result = " (" +
          groupSession.sessionNumber.toString() +
          "/" +
          GeneralHelpers.formatNumber(groupSession.group!.numberOfSessions!) +
          ")";
    }
    return result;
  }

  Widget _buildBody(BuildContext context) {
    if (classList != null) {
      if (classList!.isNotEmpty) {
        return _buildClasses(context, classList);
      } else {
        return RefreshIndicator(
          child: Stack(
            children: <Widget>[
              Center(
                child: Text(AppLocalizations.of(context)!.noClass),
              ),
              ListView()
            ],
          ),
          onRefresh: () async {
            setState(() {});
          },
        );
      }
    } else {
      return RefreshIndicator(
        child: Stack(
          children: <Widget>[
            const Center(
              child: NoData(),
            ),
            ListView()
          ],
        ),
        onRefresh: () async {
          setState(() {});
        },
      );
    }
  }

  ListView _buildClasses(
      BuildContext context, List<DashboardGroupModel>? groupSessions) {
    return ListView.builder(
      itemCount: groupSessions!.length,
      padding: const EdgeInsets.only(top: 25, left: 35, right: 35, bottom: 25),
      itemBuilder: (context, index) {
        return Card(
            elevation: 4,
            color: getColorCard(groupSessions[index].groupSession!),
            child: ListTile(
              onTap: () {
                if (canOpenAttendanceScreen(
                    groupSessions[index].groupSession!)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                              attendanceQModel: createAttendanceQModel(
                                  groupSessions[index].groupSession!))));
                }
              },
              title: Container(
                  margin: const EdgeInsets.only(
                      left: 15, top: 25, bottom: 15, right: 15),
                  child: Text(
                    getGroupTimeString(groupSessions[index].groupSession!),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  )),
              subtitle: Container(
                  margin:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(groupSessions[index]
                                      .groupSession!
                                      .group!
                                      .title
                                      .toString() +
                                  getSessionNumbersString(
                                      groupSessions[index].groupSession!)),
                            ),
                          ]),
                      if (groupSessions[index].groupSession!.sessionStatus ==
                              GroupSessionStatus.cancelled ||
                          groupSessions[index].groupSession!.sessionStatus ==
                              GroupSessionStatus.requested)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(getSessionStatusString(
                                    groupSessions[index].groupSession!,
                                    context)),
                              ),
                            ]),
                      if (groupSessions[index].groupSession!.group?.contact !=
                          null)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Text(groupSessions[index]
                                          .groupSession!
                                          .group!
                                          .contact!
                                          .fullName!))),
                            ]),
                      if (groupSessions[index].groupSession!.group?.address !=
                          null)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Text(groupSessions[index]
                                          .groupSession!
                                          .group!
                                          .address!))),
                            ]),
                      if (groupSessions[index].groupSession!.teacherNotes !=
                              null ||
                          groupSessions[index].groupSession!.privateNote !=
                              null ||
                          groupSessions[index].groupSession!.note != null)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(getNoteString(
                                    groupSessions[index].groupSession!)),
                              ),
                            ]),
                    ],
                  )),
            ));
      },
    );
  }
}
