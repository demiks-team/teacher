import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../authentication/helpers/dio/dio_api.dart';
import '../models/group_model.dart';

class GroupService {
  Future<List<GroupModel>> getGroups() async {
    var response =
        await DioApi().dio.get(dotenv.env['api'].toString() + "groups/list");

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
        .get(dotenv.env['api'].toString() + "groups/group/" + id.toString());

    Map<String, dynamic> decodedList = jsonDecode(json.encode(response.data));

    if (response.statusCode == 200) {
      return GroupModel.fromJson(decodedList);
    } else {
      throw Exception('Unable to retrieve class.');
    }
  }
}
