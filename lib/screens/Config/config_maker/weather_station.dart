import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';

import '../../../constants/theme.dart';
import '../../../state_management/config_maker_provider.dart';


class WeatherStationConfig extends StatefulWidget {
  const WeatherStationConfig({super.key});

  @override
  State<WeatherStationConfig> createState() => _WeatherStationConfigState();
}

class _WeatherStationConfigState extends State<WeatherStationConfig> {
  @override

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
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        padding: EdgeInsets.all(10),
        color: Color(0xFFF3F3F3),
        child: Column(
          children: [
            SizedBox(height: 5,),
            Row(
              children: [
                InkWell(
                  onTap: (){
                    if(configPvd.oRoWeatherForStation.length == 0){
                      showDialog(
                          context: context,
                          builder: (context){
                            return showingMessage('Oops!', 'The weather station limit is achieved!..', context);
                          }
                      );
                    }else{
                      configPvd.weatherStationFuntionality(['add']);
                    }
                  },
                  child: Container(
                    width: 180,
                    height: 50,
                    child: Center(
                      child: Text('Add ORO Weather(${configPvd.oRoWeatherForStation.length})',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w100),),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: myTheme.primaryColor
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10,),
            Expanded(
                child: ListView.builder(
                    itemCount: configPvd.weatherStation.length,
                    itemBuilder: (context,index){
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        color: Colors.indigo.shade50,
                        width: double.infinity,
                        height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['oroWeatherHeight'],
                        child: Column(
                          children: [
                            Container(
                              color: Colors.indigo.shade50,
                              height: 40,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('   ORO Weather ${index + 1}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.black87),),
                                  IconButton(
                                      onPressed: (){
                                        configPvd.weatherStationFuntionality(['delete',index]);
                                      },
                                      icon: Icon(Icons.cancel_presentation_outlined,size: 25,color: Colors.red,)
                                  )
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
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/temperature.png'),
                                          ),
                                          Text('Temperature',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/soilTemperature.png'),
                                          ),
                                          Text('Soil',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                          Text('Temperature',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/windDirection.png'),
                                          ),
                                          Text('Wind',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                          Text('Direction',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/windSpeed.png'),
                                          ),
                                          Text('Wind',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                          Text('Speed',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/rainGauge.png'),
                                          ),
                                          Text('Rain',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                          Text('Gauge',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/moisture.png'),
                                          ),
                                          Text('Moisture',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/lux.png'),
                                          ),
                                          Text('Lux',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/ldrSensor.png'),
                                          ),
                                          Text('LDR',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/humidity.png'),
                                          ),
                                          Text('Humidity',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/co2.png'),
                                          ),
                                          Text('CO2',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.white
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            height: returnGridSize(constraints.maxWidth,constraints.maxHeight)['imageSize'],
                                            child: Image.asset('assets/images/leafWetness.png'),
                                          ),
                                          Text('Leaf',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
                                          Text('Wetness',style: TextStyle(fontSize: returnGridSize(constraints.maxWidth,constraints.maxHeight)['textSize']),),
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