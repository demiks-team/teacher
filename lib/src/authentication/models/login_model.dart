import 'dart:convert';

List<LoginModel> loginFromJson(String str) =>
    List<LoginModel>.from(
        json.decode(str).map((x) => LoginModel.fromJson(x)));
String loginToJson(List<LoginModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LoginModel {
  LoginModel({
    this.email,
    this.password,
    this.tempToken,
    this.studentLanguage,
    this.code,
    this.localTimeZone,
  });

  String? email;
  String? password;
  String? tempToken;
  String? studentLanguage;
  String? code;
  String? localTimeZone;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      LoginModel(
        email: json["email"],
        password: json["password"],
        tempToken: json["tempToken"],
        studentLanguage: json["studentLanguage"],
        code: json["code"],
        localTimeZone: json["localTimeZone"],
      );
  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "tempToken": tempToken,
        "studentLanguage": studentLanguage,
        "code": code,
        "localTimeZone": localTimeZone,
      };
}
