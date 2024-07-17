import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../constants/http_service.dart';

class SensorHourlyLogs extends StatefulWidget {
  const SensorHourlyLogs({Key? key, required this.userId, required this.controllerId}) : super(key: key);
  final int userId, controllerId;

  @override
  State<SensorHourlyLogs> createState() => _SensorHourlyLogsState();
}

class _SensorHourlyLogsState extends State<SensorHourlyLogs> {
  DateTime selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> sensorHourlyLogs = {};

  @override
  void initState() {
    super.initState();
    getSensorHourlyLogs(widget.userId, widget.controllerId, selectedDate);
  }

  Future<void> getSensorHourlyLogs(userId, controllerId, selectedDate) async {
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    Map<String, Object> body = {
      "userId": userId,
      "controllerId": controllerId,
      "fromDate": date,
      "toDate": date
    };

    final response = await HttpService().postRequest("getUserSensorHourlyLog", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        try {
          Map<String, dynamic> jsonMap = data;
          filterData(jsonMap);
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  void filterData(Map<String, dynamic> jsonMap) {
    sensorHourlyLogs = {};

    for (var record in jsonMap['data']) {
      for (var hour in record.keys.where((k) => (k as String).startsWith('hour'))) {
        var filteredHourData = (record[hour] as List<dynamic>)
            .map((entry) => entry as Map<String, dynamic>)
            .toList();
        sensorHourlyLogs[hour] = filteredHourData;
      }
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    List<LineSeries<ChartData, String>> msSeriesList = [];

    // Extract all unique sensor IDs from the data
    Set<String> sensorIds = sensorHourlyLogs.values
        .expand((hourData) => hourData)
        .map((data) => data['Id'] as String)
        .toSet();

    // Iterate over all unique sensor IDs to create a series for each
    for (String sensorId in sensorIds) {
      List<ChartData> msChartData = [];

      int i = 0;

      // Collect data for this sensor ID across all hours
      for (var hourData in sensorHourlyLogs.values.expand((e) => e)) {
        if (hourData['Id'] == sensorId) {
          msChartData.add(ChartData('${i++}', double.tryParse(hourData['Value'].toString()) ?? 0.0));
        }
      }

      msSeriesList.add(LineSeries<ChartData, String>(
        dataSource: msChartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: sensorId,
      ));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Data Chart')),
      body: sensorHourlyLogs.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(),
          legend: const Legend(isVisible: true),
          series: msSeriesList,
        ),
      )
          : const Center(child: Text('No data available')),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
