import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../constants/http_service.dart';
import '../../../constants/theme.dart';
import '../../../state_management/constant_provider.dart';

class FinishInConstant extends StatefulWidget {
  const FinishInConstant({super.key, required this.userId, required this.controllerId, required this.customerId});
  final userId, controllerId, customerId;

  @override
  State<FinishInConstant> createState() => _FinishInConstantState();
}

class _FinishInConstantState extends State<FinishInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Container(
      color: Color(0xFFF3F3F3),
      child: Center(
        child: InkWell(
          onTap: ()async{

            showDialog(context: context, builder: (context){
              return Consumer<ConstantProvider>(builder: (context,constantPvd,child){
                return AlertDialog(
                  title: Text(constantPvd.wantToSendData == 0 ? 'Send to server' : constantPvd.wantToSendData == 1 ?  'Sending.....' : constantPvd.wantToSendData == 2 ? 'Success...' : 'Oopss!!!',style: TextStyle(color: constantPvd.wantToSendData == 3 ? Colors.red : Colors.green),),
                  content: constantPvd.wantToSendData == 0 ? Text('Are you sure want to send data ? ') : SizedBox(
                    width: 200,
                    height: 200,
                    child: constantPvd.wantToSendData == 2 ? Image.asset(constantPvd.wantToSendData == 3 ? 'assets/images/serverError.png' : 'assets/images/success.png') :LoadingIndicator(
                      indicatorType: Indicator.pacman,
                    ),
                  ),
                  actions: [
                    if(constantPvd.wantToSendData == 0)
                      InkWell(
                        onTap: ()async{
                          constantPvd.editWantToSendData(1);
                          HttpService service = HttpService();
                          try{
                            var response = await service.postRequest('createUserConstant', {
                              'userId' : widget.customerId,
                              'controllerId' : widget.controllerId,
                              'createUser' : widget.userId,
                              'general' : {
                                'resetTime' : constantPvd.general[0][1],
                                'fertilizerLeakageLimit' : constantPvd.general[1][1],
                                'runListLimit' : constantPvd.general[2][1],
                                'currentIrrigationDay' : constantPvd.general[3][1],
                                'noPressureDelay' : constantPvd.general[4][1],
                                'waterPulseBeforeDosing' : constantPvd.general[5][1],
                                'commonDosingCoefficient' : constantPvd.general[6][1],
                              },
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
                              // 'levelSensor' : [],
                              'normalAlarm' : constantPvd.alarmUpdated,
                              'criticalAlarm' : constantPvd.criticalAlarmUpdated,
                            });
                            var jsonData = jsonDecode(response.body);
                            if(jsonData['code'] == 200){
                              Future.delayed(Duration(seconds: 1), () {
                                constantPvd.editWantToSendData(2);
                              });

                            }else{
                              constantPvd.editWantToSendData(3);
                            }
                            print('jsonData : ${jsonData['code']}');
                            // constantPvd.sendDataToHW();
                            //MqttWebClient().publishMessage('AppToFirmware/${widget.controllerId}', jsonEncode(constantPvd.sendDataToHW()));
                          }catch(e){
                            print(e.toString());
                          }
                          // store.writeDataInJsonFile('configFile', constantPvd.sendData());
                          Future.delayed(Duration(seconds: 10), () {
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          child: Center(
                            child: Text('Yes',style: TextStyle(color: Colors.white,fontSize: 16),
                            ),
                          ),
                          width: 80,
                          height: 30,
                          color: myTheme.primaryColor,
                        ),
                      ),
                    if([2,3].contains(constantPvd.wantToSendData))
                      InkWell(
                        onTap: (){
                          constantPvd.editWantToSendData(0);
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Center(
                            child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                            ),
                          ),
                          width: 80,
                          height: 30,
                          color: myTheme.primaryColor,
                        ),
                      )
                  ],
                );
              });

            });
          },
          child: Container(
            width: 250,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/sendToServer.png')),
                Text('Send',style: TextStyle(fontSize: 20,color: Colors.black),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}