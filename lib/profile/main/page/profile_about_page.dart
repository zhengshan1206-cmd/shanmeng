// 关于我们页面。
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'profile_shared.dart';

/// 展示版本号、备案信息和公司信息。
class ProfileAboutPage extends StatefulWidget {
  const ProfileAboutPage({super.key});

  @override
  State<ProfileAboutPage> createState() => _ProfileAboutPageState();
}

class _ProfileAboutPageState extends State<ProfileAboutPage> {
  String _version = '--';
  String _appName = '闪梦 AI';

  @override
  void initState() {
    super.initState();
    // 版本信息来自本机包体，而不是后端接口。
    _loadPackageInfo();
  }

  /// 读取本地安装包信息。
  Future<void> _loadPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _version = packageInfo.version;
      _appName = packageInfo.appName.isEmpty ? '闪梦 AI' : packageInfo.appName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: '关于我们',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: <Widget>[
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFFF4B6A), Color(0xFFFF8D52)],
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x40FF4B6A),
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon.png',
                  width: 96,
                  height: 96,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _appName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '版本号 v$_version',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          // 当前关于页以静态公司信息为主，后续如需接版本更新接口可在此扩展。
          const ProfileSectionCard(
            child: Column(
              children: <Widget>[
                _AboutRow(title: '版本更新', trailing: '当前已是最新版本'),
                SizedBox(height: 14),
                _AboutRow(title: '客服邮箱', trailing: 'zdrawai@163.com'),
                SizedBox(height: 14),
                _AboutRow(title: '备案信息', trailing: '蜀ICP备2025127142号-2A'),
                SizedBox(height: 14),
                _AboutRow(title: '版权所有', trailing: '成都智绘星河科技有限公司'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 关于页的单行信息项。
class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: <Widget>[
        Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
        ),
        Text(
            trailing,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 13,
              height: 1.5,
            ),
        ),
      ],
    );
  }
}
