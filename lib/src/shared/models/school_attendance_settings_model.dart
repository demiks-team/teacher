class SchoolAttendanceSettingsModel {
  SchoolAttendanceSettingsModel({this.showLateAttendance, this.showLeftEarlyAttendance});
  bool? showLateAttendance;
  bool? showLeftEarlyAttendance;

  factory SchoolAttendanceSettingsModel.fromJson(Map<String, dynamic> json) =>
      SchoolAttendanceSettingsModel(
        showLateAttendance: json["showLateAttendance"],
        showLeftEarlyAttendance: json["showLeftEarlyAttendance"],
      );

  Map<String, dynamic> toJson() => {
        "showLateAttendance": showLateAttendance,
        "showLeftEarlyAttendance": showLeftEarlyAttendance,
      };
}
