import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tail_app/Backend/Bluetooth/BluetoothManager.dart';

import '../intnDefs.dart';

class BackButtonToClose extends ConsumerStatefulWidget {
  const BackButtonToClose({required this.child, super.key});

  final Widget child;

  @override
  _BackButtonToCloseState createState() => _BackButtonToCloseState();
}

class _BackButtonToCloseState extends ConsumerState<BackButtonToClose> {
  Timer timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (info.currentRoute(context)!.isFirst && info.currentRoute(context)!.isCurrent) {
      if (ref.read(knownDevicesProvider).values.where((element) => element.deviceConnectionState.value == DeviceConnectionState.connected).isNotEmpty) {
        return true;
      }
      if (timer.isActive) {
        return false;
      }
      timer = Timer(const Duration(seconds: 1), () {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(doubleBackToClose()),
        ),
      );
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}