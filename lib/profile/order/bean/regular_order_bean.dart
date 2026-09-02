class RegularOrderBean {
  RegularOrderBean({
    required this.id,
    required this.orderNo,
    required this.title,
    required this.payTime,
    required this.pay,
  });

  final int id;
  final String orderNo;
  final String title;
  final String payTime;
  final int pay;

  factory RegularOrderBean.fromJson(Map<String, dynamic> json) {
    return RegularOrderBean(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNo: json['order_no']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      payTime: json['pay_time']?.toString() ?? '',
      pay: json['pay'] is int
          ? json['pay'] as int
          : int.tryParse(json['pay']?.toString() ?? '0') ?? 0,
    );
  }
}
