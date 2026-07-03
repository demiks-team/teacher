import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teacher/l10n/app_localizations.dart';
import 'package:teacher/src/shared/helpers/colors/hex_color.dart';
import 'package:teacher/src/shared/models/progress_area_group_session_model.dart';
import 'package:teacher/src/shared/models/progress_area_group_session_student_item_model.dart';
import 'package:teacher/src/shared/models/progress_area_group_session_student_model.dart';
import 'package:teacher/src/shared/services/student_progress_area_service.dart';
import 'package:teacher/src/shared/theme/colors/app_colors.dart';

class StudentProgressAreaScreen extends StatefulWidget {
  final String groupTitle;
  final ProgressAreaGroupSessionModel progressAreaGroupSession;

  const StudentProgressAreaScreen({
    super.key,
    required this.groupTitle,
    required this.progressAreaGroupSession,
  });

  @override
  State<StudentProgressAreaScreen> createState() =>
      _StudentProgressAreaScreenState();
}

class _StudentProgressAreaScreenState extends State<StudentProgressAreaScreen> {
  final StudentProgressAreaService _service = StudentProgressAreaService();
  bool isSaving = false;

  // [studentIndex][itemIndex] — null for non-number items
  late List<List<TextEditingController?>> _controllers;
  // computed display values for formula items [studentIndex][itemIndex]
  late List<List<String>> _formulaValues;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final students =
        widget.progressAreaGroupSession.progressAreaGroupSessionStudents ?? [];
    _controllers = [];
    _formulaValues = [];

    for (int si = 0; si < students.length; si++) {
      final items = students[si].progressAreaGroupSessionStudentItems ?? [];
      final studentControllers = <TextEditingController?>[];
      final studentFormulas = <String>[];

      for (int ii = 0; ii < items.length; ii++) {
        if (items[ii].responseType == 1) {
          final ctrl =
              TextEditingController(text: items[ii].result ?? '');
          final capturedSi = si;
          ctrl.addListener(() => _recomputeFormulas(capturedSi));
          studentControllers.add(ctrl);
        } else {
          studentControllers.add(null);
        }
        studentFormulas.add('');
      }

      _controllers.add(studentControllers);
      _formulaValues.add(studentFormulas);

      _recomputeFormulasFor(
          si, students[si].progressAreaGroupSessionStudentItems ?? []);
    }
  }

  void _recomputeFormulas(int studentIndex) {
    final students =
        widget.progressAreaGroupSession.progressAreaGroupSessionStudents ?? [];
    if (studentIndex >= students.length) return;
    _recomputeFormulasFor(
        studentIndex,
        students[studentIndex].progressAreaGroupSessionStudentItems ?? []);
  }

  void _recomputeFormulasFor(int si,
      List<ProgressAreaGroupSessionStudentItemModel> items) {
    final numberValues = <double>[];
    for (int i = 0; i < items.length; i++) {
      if (items[i].responseType == 1) {
        final val =
            double.tryParse(_controllers[si][i]?.text ?? '') ?? 0.0;
        numberValues.add(val);
      }
    }

    bool changed = false;
    for (int i = 0; i < items.length; i++) {
      if (items[i].responseType == 4) {
        final computed =
            _calcFormula(items[i].formulaType, numberValues);
        if (_formulaValues[si][i] != computed) {
          _formulaValues[si][i] = computed;
          changed = true;
        }
      }
    }
    if (changed && mounted) setState(() {});
  }

  String _calcFormula(int? formulaType, List<double> values) {
    if (values.isEmpty) return '';
    final allInts = values.every((v) => v % 1 == 0);

    switch (formulaType) {
      case 1: // average
        final avg = values.reduce((a, b) => a + b) / values.length;
        return (allInts && avg > 20)
            ? avg.toStringAsFixed(0)
            : avg.toStringAsFixed(2);
      case 2: // sum
        final sum = values.reduce((a, b) => a + b);
        return sum % 1 == 0
            ? sum.toStringAsFixed(0)
            : sum.toStringAsFixed(2);
      case 3: // maximum
        final max = values.reduce((a, b) => a > b ? a : b);
        return max % 1 == 0
            ? max.toStringAsFixed(0)
            : max.toStringAsFixed(2);
      case 4: // minimum
        final min = values.reduce((a, b) => a < b ? a : b);
        return min % 1 == 0
            ? min.toStringAsFixed(0)
            : min.toStringAsFixed(2);
      default:
        return '';
    }
  }

  @override
  void dispose() {
    for (final row in _controllers) {
      for (final ctrl in row) {
        ctrl?.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => isSaving = true);
    try {
      await _service.upsertProgressAreaGroupSessionStudents(_buildModel());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
    }
  }

  ProgressAreaGroupSessionModel _buildModel() {
    final students =
        widget.progressAreaGroupSession.progressAreaGroupSessionStudents ?? [];
    final resultStudents = <ProgressAreaGroupSessionStudentModel>[];

    for (int si = 0; si < students.length; si++) {
      final src = students[si];
      final items = src.progressAreaGroupSessionStudentItems ?? [];
      final resultItems = <ProgressAreaGroupSessionStudentItemModel>[];

      for (int ii = 0; ii < items.length; ii++) {
        String? result;
        if (items[ii].responseType == 1) {
          final text = _controllers[si][ii]?.text ?? '';
          result = text.isNotEmpty ? text : null;
        } else if (items[ii].responseType == 4) {
          final v = _formulaValues[si][ii];
          result = v.isNotEmpty ? v : null;
        }

        resultItems.add(ProgressAreaGroupSessionStudentItemModel(
          studentProgressAreaId: items[ii].studentProgressAreaId,
          title: items[ii].title,
          responseType: items[ii].responseType,
          formulaType: items[ii].formulaType,
          result: result,
          passCondition: items[ii].passCondition,
          responseOptionsId: items[ii].responseOptionsId,
          levelId: items[ii].levelId,
        ));
      }

      resultStudents.add(ProgressAreaGroupSessionStudentModel(
        studentId: src.studentId,
        fullName: src.fullName,
        groupEnrollmentId: src.groupEnrollmentId,
        groupSessionId: src.groupSessionId,
        groupId: src.groupId,
        progressAreaGroupSessionStudentItems: resultItems,
      ));
    }

    return ProgressAreaGroupSessionModel(
      groupSessionId: widget.progressAreaGroupSession.groupSessionId,
      progressAreaGroupSessionStudents: resultStudents,
    );
  }

  @override
  Widget build(BuildContext context) {
    final students =
        widget.progressAreaGroupSession.progressAreaGroupSessionStudents ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: HexColor.fromHex(AppColors.accentColor)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme:
            IconThemeData(color: HexColor.fromHex(AppColors.accentColor)),
      ),
      body: students.isEmpty
          ? Center(
              child: Text(AppLocalizations.of(context)!.noData),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: List.generate(
                    students.length,
                    (si) =>
                        _buildStudentCard(context, si, students[si])),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton(
          onPressed: isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: HexColor.fromHex(AppColors.accentColor),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  AppLocalizations.of(context)!.save,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, int si,
      ProgressAreaGroupSessionStudentModel student) {
    final items = student.progressAreaGroupSessionStudentItems ?? [];

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student.fullName ?? '',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ...List.generate(items.length,
                (ii) => _buildItemRow(si, ii, items[ii])),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(int si, int ii,
      ProgressAreaGroupSessionStudentItemModel item) {
    if (item.responseType == 1) {
      // number — editable field
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: _controllers[si][ii],
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
          ],
          decoration: InputDecoration(
            labelText: item.title ?? '',
            border: const OutlineInputBorder(),
            suffixText: item.passCondition != null &&
                    item.passCondition!.isNotEmpty
                ? '/ ${item.passCondition}'
                : null,
          ),
        ),
      );
    } else if (item.responseType == 4) {
      // formula — read-only computed display
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: item.title ?? '',
            border: const OutlineInputBorder(),
          ),
          child: Text(
            _formulaValues[si][ii].isNotEmpty
                ? _formulaValues[si][ii]
                : '—',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
