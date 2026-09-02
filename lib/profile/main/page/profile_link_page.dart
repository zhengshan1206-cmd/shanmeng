// 简单的协议/客服链接承接页。
// 当前项目尚未接入内嵌 WebView，因此先以可复制链接的形式完成链路承接。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile_shared.dart';

/// 通用链接详情页。
class ProfileLinkPage extends StatelessWidget {
  const ProfileLinkPage({
    super.key,
    required this.title,
    required this.description,
    this.url = '',
    this.emptyMessage = '当前暂未配置内容',
  });

  final String title;
  final String description;
  final String url;
  final String emptyMessage;

  /// 是否已经拿到有效链接。
  bool get _hasUrl => url.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: title,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          ProfileSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _hasUrl ? '链接地址' : '提示',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                SelectionArea(
                  // 链接和说明都允许用户直接选中复制。
                  child: Text(
                    _hasUrl ? url : emptyMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                if (_hasUrl) ...<Widget>[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // 当前版本不直接拉起浏览器，而是先提供复制动作作为最稳妥的承接。
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('链接已复制')));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4B6A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('复制链接'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
