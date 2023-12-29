import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oro_irrigation_new/screens/Customer/weather_barchart.dart';
import 'package:oro_irrigation_new/screens/Customer/weather_report.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen(
      {super.key, required this.userId, required this.controllerId});
  final userId, controllerId;
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //  0aa7f59482130e8e8384ae8270d79097 // API KEY
  // final WeatherService weatherService = WeatherService();
  Map<String, dynamic> weatherData = {};
  late Timer _timer;
  late DateTime _currentTime;
  List<FlSpot> spots = [];

  @override
  void initState() {
    _currentTime = DateTime.now();
    _startTimer();
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

//assets/images/rain1.gif
  @override
  Widget build(BuildContext context) {
    if (weatherData.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        body: AnimatedBackground(
          assetImagePath: 'assets/GiffFile/c2.gif',
          child: SingleChildScrollView(
            child: Container(
              // color: Colors.black12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: weathermain(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        //dew_point_2m hourly
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WeatherBar(
                                      tempdata: weatherData['hourly']
                                      ['temperature_2m'],
                                      timedata: [],title: 'UV Reports'
                                  )),
                            );
                          },
                          child: weather(
                              'To Hot',
                              'UV INDEX',
                              '${weatherData['daily']['uv_index_max'][0]}',
                              'mW / m2'),
                        ),
                        weather('Normal', 'MOISTURE', '140 ', 'kPA'),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WeatherReport(
                                      tempdata: weatherData['hourly']
                                      ['rain'],
                                      timedata: weatherData['hourly']
                                      ['time'],title: 'RAIN RATE REPORT',
                                    )),
                              );
                            },
                            child: weather(
                                'To Heavy', 'RAIN RATE', '40 ', 'mm/hr')),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WeatherReport(
                                    tempdata: weatherData['hourly']
                                    ['relative_humidity_2m'],
                                    timedata: weatherData['hourly']['time'],title: 'HUMIDITY REPORT',
                                  )),
                            );
                          },
                          child: weather('Tropical wet and dry', 'HUMIDITY',
                              '70', '(g/m3)'),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WeatherReport(
                                    tempdata: weatherData['hourly']
                                    ['dew_point_2m'],
                                    timedata: weatherData['hourly']['time'],title: 'DEW POINT REPORT',
                                  )),
                            );
                          },
                          child: weather(
                              'becoming "sticky" with muggy evenings',
                              'DEW POINT',
                              '${weatherData['hourly']['dew_point_2m'][0]}',
                              '°C'),
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WeatherReport(
                                      tempdata: weatherData['hourly']
                                      ['wind_speed_10m'],
                                      timedata: weatherData['hourly']
                                      ['time'],title: 'WIND SPEED REPORT',
                                    )),
                              );
                            },
                            child: weather('Strong Breeze ', 'WIND SPEED', '13',
                                '(mph)')), //
                        weather('Tropical wet and dry', 'RELATIVE PRESSURE',
                            ' 28.6', '(Pa)'),
                        weather(
                            'Horizon of the sun', 'SUN RAISE', '06:37', 'am'),
                        weather('Grateful for this sunset', 'SUN SET', '07:03',
                            'pm'),
                        // chart(weatherData['hourly']['temperature_2m'],weatherData['hourly']['temperature_2m']),
                        // scrollchart(context)
                      ],
                    ),
                  ),
                  // Container(child: chart(),)
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget Temprature() {
    return Expanded(
      child: Container(
        height: 120,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: Colors.transparent.withAlpha(90),
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
                'Cloudy Conditions will continue for the rest of the day. wind gusts are up to 15 kph.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Container(
              color: Colors.white,
              height: 0.5,
              width: double.infinity,
            ),
            Expanded(
              child: Container(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: weatherData['hourly']['time'].length,
                  itemBuilder: (context, index) {
                    List<String> part =
                    weatherData['hourly']['time'][index].split('T');
                    List<String> parts = part.isNotEmpty
                        ? weatherData['hourly']['time'][index].split('T')
                        : ['00:00', '00:00'];
                    return Tab(
                        '${parts[1]}',
                        '${weatherData['hourly']['temperature_2m'][index]}',
                        '');
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      color: Colors.grey,
                      thickness: 10,
                      height: 0,
                    );
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget weather(String desc, String title, String value, String measure) {
    return Container(
      height: 160,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.transparent.withAlpha(90),
        border: Border.all(color: Colors.black12),
        // image: DecorationImage(
        //    image: AssetImage(
        //        'assets/images/ sun.gif'),
        //    fit: BoxFit.cover,
        //  ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$title',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Container(
                color: Colors.white,
                height: 0.5,
                width: double.infinity,
              ),
              Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('$measure',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ]),
      ),
    );
  }

  Widget weathermain() {
    DateTime currentDateTime = DateTime.now();

    return GestureDetector(
      onTap: () {
        showAlert(context);
      },
      child: Container(
        height: 160,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: Colors.transparent.withAlpha(70),
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    ' ${currentDateTime.day}/${currentDateTime.month}/${currentDateTime.year} ${currentDateTime.hour}:${currentDateTime.minute}:${currentDateTime.second}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('${weatherData['daily']['temperature_2m_max'][0]} °C',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Text('Mostly clear Partly cloudy conditions expected',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    '${weatherData['daily']['rain_sum'][0]} MM in last 24 hours ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
        ),
      ),
    );
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hourly report'),
          actions: <Widget>[
            Container(color: Colors.lightBlue, child: Temprature()),
          ],
        );
      },
    );
  }

  // TODO: implement widget
  Widget Tab(String Time, String temp, String type) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text(Time, style: TextStyle(color: Colors.white)),
          Container(
            // height: 53,
            // width: 50,
            child: Text('$temp°C', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=11.56&longitude=76.47&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,rain,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,daylight_duration,sunshine_duration,uv_index_max,rain_sum'));
      if (response.statusCode == 200) {
        weatherData = json.decode(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Widget chart(List data1, List data2) {
    List<FlSpot> dummyData1 = [];
    List<FlSpot> dummyData2 = [];
    for (int index = 0; index < data1.length; index++) {
      dummyData1.add(FlSpot(index.toDouble(), data1[index]));
    }
    for (int index = 0; index < data2.length; index++) {
      dummyData2.add(FlSpot(index.toDouble(), data2[index]));
    }
    return Container(
      color: Colors.blue.withAlpha(10),
      height: 200,
      // width: 100,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // The red line
            LineChartBarData(
              spots: dummyData1,
              isCurved: false,
              barWidth: 3,
              color: Colors.indigo,
            ),
            // The orange line
            LineChartBarData(
              spots: dummyData2,
              isCurved: false,
              barWidth: 3,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget scrollchart(BuildContext context) {
    List<FlSpot> chartData = List.generate(
        100, (index) => FlSpot(index.toDouble(), index.toDouble()));

    return ListView(
      scrollDirection: Axis.horizontal, // Make the list scroll horizontally
      children: [
        Container(
          width: 800, // Set width to ensure chart's width
          height: 300, // Set height as needed
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: chartData,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final String assetImagePath;

  AnimatedBackground({required this.child, required this.assetImagePath});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    animation = Tween<double>(begin: 0, end: 1).animate(controller);

    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            widget.assetImagePath,
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: widget.child, // Child widget remains static
        ),
      ],
    );
  }
}