import 'dart:convert';

List<BookModel> dataFromJson(String str) =>
    List<BookModel>.from(json.decode(str).map((x) => BookModel.fromJson(x)));
String dataToJson(List<BookModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BookModel {
  BookModel({
    required this.id,
    this.title,
    this.isActive,
    this.displayOrder,
  });

  int id;
  String? title;
  bool? isActive;
  int? displayOrder;

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
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
