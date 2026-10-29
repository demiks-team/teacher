import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../authentication/helpers/dio/dio_api.dart';

class MyInlinguaService {
  // A one-off link that signs the teacher into my.inlingua; it expires, so it is fetched on every tap.
  Future<String> signIn() async {
    var response = await DioApi().dio.post("${dotenv.env['api']}my-inlingua/sign-in");

    if (response.statusCode == 200 && response.data["url"] != null) {
      return response.data["url"] as String;
    } else {
      throw Exception('Unable to open my.inlingua.');
    }
  }
}
