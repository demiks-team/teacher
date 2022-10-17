import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../authentication/helpers/dio/dio_api.dart';
import '../models/student_model.dart';

class StudentService {
  Future<List<StudentModel>> getStudents() async {
    var response =
        await DioApi().dio.get(dotenv.env['api'].toString() + "student");

    if (response.statusCode == 200) {
      Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));
      var studentList = decodedList["items"] as List;

      List<StudentModel> students = studentList
          .map(
            (dynamic item) => StudentModel.fromJson(item),
          )
          .toList();
      return students;
    } else {
      throw "Unable to retrieve students.";
    }
  }
}
