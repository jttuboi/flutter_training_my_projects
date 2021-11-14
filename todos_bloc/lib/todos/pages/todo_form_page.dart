import 'package:flutter/material.dart';
import 'package:todos_bloc/todos/todos.dart';

class TodoFormPage extends StatefulWidget {
  const TodoFormPage._({required Todo todo, Key? key})
      : _todo = todo,
        super(key: key);

  static Route route({Todo? todo}) {
    return MaterialPageRoute(builder: (context) => TodoFormPage._(todo: todo ?? Todo.empty));
  }

  final Todo _todo;

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget._todo.title);
    _subtitleController = TextEditingController(text: widget._todo.subtitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget._todo == Todo.empty ? const Text('Add todo') : const Text('Edit todo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                controller: _subtitleController,
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('== save todo - precisa validar antes');
          print(widget._todo.id);
          print(_titleController.text);
          print(_subtitleController.text);
          print(widget._todo.completed);
          Navigator.pop(context);
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
