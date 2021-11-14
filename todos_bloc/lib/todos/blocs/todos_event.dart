part of 'todos_bloc.dart';

abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object> get props => [];
}

class TodosTabOpened extends TodosEvent {}

class ShowAllTodos extends TodosEvent {}

class ShowActiveTodos extends TodosEvent {}

class ShowCompletedTodos extends TodosEvent {}

class TodosUpdated extends TodosEvent {}

class TodoChecked extends TodosEvent {
  const TodoChecked({required this.todo, required this.isCompleted});

  final Todo todo;
  final bool isCompleted;

  @override
  List<Object> get props => [todo, isCompleted];
}

class TodoDeleted extends TodosEvent {
  const TodoDeleted({required this.todo});

  final Todo todo;

  @override
  List<Object> get props => [todo];
}

class TodoUndone extends TodosEvent {}
