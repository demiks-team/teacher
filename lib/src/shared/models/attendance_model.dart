import 'dart:convert';

import 'group_enrollment_model.dart';

List<AttendanceModel> dataFromJson(String str) => List<AttendanceModel>.from(
    json.decode(str).map((x) => AttendanceModel.fromJson(x)));
String dataToJson(List<AttendanceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttendanceModel {
  AttendanceModel({
    required this.id,
    this.groupEnrollmentId,
    this.groupEnrollment,
    this.groupSessionId,
    this.status,
    this.internalNotes,
    this.notesForStudent,
    this.studentLevelId,
  });

  int id;
  int? groupEnrollmentId;
  GroupEnrollmentModel? groupEnrollment;
  int? groupSessionId;
  int? status;
  String? internalNotes;
  String? notesForStudent;
  int? studentLevelId;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        id: json["id"],
        groupEnrollmentId: json["groupEnrollmentId"],
        groupEnrollment: json["groupEnrollment"] != null
            ? GroupEnrollmentModel.fromJson(json["groupEnrollment"])
            : null,
        groupSessionId: json["groupSessionId"],
        status: json["status"],
        internalNotes: json["internalNotes"],
        notesForStudent: json["notesForStudent"],
        studentLevelId: json["studentLevelId"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "groupEnrollmentId": groupEnrollmentId,
        "groupEnrollment":
            groupEnrollment != null ? groupEnrollment!.toJson() : null,
        "groupSessionId": groupSessionId,
        "status": status,
        "internalNotes": internalNotes,
        "notesForStudent": notesForStudent,
        "studentLevelId": studentLevelId,
      };
}
