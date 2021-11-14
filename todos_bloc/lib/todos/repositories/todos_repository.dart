import 'package:todos_bloc/todos/todos.dart';

abstract class ITodosRepository {
  static const completeSituation = 'complete';
  static const incompleteSituation = 'incomplete';

  Future<List<Todo>> getTodos();

  Future<List<Todo>> getIncompleteTodos();

  Future<List<Todo>> getCompleteTodos();

  Future<Map<String, int>> countTodosSituation();

  Future<void> deleteTodo(Todo todo);

  Future<void> addTodo(Todo todo);

  Future<bool> hasIncomplete();

  Future<void> markAllToComplete();

  Future<void> markAllToIncomplete();

  Future<void> clearAllCompleted();
}

class TodosRepository implements ITodosRepository {
  List<Todo> _todos = [
    Todo(id: 'qwe', title: 'lavar louça', subtitle: 'não esquecer de guarda-los', completed: true),
    Todo(id: 'asd', title: 'lavar louça 2', subtitle: 'não esquecer de guarda-los 2', completed: true),
    Todo(id: 'zxc', title: 'estudar bloc', subtitle: 'não esquecer de testar', completed: false),
    Todo(id: 'rty', title: 'estudar bloc 2', subtitle: 'não esquecer de testar 2', completed: false),
  ];

  @override
  Future<List<Todo>> getTodos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_todos);
  }

  @override
  Future<List<Todo>> getIncompleteTodos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _todos.where((todo) => !todo.completed).toList();
  }

  @override
  Future<List<Todo>> getCompleteTodos() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _todos.where((todo) => todo.completed).toList();
  }

  @override
  Future<Map<String, int>> countTodosSituation() async {
    await Future.delayed(const Duration(milliseconds: 100));

    var completeQuantity = 0;
    var incompleteQuantity = 0;

    for (final todo in _todos) {
      if (todo.completed) {
        completeQuantity++;
      } else {
        incompleteQuantity++;
      }
    }

    return {
      ITodosRepository.completeSituation: completeQuantity,
      ITodosRepository.incompleteSituation: incompleteQuantity,
    };
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _todos.remove(todo);
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _todos.add(todo);
  }

  @override
  Future<bool> hasIncomplete() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _todos.fold<bool>(false, (previousValue, todo) => previousValue || !todo.completed);
  }

  @override
  Future<void> markAllToComplete() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newTodos = <Todo>[];
    for (final todo in _todos) {
      newTodos.add(todo.copyWith(completed: true));
    }
    _todos = newTodos;
  }

  @override
  Future<void> markAllToIncomplete() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newTodos = <Todo>[];
    for (final todo in _todos) {
      newTodos.add(todo.copyWith(completed: false));
    }
    _todos = newTodos;
  }

  @override
  Future<void> clearAllCompleted() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _todos.removeWhere((todo) => todo.completed);
  }
}
