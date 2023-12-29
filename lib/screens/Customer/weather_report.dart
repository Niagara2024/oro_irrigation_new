import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/theme.dart';

enum Segment { Weekly, Monthly, Yearly }

class WeatherReport extends StatelessWidget {
  WeatherReport(
      {super.key, required this.tempdata,required this.timedata,required this.title});
  List tempdata = [];
  List timedata = [];
  String title;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text('$title')),
      body: ScrollableChart(tempdata: tempdata,timedata: timedata,),
    );
  }
}

class ScrollableChart extends StatefulWidget {
  ScrollableChart(
      {super.key, required this.tempdata,required this.timedata});
  List tempdata = [];
  List timedata = [];
  Segment selectedSegment = Segment.Weekly;


  @override
  State<ScrollableChart> createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<ScrollableChart> {
  @override
  Widget build(BuildContext context) {



    List<FlSpot> chartData = [];
    for (int index = 0; index < widget.tempdata.length; index++) {
      List<String> part = widget.timedata[index].split(
          'T');
      String replacedValue = part[1].replaceAll(':', '.'); double.parse(replacedValue);
      chartData.add(FlSpot(index.toDouble(), widget.tempdata[index]));
    }
    if(widget.selectedSegment == Segment.Weekly) {

      chartData = chartData.sublist(0, 7);
    }
    else if(widget.selectedSegment == Segment.Monthly) {
      chartData = chartData.sublist(0, 30);
    }
    else{
      // chartData = chartData.sublist(0, 90);
      // chartData = widget.tempdata;
    }
    return  Column(
      children: [
        SizedBox(height: 10,),
        SegmentedButton<Segment>(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
                myTheme.primaryColor.withOpacity(0.1)),
            iconColor: MaterialStateProperty.all(myTheme.primaryColor),
          ),
          segments:  const <ButtonSegment<Segment>>[
            ButtonSegment<Segment>(
                value: Segment.Weekly,
                label: Text('Weekly'),
                icon: Icon(Icons.calendar_today_outlined)),
            ButtonSegment<Segment>(
                value: Segment.Monthly,
                label: Text('Monthly'),
                icon: Icon(Icons.calendar_view_week)),
            ButtonSegment<Segment>(
                value: Segment.Yearly,
                label: Text('Yearly'),
                icon: Icon(Icons.calendar_month)),
          ],
          selected: <Segment>{widget.selectedSegment},
          onSelectionChanged: (Set<Segment> newSelection) {
            setState(() {
              print('selectedSegment$widget.selectedSegment');
              widget.selectedSegment = newSelection.first;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width - 100 ,// chartData.length * 20 < MediaQuery.of(context).size.width ? MediaQuery.of(context).size.width : chartData.length * 20, // Set width to ensure chart's width
                  height: 300, // Set height as needed
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: false,
                          color: Colors.blue,
                          barWidth: 1,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: true),
                        ),
                      ],
                      borderData: FlBorderData(show: true),
                      gridData: FlGridData(show: true),
                      // rangeAnnotations: RangeAnnotations(),
                    ),
                  ),

                ),
              ],

            ),
          ),
        ),
      ],
    );
  }
}
