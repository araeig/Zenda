import 'package:flutter/foundation.dart';

final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

void notifyDataChanged() => dataVersion.value++;