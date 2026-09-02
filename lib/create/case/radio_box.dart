import 'package:flutter/material.dart';

/// 视频比例卡片数据。
class CreateRatioData {
  const CreateRatioData({
    required this.label,
    required this.width,
    required this.height,
  });

  final String label;
  final double width;
  final double height;
}

const List<CreateRatioData> ratioOptions = <CreateRatioData>[
  CreateRatioData(label: '4:3', width: 26, height: 20),
  CreateRatioData(label: '3:4', width: 18, height: 24),
  CreateRatioData(label: '16:9', width: 30, height: 18),
  CreateRatioData(label: '9:16', width: 16, height: 28),
];

class CreateRatioRow extends StatefulWidget {
  const CreateRatioRow({super.key, this.onSelected});

  final ValueChanged<String>? onSelected;

  @override
  State<CreateRatioRow> createState() => _CreateRatioRowState();
}

class _CreateRatioRowState extends State<CreateRatioRow> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ratioOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _CreateRatioCard(
          data: ratioOptions[index],
          selected: _selectedIndex == index,
          onTap: () {
            widget.onSelected?.call(ratioOptions[index].label);
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _CreateRatioCard extends StatelessWidget {
  const _CreateRatioCard({
    required this.data,
    required this.selected,
    this.onTap,
  });

  final CreateRatioData data;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        decoration: BoxDecoration(
          color: selected ? Color(0x32FFFFFF) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: data.width,
              height: data.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
