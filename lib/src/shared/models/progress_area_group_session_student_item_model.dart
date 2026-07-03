class ProgressAreaGroupSessionStudentItemModel {
  int? studentProgressAreaId;
  String? title;
  String? result;
  String? passCondition;
  int? responseType;
  int? formulaType;
  int? responseOptionsId;
  int? levelId;

  ProgressAreaGroupSessionStudentItemModel({
    this.studentProgressAreaId,
    this.title,
    this.result,
    this.passCondition,
    this.responseType,
    this.formulaType,
    this.responseOptionsId,
    this.levelId,
  });

  factory ProgressAreaGroupSessionStudentItemModel.fromJson(Map<String, dynamic> json) =>
      ProgressAreaGroupSessionStudentItemModel(
        studentProgressAreaId: json["studentProgressAreaId"],
        title: json["title"],
        result: json["result"],
        passCondition: json["passCondition"]?.toString(),
        responseType: json["responseType"],
        formulaType: json["formulaType"],
        responseOptionsId: json["responseOptionsId"],
        levelId: json["levelId"],
      );

  Map<String, dynamic> toJson() => {
        "studentProgressAreaId": studentProgressAreaId,
        "title": title,
        "result": result,
        "passCondition": passCondition,
        "responseType": responseType,
        "formulaType": formulaType,
        "responseOptionsId": responseOptionsId,
        "levelId": levelId,
      };
}
