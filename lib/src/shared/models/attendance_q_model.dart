import 'dart:convert';

import 'package:teacher/src/shared/models/group_model.dart';
import 'group_session_model.dart';

List<AttendanceQModel> dataFromJson(String str) => List<AttendanceQModel>.from(
    json.decode(str).map((x) => AttendanceQModel.fromJson(x)));
String dataToJson(List<AttendanceQModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttendanceQModel {
  AttendanceQModel({this.group, this.groupSession, this.showLateAttendance, this.showLeftEarlyAttendance, this.allowSessionMaterialLink});
  GroupModel? group;
  GroupSessionModel? groupSession;
  bool? showLateAttendance;
  bool? showLeftEarlyAttendance;
  bool? allowSessionMaterialLink;

  factory AttendanceQModel.fromJson(Map<String, dynamic> json) =>
      AttendanceQModel(
        group:
            json["group"] != null ? GroupModel.fromJson(json["group"]) : null,
        groupSession: json["groupSession"] != null
            ? GroupSessionModel.fromJson(json["groupSession"])
            : null,
        showLateAttendance: json["showLateAttendance"],
        showLeftEarlyAttendance: json["showLeftEarlyAttendance"],
        allowSessionMaterialLink: json["allowSessionMaterialLink"],
      );
  Map<String, dynamic> toJson() => {
        "group": group?.toJson(),
        "groupSession": groupSession?.toJson(),
        "showLateAttendance": showLateAttendance,
        "showLeftEarlyAttendance": showLeftEarlyAttendance,
        "allowSessionMaterialLink": allowSessionMaterialLink,
      };
}
