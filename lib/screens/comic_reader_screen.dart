import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:another_xlider/another_xlider.dart';
import 'package:event/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/reader_controller_type.dart';
import 'package:jasmine/configs/reader_direction.dart';
import 'package:jasmine/configs/reader_slider_position.dart';
import 'package:jasmine/configs/reader_type.dart';
import 'package:jasmine/configs/two_page_direction.dart';
import 'package:jasmine/screens/components/content_error.dart';
import 'package:jasmine/screens/components/content_loading.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../configs/ignore_view_log.dart';
import '../configs/no_animation.dart';
import '../configs/volume_key_control.dart';
import 'components/images.dart';
import 'components/right_click_pop.dart';

class ComicReaderScreen extends StatefulWidget {
  final ComicBasic comic;
  final List<Series> series;
  final int chapterId;
  final int initRank;
  final Future<ChapterResponse> Function(int seriesId) loadChapter;
  final bool fullScreenOnInit;

  const ComicReaderScreen({
    Key? key,
    required this.comic,
    required this.series,
    required this.chapterId,
    required this.initRank,
    required this.loadChapter,
    this.fullScreenOnInit = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ComicReaderScreenState();
}

class _ComicReaderScreenState extends State<ComicReaderScreen> {
  late ReaderType _readerType;
  late ReaderDirection _readerDirection;
  late Future<ChapterResponse> _chapterFuture;

  void _load() {
    setState(() {
      _readerType = currentReaderType;
      _readerDirection = currentReaderDirection;
      _chapterFuture = widget.loadChapter(widget.chapterId);
    });
  }

  @override
  void initState() {
    if (currentIgnoreVewLog()) {
      late Future<AlbumResponse> _albumFuture = methods.album(
        widget.comic.id,
      );
      _albumFuture.then((value) {
          methods.updateViewLog(widget.comic.id, widget.chapterId, widget.initRank);
      });
    } else {
      methods.updateViewLog(widget.comic.id, widget.chapterId, widget.initRank);
    }
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return FutureBuilder(
      future: _chapterFuture,
      builder: (BuildContext context, AsyncSnapshot<ChapterResponse> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: ContentError(
              onRefresh: () async {
                setState(() {
                  _chapterFuture = methods.chapter(widget.chapterId);
                });
              },
              error: snapshot.error,
              stackTrace: snapshot.stackTrace,
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(),
            body: const ContentLoading(),
          );
        }
        final chapter = snapshot.requireData;
        final screen = Scaffold(
          backgroundColor: Colors.black,
          body: _ComicReader(
            comicId: widget.comic.id,
            chapter: chapter,
            startIndex: widget.initRank,
            reload: (int index, bool fullScreen) async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
                  return ComicReaderScreen(
                    comic: widget.comic,
                    series: widget.series,
                    chapterId: widget.chapterId,
                    initRank: index,
                    loadChapter: widget.loadChapter,
                    fullScreenOnInit: fullScreen,
                  );
                }),
              );
            },
            onChangeEp: (int id, bool fullScreen) async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
                  return ComicReaderScreen(
                    comic: widget.comic,
                    series: widget.series,
                    chapterId: id,
                    initRank: 0,
                    loadChapter: widget.loadChapter,
                    fullScreenOnInit: fullScreen,
                  );
                }),
              );
            },
            readerType: _readerType,
            readerDirection: _readerDirection,
            fullScreenOnInit: widget.fullScreenOnInit,
          ),
        );
        return readerKeyboardHolder(screen);
      },
    );
  }
}

////////////////////////////////

// 仅支持安卓
// 监听后会拦截安卓手机音量键
// 仅最后一次监听生效
// event可能为DOWN/UP

var _volumeListenCount = 0;

void _onVolumeEvent(dynamic args) {
  _readerControllerEvent.broadcast(_ReaderControllerEventArgs("$args"));
}

EventChannel volumeButtonChannel = const EventChannel("volume_button");
StreamSubscription? volumeS;

void addVolumeListen() {
  _volumeListenCount++;
  if (_volumeListenCount == 1) {
    volumeS =
        volumeButtonChannel.receiveBroadcastStream().listen(_onVolumeEvent);
  }
}

void delVolumeListen() {
  _volumeListenCount--;
  if (_volumeListenCount == 0) {
    volumeS?.cancel();
  }
}

Widget readerKeyboardHolder(Widget widget) {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    widget = RawKeyboardListener(
      focusNode: FocusNode(),
      child: widget,
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            _readerControllerEvent.broadcast(_ReaderControllerEventArgs("UP"));
          }
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            _readerControllerEvent
                .broadcast(_ReaderControllerEventArgs("DOWN"));
          }
        }
      },
    );
  }
  return widget;
}

////////////////////////////////

Event<_ReaderControllerEventArgs> _readerControllerEvent =
    Event<_ReaderControllerEventArgs>();

class _ReaderControllerEventArgs extends EventArgs {
  final String key;

  _ReaderControllerEventArgs(this.key);
}

class _ComicReader extends StatefulWidget {
  final int comicId;
  final ChapterResponse chapter;
  final FutureOr Function(int, bool) reload;
  final FutureOr Function(int, bool) onChangeEp;
  final int startIndex;
  final ReaderType readerType;
  final ReaderDirection readerDirection;
  final bool fullScreenOnInit;

  const _ComicReader({
    required this.comicId,
    required this.chapter,
    required this.reload,
    required this.onChangeEp,
    required this.startIndex,
    required this.readerType,
    required this.readerDirection,
    required this.fullScreenOnInit,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    switch (readerType) {
      case ReaderType.webtoon:
        return _ComicReaderWebToonState();
      case ReaderType.gallery:
        return _ComicReaderGalleryState();
      case ReaderType.webToonFreeZoom:
        return _ListViewReaderState();
      case ReaderType.twoPageGallery:
        return _TwoPageGalleryReaderState();
    }
  }
}

abstract class _ComicReaderState extends State<_ComicReader> {
  bool _sliderDragging = false;
  Widget _buildViewer();

  _needJumpTo(int pageIndex, bool animation);

  late bool _fullScreen;
  late int _current;
  late int _slider;

  Future _onFullScreenChange(bool fullScreen) async {
    setState(() {
      if (Platform.isAndroid || Platform.isIOS) {
        if (fullScreen) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: [],
          );
        } else {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.edgeToEdge,
            overlays: SystemUiOverlay.values,
          );
        }
      }
      _fullScreen = fullScreen;
    });
  }

  void _onCurrentChange(int index) {
    if (index != _current) {
      setState(() {
        _current = index;
        _slider = index;
        var _ = methods.updateViewLog(
          widget.comicId,
          widget.chapter.id,
          index,
        ); // 在后台线程入库
      });
    }
  }

  @override
  void initState() {
    _fullScreen = widget.fullScreenOnInit;
    if (_fullScreen) {
      if (Platform.isAndroid || Platform.isIOS) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
          overlays: SystemUiOverlay.values,
        );
      }
    }
    _current = widget.startIndex;
    _slider = widget.startIndex;
    _readerControllerEvent.subscribe(_onPageControl);
    if (currentVolumeKeyControl()) {
      addVolumeListen();
    }
    super.initState();
  }

  @override
  void dispose() {
    _readerControllerEvent.unsubscribe(_onPageControl);
    if (currentVolumeKeyControl()) {
      delVolumeListen();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
    super.dispose();
  }

  void _onPageControl(_ReaderControllerEventArgs? args) {
    if (args != null) {
      var event = args.key;
      switch (event) {
        case "UP":
          if (_current > 0) {
            _needJumpTo(_current - 1, !currentNoAnimation());
          }
          break;
        case "DOWN":
          if (_current < widget.chapter.images.length - 1) {
            _needJumpTo(_current + 1, !currentNoAnimation());
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (currentReaderControllerType) {
      // 按钮
      case ReaderControllerType.controller:
        return Stack(
          children: [
            _buildViewer(),
            if (_sliderDragging) _sliderDraggingText(),
            _buildBar(_buildFullScreenControllerStackItem()),
          ],
        );
      case ReaderControllerType.touchOnce:
        return Stack(
          children: [
            _buildTouchOnceControllerAction(_buildViewer()),
            if (_sliderDragging) _sliderDraggingText(),
            _buildBar(null),
          ],
        );
      case ReaderControllerType.touchDouble:
        return Stack(
          children: [
            _buildTouchDoubleControllerAction(_buildViewer()),
            if (_sliderDragging) _sliderDraggingText(),
            _buildBar(null),
          ],
        );
      case ReaderControllerType.touchDoubleOnceNext:
        return Stack(
          children: [
            _buildTouchDoubleOnceNextControllerAction(_buildViewer()),
            if (_sliderDragging) _sliderDraggingText(),
            _buildBar(null),
          ],
        );
      case ReaderControllerType.threeArea:
        return Stack(
          children: [
            _buildViewer(),
            if (_sliderDragging) _sliderDraggingText(),
            _buildBar(_buildThreeAreaControllerAction()),
          ],
        );
    }
  }

  Widget _sliderDraggingText() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x88000000),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "${_slider + 1} / ${widget.chapter.images.length}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenControllerStackItem() {
    if (currentReaderSliderPosition == ReaderSliderPosition.bottom &&
        !_fullScreen) {
      return Container();
    }
    if (ReaderSliderPosition.right == currentReaderSliderPosition) {
      return SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                color: Color(0x88000000),
              ),
              child: GestureDetector(
                onTap: () {
                  _onFullScreenChange(!_fullScreen);
                },
                child: Icon(
                  _fullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen_outlined,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SafeArea(
        child: Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: Color(0x88000000),
          ),
          child: GestureDetector(
            onTap: () {
              _onFullScreenChange(!_fullScreen);
            },
            child: Icon(
              _fullScreen ? Icons.fullscreen_exit : Icons.fullscreen_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildTouchOnceControllerAction(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _onFullScreenChange(!_fullScreen);
      },
      child: child,
    );
  }

  Widget _buildTouchDoubleControllerAction(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: () {
        _onFullScreenChange(!_fullScreen);
      },
      child: child,
    );
  }

  Widget _buildTouchDoubleOnceNextControllerAction(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _readerControllerEvent.broadcast(_ReaderControllerEventArgs("DOWN"));
      },
      onDoubleTap: () {
        _onFullScreenChange(!_fullScreen);
      },
      child: child,
    );
  }

  Widget _buildThreeAreaControllerAction() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var up = Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _readerControllerEvent
                  .broadcast(_ReaderControllerEventArgs("UP"));
            },
            child: Container(),
          ),
        );
        var down = Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _readerControllerEvent
                  .broadcast(_ReaderControllerEventArgs("DOWN"));
            },
            child: Container(),
          ),
        );
        var fullScreen = Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _onFullScreenChange(!_fullScreen),
            child: Container(),
          ),
        );
        late Widget child;
        switch (currentReaderDirection) {
          case ReaderDirection.topToBottom:
            child = Column(children: [
              up,
              fullScreen,
              down,
            ]);
            break;
          case ReaderDirection.leftToRight:
            child = Row(children: [
              up,
              fullScreen,
              down,
            ]);
            break;
          case ReaderDirection.rightToLeft:
            child = Row(children: [
              down,
              fullScreen,
              up,
            ]);
            break;
        }
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: child,
        );
      },
    );
  }

  Widget _buildBar(Widget? child) {
    switch (currentReaderSliderPosition) {
      case ReaderSliderPosition.bottom:
        return Column(
          children: [
            _buildAppBar(),
            Expanded(child: child ?? Container()),
            _fullScreen
                ? Container()
                : Container(
                    height: 45,
                    color: const Color(0x88000000),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: 15),
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          color: Colors.white,
                          onPressed: () {
                            _onFullScreenChange(!_fullScreen);
                          },
                        ),
                        Container(width: 10),
                        Expanded(
                          child: widget.readerType != ReaderType.webToonFreeZoom
                              ? _buildSliderBottom()
                              : Container(),
                        ),
                        Container(width: 10),
                        IconButton(
                          icon: const Icon(Icons.skip_next_outlined),
                          color: Colors.white,
                          onPressed: _onNextAction,
                        ),
                        Container(width: 15),
                      ],
                    ),
                  ),
            _fullScreen
                ? Container()
                : Container(
                    color: const Color(0x88000000),
                    child: SafeArea(
                      top: false,
                      child: Container(),
                    ),
                  ),
          ],
        );
      case ReaderSliderPosition.right:
        return Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  ...child == null ? [] : [child],
                  _buildSliderRight(),
                ],
              ),
            ),
          ],
        );
      case ReaderSliderPosition.left:
        return Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  ...child == null ? [] : [child],
                  _buildSliderLeft(),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _buildAppBar() => _fullScreen
      ? Container()
      : AppBar(
          title: Text(widget.chapter.name),
          actions: [
            IconButton(
              onPressed: _onChooseEp,
              icon: const Icon(Icons.menu_open),
            ),
            IconButton(
              onPressed: _onMoreSetting,
              icon: const Icon(Icons.more_horiz),
            ),
          ],
        );

  Widget _buildSliderBottom() {
    return Column(
      children: [
        Expanded(child: Container()),
        SizedBox(
          height: 25,
          child: _buildSliderWidget(Axis.horizontal),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _buildSliderLeft() => _fullScreen
      ? Container()
      : Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 35,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0x66000000),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, left: 6, right: 5),
              child: Center(
                child: _buildSliderWidget(Axis.vertical),
              ),
            ),
          ),
        );

  Widget _buildSliderRight() => _fullScreen
      ? Container()
      : Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 35,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0x66000000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 6),
              child: Center(
                child: _buildSliderWidget(Axis.vertical),
              ),
            ),
          ),
        );

  Widget _buildSliderWidget(Axis axis) {
    return FlutterSlider(
      axis: axis,
      values: [_slider.toDouble()],
      min: 0,
      max: (widget.chapter.images.length - 1).toDouble(),
      onDragging: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          _slider = (lowerValue.toInt());
        });
      },
      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          _sliderDragging = false;
        });
        _slider = (lowerValue.toInt());
        if (_slider != _current) {
          _needJumpTo(_slider, false);
        }
      },
      onDragStarted: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          _sliderDragging = true;
        });
      },
      trackBar: FlutterSliderTrackBar(
        inactiveTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300,
        ),
        activeTrackBar: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      step: const FlutterSliderStep(
        step: 1,
        isPercentRange: false,
      ),
      tooltip: FlutterSliderTooltip(disabled: true),
    );
  }

  Future _onChooseEp() async {
    showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xAA000000),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * (.45),
          child: _EpChooser(widget.chapter, widget.onChangeEp),
        );
      },
    );
  }

  //
  _onMoreSetting() async {
    await showMaterialModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xAA000000),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: _SettingPanel(),
        );
      },
    );
    if (widget.readerDirection != currentReaderDirection ||
        widget.readerType != currentReaderType) {
      widget.reload(_current, _fullScreen);
    } else {
      setState(() {});
    }
  }

  //
  double _appBarHeight() {
    return Scaffold.of(context).appBarMaxHeight ?? 0;
  }

  double _bottomBarHeight() {
    return 45;
  }

  bool _fullscreenController() {
    switch (currentReaderControllerType) {
      case ReaderControllerType.touchOnce:
        return false;
      case ReaderControllerType.controller:
        return false;
      case ReaderControllerType.touchDouble:
        return false;
      case ReaderControllerType.touchDoubleOnceNext:
        return false;
      case ReaderControllerType.threeArea:
        return true;
    }
  }

  bool _hasNextEp() {
    if (widget.chapter.series.isEmpty) {
      return false;
    }
    widget.chapter.series.sort(
      (a, b) => int.parse(a.sort).compareTo(int.parse(b.sort)),
    );
    int index = widget.chapter.series
        .map((e) => e.id)
        .toList()
        .indexOf(widget.chapter.id);
    return index < widget.chapter.series.length - 1;
  }

  void _onNextAction() {
    if (_hasNextEp()) {
      widget.chapter.series.sort(
        (a, b) => int.parse(a.sort).compareTo(int.parse(b.sort)),
      );
      final ids = widget.chapter.series.map((e) => e.id).toList();
      int index = ids.indexOf(widget.chapter.id);
      index++;
      widget.onChangeEp(ids[index], _fullScreen);
    } else {
      defaultToast(context, "已经到头了");
    }
  }
}

class _EpChooser extends StatefulWidget {
  final ChapterResponse chapter;
  final FutureOr Function(int, bool) onChangeEp;

  const _EpChooser(this.chapter, this.onChangeEp);

  @override
  State<StatefulWidget> createState() => _EpChooserState();
}

class _EpChooserState extends State<_EpChooser> {
  @override
  Widget build(BuildContext context) {
    if (widget.chapter.series.isEmpty) {
      return const Center(
        child: Text("无章节可选择", style: TextStyle(color: Colors.white)),
      );
    }

    var entries = widget.chapter.series;
    entries.sort(
      (a, b) => int.parse(a.sort).compareTo(int.parse(b.sort)),
    );
    var widgets = [
      Container(height: 20),
      ...entries.map((e) {
        return Container(
          margin: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          decoration: BoxDecoration(
            color:
                widget.chapter.id == e.id ? Colors.grey.withAlpha(100) : null,
            border: Border.all(
              color: const Color(0xff484c60),
              style: BorderStyle.solid,
              width: .5,
            ),
          ),
          child: MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onChangeEp(e.id, false);
            },
            textColor: Colors.white,
            child: Text(e.sort + (e.name == "" ? "" : (" - ${e.name}"))),
          ),
        );
      })
    ];
    final index = entries.map((e) => e.id).toList().indexOf(widget.chapter.id);
    return ScrollablePositionedList.builder(
      initialScrollIndex: index < 2 ? 0 : index - 2,
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int index) => widgets[index],
    );
  }
}

class _SettingPanel extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingPanelState();
}

class _SettingPanelState extends State<_SettingPanel> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            _bottomIcon(
              icon: Icons.crop_sharp,
              title: readerDirectionName(currentReaderDirection, context),
              onPressed: () async {
                await chooseReaderDirection(context);
                setState(() {});
              },
            ),
            _bottomIcon(
              icon: Icons.view_day_outlined,
              title: readerTypeName(currentReaderType, context),
              onPressed: () async {
                await chooseReaderType(context);
                setState(() {});
              },
            ),
            _bottomIcon(
              icon: Icons.control_camera_outlined,
              title: currentReaderControllerTypeName(),
              onPressed: () async {
                await chooseReaderControllerType(context);
                setState(() {});
              },
            ),
            _bottomIcon(
              icon: Icons.straighten_sharp,
              title: currentReaderSliderPositionName,
              onPressed: () async {
                await chooseReaderSliderPosition(context);
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _bottomIcon({
    required IconData icon,
    required String title,
    required void Function() onPressed,
  }) {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            IconButton(
              iconSize: 55,
              icon: Column(
                children: [
                  Container(height: 3),
                  Icon(
                    icon,
                    size: 25,
                    color: Colors.white,
                  ),
                  Container(height: 3),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 3),
                ],
              ),
              onPressed: onPressed,
            )
          ],
        ),
      ),
    );
  }
}

class _ComicReaderWebToonState extends _ComicReaderState {
  var _controllerTime = DateTime.now().millisecondsSinceEpoch + 400;
  late final List<Size?> _trueSizes = [];
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;

  @override
  void initState() {
    for (var e in widget.chapter.images) {
      _trueSizes.add(null);
    }
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_onListCurrentChange);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onListCurrentChange);
    super.dispose();
  }

  void _onListCurrentChange() {
    var to = _itemPositionsListener.itemPositions.value.first.index;
    // 包含一个下一章, 假设5张图片 0,1,2,3,4 length=5, 下一章=5
    if (to >= 0 && to < widget.chapter.images.length) {
      super._onCurrentChange(to);
    }
  }

  @override
  void _needJumpTo(int index, bool animation) {
    if (animation) {
      if (DateTime.now().millisecondsSinceEpoch < _controllerTime) {
        return;
      }
      _controllerTime = DateTime.now().millisecondsSinceEpoch + 400;
      _itemScrollController.scrollTo(
        index: index, // 减1 当前position 再减少1 前一个
        duration: const Duration(milliseconds: 400),
      );
    } else {
      _itemScrollController.jumpTo(
        index: index,
      );
    }
  }

  @override
  Widget _buildViewer() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: _buildList(),
    );
  }

  Widget _buildList() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // reload _images size
        List<Widget> _images = [];
        for (var index = 0; index < widget.chapter.images.length; index++) {
          late Size renderSize;
          if (_trueSizes[index] != null) {
            if (widget.readerDirection == ReaderDirection.topToBottom) {
              renderSize = Size(
                constraints.maxWidth,
                constraints.maxWidth *
                    _trueSizes[index]!.height /
                    _trueSizes[index]!.width,
              );
            } else {
              var maxHeight = constraints.maxHeight -
                  super._appBarHeight() -
                  super._bottomBarHeight() -
                  MediaQuery.of(context).padding.bottom;
              renderSize = Size(
                maxHeight *
                    _trueSizes[index]!.width /
                    _trueSizes[index]!.height,
                maxHeight,
              );
            }
          } else {
            if (widget.readerDirection == ReaderDirection.topToBottom) {
              renderSize = Size(constraints.maxWidth, constraints.maxWidth / 2);
            } else {
              // ReaderDirection.LEFT_TO_RIGHT
              // ReaderDirection.RIGHT_TO_LEFT
              renderSize =
                  Size(constraints.maxWidth / 2, constraints.maxHeight);
            }
          }
          var currentIndex = index;
          onTrueSize(Size size) {
            setState(() {
              _trueSizes[currentIndex] = size;
            });
          }

          _images.add(
            JMPageImage(
              widget.chapter.id,
              widget.chapter.images[index],
              width: renderSize.width,
              height: renderSize.height,
              onTrueSize: onTrueSize,
            ),
          );
        }
        return ScrollablePositionedList.builder(
          initialScrollIndex: widget.startIndex,
          scrollDirection: widget.readerDirection == ReaderDirection.topToBottom
              ? Axis.vertical
              : Axis.horizontal,
          reverse: widget.readerDirection == ReaderDirection.rightToLeft,
          padding: EdgeInsets.only(
            // 不管全屏与否, 滚动方向如何, 顶部永远保持间距
            top: super._appBarHeight(),
            bottom: widget.readerDirection == ReaderDirection.topToBottom
                ? 130 // 纵向滚动 底部永远都是130的空白
                : (super._bottomBarHeight() +
                    MediaQuery.of(context).padding.bottom)
            // 非全屏时, 顶部去掉顶部BAR的高度, 底部去掉底部BAR的高度, 形成看似填充的效果
            ,
          ),
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: widget.chapter.images.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (widget.chapter.images.length == index) {
              return _buildNextEp();
            }
            return _images[index];
          },
        );
      },
    );
  }

  Widget _buildNextEp() {
    if (super._fullscreenController()) {
      return Container();
    }
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(20),
      child: MaterialButton(
        onPressed: () {
          if (super._hasNextEp()) {
            super._onNextAction();
          } else {
            Navigator.of(context).pop();
          }
        },
        textColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.only(top: 40, bottom: 40),
          child: Text(super._hasNextEp() ? '下一章' : '结束阅读'),
        ),
      ),
    );
  }
}

class _ComicReaderGalleryState extends _ComicReaderState {
  late PageController _pageController;
  final Map<int, int> _reloadKeys = {}; // 跟踪每个页面的重新加载次数

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.startIndex);
    super.initState();
    _preloadJump(widget.startIndex, init: true);
  }

  void _reloadImage(int index) {
    if (mounted) {
      // 清除图片缓存
      final oldProvider = PageImageProvider(widget.chapter.id, widget.chapter.images[index]);
      imageCache.evict(oldProvider);
      print("evict ${widget.chapter.images[index]}");
      setState(() {
        _reloadKeys[index] = (_reloadKeys[index] ?? 0) + 1;
      });
    }
  }

  Widget _buildGallery() {
    return PhotoViewGallery.builder(
      scrollDirection: widget.readerDirection == ReaderDirection.topToBottom
          ? Axis.vertical
          : Axis.horizontal,
      reverse: widget.readerDirection == ReaderDirection.rightToLeft,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      loadingBuilder: (context, event) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return buildLoading(context, constraints.maxWidth, constraints.maxHeight);
        },
      ),
      pageController: _pageController,
      onPageChanged: _onGalleryPageChange,
      itemCount: widget.chapter.images.length,
      allowImplicitScrolling: true,
      builder: (BuildContext context, int index) {
        final reloadKey = _reloadKeys[index] ?? 0;
        final imageProvider = PageImageProvider(widget.chapter.id, widget.chapter.images[index]);
        
        return PhotoViewGalleryPageOptions.customChild(
          disableGestures: currentReaderControllerType == ReaderControllerType.touchDouble || currentReaderControllerType == ReaderControllerType.touchDoubleOnceNext,
          child: LayoutBuilder(
            key: ValueKey('page_${widget.chapter.id}_${widget.chapter.images[index]}_$reloadKey'),
            builder: (BuildContext context, BoxConstraints constraints) {
              return Image(
                key: ValueKey('image_${widget.chapter.id}_${widget.chapter.images[index]}_$reloadKey'),
                image: imageProvider,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return buildLoading(
                    context,
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                },
                errorBuilder: (b, e, s) {
                  print("$e,$s");
                  return buildError(
                    context,
                    constraints.maxWidth,
                    constraints.maxHeight,
                    onReload: () => _reloadImage(index),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget _buildViewer() {
    return Column(
      children: [
        Container(height: _fullScreen ? 0 : super._appBarHeight()),
        Expanded(
          child: Stack(
            children: [
              _buildGallery(),
              _buildNextEpController(),
            ],
          ),
        ),
        Container(height: _fullScreen ? 0 : super._bottomBarHeight()),
      ],
    );
  }

  @override
  _needJumpTo(int pageIndex, bool animation) {
    if (animation) {
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      _pageController.jumpToPage(pageIndex);
    }
    _preloadJump(pageIndex);
  }

  void _onGalleryPageChange(int to) {
    var toIndex = to * 2;
    // 提前加载
    for (var i = toIndex + 1; i < toIndex + 3 && i < widget.chapter.images.length; i++) {
      final ip = PageImageProvider(widget.chapter.id, widget.chapter.images[i]);
      precacheImage(ip, context);
    }
    // 提前加载
    super._onCurrentChange(to);
  }

  _preloadJump(int index, {bool init = false}) {
    fn() {
      for (var i = index - 1; i < index + 3; i++) {
        if (i < 0 || i >= widget.chapter.images.length) continue;
        final ip = PageImageProvider(widget.chapter.id, widget.chapter.images[i]);
        precacheImage(ip, context);
      }
    }

    if (init) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => fn());
    } else {
      fn();
    }
  }

  Widget _buildNextEpController() {
    if (super._fullscreenController()) {
      return Container();
    }
    if (_current < widget.chapter.images.length - 1) return Container();
    return Align(
      alignment: Alignment.bottomRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            color: Color(0x88000000),
          ),
          child: GestureDetector(
            onTap: () {
              if (super._hasNextEp()) {
                super._onNextAction();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(super._hasNextEp() ? '下一章' : '结束阅读',
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

class _ListViewReaderState extends _ComicReaderState
    with SingleTickerProviderStateMixin {
  final List<Size?> _trueSizes = [];
  final _transformationController = TransformationController();
  late TapDownDetails _doubleTapDetails;
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  @override
  void initState() {
    for (var e in widget.chapter.images) {
      _trueSizes.add(null);
    }
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void _needJumpTo(int index, bool animation) {}

  @override
  Widget _buildViewer() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: _buildList(),
    );
  }

  Widget _buildList() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // reload _images size
        List<Widget> _images = [];
        for (var index = 0; index < widget.chapter.images.length; index++) {
          late Size renderSize;
          if (_trueSizes[index] != null) {
            if (currentReaderDirection == ReaderDirection.topToBottom) {
              renderSize = Size(
                constraints.maxWidth,
                constraints.maxWidth *
                    _trueSizes[index]!.height /
                    _trueSizes[index]!.width,
              );
            } else {
              var maxHeight = constraints.maxHeight -
                  super._appBarHeight() -
                  (super._fullScreen
                      ? super._appBarHeight()
                      : super._bottomBarHeight());
              renderSize = Size(
                maxHeight *
                    _trueSizes[index]!.width /
                    _trueSizes[index]!.height,
                maxHeight,
              );
            }
          } else {
            if (currentReaderDirection == ReaderDirection.topToBottom) {
              renderSize = Size(constraints.maxWidth, constraints.maxWidth / 2);
            } else {
              // ReaderDirection.LEFT_TO_RIGHT
              // ReaderDirection.RIGHT_TO_LEFT
              renderSize =
                  Size(constraints.maxWidth / 2, constraints.maxHeight);
            }
          }
          var currentIndex = index;
          onTrueSize(Size size) {
            setState(() {
              _trueSizes[currentIndex] = size;
            });
          }

          _images.add(
            JMPageImage(
              widget.chapter.id,
              widget.chapter.images[index],
              width: renderSize.width,
              height: renderSize.height,
              onTrueSize: onTrueSize,
            ),
          );
        }
        var list = ListView.builder(
          scrollDirection: currentReaderDirection == ReaderDirection.topToBottom
              ? Axis.vertical
              : Axis.horizontal,
          reverse: currentReaderDirection == ReaderDirection.rightToLeft,
          padding: EdgeInsets.only(
            // 不管全屏与否, 滚动方向如何, 顶部永远保持间距
            top: currentReaderDirection == ReaderDirection.topToBottom
                ? super._appBarHeight()
                : max(super._appBarHeight(), super._bottomBarHeight()),
            bottom: currentReaderDirection == ReaderDirection.topToBottom
                ? 130 // 纵向滚动 底部永远都是130的空白
                : max(super._appBarHeight(), super._bottomBarHeight()),
          ),
          itemCount: widget.chapter.images.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (widget.chapter.images.length == index) {
              return _buildNextEp();
            }
            return _images[index];
          },
        );
        var viewer = InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1,
          maxScale: 2,
          child: list,
        );
        return GestureDetector(
          onDoubleTap: _handleDoubleTap,
          onDoubleTapDown: _handleDoubleTapDown,
          child: viewer,
        );
      },
    );
  }

  Widget _buildNextEp() {
    if (super._fullscreenController()) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(20),
      child: MaterialButton(
        onPressed: () {
          if (super._hasNextEp()) {
            super._onNextAction();
          } else {
            Navigator.of(context).pop();
          }
        },
        textColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.only(top: 40, bottom: 40),
          child: Text(super._hasNextEp() ? '下一章' : '结束阅读'),
        ),
      ),
    );
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_animationController.isAnimating) {
      return;
    }
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      var position = _doubleTapDetails.localPosition;
      var animation = Tween(begin: 0, end: 1.0).animate(_animationController);
      animation.addListener(() {
        _transformationController.value = Matrix4.identity()
          ..translate(
              -position.dx * animation.value, -position.dy * animation.value)
          ..scale(animation.value + 1.0);
      });
      _animationController.forward(from: 0);
    }
  }
}

///////////////////////////////////////////////////////////////////////////////

class _TwoPageGalleryReaderState extends _ComicReaderState {
  late PageController _pageController;
  var _controllerTime = DateTime.now().millisecondsSinceEpoch + 400;
  late final List<Size?> _trueSizes = [];
  List<ImageProvider> ips = [];
  List<PhotoViewGalleryPageOptions> options = [];
  late PhotoViewGallery _view;
  final Map<int, int> _imageProviderKeys = {};

  @override
  void initState() {
    // 需要先初始化 super._startIndex 才能使用, 所以在上面
    for (var e in widget.chapter.images) {
      _trueSizes.add(null);
    }
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex ~/ 2);
    for (var index = 0; index < widget.chapter.images.length; index++) {
      _imageProviderKeys[index] = 0;
      ips.add(PageImageProvider(
        widget.chapter.id,
        widget.chapter.images[index],
      ));
    }
    _buildOptions();
    _buildView();
    _preloadJump(widget.startIndex, init: true);
  }

  void _buildView() {
    _view = PhotoViewGallery(
      pageController: _pageController,
      pageOptions: options,
      scrollDirection: widget.readerDirection == ReaderDirection.topToBottom
          ? Axis.vertical
          : Axis.horizontal,
      reverse: widget.readerDirection == ReaderDirection.rightToLeft,
      onPageChanged: _onGalleryPageChange,
      backgroundDecoration: BoxDecoration(color: Colors.black),
    );
  }

  void _buildOptions() {
    options.clear();
    for (var index = 0; index < ips.length; index += 2) {
      // 两页
      late ImageProvider leftIp = ips[index];
      late ImageProvider rightIp = ips[index + 1];
      late int leftIndex = index;
      late int rightIndex = index + 1;
      if (index + 1 < ips.length) {
        leftIp = ips[index];
        rightIp = ips[index + 1];
        leftIndex = index;
        rightIndex = index + 1;
      } else {
        leftIp = ips[index];
        // ImageProvider by color black
        rightIp = const AssetImage('lib/assets/0.png');
        leftIndex = index;
        rightIndex = -1; // 表示右侧是占位图
      }
      if (currentTwoPageDirection == TwoPageDirection.rightToLeft) {
        final temp = leftIp;
        final tempIndex = leftIndex;
        leftIp = rightIp;
        leftIndex = rightIndex;
        rightIp = temp;
        rightIndex = tempIndex;
      }
      options.add(
        PhotoViewGalleryPageOptions.customChild(
          disableGestures: currentReaderControllerType == ReaderControllerType.touchDouble || currentReaderControllerType == ReaderControllerType.touchDoubleOnceNext,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image(
                        key: leftIndex >= 0 ? ValueKey(_imageProviderKeys[leftIndex]) : null,
                        image: leftIp,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return buildLoading(
                            context,
                            constraints.maxWidth / 2,
                            constraints.maxHeight / 2,
                          );
                        },
                        errorBuilder: (b, e, s) {
                          print("$e,$s");
                          return buildError(
                            context,
                            constraints.maxWidth / 2,
                            constraints.maxHeight / 2,
                            onReload: leftIndex >= 0 ? () => _reloadImage(leftIndex) : null,
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        key: rightIndex >= 0 ? ValueKey(_imageProviderKeys[rightIndex]) : null,
                        image: rightIp,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return buildLoading(
                            context,
                            constraints.maxWidth / 2,
                            constraints.maxHeight / 2,
                          );
                        },
                        errorBuilder: (b, e, s) {
                          print("$e,$s");
                          return buildError(
                            context,
                            constraints.maxWidth / 2,
                            constraints.maxHeight / 2,
                            onReload: rightIndex >= 0 ? () => _reloadImage(rightIndex) : null,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }

  void _reloadImage(int index) {
    if (mounted) {
      setState(() {
        _imageProviderKeys[index] = (_imageProviderKeys[index] ?? 0) + 1;
        // 清除图片缓存
        imageCache.evict(ips[index]);
        ips[index] = PageImageProvider(widget.chapter.id, widget.chapter.images[index]);
        _buildOptions();
        // 只重新构建 view，不改变整个组件的 key
        _buildView();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void _needJumpTo(int index, bool animation) {
    if (currentNoAnimation() || animation == false) {
      _pageController.jumpToPage(
        index ~/ 2,
      );
    } else {
      _pageController.animateToPage(
        index ~/ 2,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    }
    _preloadJump(index);
  }

  _preloadJump(int index, {bool init = false}) {
    fn() {
      for (var i = index - 2; i < index + 5; i++) {
        if (i < 0 || i >= ips.length) continue;
        final ip = ips[i];
        precacheImage(ip, context);
      }
    }

    if (init) {
      WidgetsBinding.instance?.addPostFrameCallback((_) => fn());
    } else {
      fn();
    }
  }

  @override
  Widget _buildViewer() {
    return Stack(
      children: [
        GestureDetector(
          child: _view,
        ),
        _buildNextEpController(),
      ],
    );
  }

  void _onGalleryPageChange(int to) {
    var toIndex = to * 2;
    // 提前加载
    for (var i = toIndex + 2; i < toIndex + 5 && i < ips.length; i++) {
      final ip = ips[i];
      precacheImage(ip, context);
    }
    // 包含一个下一章, 假设5张图片 0,1,2,3,4 length=5, 下一章=5
    if (to >= 0 && to < widget.chapter.images.length) {
      super._onCurrentChange(toIndex);
    }
  }

  Widget _buildNextEpController() {
    if (super._fullscreenController() ||
        _current < widget.chapter.images.length - 2) return Container();
    return Align(
      alignment: Alignment.bottomRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
          const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            color: Color(0x88000000),
          ),
          child: GestureDetector(
            onTap: () {
              if (_hasNextEp()) {
                _onNextAction();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              _hasNextEp() ? '下一章' : '结束阅读',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
