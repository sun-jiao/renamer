import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'file_metadata.dart';

extension ExTextEditingController on TextEditingController {
  void insertTag(String tag, BuildContext context) {
    final int cursorPos = selection.base.offset;
    final matches = metadataTagRegex.allMatches(text);
    for (final match in matches) {
      if (cursorPos > match.start && cursorPos < match.end) {
        if (Platform.isAndroid) {
          Fluttertoast.showToast(msg: 'Do not insert a tag inside another tag.');
        } else {
          toastification.show(
            context: context,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            title: const Text('Do not insert a tag inside another tag.'),
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
        return;
      }
    }
    value = value.copyWith(
      text: text.replaceRange(max(cursorPos, 0), max(cursorPos, 0), tag),
      selection: TextSelection.fromPosition(
        TextPosition(offset: max(cursorPos, 0) + tag.length),
      ),
    );
  }
}
