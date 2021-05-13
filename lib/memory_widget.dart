import 'dart:async';
import 'dart:io';

import 'package:dev_panel/chart.dart';
import 'package:dev_panel/performance_service.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:line_chart/model/line-chart.model.dart';

class MemoryWidget extends StatefulWidget {
  final int maxTime;
  final bool enableCharts;

  const MemoryWidget({Key key, this.maxTime, this.enableCharts = true}) : super(key: key);

  @override
  _MemoryWidgetState createState() => _MemoryWidgetState();
}

class _MemoryWidgetState extends State<MemoryWidget> {
  var _memUsageInMegaBytes = 0;
  var _memUsagePercentage = 0.0;

  var _memoryChartData = <LineChartModel>[];
  var _index = 0;

  var _isPhysicalDevice = true;

  Timer _updateTimer;

  @override
  void initState() {
    super.initState();

    _updateTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      PerformanceService.updatePerformance().then((value) {
        setState(() {
          _memUsageInMegaBytes = value.memUsageInMb;
          _memUsagePercentage = value.memUsageInPercents;

          _index++;

          _memoryChartData.add(LineChartModel(date: DateTime.now(), amount: _memUsageInMegaBytes.toDouble()));

          if(_memoryChartData.length == widget.maxTime)
            _memoryChartData.removeAt(0);
        });
      });
    });

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    deviceInfo.iosInfo.then((value) {
      setState(() {
        _isPhysicalDevice = value.isPhysicalDevice;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.0),
        RichText(
          overflow: TextOverflow.fade,
          maxLines: 1,
          text: TextSpan(
            text: "Memory usage: ",
            children: [
              TextSpan(
                text: (_memUsageInMegaBytes).toString() + " MB (${_memUsagePercentage.toStringAsFixed(1)}%)",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        if(!_isPhysicalDevice && Platform.isIOS)
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber)
            ),
            child: Column(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.deepOrangeAccent,),
                SizedBox(height: 8.0),
                Text("The application is running on the emulator, when calculating "
                    "the percentage of consumed memory, the total amount of RAM of "
                    "your computer is used", style: TextStyle(color: Colors.orangeAccent),),
              ],
            ),
          ),
        if(widget.enableCharts)
          Chart(data: _memoryChartData),
      ],
    );
  }
}
