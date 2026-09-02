/*
 * @Author: cold-x
 * @Date: 2025-06-14 17:36:06
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-05 17:10:24
 * @FilePath: /novel_oversea/lib/core/service/words.dart
 * @Description: 
 */


///字数显示服务
class WordsService {
  static String wordsDisplay (String words, {bool digits = true}) {
    ///字数转化为数字
    int number = 0;
    try {
      number = int.parse(words);
    } catch (e) {
      return words;
    }
    if(number >= 1000000) {
      if(digits) {
        ///保留一位小数
        final tmp = (number/100000).round()/10;
        return '$tmp M';
      }
      return '${(number/1000000).round()} M';
    }
    if (number >= 1000){
      if(digits) {
        ///保留一位小数
        final tmp = (number/100).round()/10;
        return '$tmp K';
      }
      return '${(number/1000).round()} K';
    }
    return '$number';
  }

  static String wordsDisplayCN (String words, {String unit = 'K', bool showIntegal = false}) {
    ///字数转化为数字
    int number = 0;
    try {
      number = int.parse(words);
    } catch (e) {
      return words;
    }
    if (number >= 10000){
      if(showIntegal) {
        final tmp = (number/10000).round();
        return '$tmp$unit';
      }
      ///保留一位小数
      final tmp = (number/1000).round()/10;
      return '$tmp$unit';
    }
    return '$number';
  }
}