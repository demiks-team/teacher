import 'dart:convert';

List<AttendanceSettingsModel> dataFromJson(String str) =>
    List<AttendanceSettingsModel>.from(
        json.decode(str).map((x) => AttendanceSettingsModel.fromJson(x)));
String dataToJson(List<AttendanceSettingsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttendanceSettingsModel {
  AttendanceSettingsModel({
    this.blockAttendanceNumberOfHours,
  });

  int? blockAttendanceNumberOfHours;

  factory AttendanceSettingsModel.fromJson(Map<String, dynamic> json) =>
      AttendanceSettingsModel(
        blockAttendanceNumberOfHours: json["blockAttendanceNumberOfHours"],
      );
  Map<String, dynamic> toJson() => {
        "blockAttendanceNumberOfHours": blockAttendanceNumberOfHours,
      };
}
