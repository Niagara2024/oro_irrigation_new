import 'package:flutter/material.dart';

class WeatherStationView extends StatefulWidget {
  final dynamic weatherStation;
  const WeatherStationView({super.key,required this.weatherStation});

  @override
  State<WeatherStationView> createState() => _WeatherStationViewState();
}

class _WeatherStationViewState extends State<WeatherStationView> {
  Map<String,dynamic> returnGridSize(width,height){
    int count = 0;
    double tSize= 0;
    double oWeatherHeight = 0;
    double iSize = 0;
    if(width > 1100){
      count = 11;
      tSize = 12;
      oWeatherHeight = 200;
      iSize = 45;
    }else if(width > 850){
      count = 8;
      tSize = 12;
      oWeatherHeight = 320;
      iSize = 55;
    }else if(width > 720){
      count = 7;
      tSize = 12;
      oWeatherHeight = 320;
      iSize = 55;
    }else if(width > 620){
      count = 6;
      tSize = 12;
      oWeatherHeight = 320;
      iSize = 55;
    }else if(width > 300){
      count = 5;
      tSize = 10;
      oWeatherHeight = 320;
      iSize = 35;
    }else if(width > 100){
      count = 3;
      tSize = 10;
      oWeatherHeight = 400;
      iSize = 35;
    }
    return {
      'oroWeatherHeight' : oWeatherHeight,
      'count' : count,
      'imageSize' : iSize,
      'textSize' : tSize
    };
  }

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/weather_view.jpg')
            )
        ),
        // color: Color(0xfff3f3f3),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 5,),
            SizedBox(height: 10,),
            Expanded(
                child: ListView.builder(
                    itemCount: widget.weatherStation.length,
                    itemBuilder: (context,index){
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: double.infinity,
                        height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['oroWeatherHeight'],
                        child: Column(
                          children: [
                            Container(
                              height: 40,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('   ORO Weather ${index + 1}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.count(
                                  crossAxisCount: returnGridSize(constraints.maxWidth,constraints.maxHeight)['count'],
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/temperature.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Temperature',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Temperature',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/soilTemperature.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Soil',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Temperature',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Soil',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                          Text('Temperature',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/windDirection.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Wind',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Direction',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),

                                          Text('Wind',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                          Text('Direction',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/windSpeed.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Wind',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Speed',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Wind',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                          Text('Speed',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/rainGauge.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Rain',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Gauge',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Rain',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                          Text('Gauge',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/moisture.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Moisture',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Moisture',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/lux.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Lux',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Lux',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/ldrSensor.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('LDR',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('LDR',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/humidity.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Humidity',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Humidity',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/co2.png'),
                                          ),
                                          // Container(
                                          //   color: Colors.black,
                                          //     child: Text('CO2',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('CO2',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),

                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.transparent.withOpacity(0.25)
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/leafWetness.png'),
                                          ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Leaf',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          // Container(
                                          //     color: Colors.black,
                                          //     child: Text('Wetness',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),)
                                          // ),
                                          Text('Leaf',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                          Text('Wetness',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize'],color: Colors.white),),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                )
            )

          ],
        ),
      );
    },);

  }
  int gridCount(BoxConstraints constraints){
    if(constraints.maxWidth > 1000){
      return 8;
    }else if(constraints.maxWidth > 800){
      return 7;
    }else if(constraints.maxWidth > 600){
      return 5;
    }else if(constraints.maxWidth > 400){
      return 4;
    }else{
      return 3;
    }
  }
  List<dynamic> weatherFeatures(int index){
    switch (index){
      case 0:{
        return ['Temperature','assets/images/temperature.png'];
      }
      case 1:{
        return ['Humidity','assets/images/humidity.png'];
      }
      case 2:{
        return ['Wind Speed','assets/images/windSpeed.png'];
      }
      case 3:{
        return ['Rain','assets/images/windDirection.png'];
      }
      case 4:{
        return ['Atm.Pressure','assets/images/moisture.png'];
      }
      case 5:{
        return ['UV-Radiation','assets/images/rainGauge.png'];
      }
      case 6:{
        return ['Alert','assets/images/soilTemperature.png'];
      }
      case 7:{
        return ['Daily Forecast','assets/images/lux.png'];
      }
      case 8:{
        return ['Sunset','assets/images/co2.png'];
      }
      case 9:{
        return ['W-Prediction','assets/images/ldrSensor.png'];
      }
      case 10:{
        return ['W-Prediction','assets/images/leafWetness.png'];
      }
      default:{
        return ['nothing'];
      }
    }
  }
}
