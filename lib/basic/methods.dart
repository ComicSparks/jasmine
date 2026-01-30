import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'entities.dart';

export 'entities.dart';

const methods = Methods._();

class Methods {
  const Methods._();

  static const _channel = MethodChannel("methods");
  static HttpClient httpClient = HttpClient();

  Future<String> _invoke(String method, dynamic params) async {
    late String resp;
    // if (Platform.isLinux) {
    //   var req = await httpClient.post("127.0.0.1", 52764, "invoke");
    //   req.add(utf8.encode(jsonEncode({
    //     "method": method,
    //     "params": params is String ? params : jsonEncode(params),
    //   })));
    //   var rsp = await req.close();
    //   resp = await rsp.transform(utf8.decoder).join();
    // } else
    {
      resp = await _channel.invokeMethod(
          "invoke",
          jsonEncode({
            "method": method,
            "params": params is String ? params : jsonEncode(params),
          }));
    }

    var response = _Response.fromJson(jsonDecode(resp));
    if (response.errorMessage.isNotEmpty) {
      throw StateError(response.errorMessage);
    }
    return response.responseData;
  }

  Future init() {
    return _invoke("init_dart", "");
  }

  Future<Map<String, String>> configLinks() async {
    final rsp = await _invoke("config_links", "");
    final decoded = jsonDecode(rsp);
    if (decoded is! Map) {
      return {};
    }
    return decoded.map((key, value) => MapEntry("$key", "$value"));
  }

  Future<String> loadProperty(String propertyKey) {
    return _invoke("load_property", propertyKey);
  }

  Future<ComicsResponse> comics(String slug, SortBy sortBy, int page) async {
    final rsp = await _invoke("comics", {
      "categories_slug": slug,
      "sort_by": sortBy.value,
      "page": page,
    });
    return ComicsResponse.fromJson(jsonDecode(rsp));
  }

  Future<ComicsResponse> comicSearch(
    String searchQuery,
    SortBy sortBy,
    int page,
  ) async {
    final rsp = await _invoke("comic_search", {
      "search_query": searchQuery,
      "sort_by": sortBy.value,
      "page": page,
    });
    return ComicsResponse.fromJson(jsonDecode(rsp));
  }

  Future<ComicsResponse> pageViewLog(int page) async {
    final rsp = await _invoke("page_view_log", page);
    return ComicsResponse.fromJson(jsonDecode(rsp));
  }

  Future<dynamic> deleteViewLogByComicId(int comicId) async {
    final rsp = await _invoke("delete_view_log_by_comic_id", comicId);
    return rsp;
  }

  Future<CategoriesResponse> categories() async {
    return CategoriesResponse.fromJson(
        jsonDecode(await _invoke("categories", "")));
  }

  Future saveImageFileToGallery(String path) {
    return _channel.invokeMethod("saveImageFileToGallery", path);
  }

  Future saveProperty(String key, String v) {
    return _invoke("save_property", {"k": key, "v": v});
  }

  Future<AlbumResponse> album(int id, {bool ignoreViewLog = false}) async {
    return AlbumResponse.fromJson(jsonDecode(await _invoke("album", {
      "id": id,
      "ignore_view_log": ignoreViewLog,
    })));
  }

  Future<ChapterResponse> chapter(int id) async {
    return ChapterResponse.fromJson(jsonDecode(await _invoke("chapter", id)));
  }

  Future<CommentPage> forum(String? mode, int? aid, int? uid, int page) async {
    return CommentPage.fromJson(jsonDecode(await _invoke("forum", {
      "mode": mode,
      "aid": aid,
      "uid": uid,
      "page": page,
    })));
  }

  Future<Favorite> favorites(int folderId, int page, String o) async {
    return Favorite.fromJson(
      jsonDecode(await _invoke("favorites", {
        "folder_id": folderId,
        "page": page,
        "o": o,
      })),
    );
  }

  Future<Favorite> favorite() async {
    return Favorite.fromJson(
      jsonDecode(await _invoke("favorite", "")),
    );
  }

  Future<ActionResponse> setFavorite(int aid) async {
    return ActionResponse.fromJson(
      jsonDecode(await _invoke("set_favorite", aid)),
    );
  }

  Future createFavoriteFolder(String name) async {
    return _invoke("create_favorite_folder", name);
  }

  Future deleteFavoriteFolder(int folderId) async {
    return _invoke("delete_favorite_folder", folderId);
  }

  Future comicFavoriteFolderMove(int comicId, int folderId) async {
    return _invoke("comic_favorite_folder_move", [comicId, folderId]);
  }

  Future renameFavoriteFolder(int folderId, String name) async {
    return _invoke("rename_favorite_folder", ["$folderId", name]);
  }

  Future<GamePage> games(int page) async {
    return GamePage.fromJson(
      jsonDecode(await _invoke("games", page)),
    );
  }

  Future updateViewLog(int id, int lastViewChapterId, int lastViewPage) {
    return _invoke("update_view_log", {
      "id": id,
      "last_view_chapter_id": lastViewChapterId,
      "last_view_page": lastViewPage,
    });
  }

  Future<ViewLog?> findViewLog(int id) async {
    final map = jsonDecode(await _invoke("find_view_log", id));
    if (map == null) {
      return null;
    }
    return ViewLog.fromJson(map);
  }

  Future cleanAllCache() async {
    return _invoke("clean_all_cache", "params");
  }

  Future<String> jm3x4Cover(int comicId) {
    return _invoke("jm_3x4_cover", comicId);
  }

  Future<String> jmSquareCover(int comicId) {
    return _invoke("jm_square_cover", comicId);
  }

  Future<String> jmPageImage(int id, String imageName) {
    return _invoke("jm_page_image", {"id": id, "image_name": imageName});
  }

  Future<String> jmPhotoImage(String imageName) {
    return _invoke("jm_photo_image", imageName);
  }

  Future<ImageSize> imageSize(String path) async {
    return ImageSize.fromJson(jsonDecode(await _invoke("image_size", path)));
  }

  Future httpGet(String versionUrl) {
    return _invoke("http_get", versionUrl);
  }

  Future<String> loadApiHost() {
    return _invoke("load_api_host", "");
  }

  Future<String> loadCdnHost() {
    return _invoke("load_cdn_host", "");
  }

  Future saveApiHost(String choose) {
    return _invoke("save_api_host", choose);
  }

  Future saveCdnHost(String choose) {
    return _invoke("save_cdn_host", choose);
  }

  Future<PreLoginResponse> preLogin() async {
    return PreLoginResponse.fromJson(
      jsonDecode(await _invoke("pre_login", "")),
    );
  }

  Future<SelfInfo> login(String username, String password) async {
    return SelfInfo.fromJson(
      jsonDecode(await _invoke("login", {
        "username": username,
        "password": password,
      })),
    );
  }

  Future logout() async {
    await _invoke("logout", {});
  }

  Future<CommentResponse> commentResponse(int aid, String comment) async {
    return CommentResponse.fromJson(jsonDecode(await _invoke("comment", {
      "aid": aid,
      "comment": comment,
    })));
  }

  Future<CommentResponse> comment(int aid, String comment) async {
    return CommentResponse.fromJson(jsonDecode(await _invoke("comment", {
      "aid": aid,
      "comment": comment,
    })));
  }

  Future<CommentResponse> childComment(
    int aid,
    String comment,
    int? commentId,
  ) async {
    return CommentResponse.fromJson(jsonDecode(await _invoke("child_comment", {
      "aid": aid,
      "comment": comment,
      "comment_id": commentId,
    })));
  }

  Future<String> loadUsername() {
    return _invoke("load_username", "");
  }

  Future<String> loadLastLoginUsername() {
    return _invoke("loadLastLoginUsername", "");
  }

  Future<String> loadPassword() {
    return _invoke("load_password", "");
  }

  Future clearViewLog() {
    return _invoke("clear_view_log", "");
  }

  Future<List<SearchHistory>> lastSearchHistories(int count) async {
    return List.of(jsonDecode(await _invoke("last_search_histories", "$count")))
        .map((e) => SearchHistory.fromJson(e))
        .toList()
        .cast<SearchHistory>();
  }

  /// 下载列表
  Future<List<DownloadAlbum>> allDownloads() async {
    return List.of(jsonDecode(await _invoke("all_downloads", "")))
        .map((e) => DownloadAlbum.fromJson(e))
        .toList()
        .cast<DownloadAlbum>();
  }

  /// 寻找下载
  Future<DownloadCreate?> downloadById(int id) async {
    var map = jsonDecode(await _invoke("download_by_id", "$id"));
    if (map == null) {
      return map;
    }
    return DownloadCreate.fromJson(map);
  }

  /// 创建下载
  Future<dynamic> createDownload(DownloadCreate create) async {
    return _invoke("create_download", create);
  }

  /// 下载图片列表
  Future<List<DlImage>> dlImageByChapterId(int id) async {
    return List.of(jsonDecode(await _invoke("dl_image_by_chapter_id", "$id")))
        .map((e) => DlImage.fromJson(e))
        .toList()
        .cast<DlImage>();
  }

  Future<dynamic> deleteDownload(int id) async {
    return _invoke("delete_download", id);
  }

  Future<dynamic> renewAllDownloads() async {
    return _invoke("renew_all_downloads", "");
  }

  /// 获取安卓的屏幕刷新率
  Future<List<String>> loadAndroidModes() async {
    return List.of(await _channel.invokeMethod("androidGetModes"))
        .map((e) => "$e")
        .toList();
  }

  /// 设置安卓的屏幕刷新率
  Future setAndroidMode(String androidDisplayMode) {
    return _channel
        .invokeMethod("androidSetMode", {"mode": androidDisplayMode});
  }

  /// 获取安卓的版本
  Future<int> androidGetVersion() async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod("androidGetVersion", {});
    }
    return 0;
  }

  Future export_jm_jpegs(List<int> idList, String path, bool deleteExported) {
    return _invoke("export_jm_jpegs", {
      "comic_id": idList,
      "dir": path,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_zip(List<int> idList, String path, bool deleteExported) {
    return _invoke("export_jm_zip", {
      "comic_id": idList,
      "dir": path,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_zip_single(
      int id, String folder, String? rename, bool deleteExported) {
    return _invoke("export_jm_zip_single", {
      "id": id,
      "folder": folder,
      "rename": rename,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_jpegs_zip_single(
      int id, String folder, String? rename, bool deleteExported) {
    return _invoke("export_jm_jpegs_zip_single", {
      "id": id,
      "folder": folder,
      "rename": rename,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_jmi(List<int> idList, String path, bool deleteExported) {
    return _invoke("export_jm_jmi", {
      "comic_id": idList,
      "dir": path,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_jmi_single(
      int id, String folder, String? rename, bool deleteExported) {
    return _invoke("export_jm_jmi_single", {
      "id": id,
      "folder": folder,
      "rename": rename,
      "delete_exported": deleteExported,
    });
  }

  Future export_cbzs_zip_single(
      int id, String folder, String? rename, bool deleteExported) {
    return _invoke("export_cbzs_zip_single", {
      "id": id,
      "folder": folder,
      "rename": rename,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_pdf(int id, String folder, bool deleteExported) {
    return _invoke("export_jm_pdf", {
      "comic_id": [id],
      "dir": folder,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_pdf2(int id, String folder, bool deleteExported) {
    return _invoke("export_jm_pdf2", {
      "comic_id": [id],
      "dir": folder,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_epub(List<int> idList, String path, bool deleteExported) {
    return _invoke("export_jm_epub", {
      "comic_id": idList,
      "dir": path,
      "delete_exported": deleteExported,
    });
  }

  Future export_jm_epub_single(
      int id, String folder, String? rename, bool deleteExported) {
    return _invoke("export_jm_epub_single", {
      "id": id,
      "folder": folder,
      "rename": rename,
      "delete_exported": deleteExported,
    });
  }

  Future import_jm_zip(String path) {
    print(path);
    return _invoke("import_jm_zip", path);
  }

  Future import_jm_jmi(String path) {
    print(path);
    return _invoke("import_jm_jmi", path);
  }

  Future import_jm_dir(String path) {
    print(path);
    return _invoke("import_jm_dir", path);
  }

  Future<IsPro> isPro() async {
    return IsPro.fromJson(jsonDecode(await _invoke("is_pro", "")));
  }

  Future<ProInfoAll> proInfoAll() async {
    return ProInfoAll.fromJson(jsonDecode(await _invoke("pro_info_all", "")));
  }

  Future reloadPro() {
    return _invoke("reload_pro", "");
  }

  Future inputCdKey(String cdKey) {
    return _invoke("input_cd_key", cdKey);
  }

  Future checkPat(String accessKey) {
    return _invoke("check_pat", accessKey);
  }

  Future bindPatAccount(String accessKey, String username) {
    return _invoke(
        "bind_pat",
        jsonEncode({
          "access_key": accessKey,
          "username": username,
        }));
  }

  Future reloadPatAccount() {
    return _invoke("reload_pat_account", "");
  }

  Future clearPat() {
    return _invoke("clear_pat", "");
  }

  Future<int> load_download_thread() async {
    return int.parse(await _invoke("load_download_thread", ""));
  }

  Future set_download_thread(int count) {
    return _invoke("set_download_thread", "${count}");
  }

  Future clearAllSearchLog() {
    return _invoke("clear_all_search_log", "");
  }

  Future clearASearchLog(String log) {
    return _invoke("clear_a_search_log", log);
  }

  Future setProxy(String url) {
    return _invoke("set_proxy", url);
  }

  Future<String> getProxy() {
    return _invoke("get_proxy", "");
  }

  Future webDavSync(dynamic params) {
    return _invoke("sync_webdav", params);
  }

  Future<String> iosGetDocumentDir() async {
    return await _channel.invokeMethod("iosGetDocumentDir");
  }

  Future<String> androidDefaultExportsDir() async {
    return await _channel.invokeMethod("androidDefaultExportsDir");
  }

  Future<String> getDownloadAndExportTo() async {
    return await _invoke("get_download_and_export_to", "");
  }

  Future<String> getHomeDir() async {
    return await _invoke("getHomeDir", "");
  }

  Future setDownloadAndExportTo(String path) async {
    return await _invoke("set_download_and_export_to", path);
  }

  Future<int> ping(String idx) async {
    print("PING API $idx");
    return int.parse(await _invoke("ping_server", idx));
  }

  Future<int> pingCdn(String idx) async {
    print("PING CDN $idx");
    return int.parse(await _invoke("ping_cdn", idx));
  }

  Future mkdirs(String path) {
    return _invoke("mkdirs", path);
  }

  Future androidMkdirs(String path) async {
    return await _channel.invokeMethod("androidMkdirs", path);
  }

  Future<String> picturesDir() async {
    return await _channel.invokeMethod("picturesDir");
  }

  Future<String> copyPictureToFolder(String folder, String path) async {
    return await _invoke(
      "copyPictureToFolder",
      {
        "folder": folder,
        "path": path,
      },
    );
  }

  Future<String> getProServerName() async {
    return await _invoke("get_pro_server_name", "");
  }

  Future setProServerName(String serverName) async {
    return await _invoke("set_pro_server_name", serverName);
  }

  Future<bool> verifyAuthentication() async {
    return await _channel.invokeMethod("verifyAuthentication");
  }

  Future<String> daily(int uid) {
    return _invoke("daily", uid);
  }

  Future<WeekData> week(int page) async {
    return WeekData.fromJson(jsonDecode(await _invoke("week", {
      "page": page,
    })));
  }

  Future<WeekFilterResponse> weekFilter(
      String categoryId, String typeId, int page) async {
    return WeekFilterResponse.fromJson(jsonDecode(await _invoke("week_filter", {
      "category_id": categoryId,
      "type_id": typeId,
      "page": page,
    })));
  }
}

class _Response {
  late String errorMessage;
  late String responseData;

  _Response.fromJson(Map json) {
    errorMessage = json["error_message"];
    responseData = json["response_data"];
  }
}
