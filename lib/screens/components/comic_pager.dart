import 'package:event/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/log.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/pager_controller_mode.dart';
import 'package:jasmine/screens/comic_info_screen.dart';
import 'package:jasmine/screens/components/content_builder.dart';
import 'package:jasmine/screens/components/types.dart';

import '../../configs/is_pro.dart';
import 'comic_list.dart';

const _noProMax = 10;

class ComicPager extends StatefulWidget {
  final Future<InnerComicPage> Function(int page) onPage;
  final List<ComicLongPressMenuItem>? longPressMenuItems;
  final List<Widget>? appendList;

  const ComicPager(
      {required this.onPage,
      this.longPressMenuItems,
      this.appendList,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicPagerState();
}

class _ComicPagerState extends State<ComicPager> {
  @override
  void initState() {
    currentPagerControllerModeEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    currentPagerControllerModeEvent.unsubscribe(_setState);
    super.dispose();
  }

  _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (currentPagerControllerMode) {
      case PagerControllerMode.stream:
        return _StreamPager(
            onPage: widget.onPage,
            longPressMenuItems: widget.longPressMenuItems,
            appendList: widget.appendList);
      case PagerControllerMode.pager:
        return _PagerPager(
            onPage: widget.onPage,
            longPressMenuItems: widget.longPressMenuItems,
            appendList: widget.appendList);
    }
  }
}

class _StreamPager extends StatefulWidget {
  final Future<InnerComicPage> Function(int page) onPage;
  final List<ComicLongPressMenuItem>? longPressMenuItems;
  final List<Widget>? appendList;

  const _StreamPager(
      {Key? key,
      required this.onPage,
      this.longPressMenuItems,
      this.appendList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _StreamPagerState();
}

class _StreamPagerState extends State<_StreamPager> {
  int _maxPage = 1;
  int _nextPage = 1;
  int _total = 0;

  bool get _noPro => !isPro && _nextPage > _noProMax;

  var _joining = false;
  var _joinSuccess = true;

  Future _join() async {
    try {
      setState(() {
        _joining = true;
      });
      var response = await widget.onPage(_nextPage);
      if (_nextPage == 1) {
        if (_redirectAid(response.redirectAid, context)) {
          return;
        }
        if (response.total == 0) {
          _maxPage = 1;
        } else {
          _maxPage = (response.total / response.list.length).ceil();
        }
        _total = response.total;
      }
      _nextPage++;
      _data.addAll(response.list);
      setState(() {
        _joinSuccess = true;
        _joining = false;
      });
    } catch (e, st) {
      debugPrient("$e\n$st");
      setState(() {
        _joinSuccess = false;
        _joining = false;
      });
    }
  }

  final List<ComicSimple> _data = [];
  late ScrollController _controller;
  final TextEditingController _textEditController = TextEditingController();

  _jumpPage() {
    if (_total == 0) {
      return;
    }
    if (!isPro) {
      defaultToast(context, "发电才能跳页哦~");
      return;
    }
    _textEditController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Card(
            child: TextField(
              controller: _textEditController,
              decoration: const InputDecoration(
                labelText: "请输入页数：",
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\d+')),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                var text = _textEditController.text;
                if (text.isEmpty || text.length > 7) {
                  return;
                }
                var num = int.parse(text);
                if (num == 0 || num > _maxPage) {
                  return;
                }
                _data.clear();
                _nextPage = num;
                _join();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    proEvent.subscribe(_setState);
    _controller = ScrollController();
    _join();
    super.initState();
  }

  @override
  void dispose() {
    proEvent.unsubscribe(_setState);
    _textEditController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_joining || _nextPage > _maxPage || _noPro) {
      return;
    }
    if (_controller.position.pixels + 100 >
        _controller.position.maxScrollExtent) {
      _join();
    }
  }

  Widget? _buildLoadingCard() {
    if (_noPro) {
      return Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: const Icon(Icons.power_off_outlined),
            ),
            const Text(
              '$_noProMax页以上需要发电鸭',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_joining) {
      return Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: const CupertinoActivityIndicator(
                radius: 14,
              ),
            ),
            const Text('加载中'),
          ],
        ),
      );
    }
    if (!_joinSuccess) {
      return Card(
        child: InkWell(
          onTap: () {
            _join();
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: const Icon(Icons.sync_problem_rounded),
              ),
              const Text('出错, 点击重试'),
            ],
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPagerBar(),
        Expanded(
          child: ComicList(
            controller: _controller,
            onScroll: _onScroll,
            data: _data,
            appendList: _buildLoadingCard() != null
                ? [
                    _buildLoadingCard()!,
                    ...(widget.appendList ?? []),
                  ]
                : widget.appendList,
            longPressMenuItems: widget.longPressMenuItems,
          ),
        ),
      ],
    );
  }

  PreferredSize _buildPagerBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(30),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: .5,
              style: BorderStyle.solid,
              color: Colors.grey[200]!,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: _jumpPage,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("已加载 ${_nextPage - 1} / $_maxPage 页"),
                Text("已加载 ${_data.length} / $_total 项"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setState(EventArgs? args) {
    setState(() {});
  }
}

class _PagerPager extends StatefulWidget {
  final Future<InnerComicPage> Function(int page) onPage;
  final List<ComicLongPressMenuItem>? longPressMenuItems;
  final List<Widget>? appendList;

  const _PagerPager(
      {Key? key,
      required this.onPage,
      this.longPressMenuItems,
      this.appendList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PagerPagerState();
}

class _PagerPagerState extends State<_PagerPager> {
  final TextEditingController _textEditController =
      TextEditingController(text: '');
  late int _currentPage = 1;
  late int _maxPage = 1;
  late final List<ComicSimple> _data = [];
  late Future _pageFuture = _load();
  late Key _pageKey = UniqueKey();

  Future<dynamic> _load() async {
    var response = await widget.onPage(_currentPage);
    setState(() {
      if (_currentPage == 1) {
        if (_redirectAid(response.redirectAid, context)) {
          return;
        }
        if (response.total == 0) {
          _maxPage = 1;
        } else {
          _maxPage = (response.total / response.list.length).ceil();
        }
      }
      _data.clear();
      _data.addAll(response.list);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentBuilder(
      key: _pageKey,
      future: _pageFuture,
      onRefresh: () async {
        setState(() {
          _pageFuture = _load();
          _pageKey = UniqueKey();
        });
      },
      successBuilder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Scaffold(
          appBar: _buildPagerBar(),
          body: ComicList(
            appendList: widget.appendList,
            data: _data,
            longPressMenuItems: widget.longPressMenuItems,
          ),
        );
      },
    );
  }

  PreferredSize _buildPagerBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: .5,
              style: BorderStyle.solid,
              color: Colors.grey[200]!,
            ),
          ),
        ),
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (!isPro) {
                    defaultToast(context, "发电才能跳页哦~");
                    return;
                  }
                  _textEditController.clear();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Card(
                          child: TextField(
                            controller: _textEditController,
                            decoration: const InputDecoration(
                              labelText: "请输入页数：",
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'\d+')),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('取消'),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                              var text = _textEditController.text;
                              if (text.isEmpty || text.length > 5) {
                                return;
                              }
                              var num = int.parse(text);
                              if (num == 0 || num > _maxPage) {
                                return;
                              }
                              setState(() {
                                _currentPage = num;
                                _pageFuture = _load();
                                _pageKey = UniqueKey();
                              });
                            },
                            child: const Text('确定'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Text("第 $_currentPage / $_maxPage 页"),
                  ],
                ),
              ),
              Row(
                children: [
                  MaterialButton(
                    minWidth: 0,
                    onPressed: () {
                      if (_currentPage > 1) {
                        setState(() {
                          _currentPage = _currentPage - 1;
                          _pageFuture = _load();
                          _pageKey = UniqueKey();
                        });
                      }
                    },
                    child: const Text('上一页'),
                  ),
                  MaterialButton(
                    minWidth: 0,
                    onPressed: () {
                      if (_currentPage < _maxPage) {
                        if (!isPro && _currentPage + 1 > _noProMax) {
                          defaultToast(context, "$_noProMax页以上需要发电鸭");
                          return;
                        }
                        setState(() {
                          _currentPage = _currentPage + 1;
                          _pageFuture = _load();
                          _pageKey = UniqueKey();
                        });
                      }
                    },
                    child: const Text('下一页'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _redirectAid(int? redirectAid, BuildContext context) {
  if (redirectAid != null) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
      return ComicInfoScreen(redirectAid, null);
    }));
    return true;
  }
  return false;
}
