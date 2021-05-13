import 'dart:async';

import 'package:dev_panel/cpu_widget.dart';
import 'package:dev_panel/fps_widget.dart';
import 'package:dev_panel/memory_widget.dart';
import 'package:flutter/material.dart';

class DeveloperWindow extends StatefulWidget {
  const DeveloperWindow({Key key}) : super(key: key);

  @override
  _DeveloperWindowState createState() => _DeveloperWindowState();
}

class _DeveloperWindowState extends State<DeveloperWindow>
    with TickerProviderStateMixin {
  static const int CHARTS_MAX_TIME_IN_SECONDS = 30;

  static const double CONTAINER_WIDTH_OPENED = 300.0;
  static const double CONTAINER_WIDTH_CLOSED = 30.0;

  static Duration baseAnimationDuration = Duration(milliseconds: 300);
  static Duration draggingAnimationDuration = Duration(milliseconds: 20);

  var _containerWidth = CONTAINER_WIDTH_CLOSED;
  var _animationDuration = baseAnimationDuration;

  var _enableCharts = true;

  Timer _updateTimer;

  @override
  void dispose() {
    super.dispose();

    _updateTimer.cancel();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOutQuad,
        width: _containerWidth,
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            AnimatedContainer(
              duration: _animationDuration,
              curve: Curves.easeInOutQuad,
              width: _containerWidth - 30,
              height: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    offset: Offset(3.0, 0.0),
                  )
                ],
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 32.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          vsync: this,
                          child: MaterialButton(onPressed: () {
                            setState(() {
                              _enableCharts = !_enableCharts;
                            });
                          }, child: Text("${_enableCharts ? "Hide" : "Show"} charts", overflow: TextOverflow.fade,), color: Colors.blue, textColor: Colors.white,),
                        ),
                        FpsWidget(maxTime: CHARTS_MAX_TIME_IN_SECONDS, enableCharts: _enableCharts,),
                        MemoryWidget(maxTime: CHARTS_MAX_TIME_IN_SECONDS, enableCharts: _enableCharts,),
                        CpuWidget(maxTime: CHARTS_MAX_TIME_IN_SECONDS, enableCharts: _enableCharts,)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragStart: (detail) {
                setState(() {
                  _animationDuration = draggingAnimationDuration;
                });
              },
              onHorizontalDragEnd: (detail) {
                setState(() {
                  _animationDuration = baseAnimationDuration;
                });

                if (_containerWidth > CONTAINER_WIDTH_OPENED / 2) {
                  _containerWidth = CONTAINER_WIDTH_OPENED;
                } else {
                  _containerWidth = CONTAINER_WIDTH_CLOSED;
                }
              },
              onHorizontalDragUpdate: (detail) {
                double x = detail.globalPosition.dx;

                setState(() {
                  if (x < CONTAINER_WIDTH_OPENED) {
                    if (x < CONTAINER_WIDTH_CLOSED) {
                      x = CONTAINER_WIDTH_CLOSED;
                    } else {
                      _containerWidth = x;
                    }
                  } else {
                    _containerWidth = CONTAINER_WIDTH_OPENED;
                  }
                });
              },
              onTap: () {
                setState(() {
                  if (_containerWidth == CONTAINER_WIDTH_CLOSED) {
                    _containerWidth = CONTAINER_WIDTH_OPENED;
                  } else {
                    _containerWidth = CONTAINER_WIDTH_CLOSED;
                  }
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(5.0, 0.0))
                  ],
                ),
                child: Icon(
                  Icons.developer_board,
                  color: Colors.black54,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DeveloperToolsWrapper extends StatelessWidget {
  final bool disable;
  final Widget child;

  const DeveloperToolsWrapper({Key key, this.disable = false, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (disable) {
      return child;
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        Directionality(
          textDirection: TextDirection.ltr,
          child: DeveloperWindow(),
        )
      ],
    );
  }
}

class LineChartModel {
  final double date;
  final double amount;

  LineChartModel({this.date, this.amount});
}