import 'progress_area_group_session_student_item_model.dart';

class ProgressAreaGroupSessionStudentModel {
  int? studentId;
  String? fullName;
  int? groupEnrollmentId;
  int? groupSessionId;
  int? groupId;
  List<ProgressAreaGroupSessionStudentItemModel>? progressAreaGroupSessionStudentItems;

  ProgressAreaGroupSessionStudentModel({
    this.studentId,
    this.fullName,
    this.groupEnrollmentId,
    this.groupSessionId,
    this.groupId,
    this.progressAreaGroupSessionStudentItems,
  });

  factory ProgressAreaGroupSessionStudentModel.fromJson(Map<String, dynamic> json) =>
      ProgressAreaGroupSessionStudentModel(
        studentId: json["studentId"],
        fullName: json["fullName"],
        groupEnrollmentId: json["groupEnrollmentId"],
        groupSessionId: json["groupSessionId"],
        groupId: json["groupId"],
        progressAreaGroupSessionStudentItems: json["progressAreaGroupSessionStudentItems"] != null
            ? (json["progressAreaGroupSessionStudentItems"] as List)
                .map((e) => ProgressAreaGroupSessionStudentItemModel.fromJson(e))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "fullName": fullName,
        "groupEnrollmentId": groupEnrollmentId,
        "groupSessionId": groupSessionId,
        "groupId": groupId,
        "progressAreaGroupSessionStudentItems":
            progressAreaGroupSessionStudentItems?.map((e) => e.toJson()).toList(),
      };
}
