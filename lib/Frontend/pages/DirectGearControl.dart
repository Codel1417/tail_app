import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math.dart';

import '../../Backend/Bluetooth/BluetoothManager.dart';
import '../../Backend/Bluetooth/btMessage.dart';
import '../../Backend/Definitions/Device/BaseDeviceDefinition.dart';
import '../../Backend/moveLists.dart';
import '../intnDefs.dart';

class DirectGearControl extends ConsumerStatefulWidget {
  const DirectGearControl({super.key});

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends ConsumerState<DirectGearControl> {
  double left = 0;
  double right = 0;
  double x = 0;
  double y = 0;
  Speed speed = Speed.fast;
  EasingType easingType = EasingType.linear;
  Set<DeviceType> deviceTypes = DeviceType.values.toSet();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
/*          ListTile(
            title: const Text("Left Servo"),
            subtitle: Slider(
              value: left,
              max: 128,
              divisions: 8,
              onChanged: (value) {
                setState(() {
                  left = value;
                });
              },
              onChangeEnd: (value) => SendMove(),
            ),
          ),
          ListTile(
            title: const Text("Right Servo"),
            subtitle: Slider(
              value: right,
              max: 128,
              divisions: 8,
              onChanged: (value) {
                setState(() {
                  right = value;
                });
              },
              onChangeEnd: (value) => SendMove(),
            ),
          ),*/
        ListTile(
          title: Text(sequencesEditSpeed()),
          subtitle: SegmentedButton<Speed>(
            selected: <Speed>{speed},
            onSelectionChanged: (Set<Speed> value) {
              setState(() {
                speed = value.first;
              });
            },
            segments: Speed.values.map<ButtonSegment<Speed>>(
              (Speed value) {
                return ButtonSegment<Speed>(
                  value: value,
                  label: Text(value.name),
                );
              },
            ).toList(),
          ),
        ),
        ListTile(
          title: Text(sequencesEditEasing()),
          subtitle: SegmentedButton<EasingType>(
            selected: <EasingType>{easingType},
            onSelectionChanged: (Set<EasingType> value) {
              setState(
                () {
                  easingType = value.first;
                },
              );
            },
            segments: EasingType.values.map<ButtonSegment<EasingType>>((EasingType value) {
              return ButtonSegment<EasingType>(value: value, icon: value.widget(context), tooltip: value.name);
            }).toList(),
          ),
        ),
        ListTile(
          title: Text(deviceType()),
          subtitle: SegmentedButton<DeviceType>(
            multiSelectionEnabled: true,
            selected: deviceTypes,
            onSelectionChanged: (Set<DeviceType> value) {
              setState(() => deviceTypes = value);
            },
            segments: DeviceType.values.map<ButtonSegment<DeviceType>>(
              (DeviceType value) {
                return ButtonSegment<DeviceType>(
                  value: value,
                  label: Text(value.name),
                );
              },
            ).toList(),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Joystick(
                    mode: JoystickMode.all,
                    onStickDragEnd: () {
                      Move move = Move();
                      move.moveType = MoveType.home;
                      ref.read(knownDevicesProvider).values.forEach((element) {
                        generateMoveCommand(move, element).forEach((message) {
                          message.responseMSG = null;
                          message.priority = Priority.high;
                          element.commandQueue.addCommand(message);
                        });
                      });
                    },
                    base: const Card(
                      elevation: 1,
                      shape: CircleBorder(),
                      child: SizedBox.square(dimension: 300),
                    ),
                    stick: Card(
                      elevation: 2,
                      shape: const CircleBorder(),
                      color: Theme.of(context).primaryColor,
                      child: SizedBox.square(dimension: 100),
                    ),
                    listener: (details) {
                      setState(() {
                        x = details.x;
                        y = details.y;

                        double sign = x.sign;
                        double direction = degrees(atan2(y.abs(), x.abs())); // 0-90
                        double magnitude = sqrt(pow(x.abs(), 2).toDouble() + pow(y.abs(), 2).toDouble());

                        double secondServo = ((((direction - 0) * (128 - 0)) / (90 - 0)) + 0).clamp(0, 128);
                        double primaryServo = ((((magnitude - 0) * (128 - 0)) / (1 - 0)) + 0).clamp(0, 128);
                        if (sign > 0) {
                          left = primaryServo;
                          right = secondServo;
                        } else {
                          right = primaryServo;
                          left = secondServo;
                        }
                      });
                      SendMove();
                    },
                    period: const Duration(milliseconds: 500),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text("Left: ${left}"), Text("Right: ${right}"), Text("X: ${x}"), Text("Y: ${y}")],
                )
              ],
            ],
          ),
        )
      ],
    );
  }

  void SendMove() {
    Move move = Move();
    move.easingType = easingType;
    move.speed = speed;
    move.rightServo = right;
    move.leftServo = left;
    ref.read(knownDevicesProvider).values.where((element) => deviceTypes.contains(element.baseDeviceDefinition.deviceType)).forEach((element) {
      generateMoveCommand(move, element).forEach((message) {
        message.responseMSG = null;
        message.priority = Priority.high;
        element.commandQueue.addCommand(message);
      });
    });
  }
}
