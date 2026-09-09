class SchoolAttendanceSettingsModel {
  SchoolAttendanceSettingsModel({this.showLateAttendance, this.showLeftEarlyAttendance, this.allowSessionMaterialLink});
  bool? showLateAttendance;
  bool? showLeftEarlyAttendance;
  bool? allowSessionMaterialLink;

  factory SchoolAttendanceSettingsModel.fromJson(Map<String, dynamic> json) =>
      SchoolAttendanceSettingsModel(
        showLateAttendance: json["showLateAttendance"],
        showLeftEarlyAttendance: json["showLeftEarlyAttendance"],
        allowSessionMaterialLink: json["allowSessionMaterialLink"],
      );

  Map<String, dynamic> toJson() => {
        "showLateAttendance": showLateAttendance,
        "showLeftEarlyAttendance": showLeftEarlyAttendance,
        "allowSessionMaterialLink": allowSessionMaterialLink,
      };
}
