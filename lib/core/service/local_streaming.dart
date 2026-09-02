
import 'dart:async';

/// 字符串流式输出管理类
class LocalStreamManager {
  
  /// 目标输出字符串
  String _targetString = '';
  
  /// 当前输出位置
  int _currentPosition = 0;
  
  /// 输出间隔时间(毫秒)
  final int _intervalMs;
  
  /// 每次输出的字符数
  final int _charsPerStep;
  
  /// 定时器
  Timer? _timer;
  
  /// 是否正在输出
  bool _isStreaming = false;
  
  /// 是否处于暂停状态
  bool _isPaused = false;

  /// 构造函数
  /// [intervalMs] 输出间隔时间(毫秒)
  /// [charsPerStep] 每次输出的字符数
  LocalStreamManager({
    int intervalMs = 100,
    int charsPerStep = 4,
  })  : _intervalMs = intervalMs,
        _charsPerStep = charsPerStep > 0 ? charsPerStep : 1;

  /// 是否正在输出
  bool get isStreaming => _isStreaming;

  /// 是否处于暂停状态
  bool get isPaused => _isPaused;

  /// 获取当前输出回调
  void Function(String, bool)? output;
  

  /// 设置目标字符串
  void setTargetString(String target) {
    _targetString = target;
    reset();
  }

  /// 开始流式输出
  void start() {
    if (_isStreaming && !_isPaused) return;
    
    // 如果是从暂停状态恢复，不需要重置位置
    if (_isPaused) {
      _isPaused = false;
    } else {
      // 重新开始，重置位置
      _currentPosition = 0;
    }
    
    _isStreaming = true;
    _startTimer();
  }

  /// 暂停流式输出
  void pause() {
    if (!_isStreaming || _isPaused) return;
    
    _isPaused = true;
    _timer?.cancel();
  }

  /// 继续流式输出
  void resume() {
    if (!_isStreaming || !_isPaused) return;
    
    _isPaused = false;
    _startTimer();
  }

  /// 重置流式输出
  void reset() {
    _timer?.cancel();
    _isStreaming = false;
    _isPaused = false;
    _currentPosition = 0;
  }

  /// 开始定时器输出
  void _startTimer() {
    _timer?.cancel();
    
    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (timer) {
      if (_currentPosition >= _targetString.length) {
        // 输出完成
        _isStreaming = false;
        timer.cancel();
        return;
      }
      
      // 计算本次输出的结束位置
      final endPosition = (_currentPosition + _charsPerStep) > _targetString.length
          ? _targetString.length
          : _currentPosition + _charsPerStep;
      
      // 获取本次要输出的子串
      final substring = _targetString.substring(_currentPosition, endPosition);
      
      // 发送到流式输出回调
      output?.call(substring, endPosition < _targetString.length);
      
      // 更新当前位置
      _currentPosition = endPosition;
      
      // 检查是否输出完成
      if (_currentPosition >= _targetString.length) {
        _isStreaming = false;
        timer.cancel();
      }
    });
  }

  /// 释放资源
  void dispose() {
    _timer?.cancel();
  }
}
