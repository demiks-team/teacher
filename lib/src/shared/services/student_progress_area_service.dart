import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../authentication/helpers/dio/dio_api.dart';
import '../models/progress_area_group_filter_model.dart';
import '../models/progress_area_group_session_model.dart';

class StudentProgressAreaService {
  Future<bool> hasAnyProgressArea(int? courseId) async {
    String url = "${dotenv.env['api']}student-progress-area/has-any-progress-area";
    if (courseId != null) {
      url += "?courseId=$courseId";
    }
    var response = await DioApi().dio.get(url);
    if (response.statusCode == 200) {
      return response.data == true;
    }
    return false;
  }

  Future<ProgressAreaGroupSessionModel> getAttendanceStudentProgressAreas(
      ProgressAreaGroupFilterModel filter) async {
    Response response = await DioApi().dio.post(
      '${dotenv.env['api']}student-progress-area/attendance',
      options: Options(headers: {HttpHeaders.contentTypeHeader: "application/json"}),
      data: jsonEncode(filter.toJson()),
    );
    if (response.statusCode == 200) {
      return ProgressAreaGroupSessionModel.fromJson(
          jsonDecode(json.encode(response.data)));
    }
    throw Exception('Unable to retrieve student progress areas.');
  }

  Future<bool> upsertProgressAreaGroupSessionStudents(
      ProgressAreaGroupSessionModel model) async {
    Response response = await DioApi().dio.put(
      '${dotenv.env['api']}student-progress-area/attendance',
      options: Options(headers: {HttpHeaders.contentTypeHeader: "application/json"}),
      data: jsonEncode(model.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
