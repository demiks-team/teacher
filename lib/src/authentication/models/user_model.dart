import 'dart:convert';

import '../../shared/models/school_model.dart';

List<UserModel> userFromJson(String str) =>
    List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));
String userToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModel {
  UserModel(
      {required this.id,
      this.fullName,
      this.image,
      this.token,
      this.refresh,
      this.languageId,
      this.school,
      this.schoolId});

  int id;
  String? fullName;
  String? image;
  int? languageId;
  String? token;
  String? refresh;
  int? schoolId;
  SchoolModel? school;
  // int? subscriptionPlan;
  // String? imageName;
  // bool? hasPassword;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        fullName: json["fullName"],
        image: json["image"],
        token: json["token"],
        refresh: json["refresh"],
        languageId: json["languageId"],
        schoolId: json["schoolId"],
        school: json["school"] != null
            ? SchoolModel.fromJson(json["school"])
            : null,
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
        "image": image,
        "token": token,
        "refresh": refresh,
        "languageId": languageId,
        "schoolId": schoolId,
        "school": school != null ? school!.toJson() : null,
      };
}
