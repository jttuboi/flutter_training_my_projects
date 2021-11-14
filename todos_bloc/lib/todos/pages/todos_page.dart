import 'package:flutter/material.dart';
import 'package:todos_bloc/todos/todos.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({Key? key}) : super(key: key);

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              PopupMenuItem(
                  onTap: () {
                    print('== show all');
                  },
                  child: const Text('Show all')),
              PopupMenuItem(
                  onTap: () {
                    print('== show active');
                  },
                  child: const Text('Show active')),
              PopupMenuItem(
                  onTap: () {
                    print('== show completed');
                  },
                  child: const Text('Show completed')),
            ],
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz),
            itemBuilder: (context) => [
              PopupMenuItem(
                  onTap: () {
                    print('== mark all completed');
                  },
                  child: const Text('Mark all completed')),
              PopupMenuItem(
                  onTap: () {
                    print('== mark all incompleted');
                  },
                  child: const Text('Mark all incompleted')),
              PopupMenuItem(
                  onTap: () {
                    print('== clear completed');
                  },
                  child: const Text('Clear completed')),
            ],
          ),
        ],
      ),
      body: _tabIndex == 0 ? TodosTab() : StatsTab(completedTodos: 4, activeTodos: 5),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Todos'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Stats'),
        ],
        onTap: (tabIndex) {
          print(tabIndex);
          setState(() {
            _tabIndex = tabIndex;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('== add todo from todos');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const TodoFormPage();
            },
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
