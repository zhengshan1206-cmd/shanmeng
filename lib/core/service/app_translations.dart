// app_translations.dart
import 'dart:ui';
import 'package:get/get.dart';

import '../../global/const/const_string.dart';
import '../../global/other/language/ja_translations.dart';
import '../../global/other/language/zh_translations.dart';
import '../../global/other/language/en_translations.dart';
import '../../global/other/language/es_translations.dart';
import '../../global/other/language/ar_translations.dart';
import '../../global/other/language/fr_translations.dart';
import '../../global/other/language/ko_translations.dart';
import '../../global/other/language/pt_translations.dart';
import '../../global/other/language/ru_translations.dart';
import '../cache/cache.dart';


class LanguageService {

  // 保存语言设置（如"zh_CN"、"en_US"）
  static Future<void> saveLanguage(String languageCode) async {
    await LocalCacheManager.saveJsonData(ConstString.kLanguageSetting, languageCode);
  }

  // 读取保存的语言设置，默认跟随本地语言
  static Future<Locale?> getSavedLanguage() async {
    final language = await LocalCacheManager.readJsonData(ConstString.kLanguageSetting);
    if (language.isNotEmpty) {
      final String languageCode = language.toString().split('_')[0];
      final String languageCountry = language.toString().split('_')[1];
      return Locale(languageCode, languageCountry);
    }
    return Get.deviceLocale;
  }
}

class AppTranslations extends Translations {
  // 支持的语言
  @override
  Map<String, Map<String, String>> get keys => {
        // 英文
        'en_US': enTranslations,
        // 中文
        'zh_CN': zhTranslations,
        // 日语
        'ja_JP': jaTranslations,
        // 韩语
        'ko_KO': koTranslations,
        // 法语
        'fr_FR': frTranslations,
        // 西班牙语
        'es_ES': esTranslations,
        // 俄语
        'ru_RU': ruTranslations,
        // 葡萄牙语
        'pt_BR': ptTranslations,
        // 阿拉伯语
        'ar_AR': arTranslations,
      };
}