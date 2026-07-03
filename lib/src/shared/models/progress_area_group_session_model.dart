import 'progress_area_group_session_student_model.dart';

class ProgressAreaGroupSessionModel {
  int? groupSessionId;
  List<ProgressAreaGroupSessionStudentModel>? progressAreaGroupSessionStudents;

  ProgressAreaGroupSessionModel({
    this.groupSessionId,
    this.progressAreaGroupSessionStudents,
  });

  factory ProgressAreaGroupSessionModel.fromJson(Map<String, dynamic> json) =>
      ProgressAreaGroupSessionModel(
        groupSessionId: json["groupSessionId"],
        progressAreaGroupSessionStudents: json["progressAreaGroupSessionStudents"] != null
            ? (json["progressAreaGroupSessionStudents"] as List)
                .map((e) => ProgressAreaGroupSessionStudentModel.fromJson(e))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "groupSessionId": groupSessionId,
        "progressAreaGroupSessionStudents":
            progressAreaGroupSessionStudents?.map((e) => e.toJson()).toList(),
      };
}
