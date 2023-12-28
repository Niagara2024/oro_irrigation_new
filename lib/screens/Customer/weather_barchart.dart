import 'package:flutter/material.dart';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';

 
class WeatherBar extends StatelessWidget {
   WeatherBar(
      {super.key, required this.tempdata,required this.timedata});
  List tempdata = [];
  List timedata = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomePage(tempdata: tempdata,timedata: [],),
    );
  }
}

// Define data structure for a bar group
class DataItem {
  int x;
  double y1;
  double y2;
  double y3;
  DataItem(
      {required this.x, required this.y1, required this.y2, required this.y3});
}

class HomePage extends StatelessWidget {
  HomePage(
      {super.key, required this.tempdata,required this.timedata});
  List tempdata = [];
  List timedata = [];


  // HomePage({Key? key}) : super(key: key);

   @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> barGroups = [];
    List first30Values = [];
    print(tempdata);
    if(tempdata.length > 30) {
       first30Values = tempdata.sublist(0, 30);
    }
    else{
       first30Values = tempdata;
    }

    for (int index = 0; index < first30Values.length; index++) {
      BarChartGroupData barChartGroupData = BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: first30Values[index],
            width: 10,
            color: Colors.amber,
          ),
        ],
      );

      barGroups.add(barChartGroupData);
    }



    return Scaffold(
      appBar: AppBar(
        title: const Text('Barchart'),
      ),
      body: Padding(
       padding: const EdgeInsets.all(30),
       child: BarChart(BarChartData(
         minY: 0,
             borderData: FlBorderData(
               border: const Border(
                 top: BorderSide.none,
                 right: BorderSide.none,
                 left: BorderSide(width: 1),
                 bottom: BorderSide(width: 1),
               )),
           groupsSpace: 10,
           barGroups:  barGroups)),
              ),
    );
  }

}