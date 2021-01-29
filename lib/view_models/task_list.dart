import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/task.dart';

class TaskList extends StateNotifier<List<Task>> {
  TaskList([List<Task> initialTask]) : super(initialTask ?? []);

  void toggleDone(String targetId) {
    state = [
      for (final task in state)
        if (task.id == targetId)
          Task(id: task.id, title: task.title, isDone: !task.isDone)
        else
          task
    ];
  }

  void addTask(String title) {
    state = [...state, Task(title: title)];
  }

  void deleteTask(Task target) {
    state = state.where((task) => task.id != target.id).toList();
  }

  void deleteAllTasks() {
    state = [];
  }

  void deleteDoneTasks() {
    state = state.where((task) => !task.isDone).toList();
  }

  void updateTasks(List<Task> newTasks) {
    state = [for (final task in newTasks) task];
  }
}
