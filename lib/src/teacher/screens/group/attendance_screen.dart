import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teacher/src/shared/models/attendance_creation_model.dart';
import 'package:teacher/src/shared/models/attendance_model.dart';
import 'package:teacher/src/shared/models/group_enrollment_model.dart';

import '../../../shared/helpers/colors/hex_color.dart';
import '../../../shared/helpers/colors/material_color.dart';
import '../../../shared/models/attendance_q_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/models/enums.dart';
import '../../../shared/models/level_model.dart';
import '../../../shared/services/general_service.dart';
import '../../../shared/services/group_service.dart';
import '../../../shared/theme/colors/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  final AttendanceQModel attendanceQModel;

  const AttendanceScreen({Key? key, required this.attendanceQModel})
      : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool completedTasks = false;
  final GroupService _groupService = GroupService();
  final GeneralService _generalService = GeneralService();

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      await initializeTheData();
      completedTasks = true;
    });

    super.initState();
  }

  AttendanceCreationModel? attendanceCreation;
  List<GroupEnrollmentModel> groupStudentsExceptSessionStudents = [];
  List<LevelModel> levels = [];

  List<int?> selectedLevelIds = [];

  initializeTheData() async {
    await getSessionStudents();
    await getGroupEnrollments();
    await getSchoolLevels();
  }

  getSessionStudents() async {
    Future<AttendanceCreationModel> getAttendanceCreation = _groupService
        .getSessionStudents(widget.attendanceQModel.groupSession!.id);
    await getAttendanceCreation.then((result) {
      setState(() {
        attendanceCreation = result;
        initializedTheForm();
      });
    });
  }

  initializedTheForm() {
    notesController = TextEditingController(text: attendanceCreation!.notes);
    for (var element in attendanceCreation!.attendances!) {
      selectedStatusValues.add(element.status ?? 3);
      studentNotesControllers
          .add(TextEditingController(text: element.notesForStudent));
      internalNotesControllers
          .add(TextEditingController(text: element.internalNotes));
      selectedLevelIds.add(element.studentLevelId);
    }
  }

  getGroupEnrollments() async {
    Future<List<GroupEnrollmentModel>> getGroupEnrollments =
        _groupService.getGroupEnrollments(widget.attendanceQModel.group!.id);
    await getGroupEnrollments.then((result) {
      setState(() {
        setGroupStudentsExceptSessionStudents(result);
      });
    });
  }

  getSchoolLevels() async {
    Future<List<LevelModel>> getLevels = _generalService.getSchoolLevels();
    await getLevels.then((result) {
      setState(() {
        levels = result;
      });
    });
  }

  void setGroupStudentsExceptSessionStudents(
      List<GroupEnrollmentModel> groupEnrollments) {
    groupStudentsExceptSessionStudents.addAll(groupEnrollments.where((ge) =>
        !attendanceCreation!.attendances!
            .any((a) => a.groupEnrollmentId == ge.id)));
  }

  void addStudentToAttendanceList(GroupEnrollmentModel groupEnrollment) {
    setState(() {
      var attendance = AttendanceModel(id: 0);
      attendance.groupEnrollmentId = groupEnrollment.id;
      attendance.groupEnrollment = groupEnrollment;
      attendance.groupSessionId = widget.attendanceQModel.groupSession!.id;
      attendance.status = AttendanceStatus.absent.index;
      attendance.studentLevelId = groupEnrollment.enrollment?.student?.levelId;

      selectedStatusValues.add(AttendanceStatus.absent.index);
      studentNotesControllers
          .add(TextEditingController(text: attendance.notesForStudent));
      internalNotesControllers
          .add(TextEditingController(text: attendance.internalNotes));
      selectedLevelIds.add(attendance.studentLevelId);

      attendanceCreation!.attendances!.add(attendance);
      groupStudentsExceptSessionStudents
          .removeWhere((s) => s.id == groupEnrollment.id);
    });
  }

  void onChangedAttendanceStatus(int value, int index) {
    setState(() {
      if (selectedStatusValues.length > index) {
        selectedStatusValues[index] = value;
      } else {
        selectedStatusValues.add(value);
      }
    });
  }

  void onChangedAttendanceStatusAll(int value) {
    setState(() {
      _selectedValue = value;
    });
    for (var index = 0;
        index < attendanceCreation!.attendances!.length;
        index++) {
      onChangedAttendanceStatus(value, index);
    }
  }

  bool isSaving = false;

  submit() async {
    var att = AttendanceCreationModel();
    att.attendances = [];
    att.groupSessionId = widget.attendanceQModel.groupSession!.id;

    att.notes = notesController!.value.text;

    for (int index = 0;
        index < attendanceCreation!.attendances!.length;
        index++) {
      var attendance =
          AttendanceModel(id: attendanceCreation!.attendances![index].id);

      attendance.groupEnrollment =
          attendanceCreation!.attendances![index].groupEnrollment;

      attendance.groupEnrollmentId =
          attendanceCreation!.attendances![index].groupEnrollmentId;

      attendance.status = selectedStatusValues[index];

      if (studentNotesControllers[index].value.text.isNotEmpty) {
        attendance.notesForStudent = studentNotesControllers[index].value.text;
      } else {
        attendance.notesForStudent = null;
      }

      if (internalNotesControllers[index].value.text.isNotEmpty) {
        attendance.internalNotes = internalNotesControllers[index].value.text;
      } else {
        attendance.internalNotes = null;
      }

      attendance.groupSessionId = widget.attendanceQModel.groupSession!.id;

      attendance.studentLevelId = selectedLevelIds[index];
      att.attendances!.add(attendance);
    }

    setState(() {
      isSaving = true;
    });
    await _groupService.saveAttendance(att).then((result) {
      if (result) {
        Navigator.pop(context);
      } else {
        setState(() {
          isSaving = false;
        });
      }
    });
  }

  List<int> selectedStatusValues = [];
  int _selectedValue = 0;

  List<TextEditingController> studentNotesControllers = [];
  List<TextEditingController> internalNotesControllers = [];
  TextEditingController? notesController;

  @override
  Widget build(BuildContext context) {
    if (completedTasks) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('fr', ''),
          ],
          theme: ThemeData(
              primarySwatch: buildMaterialColor(const Color(0xffffffff))),
          home: DefaultTabController(
              length: 4,
              child: Scaffold(
                  appBar: AppBar(
                    title:
                        Text(widget.attendanceQModel.group!.title!.toString()),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: HexColor.fromHex(AppColors.accentColor)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    iconTheme: IconThemeData(
                        color: HexColor.fromHex(AppColors.accentColor)),
                  ),
                  body: SingleChildScrollView(
                      child: Center(
                          child: Column(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            margin: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: TextField(
                              controller: notesController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.recordOfWork,
                                border: const OutlineInputBorder(),
                              ),
                            )),
                        Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            margin: const EdgeInsets.only(top: 10),
                            child: ToggleButtons(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      onChangedAttendanceStatusAll(0),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.snooze,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      onChangedAttendanceStatusAll(1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.alarm,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      onChangedAttendanceStatusAll(2),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.block,
                                      color: Colors.red),
                                  onPressed: () =>
                                      onChangedAttendanceStatusAll(3),
                                ),
                              ],
                              fillColor: Colors.grey.shade200,
                              isSelected: List.generate(
                                  4, (index) => index == _selectedValue),
                              onPressed: (int index) {
                                onChangedAttendanceStatusAll(_selectedValue);
                              },
                            )),
                        for (int index = 0;
                            index < attendanceCreation!.attendances!.length;
                            index++)
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Card(
                                  margin: const EdgeInsets.only(top: 30),
                                  child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: Text(attendanceCreation!
                                                  .attendances![index]
                                                  .groupEnrollment!
                                                  .enrollment!
                                                  .student!
                                                  .nameIdentification
                                                  .toString()),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: ToggleButtons(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.check,
                                                        color: Colors.blue),
                                                    onPressed: () =>
                                                        onChangedAttendanceStatus(
                                                            0, index),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.snooze,
                                                        color: Colors.orange),
                                                    onPressed: () =>
                                                        onChangedAttendanceStatus(
                                                            1, index),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.alarm,
                                                        color: Colors.orange),
                                                    onPressed: () =>
                                                        onChangedAttendanceStatus(
                                                            2, index),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.block,
                                                        color: Colors.red),
                                                    onPressed: () =>
                                                        onChangedAttendanceStatus(
                                                            3, index),
                                                  ),
                                                ],
                                                fillColor: Colors.grey.shade200,
                                                isSelected: List.generate(
                                                    4,
                                                    (i) =>
                                                        selectedStatusValues[
                                                            index] ==
                                                        i),
                                                onPressed: (int i) {
                                                  onChangedAttendanceStatus(
                                                      i, index);
                                                },
                                              ),
                                            ),
                                            TextField(
                                              controller:
                                                  studentNotesControllers[
                                                      index],
                                              decoration: InputDecoration(
                                                  labelText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .studentNote),
                                            ),
                                            TextField(
                                              controller:
                                                  internalNotesControllers[
                                                      index],
                                              decoration: InputDecoration(
                                                  labelText:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .internalNote),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: DropdownButtonFormField<
                                                    int>(
                                                  value: attendanceCreation!
                                                      .attendances![index]
                                                      .studentLevelId,
                                                  items: levels.map((level) {
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: level.id,
                                                      child: Text(level.title!
                                                          .toString()),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() => {
                                                          selectedLevelIds[
                                                              index] = value
                                                        });
                                                  },
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .level),
                                                )),
                                          ])))),
                      ],
                    ),
                    if (groupStudentsExceptSessionStudents.isNotEmpty)
                      for (var groupEnrollment
                          in groupStudentsExceptSessionStudents)
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: Card(
                                margin: const EdgeInsets.only(top: 30),
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text(AppLocalizations.of(
                                                    context)!
                                                .addOtherStudentsToAttendanceList),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    addStudentToAttendanceList(
                                                        groupEnrollment);
                                                  },
                                                  icon: const Icon(Icons
                                                      .add), // Add icon to the button
                                                  color: HexColor.fromHex(AppColors
                                                      .primaryColor) // Set icon color to white
                                                  ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Text(groupEnrollment
                                                    .enrollment!
                                                    .student!
                                                    .nameIdentification!),
                                              ),
                                            ],
                                          )
                                        ])))),
                    Container(
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(60),
                                      backgroundColor: HexColor.fromHex(
                                          AppColors.primaryColor),
                                      padding: const EdgeInsets.all(20)),
                                  onPressed: isSaving
                                      ? null
                                      : () async {
                                          await submit();
                                        },
                                  child: Text(
                                      AppLocalizations.of(context)!.save,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20))))),
                    ),
                  ]))))));
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
