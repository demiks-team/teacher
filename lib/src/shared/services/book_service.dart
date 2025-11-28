import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/src/shared/models/chapter_model.dart';

import '../../authentication/helpers/dio/dio_api.dart';

class BookService {
  Future<List<ChapterModel>> getChapters(int bookId) async {
    var response = await DioApi().dio.get("${dotenv.env['api']}book/$bookId/chapters");

    if (response.statusCode == 200) {
      List decodedList = jsonDecode(json.encode(response.data));

      List<ChapterModel> chapters = decodedList
          .map(
            (dynamic item) => ChapterModel.fromJson(item),
          )
          .toList();
      return chapters;
    } else {
      throw "Unable to retrieve chapters.";
    }
  }
}
