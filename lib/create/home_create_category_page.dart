import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global/routes/app_pages.dart';
import '../profile/main/page/profile_page.dart';
import 'home_create_type_dialog.dart';

class CreateCategoryPage extends StatelessWidget {
  const CreateCategoryPage({
    super.key,
    required this.title,
    required this.category,
  });

  final String title;
  final GenerateCategory category;

  @override
  Widget build(BuildContext context) {
    List<CreateTypeEntryData> entries = createTypeEntries;
    if (category == .image) {
      entries = createTypeEntries.where((e) => e.mode == .image).toList();
    } else if (category == .video) {
      entries = createTypeEntries.where((e) => e.mode == .video).toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final CreateTypeEntryData entry = entries[index];
            return _CreateCategoryTile(
              data: entry,
              onTap: () {
                Get.toNamed(Routes.create, arguments: {'entry': entry});
              },
            );
          },
        ),
      ),
    );
  }
}

class _CreateCategoryTile extends StatelessWidget {
  const _CreateCategoryTile({required this.data, required this.onTap});

  final CreateTypeEntryData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 38,
                height: 38,
                child: Image.asset(data.assetPath),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 11,
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
