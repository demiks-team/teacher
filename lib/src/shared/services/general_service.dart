import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../authentication/helpers/dio/dio_api.dart';
import '../models/level_model.dart';

class GeneralService {
  Future<List<LevelModel>> getSchoolLevels() async {
    var response = await DioApi()
        .dio
        .get(dotenv.env['api'].toString() + "general/schoolLevels");

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
}
