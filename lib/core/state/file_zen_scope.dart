import 'package:flutter/widgets.dart';

import '../../data/controllers/file_zen_controller.dart';

class FileZenScope extends InheritedNotifier<FileZenController> {
  const FileZenScope({
    super.key,
    required FileZenController controller,
    required super.child,
  }) : super(notifier: controller);

  static FileZenController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FileZenScope>();
    assert(scope != null, 'FileZenScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
