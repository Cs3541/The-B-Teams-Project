import 'package:flutter/widgets.dart';

import '../presenters/settings_presenter.dart';

class SettingsScope extends InheritedNotifier<SettingsPresenter> {
  const SettingsScope({
    super.key,
    required SettingsPresenter presenter,
    required super.child,
  }) : super(notifier: presenter);

  static SettingsPresenter of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}
