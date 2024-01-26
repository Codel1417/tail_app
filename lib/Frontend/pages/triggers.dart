import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tail_app/Backend/ActionRegistry.dart';
import 'package:tail_app/Backend/Definitions/Action/BaseAction.dart';
import 'package:tail_app/Backend/Definitions/Device/BaseDeviceDefinition.dart';
import 'package:tail_app/Backend/Sensors.dart';

import '../intnDefs.dart';

class Triggers extends ConsumerStatefulWidget {
  const Triggers({super.key});

  @override
  _TriggersState createState() => _TriggersState();
}

class _TriggersState extends ConsumerState<Triggers> {
  @override
  Widget build(BuildContext context) {
    final List<Trigger> triggersList = ref.watch(triggerListProvider);
    TriggerDefinition? triggerDefinition;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        onPressed: () {
          showDialog<TriggerDefinition>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Text(triggersSelectLabel()),
                    content: StatefulBuilder(
                      builder: (context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: ref
                              .watch(triggerDefinitionListProvider)
                              .map((TriggerDefinition e) => ListTile(
                                    title: Text(e.name),
                                    leading: Radio<TriggerDefinition>(
                                      value: e,
                                      groupValue: triggerDefinition,
                                      onChanged: (TriggerDefinition? value) {
                                        setState(() {
                                          triggerDefinition = value;
                                        });
                                      },
                                    ),
                                    trailing: e.icon,
                                    subtitle: Text(e.description),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, null),
                        child: Text(cancel()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, triggerDefinition),
                        child: Text(ok()),
                      ),
                    ],
                  )).then(
            (TriggerDefinition? value) {
              if (value != null) {
                // The user selected a Trigger Definition
                setState(
                  () {
                    Trigger trigger = Trigger.trigDef(triggerDefinition!);
                    ref.read(triggerListProvider.notifier).add(trigger);
                  },
                );
              }
            },
          );
        },
        label: Text(triggersAdd()),
      ),
      body: ListView.builder(
        itemCount: triggersList.length,
        primary: true,
        itemBuilder: (BuildContext context, int index) {
          return ExpansionTile(
            title: Text(triggersList[index].triggerDefinition!.name),
            subtitle: Text(triggersList[index].triggerDefinition!.description),
            //leading: triggersList[index].triggerDefinition.icon,
            leading: Switch(
              value: triggersList[index].enabled,
              onChanged: (bool value) {
                setState(
                  () {
                    triggersList[index].enabled = value;
                    ref.read(triggerListProvider.notifier).store();
                  },
                );
              },
            ),
            children: getTriggerOptions(triggersList[index]),
          );
        },
      ),
    );
  }

  List<Widget> getTriggerOptions(Trigger trigger) {
    List<Widget> results = [];
    results.add(
      ListTile(
        title: Text(deviceType()),
        subtitle: SegmentedButton<DeviceType>(
          multiSelectionEnabled: true,
          selected: trigger.deviceType,
          onSelectionChanged: (Set<DeviceType> value) {
            setState(() => trigger.deviceType = value);
            ref.read(triggerListProvider.notifier).store();
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
    );
    results.addAll(
      trigger.actions.map(
        (TriggerAction e) => ListTile(
          title: Text(e.name),
          //TODO: Replace with window to select action/movelist. The dropdown is slow and cluttered
          trailing: DropdownMenu<BaseAction>(
            initialSelection: e.action,
            dropdownMenuEntries: ActionRegistry.allCommands
                .map(
                  (BaseAction e) => DropdownMenuEntry<BaseAction>(
                    label: e.name,
                    value: e,
                    leadingIcon: const Icon(Icons.moving),
                  ),
                )
                .toList(),
            onSelected: (BaseAction? value) {
              setState(
                () {
                  e.action = value;
                  ref.read(triggerListProvider.notifier).store();
                },
              );
            },
          ),
        ),
      ),
    );
    return results;
  }
}