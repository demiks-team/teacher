import 'dart:convert';

import 'package:teacher/src/shared/models/chapter_model.dart';
import 'package:teacher/src/shared/models/topic_model.dart';

import 'attendance_model.dart';

List<AttendanceCreationModel> dataFromJson(String str) =>
    List<AttendanceCreationModel>.from(
      json.decode(str).map((x) => AttendanceCreationModel.fromJson(x)),
    );
String dataToJson(List<AttendanceCreationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AttendanceCreationModel {
  AttendanceCreationModel({
    this.groupSessionId,
    this.chapterId,
    this.chapter,
    this.notes,
    this.attendances,
    this.topicIds,
    this.topics,
  });

  int? groupSessionId;
  int? chapterId;
  ChapterModel? chapter;
  String? notes;
  List<AttendanceModel>? attendances;
  List<int>? topicIds;
  List<TopicModel>? topics;

  factory AttendanceCreationModel.fromJson(Map<String, dynamic> json) =>
      AttendanceCreationModel(
        groupSessionId: json["groupSessionId"],
        chapterId: json["chapterId"],
        chapter: json["chapter"] != null
            ? ChapterModel.fromJson(json["chapter"])
            : null,
        notes: json["notes"],
        attendances: json["attendances"] != null
            ? (json["attendances"] as List)
                  .map((dynamic item) => AttendanceModel.fromJson(item))
                  .toList()
            : null,
        topicIds: json["topicIds"] != null
            ? List<int>.from(json["topicIds"])
            : null,
        topics: json["topics"] != null
            ? (json["topics"] as List)
                  .map((item) => TopicModel.fromJson(item))
                  .toList()
            : null,
      );
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> attendancesJsonList =
        attendances?.map((attendance) => attendance.toJson()).toList() ?? [];

    return {
      "groupSessionId": groupSessionId,
      "chapterId": chapterId,
      "chapter": chapter?.toJson(),
      "notes": notes,
      'attendances': attendancesJsonList,
      'topicIds': topicIds,
    };
  }
}
