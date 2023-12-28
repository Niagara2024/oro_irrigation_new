import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';



class WeatherReport extends StatelessWidget {
   WeatherReport(
      {super.key, required this.tempdata,required this.timedata});
  List tempdata = [];
   List timedata = [];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(title: Text('Report Chart ')),
        body: ScrollableChart(tempdata: tempdata,timedata: timedata,),
     );
  }
}

class ScrollableChart extends StatelessWidget {
  ScrollableChart(
      {super.key, required this.tempdata,required this.timedata});
  List tempdata = [];
  List timedata = [];
  @override
  Widget build(BuildContext context) {
    // Dummy data for the chart
    // List<FlSpot> chartData = List.generate(
    //     data, (index) => FlSpot(index.toDouble(), index.toDouble()));

    List<FlSpot> chartData = [];
    for (int index = 0; index < tempdata.length; index++) {
      List<String> part = timedata[index].split(
          'T');
      String replacedValue = part[1].replaceAll(':', '.'); double.parse(replacedValue);
        chartData.add(FlSpot(index.toDouble(), tempdata[index]));
    }
    return  Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
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
    );
  }
}
