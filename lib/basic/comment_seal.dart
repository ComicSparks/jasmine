List<String> _commentSealWords = const <String>[];

List<String> currentCommentSealWords() => _commentSealWords;

void updateCommentSealWords(List<String> words) {
  _commentSealWords = words;
}

final _htmlTag = RegExp(r'<[^>]*>');

bool matchCommentSealed(String content) {
  if (_commentSealWords.isEmpty) {
    return false;
  }
  final text = content.replaceAll(_htmlTag, '');
  for (final word in _commentSealWords) {
    if (word.isNotEmpty && text.contains(word)) {
      return true;
    }
  }
  return false;
}
