import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jasmine/configs/content_convert.dart';

import '../../basic/methods.dart';
import 'images.dart';

class ComicDownloadCard extends StatelessWidget {
  final DownloadAlbum comic;

  const ComicDownloadCard(
    this.comic, {
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
                CcText(comic.name, style: titleStyle),
                Container(height: 4),
                CcText(_author(comic.author), style: authorStyle),
                Container(height: 4),
                _buildCategoryRow(),
                Container(height: 4),
                Text.rich(TextSpan(children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.download, size: 12),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(width: 3),
                  ),
                  TextSpan(
                    text: "${comic.dledImageCount} / ${comic.imageCount}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ])),
                ...(comic.dlStatus == 0)
                    ? [
                        const Text("队列中", style: TextStyle(color: Colors.blue)),
                      ]
                    : [],
                ...(comic.dlStatus == 1)
                    ? [
                        const Text("已下载",
                            style: TextStyle(color: Colors.green)),
                      ]
                    : [],
                ...(comic.dlStatus == 2)
                    ? [
                        const Text("已失败", style: TextStyle(color: Colors.red)),
                      ]
                    : [],
                ...(comic.dlStatus == 3)
                    ? [
                        const Text("删除中",
                            style: TextStyle(color: Colors.orange)),
                      ]
                    : [],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    if (comic is ComicSimple) {
      var _comic = comic as ComicSimple;
      return Row(
        children: [
          ..._c(_comic.category),
          ..._c(_comic.categorySub),
        ],
      );
    }
    return Container();
  }

  List<Widget> _c(ComicSimpleCategory? category) {
    if (category == null || category.title == null) {
      return [];
    }
    return [
      CcText(category.title!),
      Container(width: 15),
    ];
  }
}

String _author(String author) {
  try {
    return List.of(jsonDecode(author)).cast<String>().join(", ");
  } catch (e) {
    return author;
  }
}
