import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:todos_bloc/todos/todos.dart';

part 'todos_event.dart';
part 'todos_state.dart';

enum ShowStatus {
  allTodos,
  completeTodos,
  incompleteTodos,
}

extension ShowStatusExtension on ShowStatus {
  bool get showAllTodos => this == ShowStatus.allTodos;
  bool get showCompleteTodos => this == ShowStatus.completeTodos;
  bool get showIncompleteTodos => this == ShowStatus.incompleteTodos;
}

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc({required ITodosRepository todosRepository})
      : _todosRepository = todosRepository,
        super(const TodosState()) {
    on<TodosTabOpened>(_onTodosTabOpened);
    on<ShowAllTodos>(_onShowAllTodos);
    on<ShowActiveTodos>(_onShowActiveTodos);
    on<ShowCompletedTodos>(_onShowCompletedTodos);

    // ATUALIZA TOoDO TILE
    on<TodoChecked>(_onTodoChecked);

    on<TodoDeleted>(_onTodoDeleted);
    on<TodoUndone>(_onTodoUndone);
    on<TodosUpdated>(_onTodosUpdated);
  }

  final ITodosRepository _todosRepository;

  Todo _todoDeleted = Todo.empty;

  Future<void> _onTodosTabOpened(TodosTabOpened event, Emitter<TodosState> emit) async {
    final todos = await _todosRepository.getTodos();
    emit(state.copyWith(todos: todos));
  }

  Future<void> _onShowAllTodos(ShowAllTodos event, Emitter<TodosState> emit) async {
    final todos = await _todosRepository.getTodos();
    emit(state.copyWith(todos: todos, showStatus: ShowStatus.allTodos));
  }

  Future<void> _onShowActiveTodos(ShowActiveTodos event, Emitter<TodosState> emit) async {
    final activeTodos = await _todosRepository.getIncompleteTodos();
    emit(state.copyWith(todos: activeTodos, showStatus: ShowStatus.incompleteTodos));
  }

  Future<void> _onShowCompletedTodos(ShowCompletedTodos event, Emitter<TodosState> emit) async {
    final completeTodos = await _todosRepository.getCompleteTodos();
    emit(state.copyWith(todos: completeTodos, showStatus: ShowStatus.completeTodos));
  }

  Future<void> _onTodoChecked(TodoChecked event, Emitter<TodosState> emit) async {
    // // dados do state
    // final newTodos = <Todo>[];
    // for (final todo in state.todos) {
    //   newTodos.add((todo != event.todo) ? todo : todo.copyWith(completed: event.isCompleted));
    // }
    // // banco de dados
    // final newTodos2 = <Todo>[];
    // for (final todo in _todos) {
    //   newTodos2.add((todo != event.todo) ? todo : todo.copyWith(completed: event.isCompleted));
    // }
    // _todos = newTodos2;
    // emit(state.copyWith(todos: newTodos));
  }

  Future<void> _onTodoDeleted(TodoDeleted event, Emitter<TodosState> emit) async {
    _todoDeleted = event.todo;
    await _todosRepository.deleteTodo(_todoDeleted);

    if (state.showStatus.showAllTodos) {
      emit(state.copyWith(todos: await _todosRepository.getTodos()));
    } else if (state.showStatus.showCompleteTodos) {
      emit(state.copyWith(todos: await _todosRepository.getCompleteTodos()));
    } else if (state.showStatus.showIncompleteTodos) {
      emit(state.copyWith(todos: await _todosRepository.getIncompleteTodos()));
    }
  }

  Future<void> _onTodoUndone(TodoUndone event, Emitter<TodosState> emit) async {
    if (_todoDeleted == Todo.empty) {
      return;
    }

    await _todosRepository.addTodo(_todoDeleted);
    _todoDeleted = Todo.empty;

    if (state.showStatus.showAllTodos) {
      final todos2 = await _todosRepository.getTodos();
      emit(state.copyWith(todos: todos2));
    } else if (state.showStatus.showCompleteTodos) {
      final todos2 = await _todosRepository.getCompleteTodos();
      emit(state.copyWith(todos: todos2));
    } else if (state.showStatus.showIncompleteTodos) {
      final todos2 = await _todosRepository.getIncompleteTodos();
      emit(state.copyWith(todos: todos2));
    }
  }

  Future<void> _onTodosUpdated(TodosUpdated event, Emitter<TodosState> emit) async {
    if (state.showStatus.showAllTodos) {
      emit(state.copyWith(todos: await _todosRepository.getTodos()));
    } else if (state.showStatus.showCompleteTodos) {
      emit(state.copyWith(todos: await _todosRepository.getCompleteTodos()));
    } else if (state.showStatus.showIncompleteTodos) {
      emit(state.copyWith(todos: await _todosRepository.getIncompleteTodos()));
    }
  }
}
