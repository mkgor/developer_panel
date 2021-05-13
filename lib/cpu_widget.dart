import 'dart:async';

import 'package:dev_panel/chart.dart';
import 'package:dev_panel/performance_service.dart';
import 'package:flutter/material.dart';
import 'package:line_chart/model/line-chart.model.dart';

class CpuWidget extends StatefulWidget {
  final int maxTime;
  final bool enableCharts;

  const CpuWidget({Key key, this.maxTime, this.enableCharts = true}) : super(key: key);

  @override
  _CpuWidgetState createState() => _CpuWidgetState();
}

class _CpuWidgetState extends State<CpuWidget> {
  var _cpuUsage = 0.0;
  var _cpuChartData = <LineChartModel>[];

  var _index = 0;

  Timer _updateTimer;

  @override
  void initState() {
    super.initState();

    _updateTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      PerformanceService.updatePerformance().then((value) {
        setState(() {
          _cpuUsage = value.cpuUsageInPercents;
          _index++;

          _cpuChartData.add(LineChartModel(date: DateTime.now(), amount: double.parse(_cpuUsage.toStringAsFixed(2))));
          if(_cpuChartData.length == widget.maxTime)
            _cpuChartData.removeAt(0);
        });
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
            text: "CPU usage: ",
            children: [
              TextSpan(
                text: "${_cpuUsage.toStringAsFixed(1)}%",
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
        if(widget.enableCharts)
          Chart(data: _cpuChartData),
      ],
    );
  }
}
