import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/basic/navigator.dart';
import 'package:jasmine/configs/login.dart';
import 'package:jasmine/screens/comic_search_screen.dart';
import 'package:jasmine/screens/components/comic_info_card.dart';
import 'package:jasmine/screens/components/comic_list.dart';
import 'package:jasmine/screens/components/item_builder.dart';

import '../configs/ignore_view_log.dart';
import 'comic_download_screen.dart';
import 'comic_reader_screen.dart';
import 'components/comic_comments_list.dart';
import 'components/continue_read_button.dart';
import 'components/my_flat_button.dart';
import 'components/right_click_pop.dart';

class ComicInfoScreen extends StatefulWidget {
  final int comicId;
  final ComicBasic? simple;

  const ComicInfoScreen(this.comicId, this.simple, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicInfoScreenState();
}

class _ComicInfoScreenState extends State<ComicInfoScreen> with RouteAware {
  var _favouriteLoading = false;
  var _tabIndex = 0;
  late Future<AlbumResponse> _albumFuture = methods.album(
    widget.comicId,
    ignoreViewLog: currentIgnoreVewLog(),
  );
  late Future<ViewLog?> _viewFuture = methods.findViewLog(widget.comicId);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    setState(() {
      _viewFuture = methods.findViewLog(widget.comicId);
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: widget.simple != null
            ? Text(widget.simple?.name ?? "")
            : FutureBuilder(
                future: _albumFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<AlbumResponse> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done ||
                      snapshot.hasError) {
                    return const Text("");
                  }
                  return Text(snapshot.requireData.name);
                },
              ), //
        actions: [
          FutureBuilder(
            future: _albumFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<AlbumResponse> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasError) {
                return Container();
              }
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return ComicDownloadScreen(
                        snapshot.requireData,
                      );
                    }),
                  );
                },
                icon: const Icon(Icons.download),
              );
            },
          ),
          FutureBuilder(
            future: _albumFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<AlbumResponse> snapshot,
            ) {
              if (snapshot.hasError ||
                  snapshot.connectionState != ConnectionState.done) {
                return Container();
              }
              if (_favouriteLoading) {
                return IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.sync,
                  ),
                );
              }
              return IconButton(
                onPressed: () {
                  _changeFavourite(snapshot.requireData);
                },
                icon: Icon(
                  snapshot.requireData.isFavorite
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.simple != null
                ? FutureBuilder(
                    future: _albumFuture,
                    builder: (a, b) {
                      if (b.connectionState != ConnectionState.done) {
                        return ComicInfoCard(widget.simple!, link: true);
                      }
                      return Container();
                    })
                : Container(),
            ItemBuilder(
              future: _albumFuture,
              onRefresh: () async {
                setState(() {
                  _albumFuture = methods.album(
                    widget.comicId,
                    ignoreViewLog: currentIgnoreVewLog(),
                  );
                });
              },
              successBuilder: (
                BuildContext context,
                AsyncSnapshot<AlbumResponse> snapshot,
              ) {
                AlbumResponse album = snapshot.requireData;

                var _tabs = <Widget>[
                  Tab(text: '章节 (${album.series.length})'),
                  Tab(text: '评论 (${album.commentTotal})'),
                  Tab(text: '推荐 (${album.relatedList.length})'),
                ];

                final _views = [
                  _ComicSerials(
                    albumToSimple(album, widget.simple),
                    album,
                    _viewFuture,
                  ),
                  ComicCommentsList(mode: "manhua", aid: widget.comicId),
                  _ComicRelatedList(album.relatedList),
                ];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ComicInfoCard(
                      albumToSimple(album, widget.simple),
                      link: true,
                    ),
                    _buildTags(album.tags),
                    ...(album.description.isEmpty
                        ? []
                        : [
                            const Divider(),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: SelectableText(album.description),
                            ),
                          ]),
                    const Divider(),
                    DefaultTabController(
                      length: _tabs.length,
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            color:
                                theme.colorScheme.secondary.withOpacity(.025),
                            child: TabBar(
                              tabs: _tabs,
                              indicatorColor: theme.colorScheme.secondary,
                              labelColor: theme.colorScheme.secondary,
                              unselectedLabelColor:
                                  theme.textTheme.bodyMedium?.color,
                              onTap: (val) async {
                                setState(() {
                                  _tabIndex = val;
                                });
                              },
                            ),
                          ),
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 46),
                              child: _views[_tabIndex],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
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
                  child: Text(
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

  Future _changeFavourite(AlbumResponse data) async {
    setState(() {
      _favouriteLoading = true;
    });
    try {
      await methods.setFavorite(data.id);
      setState(() {
        data.isFavorite = !data.isFavorite;
      });
      defaultToast(context, "收藏成功");
      if (data.isFavorite && favData.isNotEmpty) {
        var j = favData.map((i) {
          return MapEntry(i.name, i.fid);
        }).toList();
        j.add(const MapEntry("默认 / 不移动", 0));
        var v = await chooseMapDialog<int>(
          context,
          title: "移动到资料夹",
          values: Map.fromEntries(j),
        );
        if (v != null && v != 0) {
          await methods.comicFavoriteFolderMove(data.id, v);
        }
        defaultToast(context, "移动成功");
      }
    } finally {
      setState(() {
        _favouriteLoading = false;
      });
    }
  }
}

class _ComicSerials extends StatefulWidget {
  final ComicBasic comicSimple;
  final AlbumResponse album;
  final Future<ViewLog?> viewFuture;

  const _ComicSerials(this.comicSimple, this.album, this.viewFuture);

  @override
  State<StatefulWidget> createState() => _ComicSerialsState();
}

class _ComicSerialsState extends State<_ComicSerials> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 20),
        ContinueReadButton(
          viewFuture: widget.viewFuture,
          album: widget.album,
          onChoose: _onChoose,
        ),
        widget.album.series.isEmpty ? _buildOneButton() : _buildSeries(),
      ],
    );
  }

  Widget _buildOneButton() {
    return MyFlatButton(
      title: "开始阅读",
      onPressed: () {
        _push(
          widget.comicSimple,
          widget.album.series,
          widget.comicSimple.id,
          0,
        );
      },
    );
  }

  Widget _buildSeries() {
    return _buildSeriesWrap();
  }

  Widget _buildSeriesWrap() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceAround,
        children: widget.album.series.map((e) {
          return MaterialButton(
            elevation:
                Theme.of(context).colorScheme.brightness == Brightness.light
                    ? 1
                    : 0,
            focusElevation: 0,
            onPressed: () {
              _push(widget.comicSimple, widget.album.series, e.id, 0);
            },
            color: Theme.of(context).colorScheme.brightness == Brightness.light
                ? Colors.white
                : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(.17),
            child: Text(
              e.sort + (e.name == "" ? "" : (" - ${e.name}")),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeriesList() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: widget.album.series.map((e) {
          return MaterialButton(
            elevation:
                Theme.of(context).colorScheme.brightness == Brightness.light
                    ? 1
                    : 0,
            focusElevation: 0,
            onPressed: () {
              _push(widget.comicSimple, widget.album.series, e.id, 0);
            },
            color: Theme.of(context).colorScheme.brightness == Brightness.light
                ? Colors.white
                : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(.17),
            child: Text(
              e.sort + (e.name == "" ? "" : (" - ${e.name}")),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _push(
    ComicBasic comic,
    List<Series> series,
    int seriesId,
    int initRank,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReaderScreen(
          comic: comic,
          series: series,
          chapterId: seriesId,
          initRank: initRank,
          loadChapter: methods.chapter,
        ),
      ),
    );
  }

  void _onChoose(int epOrder, int pictureRank) {
    _push(
      widget.comicSimple,
      widget.album.series,
      epOrder,
      pictureRank,
    );
  }
}

class _ComicRelatedList extends StatefulWidget {
  final List<ComicBasic> relatedList;

  const _ComicRelatedList(this.relatedList);

  @override
  State<StatefulWidget> createState() => _ComicRelatedListState();
}

class _ComicRelatedListState extends State<_ComicRelatedList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ComicList(data: widget.relatedList, inScroll: true);
  }
}
