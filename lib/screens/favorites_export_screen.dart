import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/entities.dart';
import 'package:jasmine/basic/methods.dart';

import '../configs/export_path.dart';
import 'components/content_loading.dart';
import 'components/right_click_pop.dart';

class FavoritesExportScreen extends StatefulWidget {
  const FavoritesExportScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesExportScreen> createState() => _FavoritesExportScreenState();
}

class _FavoritesExportScreenState extends State<FavoritesExportScreen> {
  static const _allFolderId = 0;

  String _sort = "mr";
  bool _exporting = false;
  bool _exportDone = false;
  bool _exportFail = false;
  bool _exportCancelled = false;
  String _exportMessage = "";
  String _exportPath = "";
  dynamic _exportError;
  bool _cancelled = false;

  static const _sortLabels = {
    "mr": "收藏时间",
    "mp": "更新时间",
  };

  Map<String, dynamic> _rowFromComic(ComicSimple comic) {
    return {
      "jm_code": "JM${comic.id}",
      "title": comic.name,
      "author": comic.author,
      "description": comic.description,
      "category_title": comic.category?.title ?? "",
      "category_sub_title": comic.categorySub?.title ?? "",
      "update_at": comic.updateAt,
      "addtime": comic.addtime,
    };
  }

  /// 与 [ComicPager] 一致：用首屏 total 与每页条数推算最大页数。
  int _maxPageForFavorite(Favorite response) {
    if (response.total == 0 || response.list.isEmpty) {
      return 0;
    }
    return (response.total / response.list.length).ceil();
  }

  Future<void> _startExport() async {
    final username = await methods.loadUsername();
    if (username.isEmpty) {
      defaultToast(context, "请先登录");
      return;
    }

    setState(() {
      _exporting = true;
      _exportDone = false;
      _exportFail = false;
      _exportCancelled = false;
      _cancelled = false;
      _exportMessage = "准备导出…";
      _exportPath = "";
      _exportError = null;
    });

    final rows = <Map<String, dynamic>>[];
    var requestCount = 0;
    var page = 1;
    int? maxPage;

    try {
      while (true) {
        if (_cancelled) {
          setState(() {
            _exportCancelled = true;
            _exportMessage = "已取消";
          });
          return;
        }
        if (maxPage != null && maxPage > 0 && page > maxPage) {
          break;
        }
        if (requestCount > 0) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        requestCount++;

        setState(() {
          _exportMessage =
              "第 $page${maxPage != null && maxPage > 0 ? '/$maxPage' : ''} 页 · 已收集 ${rows.length} 条";
        });

        final response = await methods.favoritesForExport(
          _allFolderId,
          page,
          _sort,
        );

        if (_cancelled) {
          setState(() {
            _exportCancelled = true;
            _exportMessage = "已取消";
          });
          return;
        }

        if (page == 1) {
          maxPage = _maxPageForFavorite(response);
          if (maxPage == 0) {
            break;
          }
        }

        if (response.list.isEmpty) {
          break;
        }

        for (final comic in response.list) {
          rows.add(_rowFromComic(comic));
        }

        if (maxPage != null && page >= maxPage) {
          break;
        }
        page++;
      }

      if (_cancelled) {
        setState(() {
          _exportCancelled = true;
          _exportMessage = "已取消";
        });
        return;
      }

      if (rows.isEmpty) {
        setState(() {
          _exportFail = true;
          _exportError = "收藏夹为空";
        });
        return;
      }

      setState(() {
        _exportMessage = "正在写入表格…";
      });

      final dir = await attachExportPath();
      final path = await methods.writeFavoritesXlsx(dir, rows);

      setState(() {
        _exportDone = true;
        _exportPath = path;
        _exportMessage = "导出成功";
      });
    } catch (e) {
      setState(() {
        _exportFail = true;
        _exportError = e;
      });
    } finally {
      setState(() {
        _exporting = false;
      });
    }
  }

  void _cancelExport() {
    setState(() {
      _cancelled = true;
    });
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("排序方式"),
        ..._sortLabels.entries.map(
          (e) => RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(e.value),
            value: e.key,
            groupValue: _sort,
            onChanged: (v) {
              if (v != null) {
                setState(() => _sort = v);
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        displayExportPathInfo(),
        const SizedBox(height: 24),
        MaterialButton(
          onPressed: _startExport,
          child: const Text("开始导出"),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_exporting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: ContentLoading(label: _exportMessage)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: MaterialButton(
              onPressed: _cancelExport,
              child: const Text("取消导出"),
            ),
          ),
        ],
      );
    }
    if (_exportCancelled) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("已取消导出"),
            const SizedBox(height: 16),
            MaterialButton(
              onPressed: () => setState(() {
                _exportCancelled = false;
                _exportMessage = "";
              }),
              child: const Text("返回"),
            ),
          ],
        ),
      );
    }
    if (_exportFail) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text("导出失败\n$_exportError"),
        ),
      );
    }
    if (_exportDone) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("导出成功"),
              const SizedBox(height: 12),
              SelectableText(_exportPath),
              Text(showExportPath()),
            ],
          ),
        ),
      );
    }
    return _buildForm();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      context: context,
      canPop: !_exporting,
      child: WillPopScope(
        onWillPop: () async {
          if (_exporting) {
            defaultToast(context, "导出中, 请稍后");
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("导出收藏夹到表格"),
          ),
          body: _buildBody(),
        ),
      ),
    );
  }
}
