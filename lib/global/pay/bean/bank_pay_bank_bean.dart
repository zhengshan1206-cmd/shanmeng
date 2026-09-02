// To parse this JSON data, do
//
//     final bankPayBankBean = bankPayBankBeanFromJson(jsonString);

import 'dart:convert';

BankPayBankBean bankPayBankBeanFromJson(String str) =>
    BankPayBankBean.fromJson(json.decode(str));

String bankPayBankBeanToJson(BankPayBankBean data) =>
    json.encode(data.toJson());

class BankPayBankBean {
  String bankShortName;
  String bankName;
  String bankCode;
  String bankIcon;
  String vendorBankCode;
  int supportCreditCard;
  int sort;
  String vendorBankCodeText;
  String xieyi;

  BankPayBankBean({
    required this.bankShortName,
    required this.bankName,
    required this.bankCode,
    required this.bankIcon,
    required this.vendorBankCode,
    required this.supportCreditCard,
    required this.sort,
    required this.vendorBankCodeText,
    required this.xieyi,
  });

  factory BankPayBankBean.empty() => BankPayBankBean(
    bankShortName: '',
    bankName: '',
    bankCode: '',
    bankIcon: '',
    vendorBankCode: '',
    supportCreditCard: 0,
    sort: 0,
    vendorBankCodeText: '',
    xieyi: '',
  );

  factory BankPayBankBean.fromJson(Map<String, dynamic> json) =>
      BankPayBankBean(
        bankShortName: _asString(json["bank_short_name"]),
        bankName: _asString(json["bank_name"]),
        bankCode: _asString(json["bank_code"]),
        bankIcon: _asString(json["bank_icon"]),
        vendorBankCode: _asString(json["vendor_bank_code"]),
        supportCreditCard: _asInt(json["support_credit_card"]),
        sort: _asInt(json["sort"]),
        vendorBankCodeText: _asString(json["vendor_bank_code_text"]),
        xieyi: _asString(json["xieyi"]),
      );

  Map<String, dynamic> toJson() => {
    "bank_short_name": bankShortName,
    "bank_name": bankName,
    "bank_code": bankCode,
    "bank_icon": bankIcon,
    "vendor_bank_code": vendorBankCode,
    "support_credit_card": supportCreditCard,
    "sort": sort,
    "vendor_bank_code_text": vendorBankCodeText,
    "xieyi": xieyi,
  };

  String get displayName => bankShortName.isNotEmpty ? bankShortName : bankName;

  String get displayIconText {
    if (bankShortName.isNotEmpty) {
      return bankShortName.substring(0, 1);
    }
    if (bankName.isNotEmpty) {
      return bankName.substring(0, 1);
    }
    return '银';
  }

  bool get supportDebitCard => true;

  bool get hasCreditCard => supportCreditCard == 1;

  List<BankCardType> get availableCardTypes {
    final List<BankCardType> cardTypes = <BankCardType>[];
    if (supportDebitCard) {
      cardTypes.add(BankCardType.debit);
    }
    if (hasCreditCard) {
      cardTypes.add(BankCardType.credit);
    }
    return cardTypes;
  }
}

enum BankCardType {
  debit,
  credit;

  String get label {
    switch (this) {
      case BankCardType.debit:
        return '借记卡';
      case BankCardType.credit:
        return '信用卡';
    }
  }
}

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
