import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/valve_in_constant.dart';
import 'package:oro_irrigation_new/screens/Config/Constant/water_meter_in_constant.dart';
import 'package:provider/provider.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/constant_provider.dart';
import 'analog_sensor_in_constant.dart';
import 'fertilizer_in_constant.dart';
import 'filter_in_constant.dart';
import 'general.dart';
import 'irrigation_lines_in_constant.dart';
import 'main_valve_in_constant.dart';

class ConstantInConfig extends StatefulWidget {
  const ConstantInConfig({super.key, required this.userID, required this.customerID, required this.siteID});
  final int userID, customerID, siteID;

  @override
  State<ConstantInConfig> createState() => _ConstantInConfigState();
}

class _ConstantInConfigState extends State<ConstantInConfig>
{
  @override
  void initState() {
    super.initState();
    getConstantDetails();
  }

  Future<void> getConstantDetails() async
  {
    var configPvd = Provider.of<ConstantProvider>(context, listen: false);

    Map<String, Object> body = {"userId" : widget.customerID, "controllerId" : widget.siteID};
    final response = await HttpService().postRequest("getUserConstant", body);
    if (response.statusCode == 200)
    {
      var jsonData = jsonDecode(response.body);
      configPvd.fetchAll(jsonData['data']);
    }
    else{
      //_showSnackBar(response.body);
    }

  }

  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Scaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          HttpService service = HttpService();
          try{
            print('sended data is 123: ${jsonEncode({
              'userId' : 8,
              'controllerId' : 4,
              'createUser' : 8,
              'line' : constantPvd.irrigationLines,
              'mainValve' : constantPvd.mainValve,
              'valve' : constantPvd.valve,
              'fertilization' : constantPvd.fertilizer,
              'filtration' : constantPvd.filter,
              'analogSensor' : constantPvd.analogSensor,
              'waterMeter' : constantPvd.waterMeter
            })}');
            var response = await service.postRequest('createUserConstant', {
              'userId' : 8,
              'controllerId' : 4,
              'createUser' : 8,
              'line' : constantPvd.irrigationLines,
              'mainValve' : constantPvd.mainValve,
              'valve' : constantPvd.valve,
              'fertilization' : constantPvd.fertilizer,
              'filtration' : constantPvd.filter,
              'analogSensor' : constantPvd.analogSensor,
              'waterMeter' : constantPvd.waterMeter
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
                      GeneralInConstant(),
                      IrrigationLinesConstant(),
                      MainValveConstant(),
                      ValveConstant(),
                      WaterMeterConstant(),
                      FertilizerConstant(),
                      FilterConstant(),
                      AnalogSensorConstant()
                    ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
