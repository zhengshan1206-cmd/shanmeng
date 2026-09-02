class MessageListBean {
  MessageListBean({
    required this.id,
    required this.notifyDate,
    required this.title,
    required this.content,
    required this.isRead,
  });

  final int id;
  final String notifyDate;
  final String title;
  final String content;
  int isRead;

  factory MessageListBean.fromJson(Map<String, dynamic> json) {
    return MessageListBean(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      notifyDate: json['notify_date']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['is_read'] is int
          ? json['is_read'] as int
          : int.tryParse(json['is_read']?.toString() ?? '0') ?? 0,
    );
  }
}
