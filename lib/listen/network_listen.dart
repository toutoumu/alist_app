


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_listen.g.dart';


extension NetworkListenEx on WidgetRef {

  ///是否有网络
  bool get hasInternet {
    final result = watch(netWorkListenProvider.select((value) => value.value)) ?? [];
    return result.isNotEmpty && !result.any((element) => element == ConnectivityResult.none);
  }
}

@Riverpod(keepAlive: true)
class NetWorkListen extends _$NetWorkListen {

  @override
  Stream<List<ConnectivityResult>> build() {
    return Connectivity().onConnectivityChanged;
  }

}