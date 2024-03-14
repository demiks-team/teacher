import 'dart:convert';

List<LevelModel> dataFromJson(String str) =>
    List<LevelModel>.from(json.decode(str).map((x) => LevelModel.fromJson(x)));
String dataToJson(List<LevelModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LevelModel {
  LevelModel({
    required this.id,
    this.title,
    this.isActive,
    this.displayOrder,
  });

  int id;
  String? title;
  bool? isActive;
  int? displayOrder;

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
        id: json["id"],
        title: json["title"],
        isActive: json["isActive"],
        displayOrder: json["displayOrder"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "isActive": isActive,
        "displayOrder": displayOrder,
      };
}
