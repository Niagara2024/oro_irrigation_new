import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/pump_in_constant.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/valve_in_constant.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/water_meter_in_constant.dart';
import 'package:provider/provider.dart';


import '../../../constants/http_service.dart';
import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import 'AlarmInConstant.dart';
import 'CriticalAlarmInConstant.dart';
import 'FinishInConstant.dart';
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
  const ConstantInConfig({super.key, required this.userId, required this.deviceId, required this.customerId, required this.controllerId});
  final userId, deviceId, customerId, controllerId;

  @override
  State<ConstantInConfig> createState() => _ConstantInConfigState();
}

class _ConstantInConfigState extends State<ConstantInConfig> with SingleTickerProviderStateMixin{
  late TabController myController ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myController = TabController(length: 14, vsync: this);
    //MqttWebClient().init();
    getUserConstant();
  }

  Future<void> getUserConstant() async {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    // constantPvd.sendDataToHW();
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserConstant', {'userId' : widget.customerId, 'controllerId' : widget.controllerId});
      var jsonData = jsonDecode(response.body);
      print('jsonData : ${jsonEncode(jsonData)}');
      // if(jsonData['data']['isNewConfig'] == '0'){
      //   constantPvd.fetchSettings(jsonData['data']['constant']);
      // }
      constantPvd.fetchSettings(jsonData['data']['constant']);
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
      floatingActionButton: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.small(
              heroTag: 'btn 1',
              tooltip: 'Previous',
              backgroundColor: myController.index == 0 ? Colors.white54 : Colors.white,
              onPressed: myController.index == 0
                  ? null
                  : () {
                if (myController.index != 0) {
                  setState(() {
                    myController.animateTo(myController.index - 1);
                  });
                }
              },
              child: const Icon(Icons.arrow_back_outlined),
            ),
            FloatingActionButton.small(
              heroTag: 'btn 2',
              tooltip: 'Next',
              // backgroundColor: configPvd.selectedTab == 11 ? Colors.white54 : myTheme1.colorScheme.primary,
              backgroundColor: myController.index == 13 ? Colors.white54 : Colors.white,
              onPressed: myController.index == 13
                  ? null
                  : () {
                if (myController.index != 13) {
                  setState(() {
                    myController.animateTo(myController.index + 1);
                  });
                  // configPvd.editSelectedTab(configPvd.selectedTab + 1);
                }
              },
              child: const Icon(Icons.arrow_forward_outlined),
            ),
          ],
        ),
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
                    controller: myController,
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
                    controller: myController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      // ...dynamicTab()
                      GeneralInConstant(),
                      const PumpInConstant(),
                      const IrrigationLinesConstant(),
                      const MainValveConstant(),
                      const ValveConstant(),
                      const WaterMeterConstant(),
                      const FertilizerConstant(),
                      const EcPhInConstant(),
                      // const FilterConstant(),
                      const AnalogSensorConstant(),
                      const MoistureSensorInConstant(),
                      const LevelSensorInConstant(),
                      const AlarmInConstant(),
                      const CriticalAlarmInConstant(),
                      FinishInConstant(userId: widget.userId, controllerId: widget.controllerId, customerId: widget.customerId,)
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