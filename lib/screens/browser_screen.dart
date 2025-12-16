import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/screens/components/comic_pager.dart';
import 'package:jasmine/screens/components/content_builder.dart';
import 'package:jasmine/screens/components/floating_search_bar.dart';

import '../configs/categories_sort.dart';
import '../configs/login.dart';
import 'components/browser_bottom_sheet.dart';
import 'components/actions.dart';
import 'components/comic_floating_search_bar.dart';
import 'components/content_error.dart';
import 'components/content_loading.dart';
import 'week_screen.dart';

class BrowserScreenWrapper extends StatefulWidget {
  final FloatingSearchBarController searchBarController;

  const BrowserScreenWrapper({Key? key, required this.searchBarController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BrowserScreenWrapperState();
}

class _BrowserScreenWrapperState extends State<BrowserScreenWrapper> {
  @override
  void initState() {
    loginEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    loginEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (loginStatus) {
      case LoginStatus.loginSuccess:
        return BrowserScreen(searchBarController: widget.searchBarController);
      case LoginStatus.loginField:
        return ContentError(
          error: "请先登录",
          stackTrace: StackTrace.current,
          onRefresh: () async {},
        );
      case LoginStatus.logging:
        return const ContentLoading(
          label: "登录中",
        );
      case LoginStatus.notSet:
        return ContentError(
          error: "请先登录",
          stackTrace: StackTrace.current,
          onRefresh: () async {},
        );
    }
  }
}

class BrowserScreen extends StatefulWidget {
  final FloatingSearchBarController searchBarController;

  const BrowserScreen({Key? key, required this.searchBarController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<CategoriesResponse> _future;
  late Key _key;
  String _slug = "";
  SortBy _sortBy = sortByDefault;

  Future<CategoriesResponse> _categories() async {
    final rsp = await methods.categories();
    blockStore = rsp.blocks;
    sortCategories(rsp.categories);
    return rsp;
  }

  @override
  void initState() {
    _future = _categories();
    _key = UniqueKey();
    super.initState();
    categoriesSortEvent.subscribe(_resort);
  }


  @override
  void dispose() {
    categoriesSortEvent.unsubscribe(_resort);
    super.dispose();
  }

  _resort(_) {
    setState(() {
      _future = _categories();
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("浏览"),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WeekScreen()));
            },
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: () async {
              searchHistories = await methods.lastSearchHistories(20);
              widget.searchBarController.display(modifyInput: "");
            },
            icon: const Icon(Icons.search),
          ),
          const BrowserBottomSheetAction(),
        ],
      ),
      body: ContentBuilder(
        key: _key,
        future: _future,
        onRefresh: () async {
          setState(() {
            _future = _categories();
            _key = UniqueKey();
          });
        },
        successBuilder: (
          BuildContext context,
          AsyncSnapshot<CategoriesResponse> snapshot,
        ) {
          final categories = snapshot.requireData.categories;
          if (_slug.isEmpty && categories.isNotEmpty) {
            _slug = categories[0].slug;
          }
          return Column(children: [
            SizedBox(
              height: 56,
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                color: Theme.of(context).appBarTheme.backgroundColor,
                child: Row(
                  children: [
                    Expanded(
                      child: _MTabBar(
                        categories,
                        (index) {
                          setState(() {
                            _slug = categories[index].slug;
                          });
                        },
                      ),
                    ),
                    buildOrderSwitch(context, _sortBy, (value) {
                      setState(() {
                        _sortBy = value;
                      });
                    }),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ComicPager(
                key: Key("$_slug:$_sortBy"),
                onPage: (int page) async {
                  final response = await methods.comics(_slug, _sortBy, page);
                  return InnerComicPage(
                    total: response.total,
                    list: response.content,
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _MTabBar extends StatefulWidget {
  final List<Categories> categories;
  final void Function(int index) onTab;

  const _MTabBar(this.categories, this.onTab);

  @override
  State<StatefulWidget> createState() => _MTabBarState();
}

class _MTabBarState extends State<_MTabBar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: widget.categories.length, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TabBar(
          onTap: widget.onTab,
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: const EdgeInsets.only(left: 10, right: 10),
          indicator: BoxDecoration(
            color: Colors.grey.shade500.withOpacity(.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
          tabs: widget.categories
              .map((e) => Tab(
                    text: e.name,
                  ))
              .toList()),
    );
  }
}
