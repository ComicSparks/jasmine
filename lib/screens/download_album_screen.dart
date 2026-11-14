import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/entities.dart';
import 'package:jasmine/configs/content_convert.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/screens/components/comic_download_card.dart';
import 'package:jasmine/screens/components/item_builder.dart';
import 'package:jasmine/screens/components/my_flat_button.dart';

import 'comic_info_screen.dart';
import 'comic_reader_screen.dart';
import 'comic_search_screen.dart';
import 'components/right_click_pop.dart';

class DownloadAlbumScreen extends StatefulWidget {
  final DownloadAlbum album;

  const DownloadAlbumScreen(this.album, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadAlbumScreenState();
}

class _DownloadAlbumScreenState extends State<DownloadAlbumScreen> {
  late Future<DownloadCreate?> _future;
  late Future<ViewLog?> _viewFuture;

  @override
  void initState() {
    _future = methods.downloadById(widget.album.id);
    _viewFuture = methods.findViewLog(widget.album.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CcText(widget.album.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ComicInfoScreen(widget.album.id, null);
                  },
                ),
              );
            },
            icon: const Icon(Icons.settings_ethernet_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          ComicDownloadCard(widget.album),
          _buildTags(List.of(jsonDecode(widget.album.tags)).cast()),
          ...widget.album.description == ""
              ? []
              : [
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: SelectableText(widget.album.description),
                  ),
                ],
          ItemBuilder(
            future: _future,
            onRefresh: () async {},
            successBuilder: (BuildContext context,
                AsyncSnapshot<DownloadCreate?> snapshot) {
              var data = snapshot.requireData!;
              return Column(
                children: [
                  _buildContinueButton(data),
                  _buildSeries(data),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<String> tags) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(10),
          child: Wrap(
            children: tags.map((e) {
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return ComicSearchScreen(initKeywords: e);
                    }),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 3,
                    bottom: 3,
                  ),
                  margin: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    top: 3,
                    bottom: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    border: Border.all(
                      style: BorderStyle.solid,
                      color: Colors.pink.shade400,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: CcText(
                    e,
                    style: TextStyle(
                      color: Colors.pink.shade500,
                      height: 1.4,
                    ),
                    strutStyle: const StrutStyle(
                      height: 1.4,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(DownloadCreate create) {
    return FutureBuilder(
      future: _viewFuture,
      builder: (BuildContext context, AsyncSnapshot<ViewLog?> snapshot) {
        if (snapshot.hasError) {
          return const MyFlatButton(title: "出错了, 点击重试", onPressed: null);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const MyFlatButton(title: "加载中", onPressed: null);
        }
        var log = snapshot.data;
        if (log != null &&
            create.chapters.map((e) => e.id).contains(log.lastViewChapterId)) {
          return MyFlatButton(
            title: "继续阅读",
            onPressed: () {
              _push(create, log.lastViewChapterId, log.lastViewPage);
            },
          );
        }
        return MyFlatButton(
          title: "从头开始",
          onPressed: () {
            _push(create, create.chapters[0].id, 0);
          },
        );
      },
    );
  }

  Widget _buildSeries(DownloadCreate create) {
    if (create.chapters.isEmpty) {
      return MyFlatButton(
        title: "从头开始",
        onPressed: () {
          _push(create, create.album.id, 0);
        },
      );
    }
    var list = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.spaceAround,
      children: create.chapters.map((e) {
        return MaterialButton(
          onPressed: () {
            _push(create, e.id, 0);
          },
          color: Colors.white,
          child: CcBuilder(
            (context) => Text(
              e.sort + (e.name == "" ? "" : (" - ${ccConvert(e.name)}")),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        );
      }).toList(),
    );
    return Container(padding: const EdgeInsets.all(10), child: list);
  }

  void _push(
    DownloadCreate create,
    int seriesId,
    int initRank,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReaderScreen(
          comic: ComicBasic(
            id: create.album.id,
            author: create.album.author.join(" / "),
            description: create.album.description,
            name: create.album.name,
            image: "",
          ),
          series: create.chapters
              .map((e) => Series(id: e.id, name: e.name, sort: e.sort))
              .toList(),
          chapterId: seriesId,
          initRank: initRank,
          loadChapter: (int seriesId) {
            return _loadChapter(create, seriesId);
          },
        ),
      ),
    );
  }

  Future<ChapterResponse> _loadChapter(
      DownloadCreate create, int seriesId) async {
    var i = await methods.dlImageByChapterId(seriesId);
    var name = "";
    for (var element in create.chapters) {
      if (element.id == seriesId) {
        name = element.name;
      }
    }
    return ChapterResponse(
      id: seriesId,
      series: create.chapters
          .map((e) => Series(id: e.id, name: e.name, sort: e.sort))
          .toList(),
      tags: create.album.tags.join(" / "),
      name: name,
      images: i.map((e) => e.name).toList(),
      seriesId: create.album.id,
      isFavorite: false,
      liked: false,
    );
  }
}
