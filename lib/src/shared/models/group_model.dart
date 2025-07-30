import 'dart:convert';

import 'package:teacher/src/shared/models/book_model.dart';
import 'package:teacher/src/shared/models/contact-model.dart';

import 'course_model.dart';
import 'room_model.dart';
import 'school_model.dart';
import 'teacher_model.dart';
import 'enums.dart';

List<GroupModel> groupFromJson(String str) =>
    List<GroupModel>.from(json.decode(str).map((x) => GroupModel.fromJson(x)));
String groupToJson(List<GroupModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupModel {
  GroupModel(
      {required this.id,
      this.title,
      this.schoolId,
      this.school,
      this.teacherId,
      this.teacher,
      this.courseId,
      this.course,
      this.roomId,
      this.room,
      this.contactId,
      this.contact,
      this.numberOfSessions,
      this.address,
      this.classDurationType,
      this.bookId,
      this.book});
  int id;
  String? title;
  int? schoolId;
  SchoolModel? school;
  int? teacherId;
  TeacherModel? teacher;
  int? courseId;
  CourseModel? course;
  int? roomId;
  RoomModel? room;
  int? contactId;
  ContactModel? contact;
  double? numberOfSessions;
  String? address;
  ClassDurationType? classDurationType;
  int? bookId;
  BookModel? book;

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
        id: json["id"],
        title: json["title"],
        schoolId: json["schoolId"],
        school: json["school"] != null
            ? SchoolModel.fromJson(json["school"])
            : null,
        teacherId: json["teacherId"],
        teacher: json["teacher"] != null
            ? TeacherModel.fromJson(json["teacher"])
            : null,
        courseId: json["programId"],
        course: json["program"] != null
            ? CourseModel.fromJson(json["program"])
            : null,
        roomId: json["roomId"],
        room: json["room"] != null ? RoomModel.fromJson(json["room"]) : null,
        contactId: json["contactId"],
        contact: json["contact"] != null
            ? ContactModel.fromJson(json["contact"])
            : null,
        numberOfSessions: json["numberOfSessions"],
        address: json["address"],
        classDurationType: json["classDurationType"] != null
            ? ClassDurationType.values[json["classDurationType"]]
            : null,
        bookId: json["bookId"],
        book: json["book"] != null ? BookModel.fromJson(json["book"]) : null,
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "schoolId": schoolId,
        "school": school?.toJson(),
        "teacherId": teacherId,
        "teacher": teacher?.toJson(),
        "programId": courseId,
        "program": course?.toJson(),
        "roomId": roomId,
        "room": room?.toJson(),
        "contactId": contactId,
        "contact": contact?.toJson(),
        "numberOfSessions": numberOfSessions,
        "address": address,
        "classDurationType": classDurationType,
        "bookId": bookId,
        "book": book?.toJson(),
      };
}
