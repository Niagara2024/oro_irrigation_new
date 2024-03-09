import 'dart:async';
import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/theme.dart';
import '../../../state_management/MqttPayloadProvider.dart';
import 'CentralFilter.dart';
import 'IrrigationPumpList.dart';


class MainLine extends StatefulWidget {
  const MainLine({Key? key, required this.siteData}) : super(key: key);
  final DashboardModel siteData;

  @override
  State<MainLine> createState() => _MainLineState();
}

class _MainLineState extends State<MainLine> {

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<MqttPayloadProvider>(context);

    return Row(
      children: [
        SizedBox(
          width: 280,
          child: Column(
            children: [
              widget.siteData.irrigationPump.isNotEmpty || widget.siteData.centralFilterSite.isNotEmpty?
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.siteData.irrigationPump.isNotEmpty? const IrrigationPumpList():
                  const SizedBox(),
                  SizedBox(
                    width: 70,
                    height: 160,
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            PopupMenuButton(
                              tooltip: 'Details',
                              itemBuilder: (context) {
                                return [
                                  const PopupMenuItem(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Pressure Sensor', style: TextStyle(fontWeight: FontWeight.bold),),
                                        Divider(),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              child: Image.asset('assets/images/dp_prs_sensor.png',),
                            ),
                            const Text('Prs In',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                            provider.PrsIn.isNotEmpty
                                ? Text('${double.parse(provider.PrsIn[0]['Value']).toStringAsFixed(2)} bar', style: const TextStyle(fontSize: 10))
                                : const Text('0.0 bar'),
                          ],
                        );
                      },
                    ),
                  ),
                  widget.siteData.centralFilterSite.isNotEmpty? const CentralFilter():
                  const SizedBox(),
                  SizedBox(
                    width: 70,
                    height: 160,
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            PopupMenuButton(
                              tooltip: 'Details',
                              itemBuilder: (context) {
                                return [
                                  const PopupMenuItem(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('Pressure Sensor', style: TextStyle(fontWeight: FontWeight.bold),),
                                        Divider(),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              child: Image.asset('assets/images/dp_prs_sensor.png',),
                            ),
                            const Text('Prs Out',style: TextStyle(fontSize: 10,fontWeight: FontWeight.normal),),
                            provider.PrsOut.isNotEmpty
                                ? Text('${double.parse(provider.PrsOut[0]['Value']).toStringAsFixed(2)} bar', style: const TextStyle(fontSize: 10))
                                : const Text('0.0 bar'),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ):
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50,),
                  Text('No Device Available'),
                ],
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 0),
        Expanded(
          flex :1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                title: Text('Dosing Recipes - NPK1'),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const SizedBox(width : 40, child: Icon(Icons.account_tree_rounded)),
                    const SizedBox(width: 10,),
                    const Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('EC',style: TextStyle(fontSize: 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Actual:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                              Text('00.0',style: TextStyle(fontSize: 10)),
                              SizedBox(width: 5,),
                              Text('Target:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                              Text('00.0',style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('PH',style: TextStyle(fontSize: 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Actual:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                              Text('00.0',style: TextStyle(fontSize: 10)),
                              SizedBox(width: 5,),
                              Text('Target:',style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),),
                              Text('00.0',style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width : 40, child: Image.asset('assets/images/injector.png',)),
                  ],),
              ),
              Flexible(
                  flex: 2,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 400,
                    dataRowHeight: 20.0,
                    headingRowHeight: 20,
                    headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.05)),
                    columns: const [
                      DataColumn2(
                          label: Center(child: Text('Channel', style: TextStyle(fontSize: 10),)),
                          size: ColumnSize.M
                      ),
                      DataColumn2(
                          label: Center(child: Text('1', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('2', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('3', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('4', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('5', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('6', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('7', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 37
                      ),
                      DataColumn2(
                          label: Center(child: Text('8', style: TextStyle(fontSize: 10),)),
                          fixedWidth: 30
                      ),
                    ],
                    rows: List<DataRow>.generate(5, (index) => DataRow(cells: [
                      DataCell(Center(child: Text(index==0? 'Open(%)':index==1?'Flow(l/h)':index==2?'Qty Delivered': index==3?'Time Delivered':'Set Point',
                          style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                      DataCell(Center(child: Text('1000', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 10)))),
                    ])),
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _seconds = 30;
  late Timer _timer;
  double _percentage = 1.0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        setState(() {
          if (_seconds < 1) {
            timer.cancel();
          } else {
            _seconds -= 1;
            _percentage = _seconds / 30.0; // Change 10.0 to the total time in seconds
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.greenAccent, // Set your desired background color
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: CustomPaint(
            size: const Size(30, 30),
            painter: TimerPainter(
              percentage: _percentage,
            ),
          ),
        ),
        Positioned(
          top: 7,
          left: 2.5,
          child: Container(
            width: 25,
            child: Center(
              child: Text('$_seconds', style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        )

      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class TimerPainter extends CustomPainter {
  final double percentage;

  TimerPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    Paint progressPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double angle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      -math.pi / 2,
      -angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}