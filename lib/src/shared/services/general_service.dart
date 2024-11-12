import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../authentication/helpers/dio/dio_api.dart';
import '../models/level_model.dart';

class GeneralService {
  Future<List<LevelModel>> getSchoolLevels() async {
    var response = await DioApi()
        .dio
        .get(dotenv.env['api'].toString() + "general/school-levels");

    if (response.statusCode == 200) {
      List decodedList = jsonDecode(json.encode(response.data));

      List<LevelModel> levels = decodedList
          .map(
            (dynamic item) => LevelModel.fromJson(item),
          )
          .toList();
      return levels;
    } else {
      throw "Unable to retrieve levels.";
    }
  }

  Future<String> logError(String errorMessage) async {
    try {
      final response = await DioApi().dio.post(
            dotenv.env['api'].toString() + 'general/log-error',
            data: json.encode(errorMessage),
            options: Options(
              headers: {
                'Content-Type': 'application/json',
              },
            ),
          );

      return response.data; // Assuming the API returns a string.
    } catch (e) {
      return 'Error logging the error: ${e.toString()}';
    }
  }
}
