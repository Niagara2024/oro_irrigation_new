import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/valve_in_constant.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/water_meter_in_constant.dart';
import 'package:provider/provider.dart';


import '../../../constants/http_service.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import 'analog_sensor_in_constant.dart';
import 'ec_ph_in_constant.dart';
import 'fertilizer_in_constant.dart';
import 'filter_in_constant.dart';
import 'general.dart';
import 'irrigation_lines_in_constant.dart';
import 'level_sensor_in_constant.dart';
import 'main_valve_in_constant.dart';
import 'moisture_sensor_in_constant.dart';

class ConstantInConfig extends StatefulWidget {
  const ConstantInConfig({super.key, required this.userId, required this.controllerId, required this.customerId});
  final userId, controllerId, customerId;

  @override
  State<ConstantInConfig> createState() => _ConstantInConfigState();
}

class _ConstantInConfigState extends State<ConstantInConfig> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserConstant();
  }

  Future<void> getUserConstant() async {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserConstant', {'userId' : widget.customerId,'controllerId' : widget.controllerId});
      var jsonData = jsonDecode(response.body);
      if(jsonData['data']['isNewConfig'] == '0'){
        constantPvd.fetchSettings(jsonData['data']['constant']);
      }
      constantPvd.fetchAll(jsonData['data']);
    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          constantPvd.sendDataToHW();
          HttpService service = HttpService();
          try{
            var response = await service.postRequest('createUserConstant', {
              'userId' : widget.customerId,
              'controllerId' : widget.controllerId,
              'createUser' : widget.userId,
              'general' : '',
              'line' : constantPvd.irrigationLineUpdated,
              // 'line' : [],
              'mainValve' : constantPvd.mainValveUpdated,
              // 'mainValve' : [],
              'valve' : constantPvd.valveUpdated,
              // 'valve' : [],
              'waterMeter' : constantPvd.waterMeterUpdated,
              // 'waterMeter' : [],
              'fertilization' : constantPvd.fertilizerUpdated,
              // 'fertilization' : [],
              'ecPh' : constantPvd.ecPhUpdated,
              // 'ecPh' : [],
              'filtration' : constantPvd.filterUpdated,
              // 'filtration' : [],
              'analogSensor' : constantPvd.analogSensorUpdated,
              // 'analogSensor' : [],
              'moistureSensor' : constantPvd.moistureSensorUpdated,
              // 'moistureSensor' : [],
              'levelSensor' : constantPvd.levelSensorUpdated,
              // 'levelSensor' : []
            });
            var jsonData = jsonDecode(response.body);
            print('jsonData : ${jsonData['code']}');
          }catch(e){
            print(e.toString());
          }
        },
        child: Icon(Icons.send),
      ),
      body: GestureDetector(
        onTap: (){
          constantPvd.generalSelected(-1);
        },
        child: DefaultTabController(
          length: constantPvd.myTabs.length,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Color(0XFFF3F3F3),
                child: TabBar(
                  indicatorColor: myTheme.primaryColor,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  isScrollable: true,
                    tabs: [
                      for(var i = 0;i < constantPvd.myTabs.length;i++)
                        Tab(
                          text: '${constantPvd.myTabs[i]}',
                        ),
                    ]
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                    children: [
                      // ...dynamicTab()
                      GeneralInConstant(),
                      IrrigationLinesConstant(),
                      MainValveConstant(),
                      ValveConstant(),
                      WaterMeterConstant(),
                      FertilizerConstant(),
                      EcPhInConstant(),
                      FilterConstant(),
                      AnalogSensorConstant(),
                      MoistureSensorInConstant(),
                      LevelSensorInConstant()
                    ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  List<Widget> dynamicTab(){
    List<Widget> tabs = [];
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    for(var i in constantPvd.myTabs){
      if(i == 'General'){
        tabs.add( GeneralInConstant());
      }else if(i == 'Lines'){
        tabs.add( IrrigationLinesConstant());

      }else if(i == 'Main valve'){
        tabs.add( MainValveConstant());

      }else if(i == 'Water meter'){
        tabs.add( WaterMeterConstant());

      }else if(i == 'Fertilizers'){
        tabs.add( FertilizerConstant());

      }else if(i == 'EC/PH'){
        tabs.add( EcPhInConstant());

      }else if(i == 'Filters'){
        tabs.add( FilterConstant());

      }else if(i == 'Analog sensor'){
        tabs.add( AnalogSensorConstant());

      }else if(i == 'Moisture sensor'){
        tabs.add( MoistureSensorInConstant());

      }else if(i == 'Level sensor'){
        tabs.add(LevelSensorInConstant());

      }
    }
    return tabs;
  }
}

