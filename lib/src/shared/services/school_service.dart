import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/src/shared/models/attendance_settings_model.dart';

import '../../authentication/helpers/dio/dio_api.dart';

class SchoolService {
  Future<AttendanceSettingsModel?> getAttendanceSettings() async {
    var response = await DioApi()
        .dio
        .get(dotenv.env['api'].toString() + "school/attendance-settings");

    if (response.data.toString().isNotEmpty) {
      Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));
      if (response.statusCode == 200) {
        return AttendanceSettingsModel.fromJson(decodedList);
      } else {
        throw "Unable to retrieve data.";
      }
    } else {
      return null;
    }
  }
}
