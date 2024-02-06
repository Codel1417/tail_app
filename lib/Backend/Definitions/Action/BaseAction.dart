import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:tail_app/Frontend/intnDefs.dart';

import '../Device/BaseDeviceDefinition.dart';

part 'BaseAction.g.dart';

enum ActionCategory { sequence, calm, fast, tense, glowtip, ears }

extension ActionCategoryExtension on ActionCategory {
  String get friendly {
    switch (this) {
      case ActionCategory.calm:
        return actionsCategoryCalm();
      case ActionCategory.fast:
        return actionsCategoryFast();
      case ActionCategory.tense:
        return actionsCategoryTense();
      case ActionCategory.glowtip:
        return actionsCategoryGlowtip();
      case ActionCategory.ears:
        return actionsCategoryEars();
      case ActionCategory.sequence:
        return sequencesPage();
    }
  }
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 4)
class BaseAction {
  @HiveField(1)
  String name;
  @HiveField(2)
  List<DeviceType> deviceCategory;
  @HiveField(3)
  ActionCategory actionCategory;

  BaseAction(this.name, this.deviceCategory, this.actionCategory);

  factory BaseAction.fromJson(Map<String, dynamic> json) => _$BaseActionFromJson(json);

  Map<String, dynamic> toJson() => _$BaseActionToJson(this);

  @override
  String toString() {
    return 'BaseAction{name: $name, deviceCategory: $deviceCategory, actionCategory: $actionCategory}';
  }
}

@JsonSerializable(explicitToJson: true)
class CommandAction extends BaseAction {
  final String command;
  final String? response;

  CommandAction(super.name, this.command, super.deviceCategory, super.actionCategory, this.response);

  factory CommandAction.fromJson(Map<String, dynamic> json) => _$CommandActionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommandActionToJson(this);
}
