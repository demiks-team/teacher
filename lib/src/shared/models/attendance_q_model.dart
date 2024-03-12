import 'dart:convert';

import 'package:teacher/src/shared/models/group_model.dart';
import 'group_session_model.dart';

List<AttendanceQModel> dataFromJson(String str) => List<AttendanceQModel>.from(
    json.decode(str).map((x) => AttendanceQModel.fromJson(x)));
String dataToJson(List<AttendanceQModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttendanceQModel {
  AttendanceQModel({this.group, this.groupSession});
  GroupModel? group;
  GroupSessionModel? groupSession;

  factory AttendanceQModel.fromJson(Map<String, dynamic> json) =>
      AttendanceQModel(
        group:
            json["group"] != null ? GroupModel.fromJson(json["group"]) : null,
        groupSession: json["groupSession"] != null
            ? GroupSessionModel.fromJson(json["groupSession"])
            : null,
      );
  Map<String, dynamic> toJson() => {
        "group": group != null ? group!.toJson() : null,
        "groupSession": groupSession != null ? groupSession!.toJson() : null,
      };
}
