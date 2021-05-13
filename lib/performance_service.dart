import 'dart:io';

import 'package:dev_panel/perfomance_model.dart';
import 'package:flutter/services.dart';

class PerformanceService {
  static const MethodChannel _channel = const MethodChannel('dev_panel');

  static Future<PerformanceModel> updatePerformance() async {
    var performance = await _channel.invokeMethod('getPerformance');

    if(Platform.isAndroid) {
      final List<String> performanceSplit = performance.split(";");
      final List<String> topResultSplit = performanceSplit.last.split(" ");

      final int totalMemory = int.parse(performanceSplit.first);
      final int memoryUsedByApp = int.parse(
          topResultSplit[5].substring(0, topResultSplit[5].length - 1));

      final double cpuTimeUsedPercentage = double.parse(
          topResultSplit[8].substring(0, topResultSplit[8].length - 1));

      return PerformanceModel(
          memUsageInMb: memoryUsedByApp,
          memUsageInPercents: (memoryUsedByApp / (totalMemory / 1024)) * 100,
          cpuUsageInPercents: cpuTimeUsedPercentage
      );
    } else {
      final List<String> performanceSplit = performance.split('/');

      final int memoryUsedByApp = double.parse(performanceSplit[0]) / 1024 ~/ 1024;
      final double cpuTimeUsedPercentage = double.parse(performanceSplit[2]);
      final int totalMemory = int.parse(performanceSplit[1]);

      return PerformanceModel(
        memUsageInMb: memoryUsedByApp,
        memUsageInPercents: (memoryUsedByApp / (totalMemory / 1048576)) * 100,
        cpuUsageInPercents: cpuTimeUsedPercentage
      );
    }
  }
}