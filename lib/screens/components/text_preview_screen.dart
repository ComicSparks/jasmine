import 'package:flutter/material.dart';
import 'package:jasmine/configs/app_font_size.dart';
import 'package:jasmine/configs/content_convert.dart';

class TextPreviewScreen extends StatefulWidget {
  final String text;

  const TextPreviewScreen({
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  State<TextPreviewScreen> createState() => _TextPreviewScreenState();
}

class _TextPreviewScreenState extends State<TextPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    final contentFontSize = (Theme.of(context).textTheme.bodyMedium?.fontSize ??
            14) +
        currentFontSizeAdjust(FontSizeAdjustType.fontSizeAdjustCommentContent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('评论全文'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              // 复制文本到剪贴板
              // 这里可以添加复制功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: CcSelectableText(
          widget.text,
          style: TextStyle(
            fontSize: contentFontSize,
            height: 1.5,
          ),
        ),
      ),
    );
  }
} 