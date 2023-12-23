import 'dart:async';
import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key, required this.userId, required this.controllerId});
  final userId, controllerId;
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //  0aa7f59482130e8e8384ae8270d79097 // API KEY
  // final WeatherService weatherService = WeatherService();
  late Map<String, dynamic> weatherData;
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    _currentTime = DateTime.now();
    _startTimer();
    super.initState();
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

  @override
  Widget build1(BuildContext context) {
    Color transparentBlue = Colors.transparent.withOpacity(0.5);

    return Scaffold(
        body: Flexible(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(child: Temprature()),
              ],
            ),
          ),
        ));
  }
//assets/images/rain1.gif
  @override
  Widget build(BuildContext context) {
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
                //
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      weather('To Hot', 'UV INDEX', '45 ', 'mW / m2'),
                      weather('Normal', 'MOISTURE', '140 ', 'kPA'),
                      weather('To Heavy', 'RAIN RATE', '40 ', 'mm/hr'),
                      weather('Tropical wet and dry', 'HUMIDITY', '70', '(g/m3)'),
                      weather('becoming "sticky" with muggy evenings',
                          'DEV POINT', '50-60', '°F'),
                      weather('Strong Breeze ', 'WIND SPEED', '13', '(mph)'),
                      weather('Tropical wet and dry', 'RELATIVE PRESSURE',
                          ' 28.6', '(Pa)'),
                      weather('Horizon of the sun', 'SUN RAISE', '06:37', 'am'),
                      weather(
                          'Grateful for this sunset', 'SUN SET', '07:03', 'pm'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget Temprature() {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        color: Colors.transparent.withAlpha(90),
        border: Border.all(color: Colors.black12),
        // borderRadius: BorderRadius.all(Radius.circular(20)),
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
          Container(
            height: 120,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              itemBuilder: (context, index) {
                return index == 0
                    ? Tab('Now', '${index + 5}', '')
                    : Tab('$index PM', '${index + 5}', '');
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
        ]),
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
      onTap: (){
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
                Text('27.5°C',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Mostly clear Partly cloudy conditions expected around 3PM',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                    'O MM in last 24 hours \n Next excepted is 40mm rain on sunday.',
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
          Text(Time, style: TextStyle(color: Colors.white)),
          Container(
            height: 53,
            width: 50,
            child:Text('$temp°C', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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

