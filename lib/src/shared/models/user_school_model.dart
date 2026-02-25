import 'dart:convert';

List<UserSchoolModel> dataFromJson(String str) => List<UserSchoolModel>.from(
  json.decode(str).map((x) => UserSchoolModel.fromJson(x)),
);
String dataToJson(List<UserSchoolModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserSchoolModel {
  UserSchoolModel({
    required this.id,
    this.name,
    this.isCurrentSchool,
    this.logoImageName,
  });

  int id;
  String? name;
  bool? isCurrentSchool;
  String? logoImageName;

  factory UserSchoolModel.fromJson(Map<String, dynamic> json) =>
      UserSchoolModel(
        id: json["id"],
        name: json["name"],
        isCurrentSchool: json["isCurrentSchool"],
        logoImageName: json["logoImageName"],
      );
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isCurrentSchool": isCurrentSchool,
    "logoImageName": logoImageName,
  };
}
