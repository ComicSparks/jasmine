import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';
import 'package:jasmine/configs/login.dart';
import 'package:jasmine/screens/components/comic_pager.dart';

import 'components/right_click_pop.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _folderId = 0;
  bool _isLoading = true;

  final Map<int, String> _folderMap = {
    0: "全部",
  };

  _chooseFolder() async {
    int? f = await chooseMapDialog(
      context,
      values: _folderMap.map((key, value) => MapEntry(value, key)),
      title: "选择文件夹",
    );
    if (f != null) {
      setState(() {
        _folderId = f;
      });
    }
  }

  final _sortNameMap = {
    "mr": "收藏时间",
    "mp": "更新时间",
  };
  String _sort = "mr";

  _chooseSort() async {
    String? f = await chooseMapDialog(
      context,
      values: _sortNameMap.map((key, value) => MapEntry(value, key)),
      title: "选择排序",
    );
    if (f != null) {
      setState(() {
        _sort = f;
      });
      await methods.saveProperty("favorites_sort", f);
    }
  }

  @override
  void initState() {
    for (var value in favData) {
      try {
        _folderMap[value.fid] = value.name;
      } catch (e) {
        print(e);
        defaultToast(context, "$e");
      }
    }
    _loadSort();
    super.initState();
  }

  Future<void> _loadSort() async {
    try {
      final sort = await methods.loadProperty("favorites_sort");
      if (sort.isNotEmpty && _sortNameMap.containsKey(sort)) {
        setState(() {
          _sort = sort;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // 使用默认值
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(child: buildScreen(context), context: context);
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("收藏夹"),
        actions: [
          MaterialButton(
            onPressed: _chooseSort,
            child: Row(
              children: [
                const Icon(Icons.sort, size: 15),
                Container(width: 8),
                Text(_sortNameMap[_sort] ?? ""),
              ],
            ),
          ),
          MaterialButton(
            onPressed: _chooseFolder,
            child: Row(
              children: [
                const Icon(Icons.folder_copy_outlined,size: 15),
                Container(width: 8),
                Text(_folderMap[_folderId] ?? ""),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ComicPager(
        key: Key("FAVOUR:$_folderId:$_sort"),
        onPage: (int page) async {
          final response = await methods.favorites(_folderId, page, _sort);
          setState(() {
            favData  = response.folderList;
          });
          return InnerComicPage(total: response.total, list: response.list);
        },
      ),
    );
  }
}
