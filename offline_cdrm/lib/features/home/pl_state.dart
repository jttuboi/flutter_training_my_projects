part of 'pl_cubit.dart';

abstract class PlState with EquatableMixin {
  const PlState(this.users);

  final List<String> users;

  @override
  List<Object?> get props => [users];

  @override
  bool? get stringify => true;
}

class PlInitial extends PlState {
  const PlInitial() : super(const []);
}

class PlLoaded extends PlState {
  const PlLoaded(super.users);
}
