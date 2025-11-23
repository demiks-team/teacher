import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:teacher/src/shared/helpers/general_helpers.dart';
import 'package:teacher/src/shared/models/attendance_settings_model.dart';
import 'package:teacher/src/shared/models/enums.dart';
import 'package:teacher/src/shared/services/school_service.dart';
import 'package:teacher/src/teacher/screens/group/attendance_screen.dart';

import '../../../shared/helpers/colors/hex_color.dart';
import '../../../shared/models/attendance_q_model.dart';
import '../../../shared/models/group_session_model.dart';
import '../../../shared/no_data.dart';
import '../../../shared/services/group_service.dart';
import '../../../shared/theme/colors/app_colors.dart';

class PastGroupSessionsWithoutAttendance extends StatefulWidget {
  const PastGroupSessionsWithoutAttendance({Key? key}) : super(key: key);

  @override
  State<PastGroupSessionsWithoutAttendance> createState() =>
      _PastGroupSessionsWithoutAttendance();
}

class _PastGroupSessionsWithoutAttendance
    extends State<PastGroupSessionsWithoutAttendance>
    with AutomaticKeepAliveClientMixin {
  AttendanceSettingsModel? attendanceSettings;
  List<GroupSessionModel>? groupSessionList;
  final SchoolService schoolService = SchoolService();
  final GroupService groupService = GroupService();
  bool completedTasks = false;

  AttendanceQModel createAttendanceQModel(GroupSessionModel groupSession) {
    var attendanceQModel = AttendanceQModel();
    attendanceQModel.group = groupSession.group;
    attendanceQModel.groupSession = groupSession;
    return attendanceQModel;
  }

  String getBreakTimeString(GroupSessionModel groupSession) {
    var result = "";
    if (groupSession.breakTimeInMinutes != null &&
        groupSession.breakTimeInMinutes! > 0) {
      result = AppLocalizations.of(context)!.breakTimeMinutesBreak.replaceAll(
              'value', groupSession.breakTimeInMinutes!.toString()) +
          "\n";
    }
    return result;
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
    completedTasks = false;
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
    var classesFuture = groupService.getPastSessionsGroupsWithoutAttendances();
    await classesFuture.then((a) {
      setState(() {
        groupSessionList = a;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.missedAttendances),
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

  String getGroupDateString(GroupSessionModel groupSession) {
    DateTime startDate = DateTime.parse(groupSession.startDate!).toLocal();
    DateTime endDate = DateTime.parse(groupSession.endDate!).toLocal();

    String formattedStartDate = formatDateTime(startDate, 'yyyy-MM-dd');
    String formattedStartTime = formatDateTime(startDate, 'jm');
    String formattedEndTime = formatDateTime(endDate, 'jm');

    var result =
        formattedStartDate + ", " + formattedStartTime + "-" + formattedEndTime;
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
      result = " (";
      result += groupSession.sessionNumber.toString();
      if (groupSession.group!.classDurationType !=
          ClassDurationType.rollingClass) {
        result += "/" +
            GeneralHelpers.formatNumber(groupSession.group!.numberOfSessions!);
      }
      result += ")";
    }
    return result;
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

  Widget _buildBody(BuildContext context) {
    if (groupSessionList != null) {
      if (groupSessionList!.isNotEmpty) {
        return _buildClasses(context, groupSessionList);
      } else {
        return RefreshIndicator(
          child: Stack(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.10),
                  child: Text(
                    AppLocalizations.of(context)!.missedAttendancesEmptyList,
                    textAlign: TextAlign.center, 
                  ),
                ),
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
      BuildContext context, List<GroupSessionModel>? groupSessions) {
    return ListView.builder(
      itemCount: groupSessions!.length,
      padding: const EdgeInsets.only(top: 25, left: 35, right: 35, bottom: 25),
      itemBuilder: (context, index) {
        return Card(
            elevation: 4,
            color: getColorCard(groupSessions[index]),
            child: ListTile(
              onTap: () async {
                if (canOpenAttendanceScreen(groupSessions[index])) {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                              attendanceQModel: createAttendanceQModel(
                                  groupSessions[index]))));
                  if (result == true) {
                    Future.delayed(Duration.zero, () async {
                      await initializeTheData();
                      completedTasks = true;
                    });
                  }
                }
              },
              title: Container(
                  margin: const EdgeInsets.only(
                      left: 15, top: 25, bottom: 15, right: 15),
                  child: Text(
                    getGroupDateString(groupSessions[index]),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  )),
              subtitle: Container(
                  margin:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    children: [
                      if (groupSessions[index].breakTimeInMinutes != null &&
                          groupSessions[index].breakTimeInMinutes! > 0)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  getBreakTimeString(groupSessions[index]),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              // padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(
                                  groupSessions[index].group!.title.toString() +
                                      getSessionNumbersString(
                                          groupSessions[index])),
                            ),
                          ]),
                      if (groupSessions[index].sessionStatus ==
                              GroupSessionStatus.cancelled ||
                          groupSessions[index].sessionStatus ==
                              GroupSessionStatus.requested)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Text(getSessionStatusString(
                                    groupSessions[index], context)),
                              ),
                            ]),
                      if (groupSessions[index].teacherNotes != null ||
                          groupSessions[index].privateNote != null ||
                          groupSessions[index].note != null)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child:
                                    Text(getNoteString(groupSessions[index])),
                              ),
                            ]),
                    ],
                  )),
            ));
      },
    );
  }
}
