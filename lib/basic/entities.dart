class SortBy {
  final String _value;
  final String _name;

  const SortBy._(this._value, this._name);

  get value => _value;

  @override
  String toString() {
    return _name;
  }
}

const sortByDefault = SortBy._("", "默认");
const sortByNew = SortBy._("mr", "最新");
const sortByLike = SortBy._("tf", "心");
const sortByView = SortBy._("mv", "查看");
const sortByViewDay = SortBy._("mv_t", "日榜");
const sortByViewWeek = SortBy._("mv_w", "周榜");
const sortByViewMonth = SortBy._("mv_m", "月榜");

const sorts = [
  sortByDefault,
  sortByNew,
  sortByLike,
  sortByView,
  sortByViewDay,
  sortByViewWeek,
  sortByViewMonth,
];

class Page<T> {
  late final List<T> list;
  late final int total;
}

class CountPage<T> {
  late final List<T> list;
  late final int total;
  late final int count;

  CountPage.fromJson(Map<String, dynamic> json) {
    total = json["total"];
    count = json["count"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["total"] = total;
    json["count"] = count;
    return json;
  }

  CountPage() {
    total = 0;
    count = 0;
  }
}

class SearchPage {
  SearchPage({
    required this.searchQuery,
    required this.total,
  });

  late final String searchQuery;
  late final int total;
  late final int? redirectAid;

  SearchPage.fromJson(Map<String, dynamic> json) {
    searchQuery = json['search_query'];
    total = json['total'];
    redirectAid = json['redirect_aid'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['search_query'] = searchQuery;
    _data['total'] = total;
    _data['redirect_aid'] = redirectAid;
    return _data;
  }
}

class ComicsResponse extends SearchPage {
  late final List<ComicSimple> content;

  ComicsResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    content =
        List.from(json['content']).map((e) => ComicSimple.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final _data = super.toJson();
    _data['content'] = content;
    return _data;
  }
}

class ComicSimple extends ComicBasic {
  ComicSimple({
    required int id,
    required String author,
    required String description,
    required String name,
    required String image,
    required this.category,
    required this.categorySub,
  }) : super(
            id: id,
            author: author,
            description: description,
            name: name,
            image: image);

  late final ComicSimpleCategory category;
  late final ComicSimpleCategory categorySub;

  ComicSimple.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    category = ComicSimpleCategory.fromJson(json['category']);
    categorySub = ComicSimpleCategory.fromJson(json['category_sub']);
  }

  @override
  Map<String, dynamic> toJson() {
    final _data = super.toJson();
    _data['category'] = category.toJson();
    _data['category_sub'] = categorySub.toJson();
    return _data;
  }
}

class ComicSimpleCategory {
  ComicSimpleCategory({
    this.id,
    this.title,
  });

  late final String? id;
  late final String? title;

  ComicSimpleCategory.fromJson(Map<String, dynamic> json) {
    id = null;
    title = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['title'] = title;
    return _data;
  }
}

class CategoriesResponse {
  CategoriesResponse({
    required this.categories,
    required this.blocks,
  });

  late final List<Categories> categories;
  late final List<Block> blocks;

  CategoriesResponse.fromJson(Map<String, dynamic> json) {
    categories = List.from(json['categories'])
        .map((e) => Categories.fromJson(e))
        .toList();
    blocks = List.from(json['blocks']).map((e) => Block.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['categories'] = categories.map((e) => e.toJson()).toList();
    _data['blocks'] = blocks.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Categories {
  Categories({
    required this.id,
    required this.name,
    required this.slug,
    required this.totalAlbums,
    this.type,
  });

  late final int id;
  late final String name;
  late final String slug;
  late final int totalAlbums;
  late final String? type;

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    totalAlbums = json['total_albums'];
    type = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['slug'] = slug;
    _data['total_albums'] = totalAlbums;
    _data['type'] = type;
    return _data;
  }
}

class Block {
  Block({
    required this.title,
    required this.content,
  });

  late final String title;
  late final List<String> content;

  Block.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = List.castFrom<dynamic, String>(json['content']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['title'] = title;
    _data['content'] = content;
    return _data;
  }
}

class AlbumResponse {
  AlbumResponse({
    required this.id,
    required this.name,
    required this.author,
    required this.images,
    required this.description,
    required this.totalViews,
    required this.likes,
    required this.series,
    required this.seriesId,
    required this.commentTotal,
    required this.tags,
    required this.works,
    required this.relatedList,
    required this.liked,
    required this.isFavorite,
  });

  late final int id;
  late final String name;
  late final List<String> author;
  late final List<String> images;
  late final String description;
  late final int totalViews;
  late final int likes;
  late final List<Series> series;
  late final int seriesId;
  late final int commentTotal;
  late final List<String> tags;
  late final List<String> works;
  late final List<ComicBasic> relatedList;
  late final bool liked;
  late bool isFavorite;

  AlbumResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    author = List.castFrom<dynamic, String>(json['author']);
    images = List.castFrom<dynamic, String>(json['images']);
    description = json['description'];
    totalViews = json['total_views'];
    likes = json['likes'];
    series = List.from(json['series']).map((e) => Series.fromJson(e)).toList();
    seriesId = json['series_id'];
    commentTotal = json['comment_total'];
    tags = List.castFrom<dynamic, String>(json['tags']);
    works = List.castFrom<dynamic, String>(json['works']);
    relatedList = List.from(json['related_list'])
        .map((e) => ComicBasic.fromJson(e))
        .toList();
    liked = json['liked'];
    isFavorite = json['is_favorite'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['author'] = author;
    _data['images'] = images;
    _data['description'] = description;
    _data['total_views'] = totalViews;
    _data['likes'] = likes;
    _data['series'] = series.map((e) => e.toJson()).toList();
    _data['series_id'] = seriesId;
    _data['comment_total'] = commentTotal;
    _data['tags'] = tags;
    _data['works'] = works;
    _data['related_list'] = relatedList.map((e) => e.toJson()).toList();
    _data['liked'] = liked;
    _data['is_favorite'] = isFavorite;
    return _data;
  }
}

class Series {
  Series({
    required this.id,
    required this.name,
    required this.sort,
  });

  late final int id;
  late final String name;
  late final String sort;

  Series.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sort = json['sort'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['sort'] = sort;
    return _data;
  }
}

class ComicBasic {
  ComicBasic({
    required this.id,
    required this.author,
    required this.description,
    required this.name,
    required this.image,
  });

  late final int id;
  late final String author;
  late final String description;
  late final String name;
  late final String image;

  ComicBasic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    author = json['author'];
    description = json['description'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['author'] = author;
    _data['description'] = description;
    _data['name'] = name;
    _data['image'] = image;
    return _data;
  }
}

class ChapterResponse {
  ChapterResponse({
    required this.id,
    required this.series,
    required this.tags,
    required this.name,
    required this.images,
    required this.seriesId,
    required this.isFavorite,
    required this.liked,
  });

  late final int id;
  late final List<Series> series;
  late final String tags;
  late final String name;
  late final List<String> images;
  late final int seriesId;
  late final bool isFavorite;
  late final bool liked;

  ChapterResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    series = List.from(json['series']).map((e) => Series.fromJson(e)).toList();
    tags = json['tags'];
    name = json['name'];
    images = List.castFrom<dynamic, String>(json['images']);
    seriesId = json['series_id'];
    isFavorite = json['is_favorite'];
    liked = json['liked'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['series'] = series.map((e) => e.toJson()).toList();
    _data['tags'] = tags;
    _data['name'] = name;
    _data['images'] = images;
    _data['series_id'] = seriesId;
    _data['is_favorite'] = isFavorite;
    _data['liked'] = liked;
    return _data;
  }
}

class ImageSize {
  ImageSize({
    required this.h,
    required this.w,
  });

  late final int h;
  late final int w;

  ImageSize.fromJson(Map<String, dynamic> json) {
    h = json['h'];
    w = json['w'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['h'] = h;
    _data['w'] = w;
    return _data;
  }
}

class Comment {
  Comment({
    required this.AID,
    required this.CID,
    required this.UID,
    required this.username,
    required this.nickname,
    required this.likes,
    required this.gender,
    required this.updateAt,
    required this.addtime,
    required this.parentCID,
    required this.expinfo,
    required this.name,
    required this.content,
    required this.photo,
    required this.spoiler,
    required this.replys,
  });

  late final int? AID;
  late final int CID;
  late final int UID;
  late final String username;
  late final String nickname;
  late final int likes;
  late final String gender;
  late final String updateAt;
  late final String addtime;
  late final int parentCID;
  late final Expinfo expinfo;
  late final String name;
  late final String content;
  late final String photo;
  late final int spoiler;
  late final List<Comment> replys;

  Comment.fromJson(Map<String, dynamic> json) {
    AID = json['AID'];
    CID = json['CID'];
    UID = json['UID'];
    username = json['username'];
    nickname = json['nickname'];
    likes = json['likes'];
    gender = json['gender'];
    updateAt = json['update_at'];
    addtime = json['addtime'];
    parentCID = json['parent_CID'];
    expinfo = Expinfo.fromJson(json['expinfo']);
    name = json['name'];
    content = json['content'];
    photo = json['photo'];
    spoiler = json['spoiler'];
    replys = List.from(json['replys'])
        .map((e) => Comment.fromJson(e))
        .cast<Comment>()
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['AID'] = AID;
    _data['CID'] = CID;
    _data['UID'] = UID;
    _data['username'] = username;
    _data['nickname'] = nickname;
    _data['likes'] = likes;
    _data['gender'] = gender;
    _data['update_at'] = updateAt;
    _data['addtime'] = addtime;
    _data['parent_CID'] = parentCID;
    _data['expinfo'] = expinfo.toJson();
    _data['name'] = name;
    _data['content'] = content;
    _data['photo'] = photo;
    _data['spoiler'] = spoiler;
    _data['replys'] = replys.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Expinfo {
  Expinfo({
    required this.levelName,
    required this.level,
    required this.nextLevelExp,
    required this.exp,
    required this.expPercent,
    required this.uid,
    required this.badges,
  });

  late final String levelName;
  late final int level;
  late final int nextLevelExp;
  late final String exp;
  late final double expPercent;
  late final int uid;
  late final List<Badge> badges;

  Expinfo.fromJson(Map<String, dynamic> json) {
    levelName = json['level_name'];
    level = json['level'];
    nextLevelExp = json['nextLevelExp'];
    exp = json['exp'];
    expPercent = json['expPercent'];
    uid = json['uid'];
    badges = List.from(json['badges']).map((e) => Badge.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['level_name'] = levelName;
    _data['level'] = level;
    _data['nextLevelExp'] = nextLevelExp;
    _data['exp'] = exp;
    _data['expPercent'] = expPercent;
    _data['uid'] = uid;
    _data['badges'] = badges.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Badge {
  Badge({
    required this.content,
    required this.name,
    required this.id,
  });

  late final String content;
  late final String name;
  late final String id;

  Badge.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['content'] = content;
    _data['name'] = name;
    _data['id'] = id;
    return _data;
  }
}

class CommentPage extends Page<Comment> {
  CommentPage.fromJson(Map<String, dynamic> json) {
    list = List.from(json['list']).map((e) => Comment.fromJson(e)).toList();
    total = json['total'];
  }
}

class PreLoginResponse {
  PreLoginResponse({
    required this.preSet,
    required this.preLogin,
    required this.selfInfo,
    required this.message,
  });

  late final bool preSet;
  late final bool preLogin;
  late final SelfInfo? selfInfo;
  late final String? message;

  PreLoginResponse.fromJson(Map<String, dynamic> json) {
    preSet = json['pre_set'];
    preLogin = json['pre_login'];
    if (json['self_info'] != null) {
      selfInfo = SelfInfo.fromJson(json['self_info']);
    } else {
      selfInfo = null;
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['pre_set'] = preSet;
    _data['pre_login'] = preLogin;
    _data['self_info'] = selfInfo?.toJson();
    _data['message'] = message;
    return _data;
  }
}

class SelfInfo {
  SelfInfo({
    required this.uid,
    required this.username,
    required this.email,
    required this.emailverified,
    required this.photo,
    required this.fname,
    required this.gender,
    required this.message,
    required this.coin,
    required this.albumFavorites,
    required this.s,
    required this.levelName,
    required this.level,
    required this.nextLevelExp,
    required this.exp,
    required this.expPercent,
    required this.badges,
    required this.albumFavoritesMax,
  });

  late final int uid;
  late final String username;
  late final String email;
  late final String emailverified;
  late final String photo;
  late final String fname;
  late final String gender;
  late final String message;
  late final int coin;
  late final int albumFavorites;
  late final String s;
  late final String levelName;
  late final int level;
  late final int nextLevelExp;
  late final String exp;
  late final double expPercent;
  late final List<dynamic> badges;
  late final int albumFavoritesMax;

  SelfInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    email = json['email'];
    emailverified = json['emailverified'];
    photo = json['photo'];
    fname = json['fname'];
    gender = json['gender'];
    message = json['message'];
    coin = json['coin'];
    albumFavorites = json['album_favorites'];
    s = json['s'];
    levelName = json['level_name'];
    level = json['level'];
    nextLevelExp = json['nextLevelExp'];
    exp = json['exp'];
    expPercent = json['expPercent'];
    badges = List.castFrom<dynamic, dynamic>(json['badges']);
    albumFavoritesMax = json['album_favorites_max'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['uid'] = uid;
    _data['username'] = username;
    _data['email'] = email;
    _data['emailverified'] = emailverified;
    _data['photo'] = photo;
    _data['fname'] = fname;
    _data['gender'] = gender;
    _data['message'] = message;
    _data['coin'] = coin;
    _data['album_favorites'] = albumFavorites;
    _data['s'] = s;
    _data['level_name'] = levelName;
    _data['level'] = level;
    _data['nextLevelExp'] = nextLevelExp;
    _data['exp'] = exp;
    _data['expPercent'] = expPercent;
    _data['badges'] = badges;
    _data['album_favorites_max'] = albumFavoritesMax;
    return _data;
  }
}

class FavoriteFolder {
  FavoriteFolder({
    required this.fid,
    required this.uid,
    required this.name,
  });

  late final String fid;
  late final String uid;
  late final String name;

  FavoriteFolder.fromJson(Map<String, dynamic> json) {
    fid = json['FID'];
    uid = json['UID'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['FID'] = fid;
    _data['UID'] = uid;
    _data['name'] = name;
    return _data;
  }
}

class Favorite extends CountPage<ComicSimple> {
  late final List<FavoriteFolderItem> folderList;
  Favorite.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    list = List.from(json['list']).map((e) => ComicSimple.fromJson(e)).toList();
    folderList = List.from(json['folder_list'])
        .map((e) => FavoriteFolderItem.fromJson(e))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final _data = super.toJson();
    _data['list'] = list;
    _data['folder_list'] = folderList;
    return _data;
  }

  Favorite(): super() {
    list = [];
    folderList = [];
  }
}

class FavoriteFolderItem {
  FavoriteFolderItem({
    required this.fid,
    required this.uid,
    required this.name,
  });

  late final int fid;
  late final int uid;
  late final String name;

  FavoriteFolderItem.fromJson(Map<String, dynamic> json) {
    fid = json['FID'];
    uid = json['UID'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['FID'] = fid;
    _data['UID'] = uid;
    _data['name'] = name;
    return _data;
  }
}

class FavoritesResponse extends CountPage<ComicSimple> {
  FavoritesResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    list = List.from(json['list']).map((e) => ComicSimple.fromJson(e)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    final _data = super.toJson();
    _data['list'] = list;
    return _data;
  }
}

class WeekFilterResponse extends Page<ComicSimple> {
    WeekFilterResponse.fromJson(Map<String, dynamic> json) {
      list = List.from(json['list']).map((e) => ComicSimple.fromJson(e)).toList();
      total = json['total'];
  }
}

class ActionResponse {
  ActionResponse({
    required this.status,
    required this.msg,
    required this.type,
  });

  late final String status;
  late final String msg;
  late final String type;

  ActionResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['msg'] = msg;
    _data['type'] = type;
    return _data;
  }
}

class InnerComicPage {
  final int total;
  final List<ComicSimple> list;
  final int? redirectAid;

  InnerComicPage({
    required this.total,
    required this.list,
    this.redirectAid,
  });
}

class CommentResponse {
  CommentResponse({
    required this.msg,
    required this.status,
    required this.aid,
    required this.cid,
    required this.spoiler,
  });

  late final String msg;
  late final String status;
  late final int aid;
  late final int cid;
  late final String spoiler;

  CommentResponse.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    status = json['status'];
    aid = json['aid'];
    cid = json['cid'];
    spoiler = json['spoiler'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    _data['status'] = status;
    _data['aid'] = aid;
    _data['cid'] = cid;
    _data['spoiler'] = spoiler;
    return _data;
  }
}

class ViewLog {
  ViewLog({
    required this.id,
    required this.author,
    required this.description,
    required this.name,
    required this.lastViewTime,
    required this.lastViewChapterId,
    required this.lastViewPage,
  });

  late final int id;
  late final String author;
  late final String description;
  late final String name;
  late final int lastViewTime;
  late final int lastViewChapterId;
  late final int lastViewPage;

  ViewLog.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    author = json['author'];
    description = json['description'];
    name = json['name'];
    lastViewTime = json['last_view_time'];
    lastViewChapterId = json['last_view_chapter_id'];
    lastViewPage = json['last_view_page'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['author'] = author;
    _data['description'] = description;
    _data['name'] = name;
    _data['last_view_time'] = lastViewTime;
    _data['last_view_chapter_id'] = lastViewChapterId;
    _data['last_view_page'] = lastViewPage;
    return _data;
  }
}

class GamePage {
  GamePage({
    required this.games,
    required this.gamesTotal,
    required this.categories,
    required this.hotGames,
  });

  late final List<Game> games;
  late final String gamesTotal;
  late final List<GameCategory> categories;
  late final List<Game> hotGames;

  GamePage.fromJson(Map<String, dynamic> json) {
    games = List.from(json['games']).map((e) => Game.fromJson(e)).toList();
    gamesTotal = json['games_total'];
    categories = List.from(json['categories'])
        .map((e) => GameCategory.fromJson(e))
        .toList();
    hotGames =
        List.from(json['hot_games']).map((e) => Game.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['games'] = games.map((e) => e.toJson()).toList();
    _data['games_total'] = gamesTotal;
    _data['categories'] = categories.map((e) => e.toJson()).toList();
    _data['hot_games'] = hotGames.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Game {
  Game({
    required this.gid,
    required this.title,
    required this.description,
    required this.tags,
    required this.link,
    required this.linkTitle,
    required this.photo,
    required this.type,
    required this.categories,
    required this.updateAt,
    required this.totalClicks,
    required this.orderRank,
    required this.status,
    required this.showLang,
  });

  late final int gid;
  late final String title;
  late final String description;
  late final String tags;
  late final String link;
  late final String linkTitle;
  late final String photo;
  late final List<String> type;
  late final GameCategory categories;
  late final int updateAt;
  late final int totalClicks;
  late final int orderRank;
  late final int status;
  late final List<String> showLang;

  Game.fromJson(Map<String, dynamic> json) {
    gid = json['gid'];
    title = json['title'];
    description = json['description'];
    tags = json['tags'];
    link = json['link'];
    linkTitle = json['link_title'];
    photo = json['photo'];
    type = List.castFrom<dynamic, String>(json['type']);
    categories = GameCategory.fromJson(json['categories']);
    updateAt = json['update_at'];
    totalClicks = json['total_clicks'];
    orderRank = json['order_rank'];
    status = json['status'];
    showLang = List.castFrom<dynamic, String>(json['show_lang']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['gid'] = gid;
    _data['title'] = title;
    _data['description'] = description;
    _data['tags'] = tags;
    _data['link'] = link;
    _data['link_title'] = linkTitle;
    _data['photo'] = photo;
    _data['type'] = type;
    _data['categories'] = categories.toJson();
    _data['update_at'] = updateAt;
    _data['total_clicks'] = totalClicks;
    _data['order_rank'] = orderRank;
    _data['status'] = status;
    _data['show_lang'] = showLang;
    return _data;
  }
}

class GameCategory {
  GameCategory({
    this.name,
    this.slug,
  });

  late final String? name;
  late final String? slug;

  GameCategory.fromJson(Map<String, dynamic> json) {
    name = null;
    slug = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['slug'] = slug;
    return _data;
  }
}

class SearchHistory {
  SearchHistory({
    required this.searchQuery,
    required this.lastSearchTime,
  });

  late final String searchQuery;
  late final int lastSearchTime;

  SearchHistory.fromJson(Map<String, dynamic> json) {
    searchQuery = json['search_query'];
    lastSearchTime = json['last_search_time'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['search_query'] = searchQuery;
    _data['last_search_time'] = lastSearchTime;
    return _data;
  }
}

class DownloadCreate {
  DownloadCreate({
    required this.album,
    required this.chapters,
  });

  late final DownloadCreateAlbum album;
  late final List<DownloadCreateChapter> chapters;

  DownloadCreate.fromJson(Map<String, dynamic> json) {
    album = DownloadCreateAlbum.fromJson(json['album']);
    chapters = List.from(json['chapters'])
        .map((e) => DownloadCreateChapter.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['album'] = album.toJson();
    _data['chapters'] = chapters.map((e) => e.toJson()).toList();
    return _data;
  }
}

class DownloadCreateAlbum {
  DownloadCreateAlbum({
    required this.id,
    required this.name,
    required this.author,
    required this.tags,
    required this.works,
    required this.description,
  });

  late final int id;
  late final String name;
  late final List<String> author;
  late final List<String> tags;
  late final List<String> works;
  late final String description;

  DownloadCreateAlbum.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    author = List.castFrom<dynamic, String>(json['author']);
    tags = List.castFrom<dynamic, String>(json['tags']);
    works = List.castFrom<dynamic, String>(json['works']);
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['author'] = author;
    _data['tags'] = tags;
    _data['works'] = works;
    _data['description'] = description;
    return _data;
  }
}

class DownloadCreateChapter {
  DownloadCreateChapter({
    required this.id,
    required this.name,
    required this.sort,
  });

  late final int id;
  late final String name;
  late final String sort;

  DownloadCreateChapter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    sort = json['sort'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['sort'] = sort;
    return _data;
  }
}

class DownloadAlbum {
  DownloadAlbum({
    required this.id,
    required this.name,
    required this.author,
    required this.tags,
    required this.works,
    required this.description,
    required this.dlSquareCoverStatus,
    required this.dl_3x4CoverStatus,
    required this.dlStatus,
    required this.imageCount,
    required this.dledImageCount,
  });

  late final int id;
  late final String name;
  late final String author;
  late final String tags;
  late final String works;
  late final String description;
  late final int dlSquareCoverStatus;
  late final int dl_3x4CoverStatus;
  late final int dlStatus;
  late final int imageCount;
  late final int dledImageCount;

  DownloadAlbum.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    author = json['author'];
    tags = json['tags'];
    works = json['works'];
    description = json['description'];
    dlSquareCoverStatus = json['dl_square_cover_status'];
    dl_3x4CoverStatus = json['dl_3x4_cover_status'];
    dlStatus = json['dl_status'];
    imageCount = json['image_count'];
    dledImageCount = json['dled_image_count'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['author'] = author;
    _data['tags'] = tags;
    _data['works'] = works;
    _data['description'] = description;
    _data['dl_square_cover_status'] = dlSquareCoverStatus;
    _data['dl_3x4_cover_status'] = dl_3x4CoverStatus;
    _data['dl_status'] = dlStatus;
    _data['image_count'] = imageCount;
    _data['dled_image_count'] = dledImageCount;
    return _data;
  }
}

class DlImage {
  DlImage({
    required this.albumId,
    required this.chapterId,
    required this.imageIndex,
    required this.name,
    required this.key,
    required this.dlStatus,
    required this.width,
    required this.height,
  });

  late final int albumId;
  late final int chapterId;
  late final int imageIndex;
  late final String name;
  late final String key;
  late final int dlStatus;
  late final int width;
  late final int height;

  DlImage.fromJson(Map<String, dynamic> json) {
    albumId = json['album_id'];
    chapterId = json['chapter_id'];
    imageIndex = json['image_index'];
    name = json['name'];
    key = json['key'];
    dlStatus = json['dl_status'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['album_id'] = albumId;
    _data['chapter_id'] = chapterId;
    _data['image_index'] = imageIndex;
    _data['name'] = name;
    _data['key'] = key;
    _data['dl_status'] = dlStatus;
    _data['width'] = width;
    _data['height'] = height;
    return _data;
  }
}

ComicBasic albumToSimple(AlbumResponse album) {
  return ComicBasic(
    id: album.id,
    description: album.description,
    name: album.name,
    author: album.author.join(" / "),
    image: album.images.isEmpty ? '' : album.images[0] ?? '',
  );
}

class IsPro {
  late bool isPro;
  late int expire;

  IsPro.fromJson(Map<String, dynamic> json) {
    isPro = json["is_pro"];
    this.expire = json["expire"];
  }
}

class ProInfoAll {
  late ProInfoAf proInfoAf;
  late ProInfoPat proInfoPat;

  ProInfoAll.fromJson(Map<String, dynamic> json) {
    proInfoAf = ProInfoAf.fromJson(json["pro_info_af"]);
    proInfoPat = ProInfoPat.fromJson(json["pro_info_pat"]);
  }
}

class ProInfoAf {
  late bool isPro;
  late int expire;

  ProInfoAf.fromJson(Map<String, dynamic> json) {
    isPro = json["is_pro"];
    expire = json["expire"];
  }
}

class ProInfoPat {
  late bool isPro;
  late String patId;
  late String bindUid;
  late int requestDelete;
  late int reBind;
  late int errorType;
  late String errorMsg;
  late String accessKey;

  ProInfoPat.fromJson(Map<String, dynamic> json) {
    isPro = json["is_pro"];
    patId = json["pat_id"] ?? "";
    bindUid = json["bind_uid"] ?? "";
    requestDelete = json["request_delete"] ?? 0;
    reBind = json["re_bind"] ?? 0;
    errorType = json["error_type"] ?? 0;
    errorMsg = json["error_msg"] ?? "";
    accessKey = json["access_key"] ?? "";
  }
}

class WeekData {
  late List<WeekCategory> categories;
  late List<WeekType> types;

  WeekData.fromJson(Map<String, dynamic> json) {
    categories = List.from(json['categories']).map((e) => WeekCategory.fromJson(e)).toList();
    types = List.from(json['type']).map((e) => WeekType.fromJson(e)).toList();
  }
}

class WeekCategory {
  late String id;
  late String time;
  late String title;

  WeekCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    time = json['time'];
    title = json['title'];
  }
}

class WeekType {
  late String id;
  late String title;

  WeekType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }
}
