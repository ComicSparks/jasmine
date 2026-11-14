import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/entities.dart';
import 'package:jasmine/screens/comic_search_screen.dart';

import '../../configs/content_convert.dart';
import '../../configs/display_jmcode.dart';
import '../../configs/search_title_words.dart';
import 'images.dart';

class ComicInfoCard extends StatelessWidget {
  final bool link;
  final ComicBasic comic;

  const ComicInfoCard(
    this.comic, {
    this.link = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontWeight: FontWeight.bold);
    final authorStyle = TextStyle(
      fontSize: 13,
      color: Colors.pink.shade300,
    );
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Card(
            shape: coverShape,
            clipBehavior: Clip.antiAlias,
            child: JM3x4Cover(
              comicId: comic.id,
              width: 100 * 3 / 4,
              height: 100,
            ),
          ),
          Container(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...link
                    ? [
                  CcBuilder((context) => Text.rich(TextSpan(children: [
                    currentSearchTitleWords()
                        ? TextSpan(
                      style: titleStyle,
                      children: titleProcess(comic.name, context),
                      recognizer: LongPressGestureRecognizer()
                        ..onLongPress = () {
                          confirmCopy(context, comic.name);
                        },
                    )
                        : TextSpan(
                      text: ccConvert(comic.name),
                      style: titleStyle,
                      children: [],
                      recognizer: LongPressGestureRecognizer()
                        ..onLongPress = () {
                          confirmCopy(context, comic.name);
                        },
                    ),
                    ...currentDisplayJmcode()
                        ? [
                      TextSpan(
                        text: "  (JM${comic.id})",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade700,
                        ),
                        recognizer: LongPressGestureRecognizer()
                          ..onLongPress = () {
                            confirmCopy(context, "JM${comic.id}");
                          },
                      ),
                    ]
                        : [],
                  ]))),
                ]
                    : [CcText(comic.name, style: titleStyle)],
                Container(height: 4),
                link
                    ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) {
                              return ComicSearchScreen(
                                initKeywords: comic.author,
                              );
                            },
                          ));
                        },
                        onLongPress: () {
                          confirmCopy(context, comic.author);
                        },
                        child: CcText(comic.author, style: authorStyle),
                      )
                    : CcText(comic.author, style: authorStyle),
                Container(height: 4),
                _buildCategoryRow(),
                if (comic.updateAt != null ||
                    comic.addtime != null) ...[
                  Container(height: 4),
                  Text(
                    _buildTimeText(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final category = comic.category;
    final categorySub = comic.categorySub;
    final categoryTitle = category?.title;
    final categorySubTitle = categorySub?.title;
    if ((categoryTitle == null || categoryTitle.isEmpty) &&
        (categorySubTitle == null || categorySubTitle.isEmpty)) {
      return Container();
    }
    late final String text;
    if (categoryTitle != null && categoryTitle.isNotEmpty) {
      if (categorySubTitle != null && categorySubTitle.isNotEmpty) {
        text = "$categoryTitle > $categorySubTitle";
      } else {
        text = categoryTitle;
      }
    } else {
      text = categorySubTitle!;
    }
    return CcText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<TextSpan> titleProcess(String name, BuildContext context) {
    RegExp regExp = RegExp(r"\[[^\]]+\]");
    int start = 0;
    List<TextSpan> result = [];
    Iterable<Match> matches = regExp.allMatches(name);
    for (Match match in matches) {
      // =======
      // if (match.start > start) {
      //   result.add(TextSpan(text: name.substring(start, match.start)));
      // }
      // result.add(TextSpan(
      //   text: name.substring(match.start, match.end),
      //   style: const TextStyle(
      //     color: Colors.blue,
      //     decoration: TextDecoration.underline,
      //   ),
      //   recognizer: TapGestureRecognizer()
      //     ..onTap = () {
      //       Navigator.of(context).push(MaterialPageRoute(
      //         builder: (BuildContext context) {
      //           return ComicSearchScreen(
      //             initKeywords: name.substring(match.start + 1, match.end - 1),
      //           );
      //         },
      //       ));
      //     },
      // ));
      // start = match.end;
      // =======
      if (match.start > start) {
        result.add(TextSpan(
            text: ccConvert(name.substring(start, match.start + 1))));
      }
      result.add(TextSpan(
        text: ccConvert(name.substring(match.start + 1, match.end - 1)),
        style: TextStyle(
          // 30%蓝色 叠加本该有的颜色
          color: Color.alphaBlend(Colors.blue.withOpacity(0.3),
              Theme.of(context).textTheme.bodyMedium!.color!),
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) {
                return ComicSearchScreen(
                  initKeywords: name.substring(match.start + 1, match.end - 1),
                );
              },
            ));
          },
      ));
      if (match.start > start) {
        result.add(
            TextSpan(text: ccConvert(name.substring(match.end - 1, match.end))));
      }
      start = match.end;
    }
    if (start < name.length) {
      result.add(TextSpan(text: ccConvert(name.substring(start))));
    }
    return result;
  }

  String _formatUpdateAt(int updateAt) {
    final milliseconds = updateAt > 1000000000000 ? updateAt : updateAt * 1000;
    final dt = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return "更新: ${dt.year}-$month-$day $hour:$minute";
  }

  String _buildTimeText() {
    final parts = <String>[];
    if (comic.updateAt != null) {
      parts.add(_formatUpdateAt(comic.updateAt!));
    }
    final addtime = comic.addtime;
    if (addtime != null) {
      parts.add("发布: ${_formatUpdateAt(addtime).replaceFirst('更新: ', '')}");
    }
    return parts.join("  |  ");
  }
}
