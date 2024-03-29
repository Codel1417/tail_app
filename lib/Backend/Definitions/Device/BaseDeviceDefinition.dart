import 'dart:async';
import 'dart:core';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tail_app/Backend/Bluetooth/BluetoothManager.dart';
import 'package:tail_app/Backend/FirmwareUpdate.dart';

import '../../../Frontend/intnDefs.dart';

part 'BaseDeviceDefinition.g.dart';

@HiveType(typeId: 6)
enum DeviceType {
  @HiveField(1)
  tail,
  @HiveField(2)
  ears,
  @HiveField(3)
  wings,
} //TODO extend with icon

extension DeviceTypeExtension on DeviceType {
  String get name {
    switch (this) {
      case DeviceType.tail:
        return deviceTypeTail();
      case DeviceType.ears:
        return deviceTypeEars();
      case DeviceType.wings:
        return deviceTypeWings();
    }
  }

  Color get color {
    switch (this) {
      case DeviceType.tail:
        return Colors.orangeAccent;
      case DeviceType.ears:
        return Colors.blueAccent;
      case DeviceType.wings:
        return Colors.greenAccent;
    }
  }
}

enum DeviceState { standby, runAction, busy }

class BaseDeviceDefinition {
  final String uuid;
  final String btName;
  final Uuid bleDeviceService;
  final Uuid bleRxCharacteristic;
  final Uuid bleTxCharacteristic;
  final DeviceType deviceType;
  final String fwURL;

  const BaseDeviceDefinition(this.uuid, this.btName, this.bleDeviceService, this.bleRxCharacteristic, this.bleTxCharacteristic, this.deviceType, this.fwURL);

  @override
  String toString() {
    return 'BaseDeviceDefinition{btName: $btName, deviceType: $deviceType}';
  }
}

// data that represents the current state of a device
class BaseStatefulDevice {
  final BaseDeviceDefinition baseDeviceDefinition;
  final BaseStoredDevice baseStoredDevice;
  late QualifiedCharacteristic rxCharacteristic;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic batteryCharacteristic;
  late QualifiedCharacteristic batteryChargeCharacteristic;

  ValueNotifier<double> battery = ValueNotifier(-1);
  ValueNotifier<bool> batteryCharging = ValueNotifier(false);
  ValueNotifier<bool> batteryLow = ValueNotifier(false);
  ValueNotifier<bool> error = ValueNotifier(false);

  ValueNotifier<String> fwVersion = ValueNotifier("");
  ValueNotifier<String> hwVersion = ValueNotifier("");

  ValueNotifier<bool> glowTip = ValueNotifier(false);
  StreamSubscription<ConnectionStateUpdate>? connectionStateStreamSubscription;
  ValueNotifier<DeviceState> deviceState = ValueNotifier(DeviceState.standby);
  Stream<List<int>>? _rxCharacteristicStream;
  StreamSubscription<void>? keepAliveStreamSubscription;

  Stream<List<int>>? get rxCharacteristicStream => _rxCharacteristicStream;
  ValueNotifier<DeviceConnectionState> deviceConnectionState = ValueNotifier(DeviceConnectionState.disconnected);
  ValueNotifier<int> rssi = ValueNotifier(-1);
  ValueNotifier<FWInfo?> fwInfo = ValueNotifier(null);
  ValueNotifier<bool> hasUpdate = ValueNotifier(false);

  set rxCharacteristicStream(Stream<List<int>>? value) {
    _rxCharacteristicStream = value?.asBroadcastStream();
  }

  Ref? ref;
  late CommandQueue commandQueue;
  StreamSubscription<List<int>>? batteryCharacteristicStreamSubscription;
  StreamSubscription<List<int>>? batteryChargeCharacteristicStreamSubscription;
  List<FlSpot> batlevels = [];
  Stopwatch stopWatch = Stopwatch();
  bool disableAutoConnect = false;
  bool forgetOnDisconnect = false;

  BaseStatefulDevice(this.baseDeviceDefinition, this.baseStoredDevice, this.ref) {
    rxCharacteristic = QualifiedCharacteristic(characteristicId: baseDeviceDefinition.bleRxCharacteristic, serviceId: baseDeviceDefinition.bleDeviceService, deviceId: baseStoredDevice.btMACAddress);
    txCharacteristic = QualifiedCharacteristic(characteristicId: baseDeviceDefinition.bleTxCharacteristic, serviceId: baseDeviceDefinition.bleDeviceService, deviceId: baseStoredDevice.btMACAddress);
    batteryCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse("0000180f-0000-1000-8000-00805f9b34fb"), characteristicId: Uuid.parse("00002a19-0000-1000-8000-00805f9b34fb"), deviceId: baseStoredDevice.btMACAddress);
    batteryChargeCharacteristic = QualifiedCharacteristic(serviceId: Uuid.parse("0000180f-0000-1000-8000-00805f9b34fb"), characteristicId: Uuid.parse("5073792e-4fc0-45a0-b0a5-78b6c1756c91"), deviceId: baseStoredDevice.btMACAddress);

    commandQueue = CommandQueue(ref, this);
  }

  @override
  String toString() {
    return 'BaseStatefulDevice{baseDeviceDefinition: $baseDeviceDefinition, baseStoredDevice: $baseStoredDevice, battery: $battery}';
  }
}

@HiveType(typeId: 12)
enum AutoActionCategory {
  @HiveField(1)
  calm,
  @HiveField(2)
  fast,
  @HiveField(3)
  tense,
}

extension AutoActionCategoryExtension on AutoActionCategory {
  String get friendly {
    switch (this) {
      case AutoActionCategory.calm:
        return manageDevicesAutoMoveGroupsCalm();
      case AutoActionCategory.fast:
        return manageDevicesAutoMoveGroupsFast();
      case AutoActionCategory.tense:
        return manageDevicesAutoMoveGroupsFrustrated();
    }
  }
}

// All serialized/stored data
@HiveType(typeId: 1)
class BaseStoredDevice {
  @HiveField(0)
  String name = "New Gear";
  @HiveField(1)
  bool autoMove = false;
  @HiveField(2)
  double autoMoveMinPause = 15;
  @HiveField(3)
  double autoMoveMaxPause = 240;
  @HiveField(4)
  double autoMoveTotal = 60;
  @HiveField(5)
  double noPhoneDelayTime = 1;
  @HiveField(6)
  List<AutoActionCategory> selectedAutoCategories = [AutoActionCategory.calm];
  @HiveField(7)
  final String btMACAddress;
  @HiveField(8)
  final String deviceDefinitionUUID;
  @HiveField(9)
  int color;

  BaseStoredDevice(this.deviceDefinitionUUID, this.btMACAddress, this.color);

  @override
  String toString() {
    return 'BaseStoredDevice{name: $name, btMACAddress: $btMACAddress, deviceDefinitionUUID: $deviceDefinitionUUID}';
  }
}

String getNameFromBTName(String BTName) {
  switch (BTName) {
    case 'EarGear':
      return 'EarGear';
    case 'EG2':
      return 'EarGear 2';
    case 'mitail':
      return 'MiTail';
    case 'minitail':
      return 'MiTail Mini';
    case 'flutter':
      return 'FlutterWings';
    case '(!)Tail1':
      return 'DigiTail';
  }
  return BTName;
}
