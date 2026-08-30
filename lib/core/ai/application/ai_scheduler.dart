import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/ai_error.dart';
import '../domain/ai_request.dart';

/// Central prioritized task scheduler ensuring non-blocking, serialized heavy local generation.
class AiScheduler {
  static final AiScheduler instance = AiScheduler._internal();
  AiScheduler._internal();

  bool _isProcessingHeavyTask = false;
  final List<_QueuedTask> _queue = [];
  AiCancellationToken? _currentTaskCancellation;

  /// Submits an async task to the scheduler queue according to priority.
  Future<T> schedule<T>({
    required AiRequest request,
    required Future<T> Function(AiCancellationToken cancellationToken) execute,
    Duration watchdogTimeout = const Duration(seconds: 20),
  }) async {
    final completer = Completer<T>();
    final cancellationToken = request.cancellationToken ?? AiCancellationToken();

    final queuedTask = _QueuedTask(
      priority: request.priority,
      task: request.task.id,
      execute: () async {
        _isProcessingHeavyTask = true;
        _currentTaskCancellation = cancellationToken;

        Timer? watchdogTimer;
        try {
          watchdogTimer = Timer(watchdogTimeout, () {
            debugPrint('AiScheduler: Watchdog timeout exceeded (${watchdogTimeout.inSeconds}s)');
            cancellationToken.cancel();
          });

          if (cancellationToken.isCancelled) {
            completer.completeError(const GenerationCancelledError());
            return;
          }

          final result = await execute(cancellationToken);
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        } finally {
          watchdogTimer?.cancel();
          _isProcessingHeavyTask = false;
          _currentTaskCancellation = null;
          _processNext();
        }
      },
    );

    // If an interactive request arrives, insert it ahead of lower priority background tasks
    _insertByPriority(queuedTask);
    _processNext();

    return completer.future;
  }

  void _insertByPriority(_QueuedTask task) {
    int index = 0;
    while (index < _queue.length && _queue[index].priority >= task.priority) {
      index++;
    }
    _queue.insert(index, task);
  }

  void _processNext() {
    if (_isProcessingHeavyTask || _queue.isEmpty) return;

    final nextTask = _queue.removeAt(0);
    nextTask.execute();
  }

  /// Cancels the currently running heavy generation if one is active.
  void cancelCurrent() {
    _currentTaskCancellation?.cancel();
  }

  /// Clears pending background tasks from the queue during memory pressure.
  void clearBackgroundQueue() {
    _queue.removeWhere((task) => task.priority < AiPriority.interactive);
  }
}

class _QueuedTask {
  final int priority;
  final String task;
  final VoidCallback execute;

  const _QueuedTask({
    required this.priority,
    required this.task,
    required this.execute,
  });
}
