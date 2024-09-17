import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:oro_irrigation_new/screens/Customer/weather_report.dart';
import '../../constants/theme.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen(
      {super.key, required this.userId, required this.controllerId, required this.deviceID});
  final userId, controllerId, deviceID;
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //  0aa7f59482130e8e8384ae8270d79097 // API KEY
  // final WeatherService weatherService = WeatherService();
  Map<String, dynamic> weatherData = {};
  late Timer _timer;
  late DateTime _currentTime;

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
    List<String> cardname = [
      'UV INDEX',
      'MOISTURE',
      'DEW POINT',
      'WIND SPEED',
      'RAIN RATE',
      'HUMIDITY',
      'REL. PRESSURE',
      'RAIN CHANCE'
    ];
    List<String> cardvalue = [
      '5.6',
      '140',
      '16.3',
      '13',
      '12',
      '70',
      '28.6',
      '12 %'
    ];
    List<String> weekdaylist = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    List<String> imagelist = [
      'assets/images/uv.png',
      'assets/images/soil_temperature_sensor.png',
      'assets/images/windy.png',
      'assets/images/windy.png',
      'assets/images/downpour-rain.png',
      'assets/images/RainRate.png',
      'assets/images/Rel.Press.png',
      'assets/images/downpour-rain.png'
    ];
    int dayselect = selectoption();

    if (weatherData.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (MediaQuery.sizeOf(context).width < 600) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 140,
                      // width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: const RadialGradient(
                            center: Alignment.bottomCenter,
                            radius: 1.5,
                            colors: [
                              Color.fromARGB(255, 131, 180, 237),
                              Color.fromARGB(255, 220, 240, 247),
                            ],
                          )),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Image.asset(
                                    'assets/images/w08.png',
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    'Sunny',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: myTheme.primaryColor),
                                  ),
                                  Text(
                                    '20 °C',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 28,
                                        color: myTheme.primaryColor),
                                  ),

                                ],
                              ),
                              Container(
                                width: 200,
                                height: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/sunrise.png',
                                          width: 30.0,
                                          height: 30.0,
                                          fit: BoxFit.cover,
                                        ),
                                        Text(
                                          '06:00 AM',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/sunset.png',
                                          width: 30.0,
                                          height: 30.0,
                                          fit: BoxFit.cover,
                                        ),
                                        Text(
                                          '06:00 PM',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                          Text(
                            '${DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now())} Coimbatore, TN',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Center(
                        child: Text('Weather Data'),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 300,
                              // color: Colors.red,
                              padding:
                              EdgeInsets.only(left: 30, right: 30, bottom: 10,top: 10),
                              // height: constraints.maxHeight * 0.59,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  print(
                                      '${constraints.maxWidth}constraints.maxWidth / 740 ${constraints.maxWidth / 740}');
                                  print(
                                      '${constraints.maxHeight}constraints.maxHeight');
                                  // int columns = (constraints.maxWidth / 120).floor();
                                  return GridView.builder(
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 40.0,
                                      mainAxisSpacing: 30.0,
                                      childAspectRatio: MediaQuery.of(context).size.width/250,
                                    ),
                                    // childAspectRatio: 1.7),
                                    itemCount: 8,
                                    itemBuilder: (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () {
                                          if (index == 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WeatherReportbar(
                                                        tempdata:
                                                        weatherData['hourly']
                                                        ['temperature_2m'],
                                                        timedata:
                                                        weatherData['hourly']
                                                        ['time'],
                                                        title: 'UV Reports',
                                                        titletype: 'UV RADIATIONS ',
                                                      )),
                                            );
                                          }

                                          else if (index == 2) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WeatherReportbar(
                                                        tempdata:
                                                        weatherData['hourly']
                                                        ['dew_point_2m'],
                                                        timedata:
                                                        weatherData['hourly']
                                                        ['time'],
                                                        title: 'DEW POINT REPORT',
                                                        titletype: 'DEW POINT ',
                                                      )),
                                            );
                                          } else if (index == 3) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WeatherReportbar(
                                                        tempdata:
                                                        weatherData['hourly']
                                                        ['wind_speed_10m'],
                                                        timedata:
                                                        weatherData['hourly']
                                                        ['time'],
                                                        title: 'WIND SPEED REPORT',
                                                        titletype: 'WIND SPEED ',
                                                      )),
                                            );
                                          }
                                          else {
                                            return null;
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              gradient: const RadialGradient(
                                                center: Alignment.bottomLeft,
                                                radius: 1.5,
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 131, 180, 237),
                                                  Color.fromARGB(
                                                      255, 220, 240, 247),
                                                ],
                                              )),
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16, left: 8, right: 8),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        imagelist[index],
                                                        width: 20.0,
                                                        height: 20.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                        child: Text(
                                                          cardname[index],
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: myTheme
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    cardvalue[index],
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.normal,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 20,
                              padding:
                              EdgeInsets.only(left: 30, right: 30, bottom: 5),
                              child: Center(
                                child: const Text(
                                  'Forecast This week',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                            Expanded(
                              child: Container(
                                padding:
                                EdgeInsets.only(left: 30, right: 10, bottom: 1),
                                height: 200,
                                width: double.infinity,
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(7, (index) {
                                            return Container(
                                              height: 100,
                                              width: 100,
                                              margin: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors.lightBlue,
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: const RadialGradient(
                                                  center: Alignment.bottomLeft,
                                                  radius: 1.0,
                                                  colors: [
                                                    Color.fromARGB(255, 131, 180, 237),
                                                    Color.fromARGB(255, 220, 240, 247),
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  Text(weekdaylist[index]),
                                                  Image.asset(
                                                    'assets/images/w08.png',
                                                    width: 30.0,
                                                    height: 30.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        Text('21°C'),
                                                        Text('29°C'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ));
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Row(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const RadialGradient(
                          center: Alignment.bottomCenter,
                          radius: 1.5,
                          colors: [
                            Color.fromARGB(255, 131, 180, 237),
                            Color.fromARGB(255, 220, 240, 247),
                          ],
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          'assets/images/w08.png',
                          width: 150.0,
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          'Sunny',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: myTheme.primaryColor),
                        ),
                        Text(
                          '20 °C',
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 68,
                              color: myTheme.primaryColor),
                        ),
                        Container(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/sunrise.png',
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    '06:00 AM',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Image.asset(
                                    'assets/images/sunset.png',
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    '06:00 PM',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.black,
                        ),
                        Text(
                          '${DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now())}\nCoimbatore, TN',
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            height: 20,
                            padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 5),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Weather',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              // color: Colors.red,
                              padding:
                              EdgeInsets.only(left: 30, right: 30, bottom: 10),
                              // height: constraints.maxHeight * 0.59,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  print(
                                      '${constraints.maxWidth}constraints.maxWidth / 740 ${constraints.maxWidth / 740}');
                                  print(
                                      '${constraints.maxHeight}constraints.maxHeight');
                                  // int columns = (constraints.maxWidth / 120).floor();
                                  return GridView.builder(
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 40.0,
                                      mainAxisSpacing: 30.0,
                                      childAspectRatio: constraints.maxHeight > 500
                                          ? 0.9
                                          : constraints.maxHeight > 450
                                          ? 1.15
                                          : 1.65,
                                    ),
                                    // childAspectRatio: 1.7),
                                    itemCount: 8,
                                    itemBuilder: (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () {
                                          if (index == 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WeatherReportbar(
                                                        tempdata:
                                                        weatherData['hourly']
                                                        ['temperature_2m'],
                                                        timedata:
                                                        weatherData['hourly']
                                                        ['time'],
                                                        title: 'UV Reports',
                                                        titletype: 'UV RADIATIONS ',
                                                      )),
                                            );
                                          }
                                          // else if (index == 1) { Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => WeatherReportbar(
                                          //         tempdata: weatherData['hourly']
                                          //         ['relative_humidity_2m'],
                                          //         timedata: weatherData['hourly']['time'],title: 'HUMIDITY REPORT',titletype: 'HUMIDITY ',
                                          //       )),
                                          // );}
                                          else if (index == 2) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WeatherReportbar(
                                                        tempdata:
                                                        weatherData['hourly']
                                                        ['dew_point_2m'],
                                                        timedata:
                                                        weatherData['hourly']
                                                        ['time'],
                                                        title: 'DEW POINT REPORT',
                                                        titletype: 'DEW POINT ',
                                                      )),
                                            );
                                          } else if (index == 3) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WeatherReportbar(
                                                        tempdata:
                                                        weatherData['hourly']
                                                        ['wind_speed_10m'],
                                                        timedata:
                                                        weatherData['hourly']
                                                        ['time'],
                                                        title: 'WIND SPEED REPORT',
                                                        titletype: 'WIND SPEED ',
                                                      )),
                                            );
                                          }
                                          // else if (index == 4) { Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => WeatherReportbar(
                                          //         tempdata: weatherData['hourly']
                                          //         ['relative_humidity_2m'],
                                          //         timedata: weatherData['hourly']['time'],title: 'HUMIDITY REPORT',titletype: 'HUMIDITY ',
                                          //       )),
                                          // );}
                                          // else if (index == 5) { Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => WeatherReportbar(
                                          //         tempdata: weatherData['hourly']
                                          //         ['relative_humidity_2m'],
                                          //         timedata: weatherData['hourly']['time'],title: 'HUMIDITY REPORT',titletype: 'HUMIDITY ',
                                          //       )),
                                          // );}
                                          // else if (index == 6) { Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => WeatherReportbar(
                                          //         tempdata: weatherData['hourly']
                                          //         ['relative_humidity_2m'],
                                          //         timedata: weatherData['hourly']['time'],title: 'HUMIDITY REPORT',titletype: 'HUMIDITY ',
                                          //       )),
                                          // );}
                                          // else if (index == 8) { Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //       builder: (context) => WeatherReportbar(
                                          //         tempdata: weatherData['hourly']
                                          //         ['relative_humidity_2m'],
                                          //         timedata: weatherData['hourly']['time'],title: 'HUMIDITY REPORT',titletype: 'HUMIDITY ',
                                          //       )),
                                          // );}
                                          else {
                                            return null;
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                              gradient: const RadialGradient(
                                                center: Alignment.bottomLeft,
                                                radius: 1.5,
                                                colors: [
                                                  Color.fromARGB(
                                                      255, 131, 180, 237),
                                                  Color.fromARGB(
                                                      255, 220, 240, 247),
                                                ],
                                              )),
                                          height: 30,
                                          child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 16, left: 16, right: 16),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        imagelist[index],
                                                        width: 30.0,
                                                        height: 30.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                        child: Text(
                                                          cardname[index],
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: myTheme
                                                                  .primaryColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                    cardvalue[index],
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.normal,
                                                        fontSize: 59),
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                            padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 5),
                            child: const Text(
                              'Forecast This week',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            alignment: Alignment.centerLeft,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              // color: Colors.lightGreen,
                              padding:
                              EdgeInsets.only(left: 30, right: 10, bottom: 1),
                              // height: 147,
                              child: LayoutBuilder(
                                builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  // int columns = (constraints.maxWidth / 120).floor();

                                  print(
                                      '${constraints.maxWidth} constraints.maxWidth ${constraints.maxWidth / 830}');
                                  print(
                                      '${constraints.maxHeight}constraints.maxHeight');
                                  return GridView.builder(
                                    gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      crossAxisSpacing: 18.0,
                                      mainAxisSpacing: 8.0,
                                      childAspectRatio: constraints.maxHeight > 180
                                          ? 0.8
                                          : constraints.maxHeight > 150
                                          ? 1.15
                                          : 1.25,
                                    ),
                                    itemCount: 7,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            border: index == dayselect
                                                ? Border.all(
                                                width: 5.0,
                                                color: myTheme.primaryColor)
                                                : null,
                                            gradient: const RadialGradient(
                                              center: Alignment.bottomLeft,
                                              radius: 1.0,
                                              colors: [
                                                Color.fromARGB(255, 131, 180, 237),
                                                Color.fromARGB(255, 220, 240, 247),
                                              ],
                                            )),
                                        child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(weekdaylist[index]),
                                              Image.asset(
                                                'assets/images/w08.png',
                                                width: 30.0,
                                                height: 30.0,
                                                fit: BoxFit.cover,
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Text('21°C'),
                                                    Text('29°C'),
                                                  ],
                                                ),
                                              ),
                                            ]),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          }));
    }
  }

  int selectoption() {
    DateTime nowdate = DateTime.now();
    String day = DateFormat('EEE').format(nowdate);

    if (day == "Mon") {
      return 0;
    } else if (day == "Tue") {
      return 1;
    } else if (day == "Wed") {
      return 2;
    } else if (day == "Thu") {
      return 3;
    } else if (day == "Fri") {
      return 4;
    } else if (day == "Sat") {
      return 5;
    } else if (day == "Sun") {
      return 6;
    } else {
      return 0;
    }
  }

  int gridAlignment(double width) {
    if (width < 850 && width > 500) {
      return 2;
    } else if (width < 500) {
      return 1;
    } else {
      return 3;
    }
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: ListTile(
            title: const Text('HOURLY REPORTS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            trailing: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
              color: Colors.red,
            ),
          ),
          actions: <Widget>[
            // Container(child: Temprature1(),decoration: BoxDecoration(color: Colors.lightBlue,borderRadius: BorderRadius.all(Radius.circular(5)),)),
          ],
        );
      },
    );
  }

  // TODO: implement widget
  Widget Tab(String Time, String temp, String type) {
    double? temp1 = double.tryParse(temp);
    String iconimg = 'assets/images/w04.png';
    if (temp1! < 19) {
      iconimg = 'assets/images/w19.gif';
    } else if (temp1! < 21) {
      iconimg = 'assets/images/w04.png';
    } else {
      iconimg = 'assets/images/w52.gif';
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(Time, style: TextStyle(color: Colors.white)),
              SizedBox(
                height: 50,
                width: 50,
                child: Image.asset(iconimg),
              ),
              // Image.asset(
              //   'assets/images/w04.png',
              //   width: 50,
              //   height: 50,
              //   color: Colors.blue,
              //     fit: BoxFit.fill
              // ),

              Expanded(
                child: Container(
                  color: Colors.white,
                  child: LinearProgressIndicator(
                    backgroundColor: myTheme.primaryColor.withOpacity(0.3),
                    color: Colors.amber,
                    minHeight: 7,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    value: (double.tryParse(temp)! /
                        100), // Update this value to reflect loading progress
                  ),
                ),
              ),
              Text(' $temp°C', style: TextStyle(color: Colors.white)),
            ],
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
}
