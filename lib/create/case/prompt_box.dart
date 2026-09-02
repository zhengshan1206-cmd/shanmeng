import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../create_controller.dart';

class CreateSectionTitle extends StatelessWidget {
  const CreateSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null)
            TextSpan(
              text: subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class CreatePromptBox extends StatelessWidget {
  CreatePromptBox({
    super.key,
    required this.hint,
    this.enabled = true,
  });

  final String hint;
  final bool enabled;

  final CreateController controller = Get.find<CreateController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 138),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: controller.textController,
            enabled: enabled,
            maxLines: 5,
            minLines: 5,
            maxLength: 500,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.18),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              controller.promptChanged(value);
            },
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomLeft,
            child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.textController,
                    builder: (context, value, child) {
                      return Text(
                        '${value.text.characters.length}/500',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.24),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
