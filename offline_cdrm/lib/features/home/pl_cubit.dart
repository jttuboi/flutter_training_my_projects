import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pl_state.dart';

class PlCubit extends Cubit<PlState> {
  PlCubit() : super(const PlInitial());

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 2));
    emit(const PlLoaded(['aaa', 'bbb', 'ccc']));
  }
}
