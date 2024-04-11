import 'dart:async';
import 'dart:core';

import 'package:circular_buffer/circular_buffer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tail_app/Backend/Bluetooth/bluetooth_manager.dart';
import 'package:tail_app/Backend/firmware_update.dart';

import '../../../Frontend/intn_defs.dart';

part 'device_definition.g.dart';

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
  late final QualifiedCharacteristic rxCharacteristic;
  late final QualifiedCharacteristic txCharacteristic;
  late final QualifiedCharacteristic batteryCharacteristic;
  late final QualifiedCharacteristic batteryChargeCharacteristic;

  final ValueNotifier<double> battery = ValueNotifier(-1);
  final ValueNotifier<bool> batteryCharging = ValueNotifier(false);
  final ValueNotifier<bool> batteryLow = ValueNotifier(false);
  final ValueNotifier<bool> error = ValueNotifier(false);

  final ValueNotifier<String> fwVersion = ValueNotifier("");
  final ValueNotifier<String> hwVersion = ValueNotifier("");

  final ValueNotifier<bool> glowTip = ValueNotifier(false);
  StreamSubscription<ConnectionStateUpdate>? connectionStateStreamSubscription;
  final ValueNotifier<DeviceState> deviceState = ValueNotifier(DeviceState.standby);
  Stream<List<int>>? _rxCharacteristicStream;
  StreamSubscription<void>? keepAliveStreamSubscription;

  Stream<List<int>>? get rxCharacteristicStream => _rxCharacteristicStream;
  final ValueNotifier<DeviceConnectionState> deviceConnectionState = ValueNotifier(DeviceConnectionState.disconnected);
  final ValueNotifier<int> rssi = ValueNotifier(-1);
  final ValueNotifier<FWInfo?> fwInfo = ValueNotifier(null);
  final ValueNotifier<bool> hasUpdate = ValueNotifier(false);

  set rxCharacteristicStream(Stream<List<int>>? value) {
    _rxCharacteristicStream = value?.asBroadcastStream();
  }

  Ref? ref;
  late final CommandQueue commandQueue;
  StreamSubscription<List<int>>? batteryCharacteristicStreamSubscription;
  StreamSubscription<List<int>>? batteryChargeCharacteristicStreamSubscription;
  List<FlSpot> batlevels = [];
  Stopwatch stopWatch = Stopwatch();
  bool disableAutoConnect = false;
  bool forgetOnDisconnect = false;

  final CircularBuffer<MessageHistoryEntry> messageHistory = CircularBuffer(50);

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

  void reset() {
    battery.value = -1;
    batteryCharging.value = false;
    batteryLow.value = false;
    error.value = false;
    fwVersion.value = "";
    hwVersion.value = "";
    glowTip.value = false;
    connectionStateStreamSubscription?.cancel();
    connectionStateStreamSubscription = null;
    deviceState.value = DeviceState.standby;
    rxCharacteristicStream = null;
    keepAliveStreamSubscription?.cancel();
    keepAliveStreamSubscription = null;
    deviceConnectionState.value = DeviceConnectionState.disconnected;
    rssi.value = -1;
    fwInfo.value = null;
    hasUpdate.value = false;
    batteryCharacteristicStreamSubscription?.cancel();
    batteryCharacteristicStreamSubscription = null;
    batteryChargeCharacteristicStreamSubscription?.cancel();
    batteryChargeCharacteristicStreamSubscription = null;
    batlevels = [];
    stopWatch.reset();
  }
}

enum MessageHistoryType {
  send,
  receive,
}

class MessageHistoryEntry {
  final MessageHistoryType type;
  final String message;

  MessageHistoryEntry({required this.type, required this.message});
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

String getNameFromBTName(String bluetoothDeviceName) {
  switch (bluetoothDeviceName) {
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
  return bluetoothDeviceName;
}