import 'package:flutter/material.dart';
import 'package:line_chart/charts/line-chart.widget.dart';
import 'package:line_chart/model/line-chart.model.dart';

class Chart extends StatelessWidget {
  final List<LineChartModel> data;

  const Chart({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.05),
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: LineChart(
        insidePadding: 5.0,
        width: 200,
        // Width size of chart
        height: 180,
        // Height size of chart
        data: data,
        // The value to the chart
        linePaint: Paint()
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke
          ..color = Colors.lightBlue,
        // Custom paint for the line
        circlePaint: Paint()..color = Colors.blue,
        // Custom paint for the line
        showPointer: true,
        // When press or pan update the chart, create a pointer in approximated value (The default is true)
        showCircles: true,
        // Show the circle in every value of chart
        customDraw: (Canvas canvas, Size size) {},
        // You can draw anything in your chart, this callback is called when is generating the chart
        circleRadiusValue: 2,
        // The radius value of circle
        linePointerDecoration: BoxDecoration(
          color: Colors.black,
        ),
        // Your line pointer decoration,
        pointerDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueGrey,
        ),
        // Your decoration of circle pointer,
        insideCirclePaint: Paint()
          ..color = Colors
              .white, // On your circle of the chart, have a second circle, which is inside and a slightly smaller size./ This callback is called when it is on the pointer and removes your finger from the screen
      ),
    );
  }
}
