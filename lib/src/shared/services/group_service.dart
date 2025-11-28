import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/src/shared/models/dashboard_group_model.dart';
import 'package:teacher/src/shared/models/group_session_model.dart';

import '../../authentication/helpers/dio/dio_api.dart';
import '../models/attendance_creation_model.dart';
import '../models/group_enrollment_model.dart';
import '../models/group_model.dart';

class GroupService {
  Future<List<GroupModel>> getGroups() async {
    var response =
        await DioApi().dio.get("${dotenv.env['api']}groups/list");

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));
      var classList = decodedList["data"] as List;

      List<GroupModel> groups = classList
          .map(
            (dynamic item) => GroupModel.fromJson(item),
          )
          .toList();
      return groups;
    } else {
      throw "Unable to retrieve groups.";
    }
  }

  Future<GroupModel> getGroup(int id) async {
    var response = await DioApi()
        .dio
        .get("${dotenv.env['api']}groups/group/$id");

    Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));

    if (response.statusCode == 200) {
      return GroupModel.fromJson(decodedList);
    } else {
      throw Exception('Unable to retrieve class.');
    }
  }

  Future<List<DashboardGroupModel>> getListOfTodaysGroups() async {
    var response = await DioApi()
        .dio
        .get("${dotenv.env['api']}groups/group/listoftodaysgroups");

    if (response.statusCode == 200) {
      List decodedList = jsonDecode(json.encode(response.data));
      List<DashboardGroupModel> dashboardSessionList = decodedList
          .map(
            (dynamic item) => DashboardGroupModel.fromJson(item),
          )
          .toList();
      return dashboardSessionList;
    } else {
      throw "Unable to retrieve groups.";
    }
  }

  Future<List<GroupSessionModel>>
      getPastSessionsGroupsWithoutAttendances() async {
    var response = await DioApi().dio.get("${dotenv.env['api']}groups/group/pastsessionsgroupswithoutattendances");

    if (response.statusCode == 200) {
      List decodedList = jsonDecode(json.encode(response.data));

      List<GroupSessionModel> groupSessions = decodedList
          .map(
            (dynamic item) => GroupSessionModel.fromJson(item),
          )
          .toList();
      return groupSessions;
    } else {
      throw "Unable to retrieve groups.";
    }
  }

  Future<AttendanceCreationModel> getSessionStudents(int groupSessionId) async {
    var response = await DioApi().dio.get("${dotenv.env['api']}groups/sessions/$groupSessionId/students");

    Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));

    if (response.statusCode == 200) {
      return AttendanceCreationModel.fromJson(decodedList);
    } else {
      throw Exception('Unable to retrieve sessions.');
    }
  }

  Future<List<GroupEnrollmentModel>> getGroupEnrollments(int groupId) async {
    var response = await DioApi().dio.get("${dotenv.env['api']}groups/group/enrollments/$groupId");

    if (response.statusCode == 200) {
      List decodedList = jsonDecode(json.encode(response.data));

      List<GroupEnrollmentModel> groupEnrollments = decodedList
          .map(
            (dynamic item) => GroupEnrollmentModel.fromJson(item),
          )
          .toList();
      return groupEnrollments;
    } else {
      throw "Unable to retrieve group enrollments.";
    }
  }

  Future<bool> saveAttendance(AttendanceCreationModel attendances) async {
    Response response = await DioApi()
        .dio
        .post('${dotenv.env['api']}groups/attendance',
            options: Options(headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            }),
            data: jsonEncode(attendances.toJson()));

    if (response.statusCode == 200) {
      // Attendance saved successfully
      return true;
    } else {
      return false;
    }
  }
}
