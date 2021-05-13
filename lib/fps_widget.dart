import 'package:flutter/material.dart';
import 'package:line_chart/model/line-chart.model.dart';
import 'package:performance_fps/performance_fps.dart';

import 'chart.dart';

class FpsWidget extends StatefulWidget {
  final int maxTime;
  final bool enableCharts;

  const FpsWidget({Key key, this.maxTime, this.enableCharts = true}) : super(key: key);

  @override
  _FpsWidgetState createState() => _FpsWidgetState();
}

class _FpsWidgetState extends State<FpsWidget> {
  var _fps = 0.0;
  var _dropCount = 0.0;

  var _fpsChartData = <LineChartModel>[];

  @override
  void initState() {
    super.initState();

    Fps.instance.registerCallBack((fps, dropCount) {
      if (mounted)
        setState(() {
          _fps = fps;
          _dropCount = dropCount;

          _fpsChartData.add(LineChartModel(date: DateTime.now(), amount: _fps));

          if(_fpsChartData.length == widget.maxTime)
            _fpsChartData.removeAt(0);
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
            text: "FPS: ",
            children: [
              TextSpan(
                text: _fps.toStringAsFixed(1),
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
          Chart(data: _fpsChartData),
      ],
    );
  }
}
