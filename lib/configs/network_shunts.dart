import 'package:flutter/material.dart';
import 'package:jasmine/basic/commons.dart';
import 'package:jasmine/basic/methods.dart';

final ValueNotifier<int> shuntListsRevision = ValueNotifier(0);

late String _apiHost;
late String _cdnHost;

String get currentApiHostName => _apiHost;

String get currentCdnHostName => _cdnHost;

Future<void> initApiHost() async {
  await reloadApiHosts();
}

Future<void> initCdnHost() async {
  await reloadCdnHosts();
}

Future<void> reloadApiHosts() async {
  _apiHost = await methods.loadApiHost();
}

Future<void> reloadCdnHosts() async {
  _cdnHost = await methods.loadCdnHost();
}

Future<void> refreshShuntLists() async {
  await reloadApiHosts();
  await reloadCdnHosts();
  shuntListsRevision.value++;
}

Future<void> chooseApiHost(BuildContext context) async {
  final choose = await showHostDialog(
    context: context,
    title: "API分流",
    manualTitle: "自定义 API 域名",
    load: methods.loadApiHostOptions,
    ping: methods.ping,
    addCustom: methods.addApiHostCustom,
    removeCustom: methods.removeApiHostCustom,
  );
  if (choose != null && choose.isNotEmpty) {
    await methods.saveApiHost(choose);
    await reloadApiHosts();
  }
}

Future<void> chooseCdnHost(BuildContext context) async {
  final choose = await showHostDialog(
    context: context,
    title: "图片分流",
    manualTitle: "自定义图片域名",
    load: methods.loadCdnHostOptions,
    ping: methods.pingCdn,
    addCustom: methods.addCdnHostCustom,
    removeCustom: methods.removeCdnHostCustom,
  );
  if (choose != null && choose.isNotEmpty) {
    await methods.saveCdnHost(choose);
    await reloadCdnHosts();
  }
}

Widget apiHostSetting() {
  return ValueListenableBuilder<int>(
    valueListenable: shuntListsRevision,
    builder: (context, value, child) {
      return ListTile(
        onTap: () async {
          await chooseApiHost(context);
          shuntListsRevision.value++;
        },
        title: const Text("API分流"),
        subtitle: Text(_apiHost),
      );
    },
  );
}

Widget cdnHostSetting() {
  return ValueListenableBuilder<int>(
    valueListenable: shuntListsRevision,
    builder: (context, value, child) {
      return ListTile(
        onTap: () async {
          await chooseCdnHost(context);
          shuntListsRevision.value++;
        },
        title: const Text("图片分流"),
        subtitle: Text(_cdnHost),
      );
    },
  );
}

Widget updateShuntsSetting() {
  return const UpdateShuntsTile();
}

class UpdateShuntsTile extends StatefulWidget {
  const UpdateShuntsTile({Key? key}) : super(key: key);

  @override
  State<UpdateShuntsTile> createState() => _UpdateShuntsTileState();
}

class _UpdateShuntsTileState extends State<UpdateShuntsTile> {
  bool _busy = false;

  Future<void> _update() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
    });
    try {
      final result = await methods.updateShunts();
      await refreshShuntLists();
      if (!mounted) {
        return;
      }
      defaultToast(context, result.message);
    } catch (e) {
      if (!mounted) {
        return;
      }
      defaultToast(context, "$e");
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _busy ? null : _update,
      title: const Text("更新分流"),
      subtitle: Text(_busy ? "正在更新 API 和图片域名" : "刷新 API 和图片域名"),
      trailing: _busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
    );
  }
}

Future<String?> showHostDialog({
  required BuildContext context,
  required String title,
  required String manualTitle,
  required Future<HostOptions> Function() load,
  required Future<int> Function(String host) ping,
  required Future<String> Function(String host) addCustom,
  required Future<void> Function(String host) removeCustom,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return _HostDialog(
        title: title,
        manualTitle: manualTitle,
        load: load,
        ping: ping,
        addCustom: addCustom,
        removeCustom: removeCustom,
      );
    },
  );
}

class _HostDialog extends StatefulWidget {
  final String title;
  final String manualTitle;
  final Future<HostOptions> Function() load;
  final Future<int> Function(String host) ping;
  final Future<String> Function(String host) addCustom;
  final Future<void> Function(String host) removeCustom;

  const _HostDialog({
    required this.title,
    required this.manualTitle,
    required this.load,
    required this.ping,
    required this.addCustom,
    required this.removeCustom,
  });

  @override
  State<_HostDialog> createState() => _HostDialogState();
}

class _HostDialogState extends State<_HostDialog> {
  HostOptions? _options;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      final options = await widget.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _options = options;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
      });
    }
  }

  Future<void> _add() async {
    final host = await _inputHost(context, widget.manualTitle);
    if (host == null || host.isEmpty || !mounted) {
      return;
    }
    try {
      final saved = await widget.addCustom(host);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(saved);
    } catch (error) {
      if (!mounted) {
        return;
      }
      defaultToast(context, "$error");
    }
  }

  Future<void> _remove(String host) async {
    try {
      await widget.removeCustom(host);
      await refreshShuntLists();
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      defaultToast(context, "$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.45,
        child: options == null
            ? Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : Text("$_error"),
              )
            : ListView(
                children: [
                  for (final host in options.visible)
                    _HostOptionRow(
                      host: host,
                      custom: options.isCustom(host),
                      ping: widget.ping(host),
                      onTap: () => Navigator.of(context).pop(host),
                      onDelete:
                          options.isCustom(host) ? () => _remove(host) : null,
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: _add,
          child: const Text("自定义域名"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("取消"),
        ),
      ],
    );
  }
}

Future<String?> _inputHost(BuildContext context, String title) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "www.example.com",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text("确定"),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (result == null || result.isEmpty) {
    return null;
  }
  return result;
}

class _HostOptionRow extends StatelessWidget {
  final String host;
  final bool custom;
  final Future<int> ping;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _HostOptionRow({
    required this.host,
    required this.custom,
    required this.ping,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(host)),
            FutureBuilder<int>(
              future: ping,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _PingStatus("测速中", Colors.blue);
                }
                if (snapshot.hasError) {
                  return const _PingStatus("失败", Colors.red);
                }
                final latency = snapshot.requireData;
                if (latency <= 200) {
                  return _PingStatus("${latency}ms", Colors.green);
                }
                if (latency <= 500) {
                  return _PingStatus("${latency}ms", Colors.yellow);
                }
                return _PingStatus("${latency}ms", Colors.orange);
              },
            ),
            if (onDelete != null)
              IconButton(
                tooltip: custom ? "删除自定义域名" : null,
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _PingStatus extends StatelessWidget {
  final String title;
  final Color color;

  const _PingStatus(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('\u2022', style: TextStyle(color: color)),
        Text(" $title"),
      ],
    );
  }
}
