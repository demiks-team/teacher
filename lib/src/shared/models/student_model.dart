import 'dart:convert';

List<StudentModel> studentFromJson(String str) => List<StudentModel>.from(
    json.decode(str).map((x) => StudentModel.fromJson(x)));
String studentToJson(List<StudentModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudentModel {
  StudentModel({
    required this.id,
    this.fullName,
    this.nameIdentification,
    this.phoneNumber,
    this.email,
    this.levelId,
  });
  int id;
  String? fullName;
  String? nameIdentification;
  String? phoneNumber;
  String? email;
  int? levelId;

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
        id: json["id"],
        fullName: json["fullName"],
        nameIdentification: json["nameIdentification"],
        phoneNumber: json["phoneNumber"],
        email: json["email"],
        levelId: json["levelId"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "nameIdentification": nameIdentification,
        "phoneNumber": phoneNumber,
        "email": email,
        "levelId": levelId,
      };
}
