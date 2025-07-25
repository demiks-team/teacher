import 'dart:convert';

import 'package:teacher/src/shared/models/enums.dart';

List<IdentityVerificationModel> identityVerificationFromJson(String str) =>
    List<IdentityVerificationModel>.from(
        json.decode(str).map((x) => IdentityVerificationModel.fromJson(x)));
String identityVerificationToJson(List<IdentityVerificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class IdentityVerificationModel {
  IdentityVerificationModel(
      {this.identifier, this.communicationMethod, this.requestType});
  String? identifier;
  CommunicationMethod? communicationMethod;
  VerificationRequestType? requestType;

  factory IdentityVerificationModel.fromJson(Map<String, dynamic> json) =>
      IdentityVerificationModel(
        identifier: json["identifier"],
        communicationMethod: json["communicationMethod"] != null
            ? CommunicationMethod.values[json["communicationMethod"]]
            : null,
        requestType: json["requestType"] != null
            ? VerificationRequestType.values[json["requestType"]]
            : null,
      );
  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "communicationMethod": communicationMethod?.index,
        "requestType": requestType?.index
      };
}
