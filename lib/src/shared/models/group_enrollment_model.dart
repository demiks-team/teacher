import 'dart:convert';
import 'enrollment_model.dart';
import 'enums.dart';

List<GroupEnrollmentModel> dataFromJson(String str) =>
    List<GroupEnrollmentModel>.from(
        json.decode(str).map((x) => GroupEnrollmentModel.fromJson(x)));
String dataToJson(List<GroupEnrollmentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupEnrollmentModel {
  GroupEnrollmentModel({
    required this.id,
    this.groupId,
    this.enrollmentId,
    this.enrollment,
    this.startDate,
    this.endDate,
    this.estimatedEndDate,
    this.groupEnrollmentStatus,
    this.studentId,
    this.didStudentPass,
    this.canStudentPrintCertificate,
    this.evaluationIsNotNecessary,
    this.canStudentPrintReportCard,
  });

  int id;
  int? groupId;
  int? enrollmentId;
  EnrollmentModel? enrollment;
  String? startDate;
  String? endDate;
  String? estimatedEndDate;
  GroupEnrollmentStatus? groupEnrollmentStatus;
  int? studentId;
  bool? didStudentPass;
  bool? canStudentPrintCertificate;
  bool? evaluationIsNotNecessary;
  bool? canStudentPrintReportCard;

  factory GroupEnrollmentModel.fromJson(Map<String, dynamic> json) =>
      GroupEnrollmentModel(
        id: json["id"],
        groupId: json["groupId"],
        enrollmentId: json["enrollmentId"],
        enrollment: json["enrollment"] != null
            ? EnrollmentModel.fromJson(json["enrollment"])
            : null,
        startDate: json["startDate"],
        endDate: json["endDate"],
        estimatedEndDate: json["estimatedEndDate"],
        groupEnrollmentStatus: json["groupEnrollmentStatus"] != null
            ? GroupEnrollmentStatus.values[json["groupEnrollmentStatus"]]
            : null,
        studentId: json["studentId"],
        didStudentPass: json["didStudentPass"],
        canStudentPrintCertificate: json["canStudentPrintCertificate"],
        evaluationIsNotNecessary: json["evaluationIsNotNecessary"],
        canStudentPrintReportCard: json["studentId"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "enrollmentId": enrollmentId,
        "enrollment": enrollment != null ? enrollment!.toJson() : null,
        "startDate": startDate,
        "endDate": endDate,
        "estimatedEndDate": estimatedEndDate,
        "groupEnrollmentStatus": groupEnrollmentStatus?.index,
        "studentId": studentId,
        "didStudentPass": didStudentPass,
        "canStudentPrintCertificate": canStudentPrintCertificate,
        "evaluationIsNotNecessary": evaluationIsNotNecessary,
        "canStudentPrintReportCard": studentId,
      };
}
