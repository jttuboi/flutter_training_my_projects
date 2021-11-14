import 'package:flutter/material.dart';
import 'package:todos_bloc/todos/todos.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({required Todo todo, required Function(bool completed) onChecked, required Function() onUndo, Key? key})
      : _todo = todo,
        _onChecked = onChecked,
        _onUndo = onUndo,
        super(key: key);

  final Todo _todo;
  final Function(bool) _onChecked;
  final Function() _onUndo;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: GlobalKey(),
      onDismissed: (direction) {
        print('== delete todo from todos');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('deleted "${_todo.title}"'),
          action: SnackBarAction(
            label: 'undo',
            onPressed: () {
              print('== undo delete todo from todos');
              _onUndo();
            },
          ),
        ));
      },
      child: ListTile(
        leading: Checkbox(
          value: _todo.completed,
          onChanged: (value) {
            print('== check/uncheck todo');
            _onChecked(value!);
          },
        ),
        title: Text(_todo.title),
        subtitle: Text(_todo.subtitle),
        onTap: () {
          print('== edit todo');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return TodoDetailPage(todo: _todo);
            },
          ));
        },
      ),
    );
  }
}
