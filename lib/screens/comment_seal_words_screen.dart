import 'package:flutter/material.dart';
import 'package:jasmine/basic/comment_seal.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/configs/comment_seal.dart';

import 'components/right_click_pop.dart';

class CommentSealWordsScreen extends StatefulWidget {
  const CommentSealWordsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentSealWordsScreenState();
}

class _CommentSealWordsScreenState extends State<CommentSealWordsScreen> {
  final TextEditingController _textController = TextEditingController();

  Future<void> _persist(List<String> words) async {
    await saveCommentSealWords(words);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _addWord() async {
    final word = _textController.text.trim();
    if (word.isEmpty) {
      return;
    }
    final words = List<String>.from(currentCommentSealWords());
    if (!words.contains(word)) {
      words.add(word);
      await _persist(words);
    }
    _textController.clear();
  }

  Future<void> _editWord(int index) async {
    final words = List<String>.from(currentCommentSealWords());
    final edited = await displayTextInputDialog(
      context,
      title: '修改关键词',
      src: words[index],
    );
    if (edited == null) {
      return;
    }
    final word = edited.trim();
    if (word.isEmpty || word == words[index]) {
      return;
    }
    words[index] = word;
    await _persist(words);
  }

  Future<void> _removeWord(int index) async {
    final words = List<String>.from(currentCommentSealWords());
    words.removeAt(index);
    await _persist(words);
  }

  Future<void> _clearAll() async {
    if (!await confirmDialog(context, "清空关键词", "确定清空全部评论封印关键词吗?")) {
      return;
    }
    await _persist(<String>[]);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    final words = currentCommentSealWords();
    return Scaffold(
      appBar: AppBar(
        title: const Text("根据关键词封印评论"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: words.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "输入关键词",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addWord(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addWord,
                ),
              ],
            ),
          ),
          Expanded(
            child: words.isEmpty
                ? const Center(child: Text("未设置"))
                : ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(words[index]),
                        onTap: () => _editWord(index),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeWord(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
