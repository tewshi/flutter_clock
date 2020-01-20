import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:analog_clock/arc_painter.dart';
import 'package:analog_clock/clock_dial.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class TClock extends StatefulWidget {
  TClock({
    Key key,
    this.diameter = 150.0,
    this.clockText = TClockText.arabic,
    @required this.elapsedTime,
  }) : super(key: key);

  final double diameter;
  final TClockText clockText;
  final ValueChanged<int> elapsedTime;

  @override
  _TClockState createState() => _TClockState();
}

class _TClockState extends State<TClock> with TickerProviderStateMixin {
  DateFormat format;
  DateTime _now = DateTime.now();
  int seconds;
  int minutes;
  int hours;
  double secondsProgress;
  double newSecondsProgress;
  double minutesProgress;
  double newMinutesProgress;
  double hoursProgress;
  double newHoursProgress;
  AnimationController secondsCtrl;
  AnimationController minutesCtrl;
  AnimationController hoursCtrl;
  Timer timer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('en_US', null);
    format = DateFormat('h:mm:ss aaa', 'en_US');
    seconds = _now.second;
    minutes = _now.minute;
    hours = _now.hour;
    secondsProgress = 0;
    minutesProgress = 0;
    hoursProgress = 0;
    startSeconds();
    if (seconds > 0) {
      secondsCtrl.value = seconds / 60;
      secondsCtrl.forward();
    }
    startMinutes();
    if (minutes > 0) {
      minutesCtrl.value = minutes / 60;
      minutesCtrl.forward();
    }
    startHours();
    if (hours > 0) {
      hoursCtrl.value = (hours > 12 ? hours - 12 : hours) / 12;
      hoursCtrl.forward();
    }

    timer = Timer.periodic(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        (Timer t) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    secondsCtrl?.dispose();
    minutesCtrl?.dispose();
    hoursCtrl?.dispose();
    super.dispose();
  }

  void startSeconds() {
    secondsCtrl = AnimationController(
      vsync: this,
      duration: Duration(minutes: 1),
    )
      ..addListener(secondsListener)
      ..addStatusListener(secondsStatusListener);
    secondsCtrl.forward();
  }

  void startMinutes() {
    minutesCtrl = AnimationController(
      vsync: this,
      duration: Duration(hours: 1),
    )
      ..addListener(minutesListener)
      ..addStatusListener(minutesStatusListener);
    minutesCtrl.forward();
  }

  void startHours() {
    hoursCtrl = AnimationController(
      vsync: this,
      duration: Duration(hours: 12),
    )
      ..addListener(hoursListener)
      ..addStatusListener(hoursStatusListener);
    hoursCtrl.forward();
  }

  void restartSeconds() {
    secondsProgress = 0;
    secondsCtrl.removeListener(secondsListener);
    secondsCtrl.removeStatusListener(secondsStatusListener);
    secondsCtrl.reset();
    startSeconds();
  }

  void restartMinutes() {
    minutesProgress = 0;
    minutesCtrl.removeListener(minutesListener);
    minutesCtrl.removeStatusListener(minutesStatusListener);
    minutesCtrl.reset();
    startMinutes();
  }

  void restartHours() {
    hoursProgress = 0;
    hoursCtrl.removeListener(hoursListener);
    hoursCtrl.removeStatusListener(hoursStatusListener);
    hoursCtrl.reset();
    startHours();
  }

  void secondsListener() {
//    print(secondsCtrl.value);
    setState(() {
      newSecondsProgress = 2 * math.pi * secondsCtrl.value;
      secondsProgress =
          ui.lerpDouble(secondsProgress, newSecondsProgress, secondsCtrl.value);
    });
  }

  void minutesListener() {
    setState(() {
      newMinutesProgress = 2 * math.pi * minutesCtrl.value;
      minutesProgress =
          ui.lerpDouble(minutesProgress, newMinutesProgress, minutesCtrl.value);
    });
  }

  void hoursListener() {
    setState(() {
      newHoursProgress = 2 * math.pi * hoursCtrl.value;
      hoursProgress =
          ui.lerpDouble(hoursProgress, newHoursProgress, hoursCtrl.value);
    });
  }

  void secondsStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      restartSeconds();
    }
  }

  void minutesStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      restartMinutes();
    }
  }

  void hoursStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      restartHours();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.center,
      children: <Widget>[
        Material(
          color: Color(0xFFFFFFCC),
          shape: CircleBorder(),
          child: InkWell(
            onTap: () {},
            customBorder: CircleBorder(),
            child: SizedBox(
              width: widget.diameter,
              height: widget.diameter,
              child: CustomPaint(
                painter: ArcPainter(sweepAngle: secondsProgress),
              ),
            ),
          ),
        ),
        SizedBox(
          width: widget.diameter - (widget.diameter / 5),
          height: widget.diameter - (widget.diameter / 5),
          child: CustomPaint(
            painter: ArcPainter(
              sweepAngle: minutesProgress,
              color: Color.fromRGBO(53, 0, 71, 0.5),
            ),
          ),
        ),
        SizedBox(
          width: widget.diameter - (widget.diameter / 2.5),
          height: widget.diameter - (widget.diameter / 2.5),
          child: CustomPaint(
            painter: ArcPainter(
              sweepAngle: hoursProgress,
              color: Color.fromRGBO(42, 85, 0xF4, 0.5),
            ),
          ),
        ),
        Container(
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: CircleBorder(
              side: BorderSide(
                color: Color.fromRGBO(53, 0, 71, 1),
                width: widget.diameter * 0.05,
              ),
            ),
          ),
          child: SizedBox(
            width: widget.diameter,
            height: widget.diameter,
            child: CustomPaint(
              painter: TClockDialPainter(clockText: widget.clockText),
            ),
          ),
        ),
        SizedBox(
          width: widget.diameter + 10.0,
          height: widget.diameter + 10.0,
          child: Center(
            child: Text(
              format.format(_now),
              style: TextStyle(
                color: Color.fromRGBO(53, 0, 71, 1),
                fontSize: 11,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
