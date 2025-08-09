import 'dart:convert';

import 'package:teacher/src/shared/models/enums.dart';

List<ConfirmIdentityVerificationModel> confirmIdentityVerificationFromJson(
        String str) =>
    List<ConfirmIdentityVerificationModel>.from(json
        .decode(str)
        .map((x) => ConfirmIdentityVerificationModel.fromJson(x)));
String confirmIdentityVerificationToJson(
        List<ConfirmIdentityVerificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConfirmIdentityVerificationModel {
  ConfirmIdentityVerificationModel(
      {this.createdOn, this.verificationResultType, this.tempToken});
  String? createdOn;
  String? tempToken;
  VerificationResultType? verificationResultType;

  factory ConfirmIdentityVerificationModel.fromJson(
          Map<String, dynamic> json) =>
      ConfirmIdentityVerificationModel(
        createdOn: json["createdOn"],
        tempToken: json["tempToken"],
        verificationResultType: json["verificationResultType"] != null
            ? VerificationResultType.values[json["verificationResultType"]]
            : null,
      );
  Map<String, dynamic> toJson() => {
        "createdOn": createdOn,
        "tempToken": tempToken,
        "verificationResultType": verificationResultType
      };
}
