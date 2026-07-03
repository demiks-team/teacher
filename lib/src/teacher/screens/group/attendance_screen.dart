import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/shared/models/attendance_creation_model.dart';
import 'package:teacher/src/shared/models/attendance_model.dart';
import 'package:teacher/src/shared/models/chapter_model.dart';
import 'package:teacher/src/shared/models/group_enrollment_model.dart';
import 'package:teacher/src/shared/services/book_service.dart';

import '../../../shared/helpers/colors/hex_color.dart';
import '../../../shared/helpers/colors/material_color.dart';
import '../../../shared/models/attendance_q_model.dart';
// import 'package:flutter/material.dart';

import '../../../shared/models/enums.dart';
import '../../../shared/models/level_model.dart';
import '../../../shared/models/progress_area_group_filter_model.dart';
import '../../../shared/services/general_service.dart';
import '../../../shared/services/group_service.dart';
import '../../../shared/services/student_progress_area_service.dart';
import '../../../shared/theme/colors/app_colors.dart';
import 'student_progress_area_screen.dart';

class AttendanceScreen extends StatefulWidget {
  final AttendanceQModel attendanceQModel;

  const AttendanceScreen({super.key, required this.attendanceQModel});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool completedTasks = false;
  final GroupService _groupService = GroupService();
  final GeneralService _generalService = GeneralService();
  final BookService _bookService = BookService();
  final StudentProgressAreaService _progressAreaService = StudentProgressAreaService();
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      await initializeTheData();
      completedTasks = true;
    });

    super.initState();
  }

  AttendanceCreationModel? attendanceCreation;
  AttendanceCreationModel? mainAttendanceCreation;
  List<GroupEnrollmentModel> groupStudentsExceptSessionStudents = [];
  List<LevelModel> levels = [];
  List<LevelModel> dropdownLevels = [];

  List<int?> selectedLevelIds = [];

  List<ChapterModel> chapters = [];
  List<ChapterModel> dropdownChapters = [];
  int sessionDuration = 0;

  List<TextEditingController> absenceInMinutesControllers = [];

  Future<void> initializeTheData() async {
    await getSessionStudents();
    await getGroupEnrollments();
    await getSchoolLevels();

    if (widget.attendanceQModel.group!.bookId != null) {
      if (widget.attendanceQModel.group!.bookId! > 0) {
        await getChapters();
      }
    }

    final startStr = widget.attendanceQModel.groupSession!.startDate;
    final endStr = widget.attendanceQModel.groupSession!.endDate;

    final DateTime start = DateTime.parse(startStr.toString());
    final DateTime end = DateTime.parse(endStr.toString());

    final int breakTime =
        widget.attendanceQModel.groupSession?.breakTimeInMinutes ?? 0;

    sessionDuration =
        ((end.millisecondsSinceEpoch - start.millisecondsSinceEpoch) ~/ 60000) -
        breakTime;

    if (sessionDuration < 0) sessionDuration = 0; 
  }

  Future<void> getSessionStudents() async {
    Future<AttendanceCreationModel> getAttendanceCreation = _groupService
        .getSessionStudents(widget.attendanceQModel.groupSession!.id);
    await getAttendanceCreation.then((result) {
      setState(() {
        attendanceCreation = result;
        var cloneJson = jsonEncode(result.toJson());
        var clone = AttendanceCreationModel.fromJson(jsonDecode(cloneJson));
        mainAttendanceCreation = clone;
        initializedTheForm();
      });
    });
  }

  void initializedTheForm() {
    notesController = TextEditingController(text: attendanceCreation!.notes);
    for (var element in attendanceCreation!.attendances!) {
      selectedStatusValues.add(element.status ?? 3);
      studentNotesControllers.add(
        TextEditingController(text: element.notesForStudent),
      );
      internalNotesControllers.add(
        TextEditingController(text: element.internalNotes),
      );
      selectedLevelIds.add(element.levelId);

      final ctrl = TextEditingController(
        text: element.absenceInMinutes != null
            ? element.absenceInMinutes.toString()
            : '',
      );
      ctrl.addListener(() {
        setState(() {});
      });
      absenceInMinutesControllers.add(ctrl);
    }
  }

  Future<void> getGroupEnrollments() async {
    Future<List<GroupEnrollmentModel>> getGroupEnrollments = _groupService
        .getGroupEnrollments(widget.attendanceQModel.group!.id);
    await getGroupEnrollments.then((result) {
      setState(() {
        setGroupStudentsExceptSessionStudents(result);
      });
    });
  }

  Future<void> getSchoolLevels() async {
    Future<List<LevelModel>> getLevels = _generalService.getSchoolLevels();
    await getLevels.then((result) {
      setState(() {
        levels = result;
        LevelModel newLevel = LevelModel(id: 0);
        newLevel.title = "---";
        dropdownLevels.add(newLevel);
        dropdownLevels.addAll(levels);
      });
    });
  }

  bool hasAnyChapter = false;
  Future<void> getChapters() async {
    Future<List<ChapterModel>> getChapters = _bookService.getChapters(
      widget.attendanceQModel.group!.bookId!,
    );
    await getChapters.then((result) {
      setState(() {
        chapters = result;
        ChapterModel newChapter = ChapterModel(id: null);
        newChapter.title = "---";
        dropdownChapters.add(newChapter);
        dropdownChapters.addAll(chapters);
        if (chapters.isNotEmpty) {
          hasAnyChapter = true;
        }
        if (widget.attendanceQModel.groupSession!.chapterId != null) {
          if (widget.attendanceQModel.groupSession!.chapterId! > 0) {
            _selectedChapterValue =
                widget.attendanceQModel.groupSession!.chapterId;
          }
        }
      });
    });
  }

  void setGroupStudentsExceptSessionStudents(
    List<GroupEnrollmentModel> groupEnrollments,
  ) {
    groupStudentsExceptSessionStudents.addAll(
      groupEnrollments.where(
        (ge) => !attendanceCreation!.attendances!.any(
          (a) => a.groupEnrollmentId == ge.id,
        ),
      ),
    );
  }

  void addStudentToAttendanceList(GroupEnrollmentModel groupEnrollment) {
    setState(() {
      var attendance = AttendanceModel(id: 0);
      attendance.groupEnrollmentId = groupEnrollment.id;
      attendance.groupEnrollment = groupEnrollment;
      attendance.groupSessionId = widget.attendanceQModel.groupSession!.id;
      attendance.status = AttendanceStatus.absent.index;
      attendance.levelId = groupEnrollment.enrollment?.student?.levelId;

      selectedStatusValues.add(AttendanceStatus.absent.index);
      studentNotesControllers.add(
        TextEditingController(text: attendance.notesForStudent),
      );
      internalNotesControllers.add(
        TextEditingController(text: attendance.internalNotes),
      );
      selectedLevelIds.add(attendance.levelId);

      absenceInMinutes.add(TextEditingController());

      attendanceCreation!.attendances!.add(attendance);
      groupStudentsExceptSessionStudents.removeWhere(
        (s) => s.id == groupEnrollment.id,
      );
    });
  }

  void removeStudentFromAttendanceList(
    int index,
    GroupEnrollmentModel groupEnrollment,
  ) {
    setState(() {
      groupStudentsExceptSessionStudents.add(groupEnrollment);

      if (attendanceCreation?.attendances != null &&
          index < attendanceCreation!.attendances!.length) {
        attendanceCreation!.attendances!.removeAt(index);
      }

      if (index < selectedStatusValues.length) {
        selectedStatusValues.removeAt(index);
      }

      if (index < selectedLevelIds.length) {
        selectedLevelIds.removeAt(index);
      }

      if (index < studentNotesControllers.length) {
        studentNotesControllers.removeAt(index);
      }

      if (index < internalNotesControllers.length) {
        internalNotesControllers.removeAt(index);
      }

      if (index < absenceInMinutes.length) {
        absenceInMinutes.removeAt(index);
      }
    });
  }

  void onChangedAttendanceStatus(int value, int index) {
    setState(() {
      if (index < selectedStatusValues.length) {
        selectedStatusValues[index] = value;
      } else {
        selectedStatusValues.add(value);
      }

      while (absenceInMinutesControllers.length <= index) {
        final ctrl = TextEditingController();
        ctrl.addListener(() => setState(() {}));
        absenceInMinutesControllers.add(ctrl);
      }

      final absenceCtrl = absenceInMinutesControllers[index];
      // final attendanceItem = attendanceCreation!.attendances![index];

      switch (value) {
        case 0: // onTime
          absenceCtrl.text = '0';
          break;

        case 3:
          // if (sessionDuration != null) {
          absenceCtrl.text = sessionDuration.toString();
          // }
          break;

        // case 1:
        // case 2:
        //   if (attendanceItem.id > 0 &&
        //       attendanceItem.absenceInMinutes != null) {
        //     absenceCtrl.text = attendanceItem.absenceInMinutes.toString();
        //   } else {
        //     absenceCtrl.clear();
        //   }
        //   break;

        default:
          absenceCtrl.clear();
          break;
      }

      _formKey.currentState?.validate();
    });
  }

  void onChangedAttendanceStatusAll(int value) {
    setState(() {
      _selectedValue = value;

      final rows = attendanceCreation!.attendances!.length;

      if (selectedStatusValues.length != rows) {
        selectedStatusValues = List.filled(rows, value);
      } else {
        for (int i = 0; i < rows; i++) {
          selectedStatusValues[i] = value;
        }
      }

      for (int i = 0; i < rows; i++) {
        while (absenceInMinutesControllers.length <= i) {
          final ctrl = TextEditingController();
          ctrl.addListener(() => setState(() {}));
          absenceInMinutesControllers.add(ctrl);
        }

        final absenceCtrl = absenceInMinutesControllers[i];
        // final attendanceItem = attendanceCreation!.attendances![i];

        switch (value) {
          case 0: // onTime
            absenceCtrl.text = '0';
            break;

          case 3: // Absent
            // if (sessionDuration != null) {
            absenceCtrl.text = sessionDuration.toString();
            // }
            break;

          // case 1: // Late
          // case 2: // Partial
          //   if (attendanceItem.id > 0 &&
          //       attendanceItem.absenceInMinutes != null) {
          //     absenceCtrl.text = attendanceItem.absenceInMinutes.toString();
          //   } else {
          //     absenceCtrl.clear();
          //   }
          //   break;

          default:
            absenceCtrl.clear();
            break;
        }

        _formKey.currentState?.validate();
      }
    });
  }

  void onChangedAttendanceLevel(int value, int index) {
    setState(() {
      if (index < selectedLevelIds.length) {
        selectedLevelIds[index] = value;
      } else if (index == selectedLevelIds.length) {
        selectedLevelIds.add(value);
      }
    });
  }

  void onChangedAttendanceLevelAll(int? value) {
    setState(() {
      _selectedLevelValue = value;

      if (selectedLevelIds.length != attendanceCreation!.attendances!.length) {
        selectedLevelIds = List.filled(
          attendanceCreation!.attendances!.length,
          value,
        );
      } else {
        for (int i = 0; i < selectedLevelIds.length; i++) {
          selectedLevelIds[i] = value;
        }
      }

      changeAllLevels(value);
    });
  }

  void changeAllLevels(int? selectedLevel) {
    if (selectedLevel == 0) {
      selectedLevel = null;
    }
    for (int i = 0; i <= mainAttendanceCreation!.attendances!.length - 1; i++) {
      int? currentLevelId = mainAttendanceCreation!.attendances![i].levelId;

      if (currentLevelId != null && selectedLevel == null) {
        continue;
      }

      int? result = selectedLevel;
      if (selectedLevel != null &&
          selectedLevel > 0 &&
          currentLevelId != null &&
          currentLevelId > 0) {
        List<LevelModel> allowedLevels = getAllowedLevelsForStudent(
          currentLevelId,
        );

        if (!allowedLevels.any((level) => level.id == selectedLevel)) {
          result = currentLevelId;
        }
      }

      if (currentLevelId != null &&
          mainAttendanceCreation!.attendances![i].levelId != null) {
        if (mainAttendanceCreation!.attendances![i].levelId != null) {
          LevelModel? oldLevel = levels.firstWhere(
            (l) => l.id == mainAttendanceCreation!.attendances![i].levelId,
          );
          LevelModel? newLevel = levels.firstWhere(
            (l) => l.id == currentLevelId,
          );

          if (oldLevel.displayOrder == null ||
              (oldLevel.displayOrder! <= newLevel.displayOrder!)) {
            if (i < selectedLevelIds.length) {
              selectedLevelIds[i] = result;
              attendanceCreation!.attendances![i].levelId = result;
            }
          }
        }
      } else {
        if (i < selectedLevelIds.length) {
          selectedLevelIds[i] = result;
          attendanceCreation!.attendances![i].levelId = result;
        }
      }
    }
  }

  List<LevelModel> getAllowedLevelsForStudent(int? currentLevelId) {
    if (currentLevelId != null) {
      LevelModel? level = dropdownLevels.firstWhere(
        (l) => l.id == currentLevelId,
      );
      var levelDisplayOrder = level.displayOrder ?? 0;
      return levels
          .where(
            (l) =>
                l.displayOrder == null || l.displayOrder! >= levelDisplayOrder,
          )
          .toList();
    }
    return dropdownLevels;
  }

  String getBookhint() {
    var result = "";
    if (widget.attendanceQModel.group!.book != null) {
      result =
          "${AppLocalizations.of(context)!.bookNameAttendanceHint.replaceAll('bookName', widget.attendanceQModel.group!.book!.title.toString())}\n";
    }
    return result;
  }

  bool isSaving = false;

  Future<void> submit() async {
    var att = AttendanceCreationModel();
    att.attendances = [];
    att.groupSessionId = widget.attendanceQModel.groupSession!.id;
    att.chapterId = _selectedChapterValue;

    att.notes = notesController!.value.text;

    for (
      int index = 0;
      index < attendanceCreation!.attendances!.length;
      index++
    ) {
      var attendance = AttendanceModel(
        id: attendanceCreation!.attendances![index].id,
      );

      attendance.groupEnrollment =
          attendanceCreation!.attendances![index].groupEnrollment;

      attendance.absenceInMinutes =
          absenceInMinutesControllers[index].text.isNotEmpty
          ? int.tryParse(absenceInMinutesControllers[index].text)
          : null;

      attendance.groupEnrollmentId =
          attendanceCreation!.attendances![index].groupEnrollmentId;

      attendance.status = index < selectedStatusValues.length
          ? selectedStatusValues[index]
          : AttendanceStatus.absent.index;

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

      attendance.levelId = index < selectedLevelIds.length
          ? selectedLevelIds[index]
          : null;

      // NOTE: If you want to save absenceInMinutes to the model, add a field
      // to AttendanceModel and assign it here, e.g.:
      // attendance.absenceInMinutes = int.tryParse(absenceInMinutes[index].text);

      att.attendances!.add(attendance);
    }

    setState(() {
      isSaving = true;
    });
    try {
      await _groupService.saveAttendance(att);
      if (!mounted) return;

      bool hasProgressAreas = false;
      try {
        hasProgressAreas = await _progressAreaService.hasAnyProgressArea(
            widget.attendanceQModel.group!.courseId);
      } catch (e) {
        debugPrint('hasAnyProgressArea error: $e');
        hasProgressAreas = false;
      }

      if (!mounted) return;

      if (hasProgressAreas) {
        try {
          final groupEnrollmentIds = att.attendances!
              .where((a) => a.groupEnrollmentId != null)
              .map((a) => a.groupEnrollmentId!)
              .toList();

          final filter = ProgressAreaGroupFilterModel(
            groupSessionId: widget.attendanceQModel.groupSession!.id,
            groupEnrollmentIds: groupEnrollmentIds,
          );

          final progressAreaData =
              await _progressAreaService.getAttendanceStudentProgressAreas(filter);

          if (!mounted) return;

          final hasStudents =
              progressAreaData.progressAreaGroupSessionStudents?.isNotEmpty ==
                  true;

          if (hasStudents) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentProgressAreaScreen(
                  groupTitle:
                      widget.attendanceQModel.group!.title ?? '',
                  progressAreaGroupSession: progressAreaData,
                ),
              ),
            );
            return;
          }
        } catch (e) {
          debugPrint('getAttendanceStudentProgressAreas error: $e');
          // fall through to normal pop
        }
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });
    }
  }

  List<int> selectedStatusValues = [];
  int _selectedValue = 0;
  int? _selectedLevelValue;

  List<TextEditingController> studentNotesControllers = [];
  List<TextEditingController> internalNotesControllers = [];
  TextEditingController? notesController;

  // <-- CHANGED VARIABLE: renamed from numberInputControllers to absenceInMinutes
  List<TextEditingController> absenceInMinutes = [];

  int? _selectedChapterValue;
  void onChangedAttendanceChapterAll(int? value) {
    setState(() {
      _selectedChapterValue = value;
      changeAllChapters(value);
    });
  }

  void changeAllChapters(int? value) {
    if (value != null) {
      if (value > 0) {
        var chapter = chapters.firstWhere((c) => c.id == value);
        if (chapter.levelId != null) {
          if (chapter.levelId! > 0) {
            var level = levels.firstWhere((l) => l.id == chapter.levelId);

            for (
              var index = 0;
              index < attendanceCreation!.attendances!.length;
              index++
            ) {
              selectedLevelIds[index] = level.id;
            }

            changeAllLevels(level.id);
          }
        }
      }
    } else {
      changeAllLevels(null);
    }
  }

  bool isFormValid() {
    if (attendanceCreation == null) return false;

    final rows = attendanceCreation!.attendances!.length;

    for (int i = 0; i < rows; i++) {
      final status = (i < selectedStatusValues.length)
          ? selectedStatusValues[i]
          : AttendanceStatus.absent.index;

      if (status == 1 || status == 2) {
        final text = (i < absenceInMinutesControllers.length)
            ? absenceInMinutesControllers[i].text.trim()
            : '';
        if (text.isEmpty) return false;
        final parsed = int.tryParse(text);
        if (parsed == null) return false;
        if (parsed > sessionDuration) return false;
      }
    }

    return true;
  }

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
          primarySwatch: buildMaterialColor(const Color(0xffffffff)),
        ),
        home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.attendanceQModel.group!.title!.toString()),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: HexColor.fromHex(AppColors.accentColor),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              iconTheme: IconThemeData(
                color: HexColor.fromHex(AppColors.accentColor),
              ),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            margin: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * 0.90,
                            child: TextFormField(
                              controller: notesController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.recordOfWork,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (hasAnyChapter)
                            Column(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  margin: EdgeInsets.only(
                                    bottom: 2,
                                    top:
                                        MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  child: Text(getBookhint()),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: DropdownButtonFormField<int>(
                                    isExpanded: false,
                                    initialValue: _selectedChapterValue,
                                    items: dropdownChapters.map((chapter) {
                                      return DropdownMenuItem<int>(
                                        value: chapter.id,
                                        child: Text(chapter.title!.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                        () => onChangedAttendanceChapterAll(
                                          value,
                                        ),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.chapters,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (attendanceCreation!.attendances!.length > 1)
                            Builder(builder: (context) {
                              final showLate = widget.attendanceQModel.showLateAttendance != false;
                              final showLeftEarly = widget.attendanceQModel.showLeftEarlyAttendance != false;
                              final visibleStatuses = [0, if (showLate) 1, if (showLeftEarly) 2, 3];
                              return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: ToggleButtons(
                                    fillColor: Colors.grey.shade200,
                                    isSelected: [
                                      _selectedValue == 0,
                                      if (showLate) _selectedValue == 1,
                                      if (showLeftEarly) _selectedValue == 2,
                                      _selectedValue == 3,
                                    ],
                                    onPressed: (int index) {
                                      onChangedAttendanceStatusAll(visibleStatuses[index]);
                                    },
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () =>
                                            onChangedAttendanceStatusAll(0),
                                      ),
                                      if (showLate) IconButton(
                                        icon: const Icon(
                                          Icons.snooze,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () =>
                                            onChangedAttendanceStatusAll(1),
                                      ),
                                      if (showLeftEarly) IconButton(
                                        icon: const Icon(
                                          Icons.alarm,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () =>
                                            onChangedAttendanceStatusAll(2),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.block,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            onChangedAttendanceStatusAll(3),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  margin: const EdgeInsets.only(bottom: 5),
                                  child: DropdownButtonFormField<int>(
                                    isExpanded: false,
                                    initialValue: _selectedLevelValue,
                                    items: dropdownLevels.map((level) {
                                      return DropdownMenuItem<int>(
                                        value: level.id,
                                        child: Text(level.title!.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(
                                        () =>
                                            onChangedAttendanceLevelAll(value),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.level,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          for (
                            int index = 0;
                            index < attendanceCreation!.attendances!.length;
                            index++
                          )
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Card(
                                color: HexColor.fromHex(
                                  AppColors.backgroundColorMintTulip,
                                ),
                                margin: const EdgeInsets.only(top: 30),
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              removeStudentFromAttendanceList(
                                                index,
                                                attendanceCreation!
                                                    .attendances![index]
                                                    .groupEnrollment!,
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.remove,
                                            ), // Add icon to the button
                                            color: HexColor.fromHex(
                                              AppColors.primaryColor,
                                            ), // Set icon color to white
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                              bottom: 5,
                                            ),
                                            child: Text(
                                              attendanceCreation!
                                                  .attendances![index]
                                                  .groupEnrollment!
                                                  .enrollment!
                                                  .student!
                                                  .nameIdentification
                                                  .toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Builder(builder: (context) {
                                        final currentStatus = selectedStatusValues[index];
                                        final showLate = widget.attendanceQModel.showLateAttendance != false || currentStatus == 1;
                                        final showLeftEarly = widget.attendanceQModel.showLeftEarlyAttendance != false || currentStatus == 2;
                                        final visibleStatuses = [0, if (showLate) 1, if (showLeftEarly) 2, 3];
                                        return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: ToggleButtons(
                                          fillColor: Colors.grey.shade200,
                                          isSelected: [
                                            selectedStatusValues[index] == 0,
                                            if (showLate) selectedStatusValues[index] == 1,
                                            if (showLeftEarly) selectedStatusValues[index] == 2,
                                            selectedStatusValues[index] == 3,
                                          ],
                                          onPressed: (int i) {
                                            onChangedAttendanceStatus(visibleStatuses[i], index);
                                          },
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.check,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () =>
                                                  onChangedAttendanceStatus(
                                                    0,
                                                    index,
                                                  ),
                                            ),
                                            if (showLate) IconButton(
                                              icon: const Icon(
                                                Icons.snooze,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () =>
                                                  onChangedAttendanceStatus(
                                                    1,
                                                    index,
                                                  ),
                                            ),
                                            if (showLeftEarly) IconButton(
                                              icon: const Icon(
                                                Icons.alarm,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () =>
                                                  onChangedAttendanceStatus(
                                                    2,
                                                    index,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.block,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  onChangedAttendanceStatus(
                                                    3,
                                                    index,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );}),
                                      if (selectedStatusValues[index] == 1 ||
                                          selectedStatusValues[index] == 2)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            bottom: 8.0,
                                          ),
                                          child: TextFormField(
                                            controller:
                                                absenceInMinutesControllers[index],
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.absenceInMinutes,
                                              suffixText: '/$sessionDuration',
                                            ),
                                            validator: (value) {
                                              if (selectedStatusValues[index] ==
                                                      1 ||
                                                  selectedStatusValues[index] ==
                                                      2) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return AppLocalizations.of(
                                                    context,
                                                  )!.required;
                                                }
                                                final intValue = int.tryParse(
                                                  value,
                                                );
                                                if (intValue == null) {
                                                  return AppLocalizations.of(
                                                    context,
                                                  )!.invalid;
                                                }
                                                if (intValue >
                                                    sessionDuration) {
                                                  return AppLocalizations.of(
                                                    context,
                                                  )!.invalid;
                                                }
                                              }
                                              return null;
                                            },
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                          ),
                                        ),
                                      TextFormField(
                                        controller:
                                            studentNotesControllers[index],
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.studentNote,
                                        ),
                                      ),
                                      TextFormField(
                                        controller:
                                            internalNotesControllers[index],
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(
                                            context,
                                          )!.internalNote,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10.0,
                                        ),
                                        child: DropdownButtonFormField<int>(
                                          initialValue: attendanceCreation!
                                              .attendances![index]
                                              .levelId,
                                          items:
                                              getAllowedLevelsForStudent(
                                                attendanceCreation!
                                                    .attendances![index]
                                                    .levelId,
                                              ).map((level) {
                                                return DropdownMenuItem<int>(
                                                  value: level.id,
                                                  child: Text(
                                                    level.title!.toString(),
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (value) {
                                            setState(
                                              () => selectedLevelIds[index] =
                                                  value,
                                            );
                                          },
                                          decoration: InputDecoration(
                                            labelText: AppLocalizations.of(
                                              context,
                                            )!.level,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (groupStudentsExceptSessionStudents.isNotEmpty)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: Card(
                            margin: const EdgeInsets.only(top: 30),
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.addOtherStudentsToAttendanceList,
                                    ),
                                  ),
                                  for (var groupEnrollment
                                      in groupStudentsExceptSessionStudents)
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            addStudentToAttendanceList(
                                              groupEnrollment,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.add,
                                          ), // Add icon to the button
                                          color: HexColor.fromHex(
                                            AppColors.primaryColor,
                                          ), // Set icon color to white
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                          ),
                                          child: Text(
                                            groupEnrollment
                                                .enrollment!
                                                .student!
                                                .nameIdentification!,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                                  AppColors.primaryColor,
                                ),
                                padding: const EdgeInsets.all(20),
                              ),
                              onPressed: isSaving || !isFormValid()
                                  ? null
                                  : () async {
                                      await submit();
                                    },
                              child: Text(
                                AppLocalizations.of(context)!.save,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
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
