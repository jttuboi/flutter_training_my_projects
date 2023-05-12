import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../cellphone.dart';
import '../connection_type.dart';

class GenericCellphone implements ICellphone {
  @override
  Future<String> version() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Future<ConnectionType> connection() async {
    final result = await Connectivity().checkConnectivity();
    return result.toConnectionType();
  }

  @override
  Stream<ConnectionType> onConnectionChanged() {
    final result = Connectivity().onConnectivityChanged;
    return result.map<ConnectionType>((r) => r.toConnectionType());
  }
}

extension ConnectivityResultExtension on ConnectivityResult {
  ConnectionType toConnectionType() {
    switch (this) {
      case ConnectivityResult.bluetooth:
        return ConnectionType.bluetooth;
      case ConnectivityResult.wifi:
        return ConnectionType.wifi;
      case ConnectivityResult.ethernet:
        return ConnectionType.ethernet;
      case ConnectivityResult.mobile:
        return ConnectionType.mobile;
      case ConnectivityResult.none:
        return ConnectionType.none;
      case ConnectivityResult.vpn:
        return ConnectionType.vpn;
      case ConnectivityResult.other:
        return ConnectionType.other;
    }
  }
}
