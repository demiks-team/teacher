class ProgressAreaGroupFilterModel {
  int? groupSessionId;
  List<int>? groupEnrollmentIds;

  ProgressAreaGroupFilterModel({this.groupSessionId, this.groupEnrollmentIds});

  Map<String, dynamic> toJson() => {
        "groupSessionId": groupSessionId,
        "groupEnrollmentIds": groupEnrollmentIds,
      };
}
