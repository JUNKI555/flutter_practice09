import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../entities/task.dart';
import '../../view_models/task_list.dart';
import '../widgets/task_tile.dart';

final taskListProvider =
    StateNotifierProvider((ref) => TaskList([Task(title: 'Demo Task')]));

final isNotDoneTasksCount = Provider<int>((ref) {
  return ref.watch(taskListProvider.state).where((task) => !task.isDone).length;
});

enum Filter {
  all,
  active,
  done,
}

final filterProvider = StateProvider((ref) => Filter.all);

final filteredTasks = Provider<List<Task>>((ref) {
  final filter = ref.watch(filterProvider);
  final tasks = ref.watch(taskListProvider.state);

  switch (filter.state) {
    case Filter.done:
      return tasks.where((task) => task.isDone).toList();
    case Filter.active:
      return tasks.where((task) => !task.isDone).toList();
    case Filter.all:
      return tasks;
  }

  // do not work but default
  return tasks;
});

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _newTaskTitle = '';
    final _textEditingController = TextEditingController();

    void clearTextField() {
      _textEditingController.clear();
      _newTaskTitle = '';
    }

    void showSnackBar({
      List<Task> previousTasks,
      TaskList taskList,
      String content,
      ScaffoldState scaffoldState,
    }) {
      scaffoldState.removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text(content),
        action: SnackBarAction(
          label: 'restore',
          onPressed: () {
            taskList.updateTasks(previousTasks);
            scaffoldState.removeCurrentSnackBar();
          },
        ),
        duration: const Duration(seconds: 3),
      );

      scaffoldState.showSnackBar(snackBar);
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Task List'),
        ),
        body: Consumer(
          builder: (context, watch, child) {
            final taskList = watch(taskListProvider);
            final allTasks = watch(taskListProvider.state);
            final displayedTasks = watch(filteredTasks);
            final filter = watch(filterProvider);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Todo List',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: TextField(
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              hintText: 'Enter a todo title',
                              suffixIcon: IconButton(
                                onPressed: clearTextField,
                                icon: const Icon(Icons.clear),
                              ),
                            ),
                            textAlign: TextAlign.start,
                            onChanged: (newText) {
                              _newTaskTitle = newText;
                            },
                            onSubmitted: (newText) {
                              if (_newTaskTitle.isEmpty) {
                                _newTaskTitle = 'Empty Title';
                              }
                              taskList.addTask(_newTaskTitle);
                              clearTextField();
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${watch(isNotDoneTasksCount)} tasks left',
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('All'),
                                  ),
                                  onTap: () => filter.state = Filter.all,
                                ),
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Active'),
                                  ),
                                  onTap: () => filter.state = Filter.active,
                                ),
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Done'),
                                  ),
                                  onTap: () => filter.state = Filter.done,
                                ),
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Delete Done',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    final doneTasks = allTasks
                                        .where((task) => task.isDone)
                                        .toList();

                                    if (doneTasks.isEmpty) {
                                      return;
                                    }

                                    taskList.deleteDoneTasks();
                                    showSnackBar(
                                      previousTasks: allTasks,
                                      taskList: taskList,
                                      content: 'Done tasks have been deleted.',
                                      scaffoldState: Scaffold.of(context),
                                    );
                                  },
                                ),
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      'Delete All',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    if (allTasks.isEmpty) {
                                      return;
                                    }

                                    taskList.deleteAllTasks();
                                    showSnackBar(
                                      previousTasks: allTasks,
                                      taskList: taskList,
                                      content: 'All tasks have been deleted.',
                                      scaffoldState: Scaffold.of(context),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final task = displayedTasks[index];

                        return TaskTile(
                          taskTitle: task.title,
                          isChecked: task.isDone,
                          checkBoxCallBack: (bool value) {
                            taskList.toggleDone(task.id);
                          },
                          longPressCallBack: () {
                            taskList.deleteTask(task);
                            showSnackBar(
                              previousTasks: displayedTasks,
                              taskList: taskList,
                              content: '${task.title} has been deleted.',
                              scaffoldState: Scaffold.of(context),
                            );
                          },
                        );
                      },
                      itemCount: displayedTasks.length,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
