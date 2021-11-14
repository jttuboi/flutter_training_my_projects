import 'package:flutter/material.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({required int completedTodos, required int activeTodos, Key? key})
      : _completedTodos = completedTodos,
        _activeTodos = activeTodos,
        super(key: key);

  final int _completedTodos;
  final int _activeTodos;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Completed todos', style: TextStyle(fontSize: 20)),
          Text(_completedTodos.toString(), style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          const Text('Active todos', style: TextStyle(fontSize: 20)),
          Text(_activeTodos.toString(), style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
