import 'dart:convert';

SubscriptionOrderBean subscriptionOrderBeanFromJson(String str) =>
    SubscriptionOrderBean.fromJson(json.decode(str) as Map<String, dynamic>);

String subscriptionOrderBeanToJson(SubscriptionOrderBean data) =>
    json.encode(data.toJson());

class SubscriptionOrderBean {
  SubscriptionOrderBean({
    required this.id,
    required this.userId,
    required this.status,
    required this.subscribeOrderNo,
    required this.agreementNo,
    required this.signTime,
    required this.cancelTime,
    required this.subscribeMoney,
    required this.subscribePeriodType,
    required this.subscribePeriodPeriod,
    required this.subscribePeriodDay,
    required this.subscribeTopOrderId,
    required this.subscribeCurrOrderId,
    required this.nextExecuteDate,
    required this.pay,
    required this.nextExecuteTime,
    required this.executeTime,
    required this.executeSign,
    required this.cyclePayStatus,
    required this.cyclePayTime,
    required this.totalPayments,
    required this.totalAmount,
    required this.refundAmount,
    required this.updatedAt,
    required this.createdAt,
    required this.title,
  });

  final int id;
  final int userId;
  final int status;
  final String subscribeOrderNo;
  final String agreementNo;
  final String signTime;
  final String cancelTime;
  final String subscribeMoney;
  final String subscribePeriodType;
  final int subscribePeriodPeriod;
  final int subscribePeriodDay;
  final int subscribeTopOrderId;
  final int subscribeCurrOrderId;
  final String nextExecuteDate;
  final int pay;
  final String nextExecuteTime;
  final String executeTime;
  final int executeSign;
  final int cyclePayStatus;
  final String cyclePayTime;
  final int totalPayments;
  final String totalAmount;
  final String refundAmount;
  final String updatedAt;
  final String createdAt;
  final String title;

  factory SubscriptionOrderBean.fromJson(Map<String, dynamic> json) {
    return SubscriptionOrderBean(
      id: _asInt(json['id']),
      userId: _asInt(json['user_id']),
      status: _asInt(json['status']),
      subscribeOrderNo: _asString(json['subscribe_order_no']),
      agreementNo: _asString(json['agreement_no']),
      signTime: _asString(json['sign_time']),
      cancelTime: _asString(json['cancel_time']),
      subscribeMoney: _asString(json['subscribe_money']),
      subscribePeriodType: _asString(json['subscribe_period_type']),
      subscribePeriodPeriod: _asInt(json['subscribe_period_period']),
      subscribePeriodDay: _asInt(json['subscribe_period_day']),
      subscribeTopOrderId: _asInt(json['subscribe_top_order_id']),
      subscribeCurrOrderId: _asInt(json['subscribe_curr_order_id']),
      nextExecuteDate: _asString(json['next_execute_date']),
      pay: _asInt(json['pay']),
      nextExecuteTime: _asString(json['next_execute_time']),
      executeTime: _asString(json['execute_time']),
      executeSign: _asInt(json['execute_sign']),
      cyclePayStatus: _asInt(json['cycle_pay_status']),
      cyclePayTime: _asString(json['cycle_pay_time']),
      totalPayments: _asInt(json['total_payments']),
      totalAmount: _asString(json['total_amount']),
      refundAmount: _asString(json['refund_amount']),
      updatedAt: _asString(json['updated_at']),
      createdAt: _asString(json['created_at']),
      title: _asString(json['title']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'status': status,
    'subscribe_order_no': subscribeOrderNo,
    'agreement_no': agreementNo,
    'sign_time': signTime,
    'cancel_time': cancelTime,
    'subscribe_money': subscribeMoney,
    'subscribe_period_type': subscribePeriodType,
    'subscribe_period_period': subscribePeriodPeriod,
    'subscribe_period_day': subscribePeriodDay,
    'subscribe_top_order_id': subscribeTopOrderId,
    'subscribe_curr_order_id': subscribeCurrOrderId,
    'next_execute_date': nextExecuteDate,
    'pay': pay,
    'next_execute_time': nextExecuteTime,
    'execute_time': executeTime,
    'execute_sign': executeSign,
    'cycle_pay_status': cyclePayStatus,
    'cycle_pay_time': cyclePayTime,
    'total_payments': totalPayments,
    'total_amount': totalAmount,
    'refund_amount': refundAmount,
    'updated_at': updatedAt,
    'created_at': createdAt,
    'title': title,
  };

  double get subscribeMoneyValue => double.tryParse(subscribeMoney) ?? 0;
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

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}
