import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/configs/login.dart';
import 'package:jasmine/screens/about_screen.dart';
import 'package:jasmine/screens/comments_screen.dart';
import 'package:jasmine/screens/components/avatar.dart';
import 'package:jasmine/screens/pro_oh_screen.dart';
import 'package:jasmine/screens/pro_screen.dart';
import 'package:jasmine/screens/components/recommend_links_panel.dart';
import 'package:jasmine/screens/settings_screen.dart';
import 'package:jasmine/screens/view_log_screen.dart';

import '../basic/platform.dart';
import '../configs/daily_sign.dart';
import '../configs/is_pro.dart';
import 'components/badge.dart';
import 'downloads_screen.dart';
import 'favorites_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    loginEvent.subscribe(_setState);
    proEvent.subscribe(_setState);
    dailySignEvent.subscribe(_setState);
    super.initState();
  }

  @override
  void dispose() {
    loginEvent.unsubscribe(_setState);
    proEvent.unsubscribe(_setState);
    dailySignEvent.unsubscribe(_setState);
    super.dispose();
  }

  void _setState(_) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text("个人中心"), actions: [
        if (!normalPlatform)
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const ProOhScreen();
              }));
            },
            icon: Icon(
              isPro ? Icons.offline_bolt : Icons.offline_bolt_outlined,
            ),
          ),
        if (normalPlatform)
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return const ProScreen();
              }));
            },
            icon: Icon(
              isPro ? Icons.offline_bolt : Icons.offline_bolt_outlined,
            ),
          ),
        _buildSettingsIcon(),
        if (normalPlatform) _buildAboutIcon(),
      ]),
      body: SafeArea(
        child: ListView(
          children: [
            _buildCard(),
            const Divider(),
            _buildFavorites(),
            const Divider(),
            _buildViewLog(),
            const Divider(),
            _buildDownloads(),
            const Divider(),
            _buildComments(),
            const Divider(),
            const RecommendLinksPanel(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            ),
            // _buildFdT(),
            // const Divider(),
            // _buildSettingsT(),
            // const Divider(),
            // _buildAboutT(),
            // const Divider(),
            Container(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    late Widget child;
    switch (loginStatus) {
      case LoginStatus.notSet:
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginButton("登录 / 注册"),
            const SizedBox(height: 8),
          ],
        );
        break;
      case LoginStatus.logging:
        child = _buildLoginLoading();
        break;
      case LoginStatus.loginSuccess:
        child = _buildSelfInfoCard();
        break;
      case LoginStatus.loginField:
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginButton("登录失败/点击重试"),
            const SizedBox(height: 8),
            const SizedBox(height: 10),
            _buildLoginErrorButton(),
          ],
        );
        break;
    }
    return Container(
      height: 200,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey.shade200
          : Colors.grey.shade800,
      child: Center(
        child: child,
      ),
    );
  }

  Widget _buildLoginButton(String title) {
    return MaterialButton(
      onPressed: () async {
        await loginDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: .5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLoading() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        return Icon(Icons.refresh,
            size: size * .5, color: Colors.white.withOpacity(.5));
      },
    );
  }

  Widget _buildLoginErrorButton() {
    return MaterialButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("登录失败"),
              content: SelectableText(loginMessage),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("确认"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          border: Border.all(
            color: Colors.black,
            style: BorderStyle.solid,
            width: .5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: const Text(
          "查看错误",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelfInfoCard() {
    final brightness = Theme.of(context).brightness;
    final statusColor =
        brightness == Brightness.light ? Colors.black54 : Colors.white70;
    final statusStyle =
        (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
            .copyWith(fontSize: 12, color: statusColor);
    return Column(
      children: [
        Expanded(child: Container()),
        Center(
          child: Avatar(selfInfo.photo),
        ),
        Container(height: 10),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selfInfo.username,
                style: TextStyle(
                  color: brightness == Brightness.light
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () async {
                  await checkDailySignStatus(context, toast: true);
                },
                child: Text(
                  dailySignStatusLabel(),
                  style: statusStyle,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _buildFavorites() {
    return ListTile(
      onTap: () async {
        if (LoginStatus.loginSuccess == loginStatus) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) {
              return const FavoritesScreen();
            },
          ));
        } else {
          defaultToast(context, "登录之后才能使用收藏夹喔");
        }
      },
      title: const Text("收藏夹"),
    );
  }

  Widget _buildViewLog() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const ViewLogScreen();
          },
        ));
      },
      title: const Text("浏览记录"),
    );
  }

  Widget _buildDownloads() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const DownloadsScreen();
          },
        ));
      },
      title: const Text("下载列表"),
    );
  }

  Widget _buildComments() {
    return ListTile(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const CommentsScreen();
          },
        ));
      },
      title: const Text("讨论区"),
    );
  }

  Widget _buildSettingsIcon() {
    return IconButton(
      onPressed: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const SettingsScreen();
          },
        ));
      },
      icon: const Icon(Icons.settings),
    );
  }

  Widget _buildAboutIcon() {
    return IconButton(
      onPressed: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const AboutScreen();
          },
        ));
      },
      icon: const VersionBadged(
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Icon(Icons.info_outlined),
        ),
      ),
    );
  }

  Widget _buildFdT() {
    return ListTile(
      title: const Text("发电"),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const ProScreen();
          },
        ));
      },
    );
  }

  Widget _buildSettingsT() {
    return ListTile(
      title: const Text("设置"),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const SettingsScreen();
          },
        ));
      },
    );
  }

  Widget _buildAboutT() {
    return ListTile(
      title: const VersionBadged(
        child: Text("关于"),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return const AboutScreen();
          },
        ));
      },
    );
  }
}
