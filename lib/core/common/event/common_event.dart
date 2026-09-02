import 'event_bus.dart';

///公共eventBus 事件通知
final EventBus eventBus = EventBus();

///暂停video事件
class PauseVideoEvent {
  const PauseVideoEvent({this.scope});

  final String? scope;
}

///恢复video事件
class ResumeVideoEvent {
  const ResumeVideoEvent({this.scope});

  final String? scope;
}
