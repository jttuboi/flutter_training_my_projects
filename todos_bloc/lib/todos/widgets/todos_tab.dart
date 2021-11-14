import 'package:flutter/material.dart';
import 'package:todos_bloc/todos/todos.dart';

class TodosTab extends StatelessWidget {
  const TodosTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TodoTile(
          todo: Todo(id: 'qwe', title: 'lavar louça', subtitle: 'não esquecer de guarda-los', completed: true),
          onChecked: (completed) {
            print(completed);
          },
          onUndo: () {
            print('undo clicked');
          },
        ),
        TodoTile(
          todo: Todo(id: 'asd', title: 'estudar bloc', subtitle: 'não esquecer de testar', completed: false),
          onChecked: (completed) {
            print(completed);
          },
          onUndo: () {
            print('undo clicked 2');
          },
        ),
      ],
    );
  }
}
