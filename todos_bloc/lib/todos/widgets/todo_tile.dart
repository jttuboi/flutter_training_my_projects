import 'package:flutter/material.dart';
import 'package:todos_bloc/todos/todos.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    required Todo todo,
    required Function(bool completed) onChecked,
    required Function(Todo todoDeleted) onDelete,
    required Function() onUndo,
    Key? key,
  })  : _todo = todo,
        _onChecked = onChecked,
        _onDelete = onDelete,
        _onUndo = onUndo,
        super(key: key);

  final Todo _todo;
  final Function(bool) _onChecked;
  final Function(Todo) _onDelete;
  final Function() _onUndo;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: GlobalKey(),
      onDismissed: (direction) {
        _onDelete(_todo);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('deleted "${_todo.title}"'),
          action: SnackBarAction(
            label: 'undo',
            onPressed: _onUndo,
          ),
        ));
      },
      child: ListTile(
        leading: Checkbox(
          value: _todo.completed,
          onChanged: (value) => _onChecked(value!),
        ),
        title: Text(_todo.title),
        subtitle: Text(_todo.subtitle),
        onTap: () => Navigator.push(context, TodoDetailPage.route(todo: _todo)),
      ),
    );
  }
}
