import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'database_helper.dart';
import 'notification_service.dart';

/// Central state holder for tasks — loads from and writes through to
/// SQLite via DatabaseHelper, and schedules/cancels reminders.
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  final _uuid = const Uuid();

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> tasksByCategory(TaskCategory category) =>
      _tasks.where((t) => t.category == category).toList();

  Future<void> loadTasks() async {
    final loaded = await DatabaseHelper.instance.getAllTasks();
    _tasks
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String description = '',
    TaskCategory category = TaskCategory.other,
    DateTime? reminderTime,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      reminderTime: reminderTime,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.insertTask(task);
    _tasks.insert(0, task);

    if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
      await NotificationService.instance.scheduleReminder(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledTime: reminderTime,
      );
    }

    notifyListeners();
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await DatabaseHelper.instance.updateTask(updated);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = updated;
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id);
    await NotificationService.instance.cancelReminder(task.id.hashCode);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }
}
