
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lpinyin/lpinyin.dart';
import '../../../../core/network/apis.dart';
import '../../../../core/network/http_utils.dart';
import '../../../../core/ui/dialog/loading_dialog.dart';
import '../bean/illegal_words_bean.dart';
import '../view/illegal_words_dialog.dart';

class IllegalWordsManager {
  ///违禁词列表
  RxList<String> bandedWords = <String>[].obs;
  ///选择的违禁词
  Rx<String> selectedBandedWord = "".obs;
  ///内容
  Rx<String> content = ''.obs;

  ///清空
  void clear() {
    content.value = '';
    bandedWords.value = [];
    selectedBandedWord.value = '';
  }

  ///更新违禁词
  void updateBandedWords(List<String> words) {
    bandedWords.value = words;
  }
  ///更新当前选择的违禁词
  void updateSelectedBandedWord(String word) {
    selectedBandedWord.value = word;
  }

  ///首字母替换违禁词
  void replaceWithInitialLetterOfPinyin() {
    for (var e in bandedWords) {
      content.value = content.value.replaceAll(e, PinyinHelper.getShortPinyin(e));
    }
  }

  /// 将选中的违禁词替换为[word]
  void replaceWord(String word, Function call) {
    content.value = content.value.replaceAll(selectedBandedWord.value, word);
    bandedWords.removeWhere((item) => item == selectedBandedWord.value);
    updateBandedWords(List<String>.from(bandedWords));
    call();
  }

  ///违禁词检测
  void detectIllegalWords(
    String contents, {
    IllegalWordsManager? manager,
    bool showDialog = false,
    void Function(String)? onSuccess,
    void Function()? noIllegalWords,
    void Function()? onFail,
  }) {
    if(showDialog) {
      LoadingDialog().show(message: '违禁词检测中...');
    }
    content.value = contents;
    textRisk(
      content: contents,
      onSuccess: (data) {
        LoadingDialog().dismiss();
        final status = data["status"] ?? 0;
        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          updateBandedWords(riskWords);
          ///有违禁词
          if (bandedWords.isNotEmpty) {
            updateSelectedBandedWord(bandedWords.first);
            if(showDialog) {
              showIllegalWordsDialog(manager: manager, onSuccess: onSuccess);
            }
          }
          else{
            // BotToast.showText(text: '当前无违禁词');
            noIllegalWords?.call();
          }
        }
      },
      onFail: (){
        LoadingDialog().dismiss();
        onFail?.call();
      },
    );
  }

  void showIllegalWordsDialog({IllegalWordsManager? manager, void Function(String)? onSuccess}){
    showDialog(
        context: Get.context!,
        useSafeArea: false,
        barrierDismissible: true,
        builder: (ctx) {
          return IllegalWordsDialog(manager: manager!,);
        }).then((value) {
      if (value != null) {
        if (value["content"] != null) {
          onSuccess?.call(value['content']);
        }
      }
    });
  }


  ///检测
  void textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
    void Function()? onFail
  }) {
    HttpUtils.post(
      APIs.textRisk,
      {
        "type": type ?? "3",
        "needMark": needMark ?? "2",
        "labelType": "499001",
        "content": content,
      },
      forceData: true,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        onFail?.call();
      },
    );
  }

}