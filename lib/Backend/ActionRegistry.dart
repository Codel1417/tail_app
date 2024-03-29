import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tail_app/Backend/moveLists.dart';

import 'Bluetooth/BluetoothManager.dart';
import 'Definitions/Action/BaseAction.dart';
import 'Definitions/Device/BaseDeviceDefinition.dart';

part 'ActionRegistry.g.dart';

@immutable
class ActionRegistry {
  static Set<BaseAction> allCommands = {
    CommandAction("Slow 1", "TAILS1", [DeviceType.tail, DeviceType.wings], ActionCategory.calm, "TAILS1 END", "c53e980e-899e-4148-a13e-f57a8f9707f4"),
    CommandAction("Slow 2", "TAILS2", [DeviceType.tail, DeviceType.wings], ActionCategory.calm, "TAILS2 END", "eb1bdfe7-d374-4e97-943a-13e89f27ddcd"),
    CommandAction("Slow 3", "TAILS3", [DeviceType.tail, DeviceType.wings], ActionCategory.calm, "TAILS3 END", "6937b9af-3ff7-43fb-ae62-a403e5dfaf95"),
    CommandAction("Fast", "TAILFA", [DeviceType.tail, DeviceType.wings], ActionCategory.fast, "TAILFA END", "a04b558f-0ad5-410f-8e39-8f5c594791d2"),
    CommandAction("Short", "TAILSH", [DeviceType.tail, DeviceType.wings], ActionCategory.fast, "TAILSH END", "05a4c47b-45ee-4da8-bec2-4a46f4e04a7f"),
    CommandAction("Happy", "TAILHA", [DeviceType.tail, DeviceType.wings], ActionCategory.fast, "TAILHA END", "86b13d13-b09c-46ba-a887-b40d8118b00a"),
    CommandAction("Erect", "TAILER", [DeviceType.tail, DeviceType.wings], ActionCategory.fast, "TAILER END", "5b04ca3d-a22a-4aff-8f40-99363248fcaa"),
    CommandAction("Erect Pulse", "TAILEP", [DeviceType.tail, DeviceType.wings], ActionCategory.tense, "TAILEP END", "39bbe39d-aa92-4189-ac90-4bb821a59f5e"),
    CommandAction("Tremble 1", "TAILT1", [DeviceType.tail, DeviceType.wings], ActionCategory.tense, "TAILT1 END", "8cc3fc60-b8d2-4f22-810a-1e042d3984f7"),
    CommandAction("Tremble 2", "TAILT2", [DeviceType.tail, DeviceType.wings], ActionCategory.tense, "TAILT2 END", "123557a2-5489-43da-99e2-da37a36f055a"),
    CommandAction("Erect Tremble", "TAILET", [DeviceType.tail, DeviceType.wings], ActionCategory.tense, "TAILET END", "4909d4c2-0054-4f16-9589-6273ef6bf6c9"),
    CommandAction("LEDs off", "LEDOFF", [DeviceType.tail], ActionCategory.glowtip, null, "6b2a7fae-b58c-43f3-81bf-070aa21c2242"),
    CommandAction("Rectangle wave", "LEDREC", [DeviceType.tail], ActionCategory.glowtip, null, "34269c91-90bd-4a34-851d-d49daa6ac863"),
    CommandAction("Triangle wave", "LEDTRI", [DeviceType.tail], ActionCategory.glowtip, null, "64142e0b-4cc0-4b1e-845f-9c560875f993"),
    CommandAction("Sawtooth wave", "LEDSAW", [DeviceType.tail], ActionCategory.glowtip, null, "047b84ad-3eb8-4d9c-b59b-13186cf965ca"),
    CommandAction("SOS", "LEDSOS", [DeviceType.tail], ActionCategory.glowtip, null, "66164945-840f-4302-b27c-e7a7623bf475"),
    CommandAction("Beacon", "LEDBEA", [DeviceType.tail], ActionCategory.glowtip, null, "4955a936-7703-4ce6-8d4a-b18857c0ea0a"),
    CommandAction("Flame", "LEDFLA", [DeviceType.tail], ActionCategory.glowtip, null, "e46566b4-1071-4866-815b-1aefbf06b573"),
    //CommandAction("Left Twist", "LETWIST", [DeviceType.ears], ActionCategory.ears, "LETWIST END", "0d5a9dfa-38f2-4b09-9be1-cd36236a03b0"),
    //CommandAction("Right Twist", "RITWIST", [DeviceType.ears], ActionCategory.ears, "RITWIST END", "9a6be63e-36f5-4f50-88b6-7adf2680aa5c"),
    //CommandAction("Both Twist", "BOTWIST", [DeviceType.ears], ActionCategory.ears, "BOTWIST END", "2bc43e6c-65e7-4a35-834e-b2c31b8f83fe"),
    //CommandAction("Home Ears", "EARHOME", [DeviceType.ears], ActionCategory.ears, "EARHOME END", "cdd2e0ac-97a2-41d7-9ece-8d4dce4829d7"),
    MoveList.builtIn(
      "Ears Wide",
      [DeviceType.ears],
      ActionCategory.ears,
      "d8384bcf-31ed-4b5d-a25a-da3a2f96e406",
      [
        Move.move(128, 128, 80, EasingType.cubic),
        Move.delay(5),
        Move.move(0, 0, 80, EasingType.cubic),
        Move.delay(5),
        Move.move(128, 128, 80, EasingType.cubic),
        Move.delay(5),
      ],
    ),
    MoveList.builtIn(
      "Double Right",
      [DeviceType.ears],
      ActionCategory.ears,
      "0d5a9dfa-38f2-4b09-9be1-cd36236a03b0",
      [
        Move.move(128, 20, 50, EasingType.cubic),
        Move.delay(5),
        Move.move(20, 20, 50, EasingType.cubic),
        Move.delay(5),
        Move.move(128, 20, 50, EasingType.cubic),
        Move.delay(5),
      ],
    ),
    MoveList.builtIn(
      "Double Left",
      [DeviceType.ears],
      ActionCategory.ears,
      "9a6be63e-36f5-4f50-88b6-7adf2680aa5c",
      [
        Move.move(20, 128, 50, EasingType.cubic),
        Move.delay(5),
        Move.move(20, 20, 50, EasingType.cubic),
        Move.delay(5),
        Move.move(20, 128, 50, EasingType.cubic),
        Move.delay(5),
      ],
    ),
    MoveList.builtIn(
      "Left Listen",
      [DeviceType.ears],
      ActionCategory.ears,
      "83590dc9-f9de-4134-bcc7-8157a62a33ef",
      [
        Move.move(128, 50, 128, EasingType.cubic),
        Move.delay(2),
      ],
    ),
    MoveList.builtIn(
      "Right Listen",
      [DeviceType.ears],
      ActionCategory.ears,
      "007c52d3-242a-4e27-bccc-b4b737502bfb",
      [
        Move.move(50, 128, 128, EasingType.cubic),
        Move.delay(2),
      ],
    ),
    MoveList.builtIn(
      "Flick Right",
      [DeviceType.ears],
      ActionCategory.ears,
      "769dbe84-3a6e-440d-8b20-234983d36cb6",
      [
        Move.move(20, 50, 128, EasingType.linear),
        Move.delay(2),
      ],
    ),
    MoveList.builtIn(
      "Flick Left",
      [DeviceType.ears],
      ActionCategory.ears,
      "23144b42-6d3c-4822-8510-ec03c63c7808",
      [
        Move.move(50, 20, 128, EasingType.linear),
        Move.delay(2),
      ],
    ),
    MoveList.builtIn(
      "Hewo",
      [DeviceType.ears],
      ActionCategory.ears,
      "fdaff205-0a51-46a0-a5fc-4ea283dce079",
      [
        Move.move(50, 20, 50, EasingType.cubic),
        Move.delay(1),
        Move.move(60, 60, 50, EasingType.cubic),
        Move.delay(1),
      ],
    ),
  };
}

@Riverpod(dependencies: [KnownDevices], keepAlive: false)
Map<ActionCategory, Set<BaseAction>> getAvailableActions(GetAvailableActionsRef ref) {
  Map<String, BaseStatefulDevice> knownDevices = ref.watch(knownDevicesProvider);
  Map<ActionCategory, Set<BaseAction>> sortedActions = {};
  for (BaseAction baseAction in List.from(ActionRegistry.allCommands)..addAll(ref.read(moveListsProvider))) {
    Set<BaseAction>? baseActions = {};
    for (BaseStatefulDevice baseStatefulDevice in knownDevices.values.where((element) => element.deviceConnectionState.value == DeviceConnectionState.connected)) {
      // check if command matches device type
      if (baseAction.deviceCategory.contains(baseStatefulDevice.baseDeviceDefinition.deviceType) && ((baseAction.actionCategory == ActionCategory.glowtip && baseStatefulDevice.glowTip.value) || baseAction.actionCategory != ActionCategory.glowtip)) {
        // get category if it exists
        if (sortedActions.containsKey(baseAction.actionCategory)) {
          baseActions = sortedActions[baseAction.actionCategory];
        }
        // add action to category
        baseActions?.add(baseAction);
      }
    }
    // store result
    if (baseActions != null && baseActions.isNotEmpty) {
      sortedActions[baseAction.actionCategory] = baseActions;
    }
  }
  return sortedActions;
}

@Riverpod(dependencies: [KnownDevices])
Map<ActionCategory, Set<BaseAction>> getAllActions(GetAllActionsRef ref, Set<DeviceType> deviceType) {
  Map<ActionCategory, Set<BaseAction>> sortedActions = {};
  for (BaseAction baseAction in List.from(ActionRegistry.allCommands)..addAll(ref.read(moveListsProvider))) {
    Set<BaseAction>? baseActions = {};
    // check if command matches device type
    if (baseAction.deviceCategory.toSet().intersection(deviceType).isNotEmpty) {
      // get category if it exists
      if (sortedActions.containsKey(baseAction.actionCategory)) {
        baseActions = sortedActions[baseAction.actionCategory];
      }
      // add action to category
      baseActions?.add(baseAction);
    }
    // store result
    if (baseActions != null && baseActions.isNotEmpty) {
      sortedActions[baseAction.actionCategory] = baseActions;
    }
  }
  return sortedActions;
}
