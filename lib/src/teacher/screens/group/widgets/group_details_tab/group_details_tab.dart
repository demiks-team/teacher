import 'package:flutter/material.dart';

import '../../../../../shared/models/group_model.dart';

class GroupDetailsTab extends StatelessWidget {
  const GroupDetailsTab({super.key, required this.groupModel});

  final GroupModel groupModel;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 35),
        child: Column(children: [
          if (groupModel.title != null)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Text(groupModel.title.toString()),
              ),
            ]),
          if (groupModel.course != null)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Text(groupModel.course!.name.toString()),
              ),
            ]),
        ]));
  }
}
