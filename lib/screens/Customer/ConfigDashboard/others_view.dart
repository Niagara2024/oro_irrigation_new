import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/pumpView.dart';

import '../../../constants/theme.dart';

class OthersView extends StatefulWidget {
  final dynamic others;
  const OthersView({super.key,required this.others});

  @override
  State<OthersView> createState() => _OthersViewState();
}

class _OthersViewState extends State<OthersView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,constraints){
      return Column(
        children: [
          SizedBox(height: 5,),
          Row(
            children: [
              Container(
                width: 230,
                height: 50,
                color: myTheme.primaryColor,
                child: const Center(
                  child: Text('object',style: TextStyle(color: Colors.white)),
                ),
              ),

              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('Connected to',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('Reference no',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('O/P',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('I/P',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('I/0 Type',style: TextStyle(color: Colors.white),),
                    ),
                  )
              ),
            ],
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 5,),
                    if(widget.others['connSoilTempSensor'].isNotEmpty)
                      expandAndCollaps('connTempSensorVisible','temperature','Temperature',Colors.indigo),
                    for(var i = 0;i < widget.others['connTempSensor'].length;i++)
                      if(widget.others['connTempSensorVisible'])
                        object('Temp. Sensor ${i+1}',false,widget.others['connTempSensor'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connSoilTempSensor'].isNotEmpty)
                      expandAndCollaps('connSoilTempSensorVisible','soilTemperature','Soil Temperature',Colors.indigo),
                    for(var i = 0;i < widget.others['connSoilTempSensor'].length;i++)
                      if(widget.others['connSoilTempSensorVisible'])
                        object('Soil Temp. Sensor ${i+1}',false,widget.others['connSoilTempSensor'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connHumidity'].isNotEmpty)
                      expandAndCollaps('connHumidityVisible','humidity','Humidity',Colors.indigo),
                    for(var i = 0;i < widget.others['connHumidity'].length;i++)
                      if(widget.others['connHumidityVisible'])
                        object('humidity Sensor ${i+1}',false,widget.others['connHumidity'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connCo2'].isNotEmpty)
                      expandAndCollaps('connCo2Visible','Co2','co2',Colors.indigo),
                    for(var i = 0;i < widget.others['connCo2'].length;i++)
                      if(widget.others['connCo2Visible'])
                        object('Co2 Sensor ${i+1}',false,widget.others['connCo2'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connLux'].isNotEmpty)
                      expandAndCollaps('connLuxVisible','lux','Lux',Colors.indigo),
                    for(var i = 0;i < widget.others['connLux'].length;i++)
                      if(widget.others['connLuxVisible'])
                        object('Lux Sensor ${i+1}',false,widget.others['connLux'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connLdr'].isNotEmpty)
                      expandAndCollaps('connLdrVisible','ldrSensor','LDR',Colors.indigo),
                    for(var i = 0;i < widget.others['connLdr'].length;i++)
                      if(widget.others['connLdrVisible'])
                        object('Ldr Sensor ${i+1}',false,widget.others['connLdr'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connWindSpeed'].isNotEmpty)
                      expandAndCollaps('connWindSpeedVisible','windSpeed','Wind Speed',Colors.indigo),
                    for(var i = 0;i < widget.others['connWindSpeed'].length;i++)
                      if(widget.others['connWindSpeedVisible'])
                        object('wind speed ${i+1}',false,widget.others['connWindSpeed'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connWindDirection'].isNotEmpty)
                      expandAndCollaps('connWindDirectionVisible','windDirection','Wind Direction',Colors.indigo),
                    for(var i = 0;i < widget.others['connWindDirection'].length;i++)
                      if(widget.others['connWindDirectionVisible'])
                        object('wind direction ${i+1}',false,widget.others['connWindDirection'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connWindDirection'].isNotEmpty)
                      expandAndCollaps('connWindDirectionVisible','windDirection','Wind Direction',Colors.indigo),
                    for(var i = 0;i < widget.others['connWindDirection'].length;i++)
                      if(widget.others['connWindDirectionVisible'])
                        object('wind direction ${i+1}',false,widget.others['connWindDirection'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['connRainGauge'].isNotEmpty)
                      expandAndCollaps('connRainGaugeVisible','rainGauge','Rain Gauge',Colors.indigo),
                    for(var i = 0;i < widget.others['connRainGauge'].length;i++)
                      if(widget.others['connRainGaugeVisible'])
                        object('Rain Gauge ${i+1}',false,widget.others['connRainGauge'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['totalAnalogSensor'].isNotEmpty)
                      expandAndCollaps('totalAnalogSensorVisible','analog_sensor','Analog Sensor',Colors.indigo),
                    for(var i = 0;i < widget.others['totalAnalogSensor'].length;i++)
                      if(widget.others['totalAnalogSensorVisible'])
                        object('AS ${i+1}',false,widget.others['totalAnalogSensor'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['totalContact'].isNotEmpty)
                      expandAndCollaps('totalContactVisible','contact','Contact',Colors.indigo),
                    for(var i = 0;i < widget.others['totalContact'].length;i++)
                      if(widget.others['totalContactVisible'])
                        object('CNT ${i+1}',false,widget.others['totalContact'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['totalAgitator'].isNotEmpty)
                      expandAndCollaps('totalAgitatorVisible','agitator','Agitator',Colors.indigo),
                    for(var i = 0;i < widget.others['totalAgitator'].length;i++)
                      if(widget.others['totalAgitatorVisible'])
                        object('agitator ${i+1}',true,widget.others['totalAgitator'][i]),
                    const SizedBox(height: 5,),

                    if(widget.others['totalSelector'].isNotEmpty)
                      expandAndCollaps('totalSelectorVisible','selector','Selector',Colors.indigo),
                    for(var i = 0;i < widget.others['totalSelector'].length;i++)
                      if(widget.others['totalSelectorVisible'])
                        object('selector ${i+1}',true,widget.others['totalSelector'][i]),
                    SizedBox(height: 50,),

                  ],
                ),
              ),
            ),
          ),


        ],
      );
    });
  }
  bool check(data,bool inside,[String? title]){
    print(data);
    bool item = false;
    if(inside == false){
      for(var i in data){
        if(i.isNotEmpty){
          item = true;
        }
      }
    }else{
      for(var i in data){
        if(i[title].isNotEmpty){
          item = true;
        }
      }
    }
    return item;
  }

  Widget expandAndCollaps(String title, String image,String name,[Color? color]){
    print(widget.others);
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: Row(
        children: [
          SizedBox(width: 5,),
          IconButton(
              onPressed: (){
                setState(() {
                  widget.others[title] = !widget.others[title];
                });
              }, icon: Icon(widget.others[title] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset('assets/images/$image.png'),
          ),
          SizedBox(width: 5,),
          Text('$name',style: TextStyle(color: Colors.black),)
        ],
      ),
    );

  }
  Widget object(String name,bool output,data){
    print(data);
    return data.isEmpty ? Container() : SizedBox(
      // color: color,
      width: double.infinity,
      height: 20,
      child: Row(
        children: [
          connectionName(name,Colors.black),
          expand(data['rtu'],Colors.black),
          expand(data['rfNo'],Colors.black),
          expand(output ? data['output'] : '-',Colors.black),
          expand(!output ? data['input'] : '-',Colors.black),

          if(output)
            expand('1',Colors.black)
          else
            expand(data['input_type'],Colors.black),
        ],
      ),
    );
  }

}
