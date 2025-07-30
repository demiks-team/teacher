import 'dart:convert';

import 'attendance_model.dart';

List<AttendanceCreationModel> dataFromJson(String str) =>
    List<AttendanceCreationModel>.from(
        json.decode(str).map((x) => AttendanceCreationModel.fromJson(x)));
String dataToJson(List<AttendanceCreationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttendanceCreationModel {
  AttendanceCreationModel(
      {this.groupSessionId, this.chapterId, this.notes, this.attendances});

  int? groupSessionId;
  int? chapterId;
  String? notes;
  List<AttendanceModel>? attendances;

  factory AttendanceCreationModel.fromJson(Map<String, dynamic> json) =>
      AttendanceCreationModel(
        groupSessionId: json["groupSessionId"],
        chapterId: json["chapterId"],
        notes: json["notes"],
        attendances: json["attendances"] != null
            ? (json["attendances"] as List)
                .map(
                  (dynamic item) => AttendanceModel.fromJson(item),
                )
                .toList()
            : null,
      );
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> attendancesJsonList =
        attendances?.map((attendance) => attendance.toJson()).toList() ?? [];

    return {
      "groupSessionId": groupSessionId,
      "chapterId": chapterId,
      "notes": notes,
      'attendances': attendancesJsonList,
    };
  }
}
