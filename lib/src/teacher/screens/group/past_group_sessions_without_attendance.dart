import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:teacher/src/shared/models/enums.dart';
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
    extends State<PastGroupSessionsWithoutAttendance> {
  AttendanceQModel createAttendanceQModel(GroupSessionModel groupSession) {
    var attendanceQModel = AttendanceQModel();
    attendanceQModel.group = groupSession.group;
    attendanceQModel.groupSession = groupSession;
    return attendanceQModel;
  }

  @override
  Widget build(BuildContext context) {
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
            setState(() {});
          },
          child: _buildBody(context),
        ));
  }

  String getGroupDateString(GroupSessionModel groupSession) {
    DateTime startDate = DateTime.parse(groupSession.startDate!);
    DateTime endDate = DateTime.parse(groupSession.endDate!);

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
      result = " (" +
          groupSession.sessionNumber.toString() +
          "/" +
          groupSession.group!.numberOfSessions.toString() +
          ")";
    }
    return result;
  }

  FutureBuilder<List<GroupSessionModel>> _buildBody(BuildContext context) {
    final GroupService groupService = GroupService();
    return FutureBuilder<List<GroupSessionModel>>(
      future: groupService.getPastSessionsGroupsWithoutAttendances(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<GroupSessionModel>? classes = snapshot.data;
          if (classes != null) {
            if (classes.isNotEmpty) {
              return _buildClasses(context, classes);
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
        } else {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: HexColor.fromHex(AppColors.accentColor),
            ),
          );
        }
      },
    );
  }

  ListView _buildClasses(
      BuildContext context, List<GroupSessionModel>? groupSessions) {
    return ListView.builder(
      itemCount: groupSessions!.length,
      padding: const EdgeInsets.only(top: 25, left: 35, right: 35, bottom: 25),
      itemBuilder: (context, index) {
        return Card(
            elevation: 4,
            color: HexColor.fromHex(AppColors.backgroundColorMintTulip),
            child: ListTile(
              onTap: () async {
                if (groupSessions[index].sessionStatus !=
                        GroupSessionStatus.cancelled &&
                    groupSessions[index].sessionStatus !=
                        GroupSessionStatus.requested) {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                              attendanceQModel: createAttendanceQModel(
                                  groupSessions[index]))));

                  if (result == true) {
                    setState(() {});
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
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
