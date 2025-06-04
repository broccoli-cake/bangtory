import 'package:flutter/material.dart';

class DialogUtils {
  /// 삭제 확인 다이얼로그
  static Future<bool> showDeleteConfirmDialog(
      BuildContext context, {
        required String title,
        required String content,
        String cancelText = '취소',
        String deleteText = '삭제',
      }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: Text(deleteText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// 일반적인 확인 다이얼로그
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String content,
        String cancelText = '취소',
        String confirmText = '확인',
        Color? confirmColor,
      }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: confirmColor != null
                  ? TextButton.styleFrom(foregroundColor: confirmColor)
                  : null,
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}