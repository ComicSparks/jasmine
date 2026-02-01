import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../basic/web_dav_sync.dart';
import '../configs/login.dart';
import '../configs/passed.dart';
import 'app_screen.dart';
import 'first_login_screen.dart';

class UnlockBrowserScreen extends StatefulWidget {
  const UnlockBrowserScreen({Key? key}) : super(key: key);

  @override
  State<UnlockBrowserScreen> createState() => _UnlockBrowserScreenState();
}

class _UnlockBrowserScreenState extends State<UnlockBrowserScreen> {
  static const _activationScheme = 'jm://start';
  static const _defaultUrl = 'https://www.bing.com/';

  final TextEditingController _addressController =
      TextEditingController(text: _defaultUrl);
  final FocusNode _addressFocusNode = FocusNode();

  InAppWebViewController? _webViewController;
  String _currentUrl = _defaultUrl;
  double _progress = 0;

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  String _normalize(String input) {
    return input.trim();
  }

  bool _isActivationUrl(String url) {
    final normalized = _normalize(url);
    if (normalized == _activationScheme) return true;
    if (normalized == '$_activationScheme/') return true;
    return normalized.startsWith(_activationScheme);
  }

  Uri _toUri(String input) {
    final raw = _normalize(input);
    if (raw.isEmpty) return Uri.parse('about:blank');
    final uri = Uri.tryParse(raw);
    if (uri == null) return Uri.parse('about:blank');
    if (uri.hasScheme) return uri;
    return Uri.parse('https://$raw');
  }

  Future<void> _activate() async {
    await firstPassed();
    if (!mounted) return;

    if (loginStatus == LoginStatus.notSet) {
      await webDavSyncAuto(context);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) {
          return firstLoginScreen;
        }),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) {
        return const AppScreen();
      }),
    );
  }

  Future<void> _loadFromAddressBar(String value) async {
    if (_isActivationUrl(value)) {
      await _activate();
      return;
    }
    final uri = _toUri(value);
    await _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(uri.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          textInputAction: TextInputAction.go,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            hintText: '输入网址',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onSubmitted: (value) async {
            await _loadFromAddressBar(value);
          },
        ),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: () => _webViewController?.reload(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: '菜单',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline),
                              const SizedBox(width: 8),
                              Text(
                                '解锁主页',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '在地址栏输入 $_activationScheme 并回车即可解锁主页。',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.content_copy, size: 16),
                                label: const Text('复制解锁地址'),
                                onPressed: () {
                                  Clipboard.setData(
                                    const ClipboardData(text: _activationScheme),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('已复制到剪贴板'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.home_outlined, size: 16),
                                label: const Text('打开空白页'),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  _addressController.text = 'about:blank';
                                  await _loadFromAddressBar('about:blank');
                                },
                              ),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.link, size: 16),
                                label: const Text('复制当前链接'),
                                onPressed: () {
                                  final url = _currentUrl;
                                  Clipboard.setData(ClipboardData(text: url));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('已复制到剪贴板'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(value: _progress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_currentUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: true,
                allowsInlineMediaPlayback: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              shouldOverrideUrlLoading: (controller, action) async {
                final url = action.request.url?.toString() ?? '';
                if (_isActivationUrl(url)) {
                  unawaited(_activate());
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStart: (controller, url) {
                final u = url?.toString() ?? '';
                setState(() {
                  _currentUrl = u.isEmpty ? _currentUrl : u;
                  _addressController.text = _currentUrl;
                });
              },
              onLoadStop: (controller, url) async {
                final u = url?.toString() ?? '';
                setState(() {
                  _currentUrl = u.isEmpty ? _currentUrl : u;
                  _addressController.text = _currentUrl;
                  _progress = 0;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100.0;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
