import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    this.isChecked,
    this.taskTitle,
    this.checkBoxCallBack,
    this.longPressCallBack,
  });

  final bool isChecked;
  final String taskTitle;
  final Function(bool) checkBoxCallBack;
  final Function() longPressCallBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      child: GestureDetector(
        onLongPress: longPressCallBack,
        child: CheckboxListTile(
          title: Text(
            taskTitle,
            style: TextStyle(
                decoration: isChecked ? TextDecoration.lineThrough : null),
          ),
          value: isChecked,
          activeColor: Colors.lightBlueAccent,
          onChanged: checkBoxCallBack,
        ),
      ),
    );
  }
}
