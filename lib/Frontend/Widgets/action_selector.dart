import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Backend/ActionRegistry.dart';
import '../../Backend/Definitions/Action/BaseAction.dart';
import '../../Backend/Definitions/Device/BaseDeviceDefinition.dart';
import '../intnDefs.dart';

class ActionSelector extends ConsumerWidget {
  ActionSelector({super.key, required this.deviceType});

  Set<DeviceType> deviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<ActionCategory, Set<BaseAction>> actionsCatMap = ref.read(getAllActionsProvider(deviceType));
    List<ActionCategory> catList = actionsCatMap.keys.toList();
    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: Text(actionsSelectScreen()),
      ),
      body: ListView.builder(
        primary: true,
        itemCount: catList.length,
        itemBuilder: (BuildContext context, int categoryIndex) {
          List<BaseAction> actionsForCat = actionsCatMap.values.toList()[categoryIndex].toList();
          return Column(
            children: [
              Center(
                child: Text(
                  catList[categoryIndex].friendly,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 125),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: actionsForCat.length,
                itemBuilder: (BuildContext context, int actionIndex) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, actionsForCat[actionIndex]),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text(actionsForCat[actionIndex].name, semanticsLabel: actionsForCat[actionIndex].name, overflow: TextOverflow.fade, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
