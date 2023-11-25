import 'package:flutter/material.dart';

import '../../../constants/theme.dart';


class WeatherStationConfig extends StatefulWidget {
  const WeatherStationConfig({super.key});

  @override
  State<WeatherStationConfig> createState() => _WeatherStationConfigState();
}

class _WeatherStationConfigState extends State<WeatherStationConfig> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        color: Color(0xFFF3F3F3),
        child: Column(
          children: [
            SizedBox(height: 5,),
            IconButton(
              color: Colors.black,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.yellow)
              ),
              highlightColor: myTheme.primaryColor,
              onPressed: (){

              },
              icon: Icon(Icons.add),
            ),
            SizedBox(height: 5,),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0XFFF3F3F3),
                    borderRadius: BorderRadius.circular(10)
                ),
                width: double.infinity,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Niagara Weather Station'),
                        Icon(Icons.cancel_presentation,color: Colors.red,)
                      ],
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        child: GridView.builder(
                            padding: EdgeInsets.all(10),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridCount(constraints),mainAxisSpacing: 10,crossAxisSpacing: 10),
                            itemCount: 10,
                            itemBuilder: (context, index){
                              return Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width: 50,
                                      height: 50,
                                      child: Image.asset('${weatherFeatures(index)[1]}'),
                                    ),
                                    Text('${weatherFeatures(index)[0]}',style: TextStyle(fontSize: 12),)
                                  ],
                                ),
                              );
                            }

                        ),
                      ),
                    )
                  ],
                ),
              ),
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
        return ['Temperature','assets/images/temperatures.png'];
      }
      case 1:{
        return ['Humidity','assets/images/humidity.png'];
      }
      case 2:{
        return ['Wind Speed','assets/images/wind-power.png'];
      }
      case 3:{
        return ['Rain','assets/images/rainy.png'];
      }
      case 4:{
        return ['Atm.Pressure','assets/images/atm-pressure.png'];
      }
      case 5:{
        return ['UV-Radiation','assets/images/uv-protection.png'];
      }
      case 6:{
        return ['Alert','assets/images/weather-alert.png'];
      }
      case 7:{
        return ['Daily Forecast','assets/images/daily-forecast.png'];
      }
      case 8:{
        return ['Sunset','assets/images/sunset.png'];
      }
      case 9:{
        return ['W-Prediction','assets/images/weather-prediction.png'];
      }
      default:{
        return ['nothing'];
      }
    }
  }
}
