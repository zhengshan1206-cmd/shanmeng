import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ling_bao/core/cache/byhy_aes_storage_utils.dart';
import 'package:ling_bao/core/service/animate/scale_transition_widget.dart';
import 'package:ling_bao/core/ui/dialog/toast.dart';
import 'package:ling_bao/core/ui/view/byhy_base_web_view.dart';
import 'package:ling_bao/core/ui/widget/by_text.dart';
import 'package:ling_bao/global/pay/bean/bank_pay_bank_bean.dart';
import 'package:ling_bao/global/pay/controller/bank_card_select_controller.dart';
import 'package:ling_bao/global/pay/view/bank_card_agreement_confirm_dialog.dart';
import 'package:ling_bao/global/ui/colors.dart';

import '../../launch/view/finger_scale_animate_view.dart';
import '../../other/event_tracking/event_tracking.dart';

Future<String?> showBankCardQuickPayDialog({
  required BuildContext context,
  required BankPayBankBean bank,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BankCardQuickPayDialog(bank: bank),
  );
}

class BankCardQuickPayDialog extends StatefulWidget {
  const BankCardQuickPayDialog({super.key, required this.bank});

  final BankPayBankBean bank;

  @override
  State<BankCardQuickPayDialog> createState() => _BankCardQuickPayDialogState();
}

class _BankCardQuickPayDialogState extends State<BankCardQuickPayDialog> {
  static const String _cachedSignerNameKey =
      'bank_card_quick_pay_cached_signer_name';
  static const String _cachedSignerIdentityKey =
      'bank_card_quick_pay_cached_signer_identity';

  late final TextEditingController _nameController;
  late final TextEditingController _identityController;
  late final List<BankCardType> _availableCardTypes;
  late final BankCardSelectController _controller;
  late final FocusNode _blurFocusNode;
  late final FocusNode _nameFocusNode;
  late final FocusNode _identityFocusNode;

  BankCardType? _selectedCardType;
  bool _agreementChecked = false;

  String get _nameValue => _nameController.text.trim();

  String get _identityValue => _identityController.text.trim().toUpperCase();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<BankCardSelectController>();
    _nameController = TextEditingController();
    _identityController = TextEditingController();
    _blurFocusNode = FocusNode(debugLabel: 'bank_card_blur_focus');
    _nameFocusNode = FocusNode(debugLabel: 'bank_card_name_focus');
    _identityFocusNode = FocusNode(debugLabel: 'bank_card_identity_focus');
    _restoreCachedInputs();
    _availableCardTypes = widget.bank.availableCardTypes;
    if (_availableCardTypes.isNotEmpty) {
      if (_availableCardTypes.contains(BankCardType.debit)) {
        _selectedCardType = BankCardType.debit;
      } else {
        _selectedCardType = _availableCardTypes.first;
      }
    }

    _nameFocusNode.addListener(() {
      setState(() {});
    });

    _identityFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    _blurFocusNode.dispose();
    _nameFocusNode.dispose();
    _identityFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    if (!mounted) {
      return;
    }
    FocusScope.of(context).requestFocus(_blurFocusNode);
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: ByColor.colorF2, fontSize: 15.sp),
      border: InputBorder.none,
      isCollapsed: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _requestInputFocus({
    required FocusNode focusNode,
    required TextEditingController controller,
  }) {
    FocusScope.of(context).requestFocus(focusNode);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  void _restoreCachedInputs() {
    final String cachedName =
        ByStorageUtils.getString(_cachedSignerNameKey)?.trim() ?? '';
    final String cachedIdentity =
        ByStorageUtils.getString(_cachedSignerIdentityKey)?.trim() ?? '';
    if (cachedName.isNotEmpty) {
      _nameController.text = cachedName;
    }
    if (cachedIdentity.isNotEmpty) {
      _identityController.text = cachedIdentity.toUpperCase();
    }
  }

  void _cacheSignerInputs() {
    ByStorageUtils.saveString(_cachedSignerNameKey, _nameValue);
    ByStorageUtils.saveString(_cachedSignerIdentityKey, _identityValue);
  }

  bool _isValidName(String name) {
    final String normalized = name.replaceAll(' ', '');
    return RegExp(r'^[A-Za-z\u4E00-\u9FA5·•]{2,20}$').hasMatch(normalized);
  }

  bool _isValidIdentity(String identity) {
    return RegExp(
      r'^(?:[1-9]\d{7}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])\d{3}|[1-9]\d{5}(?:18|19|20)\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])\d{3}[\dX])$',
    ).hasMatch(identity);
  }

  bool _validateInputs() {
    if (_nameValue.isEmpty) {
      _requestInputFocus(
        focusNode: _nameFocusNode,
        controller: _nameController,
      );
      Toast.showText(text: '请输入“姓名”');
      return false;
    }

    if (_identityValue.isEmpty) {
      _requestInputFocus(
        focusNode: _identityFocusNode,
        controller: _identityController,
      );
      Toast.showText(text: '请输入身份证号');
      return false;
    }

    if (!_isValidName(_nameValue)) {
      _requestInputFocus(
        focusNode: _nameFocusNode,
        controller: _nameController,
      );
      Toast.showText(text: '身份证或姓名输入错误，请重新输入');
      return false;
    }

    if (!_isValidIdentity(_identityValue)) {
      _requestInputFocus(
        focusNode: _identityFocusNode,
        controller: _identityController,
      );
      Toast.showText(text: '身份证或姓名输入错误，请重新输入');
      return false;
    }

    return true;
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool enableSuggestions = true,
    bool autocorrect = true,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          _requestInputFocus(focusNode: focusNode, controller: controller),
      child: Container(
        height: 48.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Color(0xFFF6F8F9),
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(
            color: focusNode.hasFocus ? ByColor.colorG2 : Colors.transparent,
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 82.w,
              child: ByText.text(
                text: label,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                textColor: ByColor.colorF8,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                cursorColor: ByColor.colorG2,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                enableSuggestions: enableSuggestions,
                autocorrect: autocorrect,
                style: TextStyle(
                  color: ByColor.colorF8,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: _inputDecoration(hintText: hintText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTypeOption(BankCardType cardType) {
    final bool isSelected = _selectedCardType == cardType;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedCardType = cardType;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pay/radio_${isSelected ? 'selected' : 'unselected'}.png',
              width: 18.w,
              height: 18.w,
            ),
            SizedBox(width: 8.w),
            ByText.text(
              text: cardType.label,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              textColor: Colors.white.withValues(alpha: 0.72),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTypeSelector() {
    if (_availableCardTypes.length <= 1) {
      return const SizedBox.shrink();
    }
    return Container(
      height: 40.w,
      margin: EdgeInsets.only(top: 12.w),
      child: Row(
        children: [
          _buildCardTypeOption(_availableCardTypes.first),
          if (_availableCardTypes.length > 1) ...[
            Container(
              width: 1,
              height: 16.w,
              color: Colors.white.withValues(alpha: 0.16),
            ),
            _buildCardTypeOption(_availableCardTypes.last),
          ],
        ],
      ),
    );
  }

  Widget _buildAgreement() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _agreementChecked = !_agreementChecked;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(top: 14.w),
        child: Container(
          constraints: BoxConstraints(minHeight: 36.w),
          padding: EdgeInsets.symmetric(vertical: 8.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/pay/radio_${_agreementChecked ? 'selected_blue' : 'unselected'}.png',
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildAgreementRichText(
                  fontSize: 12.sp,
                  normalColor: ByColor.colorF2,
                  linkColor: widget.bank.xieyi.isNotEmpty
                      ? ByColor.colorF8
                      : ByColor.colorF8.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementRichText({
    required double fontSize,
    required Color normalColor,
    required Color linkColor,
    TextAlign textAlign = TextAlign.left,
  }) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(color: normalColor, fontSize: fontSize, height: 1.4),
        children: [
          TextSpan(
            text: '《一键绑卡协议》',
            style: TextStyle(color: linkColor),
            recognizer: widget.bank.xieyi.isEmpty
                ? null
                : (TapGestureRecognizer()
                    ..onTap = () {
                      Get.to(
                        () => ByHyBaseWebView(
                          title: '一键绑卡协议',
                          url: widget.bank.xieyi,
                        ),
                      );
                    }),
          ),
          const TextSpan(text: ' 为了保障您的权益，请您在点击按钮之前，务必审慎阅读、充分理解各协议内容。'),
        ],
      ),
    );
  }

  Future<void> _showAgreementConfirmDialog({
    required Future<void> Function() onConfirm,
  }) {
    _dismissKeyboard();
    return Get.dialog(
      BankCardAgreementConfirmDialog(
        agreementUrl: widget.bank.xieyi,
        onConfirm: () async {
          _dismissKeyboard();
          await Future.delayed(const Duration(milliseconds: 80));
          _dismissKeyboard();
          if (!mounted) {
            return;
          }
          setState(() {
            _agreementChecked = true;
          });
          await onConfirm();
        },
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _closeWithLaunchUrl(String launchUrl) async {
    if (!mounted) {
      return;
    }
    _dismissKeyboard();
    Navigator.of(context).pop(launchUrl);
  }

  Widget _buildActionButton() {
    Future<void> submitSign() async {
      _dismissKeyboard();
      final String? launchUrl = await _controller.applySign(
        bank: widget.bank,
        cardName: _nameValue,
        cardId: _identityValue,
        cardType: _selectedCardType ?? BankCardType.debit,
      );
      if (launchUrl == null || launchUrl.isEmpty) {
        _dismissKeyboard();
        return;
      }
      EventTracking.reportDataPoint(
        pageTag: 'bank_payment_suc',
        operateType: 'click',
        funcDetailTag: '',
        funcDetailImg: '',
        extra: {'bankname': widget.bank.displayName},
      );
      _cacheSignerInputs();
      Get.log('bank_sign_presign_launch_url: $launchUrl');
      await _closeWithLaunchUrl(launchUrl);
    }

    return ScaleTransitionWidget(
      min: 0.95,
      max: 1,
      period: 900,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (!_validateInputs()) {
            return;
          }
          if (_agreementChecked) {
            await submitSign();
            return;
          }
          await _showAgreementConfirmDialog(
            onConfirm: () async {
              await submitSign();
            },
          );
        },
        child: Container(
          height: 48.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.w),
            color: ByColor.colorG2,
          ),
          child: ByText.text(
            text: '同意协议并下一步',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            textColor: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 18.w, 16.w, 16.w),
          decoration: BoxDecoration(
            color: ByColor.colorF0,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.w)),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ByText.text(
                          text: '输入姓名和身份证号，以开通快捷支付',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          textColor: ByColor.colorF8,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Icon(
                            Icons.close,
                            size: 22.w,
                            color: Color(0xFF444444),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.w),
                  _buildInput(
                    label: '真实姓名',
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    hintText: '输入你的姓名',
                  ),
                  SizedBox(height: 12.w),
                  _buildInput(
                    label: '身份证号',
                    controller: _identityController,
                    focusNode: _identityFocusNode,
                    hintText: '输入你的身份证号',
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.characters,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                  _buildCardTypeSelector(),
                  SizedBox(height: 16.w),
                  _buildActionButton(),
                  _buildAgreement(),
                ],
              ),
              Positioned(
                right: -10.w,
                bottom: 33.w,
                child: const FingerScaleAnimateView(showCave: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
