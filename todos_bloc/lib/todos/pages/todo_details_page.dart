import 'package:flutter/material.dart';
import 'package:todos_bloc/todos/todos.dart';

class TodoDetailPage extends StatelessWidget {
  const TodoDetailPage({required Todo todo, Key? key})
      : _todo = todo,
        super(key: key);

  final Todo _todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print('== delete todo from todo details');
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Hero(
        tag: _todo.id,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: true,
                onChanged: (value) {
                  print('== check todo from todo details');
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text(_todo.title, style: const TextStyle(fontSize: 24)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_todo.subtitle, style: const TextStyle(fontSize: 20)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('== edit todo from todo details');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return TodoFormPage(todo: _todo);
            },
          ));
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
