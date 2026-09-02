// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:ling_bao/profile/main/page/profile_page.dart';

import '../video/shared/home_assets.dart';
import '../video/shared/home_models.dart';
import 'create_controller.dart';

/// 创作类型弹窗里每个入口的配置模型。
class CreateTypeEntryData {
  const CreateTypeEntryData({
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.mode,
    required this.flow,
    required this.bannerId,
  });

  final String title;
  final String subtitle;
  final String assetPath;
  final int bannerId;
  final CreationMode mode;
  final CreateFlowType flow;
}

const List<CreateTypeEntryData> createTypeEntries = <CreateTypeEntryData>[
  CreateTypeEntryData(
    title: '图生视频',
    subtitle: '上传图片，一键生成流畅动态视频',
    assetPath: HomeAssets.createTypeImageToVideo,
    mode: CreationMode.video,
    flow: CreateFlowType.imageToVideo,
    bannerId: 1,
  ),
  CreateTypeEntryData(
    title: '文生视频',
    subtitle: '输入文字描述，AI 自动创作完整视频',
    assetPath: HomeAssets.createTypeTextToVideo,
    mode: CreationMode.video,
    flow: CreateFlowType.textToVideo,
    bannerId: 2,
  ),
  // CreateTypeEntryData(
  //   title: '首尾帧视频',
  //   subtitle: '设置开头与结尾画面，生成连贯视频',
  //   assetPath: HomeAssets.createTypeHeadTailVideo,
  //   mode: CreationMode.video,
  //   flow: CreateFlowType.headTailVideo,
  // ),
  // CreateTypeEntryData(
  //   title: '多图融合视频',
  //   subtitle: '多张图片自动衔接，一键合成连贯视频',
  //   assetPath: HomeAssets.createTypeMultiImageVideo,
  //   mode: CreationMode.video,
  //   flow: CreateFlowType.multiImageVideo,
  // ),
  CreateTypeEntryData(
    title: 'Ai绘图',
    subtitle: '输入创意描述，快速生成高清原创作品',
    assetPath: HomeAssets.createTypeAiDraw,
    mode: CreationMode.image,
    flow: CreateFlowType.aiDraw,
    bannerId: 3,
  ),
  // CreateTypeEntryData(
  //   title: 'Ai修图',
  //   subtitle: '智能优化图片，一键提升图片质感',
  //   assetPath: HomeAssets.createTypeAiEdit,
  //   mode: CreationMode.image,
  //   flow: CreateFlowType.aiEdit,
  // ),
  CreateTypeEntryData(
    title: '参考生图',
    subtitle: '参考图片生成高度一致作品',
    assetPath: HomeAssets.createTypeReferenceImage,
    mode: CreationMode.image,
    flow: CreateFlowType.referenceImage,
    bannerId: 4,
  ),
];

class CreateTypeDialog extends StatelessWidget {
  const CreateTypeDialog({
    required this.onSelect,
    required this.onClose,
    required this.category,
    this.showCloseButton = true,
  });

  final ValueChanged<CreateTypeEntryData> onSelect;
  final VoidCallback onClose;
  final GenerateCategory category;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    List<CreateTypeEntryData> entries = createTypeEntries;
    if (category == .image) {
      entries = createTypeEntries.where((e) => e.mode == .image).toList();
    } else if (category == .video) {
      entries = createTypeEntries.where((e) => e.mode == .video).toList();
    }
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 354),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _CreateTypeTile(
                              data: entry,
                              onTap: () => onSelect(entry),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (showCloseButton) ...<Widget>[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      child: Center(
                        child: Image.asset(
                          HomeAssets.createTypeClose,
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateTypeTile extends StatelessWidget {
  const _CreateTypeTile({required this.data, required this.onTap});

  final CreateTypeEntryData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xF3282828),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 36,
                height: 36,
                child: Image.asset(data.assetPath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.52),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
