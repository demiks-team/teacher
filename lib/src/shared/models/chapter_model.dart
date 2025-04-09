import 'dart:convert';

import 'package:teacher/src/shared/models/book_model.dart';

List<ChapterModel> dataFromJson(String str) => List<ChapterModel>.from(
    json.decode(str).map((x) => ChapterModel.fromJson(x)));
String dataToJson(List<ChapterModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChapterModel {
  ChapterModel({
    required this.id,
    this.title,
    this.displayOrder,
    this.bookId,
    this.book,
    this.levelId,
  });

  int id;
  String? title;
  int? displayOrder;
  int? bookId;
  BookModel? book;
  int? levelId;

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
        id: json["id"],
        title: json["title"],
        displayOrder: json["displayOrder"],
        bookId: json["bookId"],
        book: json["book"] != null ? BookModel.fromJson(json["book"]) : null,
        levelId: json["levelId"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "displayOrder": displayOrder,
        "bookId": bookId,
        "book": book?.toJson(),
        "levelId": levelId,
      };
}
