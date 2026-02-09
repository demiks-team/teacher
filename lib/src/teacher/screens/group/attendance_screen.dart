import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pinput/pinput.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/shared/models/attendance_creation_model.dart';
import 'package:teacher/src/shared/models/attendance_model.dart';
import 'package:teacher/src/shared/models/chapter_model.dart';
import 'package:teacher/src/shared/models/group_enrollment_model.dart';
import 'package:teacher/src/shared/models/topic_model.dart';
import 'package:teacher/src/shared/services/book_service.dart';

import '../../../shared/helpers/colors/hex_color.dart';
import '../../../shared/helpers/colors/material_color.dart';
import '../../../shared/models/attendance_q_model.dart';

import '../../../shared/models/enums.dart';
import '../../../shared/models/level_model.dart';
import '../../../shared/services/general_service.dart';
import '../../../shared/services/group_service.dart';
import '../../../shared/theme/colors/app_colors.dart';

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

  ChapterModel? _selectedChapter;
  TextEditingController chapterSearchController = TextEditingController();

  List<ChapterModel> sortedChapters = [];
  List<ChapterModel> filteredChapters = [];

  List<TextEditingController> absenceInMinutesControllers = [];

  List<TopicModel> topics = [];
  List<TopicModel> filteredTopics = [];

  List<int> selectedTopicIds = [];

  TopicModel? selectedTopic;
  TextEditingController topicSearchController = TextEditingController();

  Future<void> initializeTheData() async {
    await getSessionStudents();
    await getGroupEnrollments();
    await getSchoolLevels();

    if (widget.attendanceQModel.group!.bookId != null) {
      if (widget.attendanceQModel.group!.bookId! > 0) {
        await getChapters();
      }
    }

    if (widget.attendanceQModel.group!.canTeacherSpecifyTopics != null) {
      if (widget.attendanceQModel.group!.canTeacherSpecifyTopics == true) {
        await getTopics();
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
      selectedStatusValues.add(
        element.status ?? int.parse(AttendanceStatus.notSet.toString()),
      );
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

  void buildSortedChapterList() {
    if (chapters.isEmpty) {
      sortedChapters = [];
      filteredChapters = [];
      return;
    }
    final parents = chapters.where((c) => c.parentChapterId == null).toList();
    parents.sort(
      (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
    );
    final List<ChapterModel> result = [];
    for (final parent in parents) {
      result.add(parent);
      final children = chapters
          .where((c) => c.parentChapterId == parent.id)
          .toList();
      children.sort(
        (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
      );
      result.addAll(children);
    }
    sortedChapters = result;
    filteredChapters = List.from(sortedChapters);
  }

  Future<void> getTopics() async {
    final getTopics = _generalService.getTopics();

    await getTopics.then((result) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          topics = result;

          if (attendanceCreation?.topicIds != null &&
              attendanceCreation!.topicIds!.isNotEmpty &&
              attendanceCreation?.topics != null) {
            for (var topicId in attendanceCreation!.topicIds!) {
              final exists = topics.any((t) => t.id == topicId);
              if (!exists) {
                final topicFromCreation = attendanceCreation!.topics!
                    .where((t) => t.id == topicId)
                    .firstOrNull;
                if (topicFromCreation != null) {
                  topics.add(topicFromCreation);
                }
              }
            }
          }

          if (attendanceCreation?.topicIds != null &&
              attendanceCreation!.topicIds!.isNotEmpty) {
            selectedTopicIds = List<int>.from(attendanceCreation!.topicIds!);
          }
        });
      });
    });
  }

  bool hasAnyChapter = false;
  Future<void> getChapters() async {
    final getChapters = _bookService.getChapters(
      widget.attendanceQModel.group!.bookId!,
    );

    await getChapters.then((result) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          chapters = result;

          if (attendanceCreation?.chapterId != null) {
            if (attendanceCreation!.chapter != null) {
              final exists = chapters.any(
                (c) => c.id == attendanceCreation!.chapterId,
              );
              if (!exists) {
                chapters.add(attendanceCreation!.chapter!);
              }
            }
          }

          buildSortedChapterList();
          hasAnyChapter = chapters.isNotEmpty;

          if (attendanceCreation?.chapterId != null) {
            _selectedChapterValue = attendanceCreation!.chapterId;
            _selectedChapter = chapters.firstWhere(
              (c) => c.id == _selectedChapterValue,
              orElse: () => ChapterModel(id: null),
            );
            chapterSearchController.text = _selectedChapter?.title ?? '';
          }
        });
      });
    });
  }

  void filterChapters(String query) {
    if (sortedChapters.isEmpty) {
      filteredChapters = [];
      return;
    }

    final lower = query.toLowerCase();
    final Set<int> addedIds = {};
    filteredChapters = [];

    // placeholder
    final placeholder = sortedChapters.firstWhere(
      (c) => c.id == 0,
      orElse: () => ChapterModel(id: 0, title: "---"),
    );
    filteredChapters.add(placeholder);
    addedIds.add(placeholder.id!);

    for (var chapter in sortedChapters) {
      if (chapter.id == 0) continue;
      if (chapter.title == null) continue;
      if (addedIds.contains(chapter.id!)) continue;

      final selfMatch = chapter.title!.toLowerCase().contains(lower);
      final isParent = chapter.parentChapterId == null;

      if (isParent && selfMatch) {
        filteredChapters.add(chapter);
        addedIds.add(chapter.id!);

        final children = sortedChapters.where(
          (c) => c.parentChapterId == chapter.id && !addedIds.contains(c.id!),
        );
        for (final child in children) {
          filteredChapters.add(child);
          addedIds.add(child.id!);
        }
      } else if (!isParent && selfMatch) {
        final parent = sortedChapters.firstWhere(
          (p) => p.id == chapter.parentChapterId,
          orElse: () => ChapterModel(id: null),
        );
        if (parent.id != null && !addedIds.contains(parent.id!)) {
          filteredChapters.add(parent);
          addedIds.add(parent.id!);
        }
        filteredChapters.add(chapter);
        addedIds.add(chapter.id!);
      }
    }
  }

  void onChapterSelected(ChapterModel? chapter) {
    if (chapter == null) return;
    setState(() {
      if (chapter.id == 0) {
        chapter.title = '';
      }
      _selectedChapter = chapter;
      _selectedChapterValue = chapter.id == 0 ? null : chapter.id;
      chapterSearchController.text = chapter.title ?? '';
      onChangedAttendanceChapterAll(_selectedChapterValue);
    });

    FocusScope.of(context).unfocus();
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
      attendance.status = AttendanceStatus.notSet.index;
      attendance.levelId = groupEnrollment.enrollment?.student?.levelId;

      selectedStatusValues.add(AttendanceStatus.notSet.index);
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
      attendanceCreation!.attendances!.removeAt(index);

      groupStudentsExceptSessionStudents.add(groupEnrollment);

      if (index < absenceInMinutesControllers.length) {
        absenceInMinutesControllers.removeAt(index);
      }

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

      switch (value) {
        case 0: // onTime
          absenceCtrl.text = '0';
          break;

        case 3:
          absenceCtrl.text = sessionDuration.toString();
          break;

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

    if (attendanceCreation == null || attendanceCreation!.attendances == null) {
      return;
    }

    for (int i = 0; i < attendanceCreation!.attendances!.length; i++) {
      selectedLevelIds[i] = selectedLevel;
      attendanceCreation!.attendances![i].levelId = selectedLevel;
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

    att.topicIds = selectedTopicIds;

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
    await _groupService.saveAttendance(att).then((result) {
      if (result) {
        // Navigator.pop(context, true);
      } else {
        setState(() {
          isSaving = false;
        });
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    });
  }

  List<int> selectedStatusValues = [];
  int _selectedValue = 0;
  int? _selectedLevelValue;

  List<TextEditingController> studentNotesControllers = [];
  List<TextEditingController> internalNotesControllers = [];
  TextEditingController? notesController;

  List<TextEditingController> absenceInMinutes = [];

  int? _selectedChapterValue;
  void onChangedAttendanceChapterAll(int? value) {
    setState(() {
      if (value == 0) {
        _selectedChapterValue = null;

        return;
      }
      _selectedChapterValue = value;
      changeAllChapters(value);
    });
  }

  void changeAllChapters(int? value) {
    if (attendanceCreation == null || attendanceCreation!.attendances == null) {
      return;
    }

    if (value != null && value > 0) {
      var chapter = chapters.firstWhere((c) => c.id == value);
      if (chapter.levelId != null && chapter.levelId! > 0) {
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

  void filterTopics(String query) {
    if (query.isEmpty) {
      filteredTopics = List.from(topics);
      return;
    }

    final lower = query.toLowerCase();
    filteredTopics = topics
        .where((t) => (t.title ?? '').toLowerCase().contains(lower))
        .toList();
  }

  void onTopicSelected(TopicModel topic) {
    if (!selectedTopicIds.contains(topic.id)) {
      setState(() {
        selectedTopicIds.add(topic.id);
        topicSearchController.text = '';
      });
    }

    selectedTopic = null;

    // topicSearchController.clear();
    FocusScope.of(context).unfocus();
  }

  void removeTopic(int topicId) {
    setState(() {
      selectedTopicIds.remove(topicId);
    });
  }

  String getTopicTitle(int id) {
    return topics
            .firstWhere(
              (t) => t.id == id,
              orElse: () => TopicModel(id: id, title: ''),
            )
            .title ??
        '';
  }

  bool isFormValid() {
    if (attendanceCreation == null) {
      return false;
    }

    final rows = attendanceCreation!.attendances!.length;

    if (rows == 0) {
      return false;
    }

    for (int i = 0; i < rows; i++) {
      final status = selectedStatusValues[i];

      if (status == AttendanceStatus.notSet.index) {
        return false;
      }

      // final status = (i < selectedStatusValues.length)
      //     ? selectedStatusValues[i]
      //     : AttendanceStatus.absent.index;

      if (status == 1 || status == 2) {
        final text = (i < absenceInMinutesControllers.length)
            ? absenceInMinutesControllers[i].text.trim()
            : '';
        if (text.isEmpty) return false;
        final parsed = int.tryParse(text);
        if (parsed == null) return false;
        if (parsed > sessionDuration) return false;
        if (parsed < 0) return false;
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
                                  child: Autocomplete<ChapterModel>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                          if (sortedChapters.isEmpty) {
                                            return const Iterable<
                                              ChapterModel
                                            >.empty();
                                          }
                                          filterChapters(textEditingValue.text);
                                          return filteredChapters;
                                        },
                                    displayStringForOption:
                                        (ChapterModel option) =>
                                            option.title ?? '',
                                    fieldViewBuilder:
                                        (
                                          context,
                                          controller,
                                          focusNode,
                                          onEditingComplete,
                                        ) {
                                          chapterSearchController = controller;
                                          controller.text =
                                              _selectedChapter?.title ?? '';
                                          return TextFormField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.chapter,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                          );
                                        },
                                    optionsViewBuilder:
                                        (context, onSelected, options) {
                                          return Align(
                                            alignment: Alignment.topLeft,
                                            child: Material(
                                              child: Container(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.90,
                                                color: Colors.white,
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: options.length,
                                                  itemBuilder: (context, index) {
                                                    final ChapterModel option =
                                                        options.elementAt(
                                                          index,
                                                        );
                                                    return ListTile(
                                                      title: Padding(
                                                        padding: EdgeInsets.only(
                                                          left:
                                                              option.parentChapterId !=
                                                                  null
                                                              ? 16.0
                                                              : 0,
                                                        ),
                                                        child: Text(
                                                          option.title ?? '',
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        onSelected(option);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                    onSelected: (ChapterModel selection) {
                                      onChapterSelected(selection);
                                    },
                                  ),
                                ),
                              ],
                            ),

                          if (widget
                                  .attendanceQModel
                                  .group!
                                  .canTeacherSpecifyTopics ==
                              true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  child: Autocomplete<TopicModel>(
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                          filterTopics(textEditingValue.text);
                                          return filteredTopics;
                                        },
                                    displayStringForOption:
                                        (TopicModel option) =>
                                            option.title ?? '',
                                    fieldViewBuilder:
                                        (
                                          context,
                                          controller,
                                          focusNode,
                                          onEditingComplete,
                                        ) {
                                          topicSearchController = controller;
                                          return TextFormField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              labelText: AppLocalizations.of(
                                                context,
                                              )!.topics,
                                              border: OutlineInputBorder(),
                                            ),
                                          );
                                        },
                                    onSelected: (TopicModel selection) {
                                      onTopicSelected(selection);
                                    },
                                  ),
                                ),

                                const SizedBox(height: 8),

                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: selectedTopicIds.map((topicId) {
                                      return InputChip(
                                        label: Text(getTopicTitle(topicId)),
                                        onDeleted: () {
                                          removeTopic(topicId);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),

                          if (attendanceCreation!.attendances!.length > 1)
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: ToggleButtons(
                                    fillColor: Colors.grey.shade200,
                                    isSelected: List.generate(
                                      4,
                                      (index) => index == _selectedValue,
                                    ),
                                    onPressed: (int index) {
                                      onChangedAttendanceStatusAll(
                                        _selectedValue,
                                      );
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
                                      IconButton(
                                        icon: const Icon(
                                          Icons.snooze,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () =>
                                            onChangedAttendanceStatusAll(1),
                                      ),
                                      IconButton(
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
                            ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                            icon: const Icon(Icons.remove),
                                            color: HexColor.fromHex(
                                              AppColors.primaryColor,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 5,
                                                  ),
                                              child: Text(
                                                attendanceCreation!
                                                    .attendances![index]
                                                    .groupEnrollment!
                                                    .enrollment!
                                                    .student!
                                                    .nameIdentification
                                                    .toString(),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                        ),
                                        child: ToggleButtons(
                                          fillColor: Colors.grey.shade200,
                                          isSelected: List.generate(
                                            4,
                                            (i) =>
                                                selectedStatusValues[index] ==
                                                i,
                                          ),
                                          onPressed: (int i) {
                                            onChangedAttendanceStatus(i, index);
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
                                            IconButton(
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
                                            IconButton(
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
                                      ),
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
                                              if (index < selectedStatusValues.length && (selectedStatusValues[index] ==
                                                      1 ||
                                                  selectedStatusValues[index] ==
                                                      2)) {
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

                                                if (intValue < 0) {
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

                                        // Padding(
                                        //   padding: const EdgeInsets.only(
                                        //     top: 5,
                                        //     bottom: 5,
                                        //   ),
                                        //   child: Text(
                                        //     groupEnrollment
                                        //         .enrollment!
                                        //         .student!
                                        //         .nameIdentification!,
                                        //   ),
                                        // ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 5,
                                            ),
                                            child: Text(
                                              groupEnrollment
                                                  .enrollment!
                                                  .student!
                                                  .nameIdentification!,
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                            ),
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
