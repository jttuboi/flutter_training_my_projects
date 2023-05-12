import 'connection_type.dart';

abstract interface class ICellphone {
  Future<String> version();

  Future<ConnectionType> connection();

  Stream<ConnectionType> onConnectionChanged();
}
