import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/comment_seal.dart';
import 'package:jasmine/screens/comment_seal_words_screen.dart';

import '../basic/methods.dart';

const _propertyName = "commentSealWords";

Future<void> initCommentSealConfig() async {
  final text = await methods.loadProperty(_propertyName);
  updateCommentSealWords(_parseStringArray(text));
}

List<String> _parseStringArray(String value) {
  final text = value.trim();
  if (text.isEmpty) {
    return <String>[];
  }
  try {
    final decoded = jsonDecode(text);
    if (decoded is List) {
      return decoded
          .map((e) => "$e".trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
  } catch (_) {}
  return <String>[];
}

Future<void> saveCommentSealWords(List<String> values) async {
  final words = _normalize(values);
  await methods.saveProperty(_propertyName, jsonEncode(words));
  updateCommentSealWords(words);
}

List<String> _normalize(List<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in values) {
    final word = value.trim();
    if (word.isEmpty || !seen.add(word)) {
      continue;
    }
    result.add(word);
  }
  return result;
}

Widget commentSealWordsSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      final words = currentCommentSealWords();
      return ListTile(
        title: const Text("根据关键词封印评论"),
        subtitle: Text(
          words.isEmpty ? "未设置" : words.join("、"),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CommentSealWordsScreen(),
            ),
          );
          setState(() {});
        },
      );
    },
  );
}
