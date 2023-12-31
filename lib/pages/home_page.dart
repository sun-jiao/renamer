import 'package:flutter/material.dart';

import '../rules/rule.dart';
import '../tools/file_metadata.dart';
import 'rules_page.dart';
import 'files_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final GlobalKey<FilesPageState> filesKey = GlobalKey<FilesPageState>();
  final GlobalKey<RulesPageState> rulesKey = GlobalKey<RulesPageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: FilesPage(
              key: filesKey,
              getNewName: (String name, FileMetadata metadata) async {
                for (Rule rule in rulesKey.currentState?.rules ?? []) {
                  name = await rule.newName(name, metadata: metadata);
                }
                return name;
              },
              clearRules: () {
                rulesKey.currentState?.clearRule();
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: RulesPage(
              key: rulesKey,
              onRuleChanged: () {
                filesKey.currentState?.update();
              },
            ),
          ),
        ],
      ),
    );
  }
}
