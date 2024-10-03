import 'dart:convert';

import 'package:teacher/src/shared/models/group_session_model.dart';

List<DashboardGroupModel> dataFromJson(String str) =>
    List<DashboardGroupModel>.from(
        json.decode(str).map((x) => DashboardGroupModel.fromJson(x)));
String dataToJson(List<DashboardGroupModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DashboardGroupModel {
  DashboardGroupModel({
    this.groupSession,
  });

  GroupSessionModel? groupSession;

  factory DashboardGroupModel.fromJson(Map<String, dynamic> json) =>
      DashboardGroupModel(
        groupSession: json["groupSession"] != null
            ? GroupSessionModel.fromJson(json["groupSession"])
            : null,
      );
  Map<String, dynamic> toJson() => {
        "groupSession": groupSession?.toJson(),
      };
}
