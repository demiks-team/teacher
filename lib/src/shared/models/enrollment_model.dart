import 'dart:convert';

import 'package:teacher/src/shared/models/student_model.dart';

List<EnrollmentModel> dataFromJson(String str) => List<EnrollmentModel>.from(
    json.decode(str).map((x) => EnrollmentModel.fromJson(x)));
String dataToJson(List<EnrollmentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EnrollmentModel {
  EnrollmentModel({
    required this.id,
    this.studentId,
    this.student,
  });

  int id;
  int? studentId;
  StudentModel? student;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) =>
      EnrollmentModel(
        id: json["id"],
        studentId: json["studentId"],
        student: json["student"] != null
            ? StudentModel.fromJson(json["student"])
            : null,
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "studentId": studentId,
        "student": student != null ? student!.toJson() : null,
      };
}
