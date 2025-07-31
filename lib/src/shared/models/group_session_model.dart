import 'dart:convert';

import 'package:teacher/src/shared/models/group_model.dart';

import 'enums.dart';

List<GroupSessionModel> dataFromJson(String str) =>
    List<GroupSessionModel>.from(
        json.decode(str).map((x) => GroupSessionModel.fromJson(x)));
String dataToJson(List<GroupSessionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupSessionModel {
  GroupSessionModel({
    required this.id,
    this.groupId,
    this.group,
    this.startDate,
    this.endDate,
    this.sessionStatus,
    this.sessionStatusString,
    this.internalNote,
    this.sessionNumber,
    this.cancellationNote,
    this.isCancellationRequested,
    this.isRecompensable,
    this.teacherNotes,
    this.privateNote,
    this.note,
    this.vcReferenceCode,
    this.slug,
    this.meetingId,
    this.breakTimeInMinutes,
    this.chapterId,
  });
  int id;
  int? groupId;
  GroupModel? group;
  String? startDate;
  String? endDate;
  GroupSessionStatus? sessionStatus;
  String? sessionStatusString;
  String? internalNote;
  int? sessionNumber;
  String? cancellationNote;
  bool? isCancellationRequested;
  bool? isRecompensable;
  String? teacherNotes;
  String? privateNote;
  String? note;
  String? vcReferenceCode;
  String? slug;
  int? meetingId;
  int? breakTimeInMinutes;
  int? chapterId;

  factory GroupSessionModel.fromJson(Map<String, dynamic> json) =>
      GroupSessionModel(
        id: json["id"],
        groupId: json["groupId"],
        group:
            json["group"] != null ? GroupModel.fromJson(json["group"]) : null,
        startDate: json["startDate"],
        endDate: json["endDate"],
        sessionStatus: json["sessionStatus"] != null
            ? GroupSessionStatus.values[json["sessionStatus"]]
            : null,
        sessionStatusString: json["sessionStatusString"],
        internalNote: json["internalNote"],
        sessionNumber: json["sessionNumber"],
        cancellationNote: json["cancellationNote"],
        isCancellationRequested: json["isCancellationRequested"],
        isRecompensable: json["isRecompensable"],
        teacherNotes: json["teacherNotes"],
        privateNote: json["privateNote"],
        note: json["note"],
        vcReferenceCode: json["vcReferenceCode"],
        slug: json["slug"],
        meetingId: json["meetingId"],
        breakTimeInMinutes: json["breakTimeInMinutes"],
        chapterId: json["chapterId"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "group": group?.toJson(),
        "startDate": startDate,
        "endDate": endDate,
        "sessionStatus": sessionStatus,
        "sessionStatusString": sessionStatusString,
        "internalNote": internalNote,
        "sessionNumber": sessionNumber,
        "cancellationNote": cancellationNote,
        "isCancellationRequested": isCancellationRequested,
        "isRecompensable": isRecompensable,
        "teacherNotes": teacherNotes,
        "privateNote": privateNote,
        "note": note,
        "vcReferenceCode": vcReferenceCode,
        "slug": slug,
        "meetingId": meetingId,
        "breakTimeInMinutes": breakTimeInMinutes,
        "chapterId": chapterId,
      };
}
