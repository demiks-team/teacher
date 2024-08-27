import 'dart:convert';

List<ContactModel> contactFromJson(String str) => List<ContactModel>.from(
    json.decode(str).map((x) => ContactModel.fromJson(x)));
String contactToJson(List<ContactModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ContactModel {
  ContactModel({
    required this.id,
    this.fullName,
  });
  int id;
  String? fullName;

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        id: json["id"],
        fullName: json["fullName"],
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": fullName,
      };
}
