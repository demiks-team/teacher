import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:teacher/src/shared/models/user_school_model.dart';
import '../../authentication/helpers/dio/dio_api.dart';


class UserService {


  Future<List<UserSchoolModel>>
      getUserSchools() async {
    var response = await DioApi().dio.get("${dotenv.env['api']}user/schools");

    if (response.statusCode == 200) {
      List decodedList = jsonDecode(json.encode(response.data));

      List<UserSchoolModel> userSchools = decodedList
          .map(
            (dynamic item) => UserSchoolModel.fromJson(item),
          )
          .toList();
      return userSchools;
    } else {
      throw "Unable to retrieve data.";
    }
  }


}
