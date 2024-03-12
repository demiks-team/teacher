import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

class _TodayGroupListScreenState extends State<TodayGroupListScreen> {
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
          title: Text(AppLocalizations.of(context)!.classes),
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

  FutureBuilder<List<GroupSessionModel>> _buildBody(BuildContext context) {
    final GroupService groupService = GroupService();
    return FutureBuilder<List<GroupSessionModel>>(
      future: groupService.getListOfTodaysGroups(),
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
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AttendanceScreen(
                            attendanceQModel:
                                createAttendanceQModel(groupSessions[index]))));
              },
              title: Container(
                  margin: const EdgeInsets.only(
                      left: 15, top: 25, bottom: 15, right: 15),
                  child: Text(
                    groupSessions[index].group!.title.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  )),
              // subtitle: Container(
              //     margin:
              //         const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              //     child: Column(
              //       children: [
              //         Row(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.only(top: 5, bottom: 5),
              //                 child:
              //                     Text(groups[index].school!.name.toString()),
              //               ),
              //             ]),
              //         if (groups[index].teacher != null)
              //           Row(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               children: [
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.only(top: 5, bottom: 5),
              //                   child: Text(
              //                       groups[index].teacher!.fullName.toString()),
              //                 ),
              //               ]),
              //         if (groups[index].course != null)
              //           Row(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               children: [
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.only(top: 5, bottom: 5),
              //                   child:
              //                       Text(groups[index].course!.name.toString()),
              //                 ),
              //               ]),
              //         if (groups[index].room != null)
              //           Row(
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               children: [
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.only(top: 5, bottom: 5),
              //                   child:
              //                       Text(groups[index].room!.title.toString()),
              //                 ),
              //               ]),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.end,
              //           children: const <Widget>[
              //             Icon(Icons.link, size: 30),
              //           ],
              //         ),
              //       ],
              //     )),
            ));
      },
    );
  }
}
