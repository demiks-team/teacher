import 'dart:convert';

List<TopicModel> dataFromJson(String str) =>
    List<TopicModel>.from(json.decode(str).map((x) => TopicModel.fromJson(x)));
String dataToJson(List<TopicModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TopicModel {
  TopicModel({
    required this.id,
    this.title,
    this.isActive,
    this.schoolId,
  });

  int id;
  String? title;
  bool? isActive;
  int? schoolId;

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
        id: json["id"],
        title: json["title"],
        isActive: json["isActive"],
        schoolId: json["schoolId"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "isActive": isActive,
        "schoolId": schoolId,
      };
}
