import 'dart:convert' as convert;
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../Models/create_json_file.dart';
import '../../../constants/MQTTManager.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/config_maker_provider.dart';


class FinishPageConfigMaker extends StatefulWidget {
  const FinishPageConfigMaker({super.key, required this.userId, required this.customerID, required this.controllerId,required this.imeiNo});
  final int userId, controllerId, customerID;
  final String imeiNo;

  @override
  State<FinishPageConfigMaker> createState() => _FinishPageConfigMakerState();
}

class _FinishPageConfigMakerState extends State<FinishPageConfigMaker> {
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Container(
      color: Color(0xFFF3F3F3),
      child: Center(
        child: InkWell(
          onTap: ()async{
            print('userId : ${widget.customerID}');
            print('createUser : ${widget.customerID}');
            print('controllerId : ${widget.controllerId}');
            showDialog(context: context, builder: (context){
              return Consumer<ConfigMakerProvider>(builder: (context,configPvd,child){
                for(var i in configPvd.sourcePumpUpdated){
                  if(i['waterSource'] == '-'){
                    return AlertDialog(
                      title: Text('Please assign water source',style: TextStyle(color: Colors.red,fontSize: 15,fontWeight: FontWeight.w900),),
                      content: Text('Click ok to go source pump tab',style: TextStyle(fontSize: 14)),
                      actions: [
                        InkWell(
                          onTap: (){
                            configPvd.editSelectedTab(1);
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Center(
                              child: Text('Ok',style: TextStyle(color: Colors.white,fontSize: 16),
                              ),
                            ),
                            width: 80,
                            height: 30,
                            color: myTheme.primaryColor,
                          ),
                        ),
                      ],
                    );
                  }
                }
                return AlertDialog(
                  title: Text(configPvd.wantToSendData == 0 ? 'Send to server' : configPvd.wantToSendData == 1 ?  'Sending.....' : configPvd.wantToSendData == 2 ? 'Success...' : 'Oopss!!!',style: TextStyle(color: configPvd.wantToSendData == 3 ? Colors.red : Colors.green),),
                  content: configPvd.wantToSendData == 0 ? Text('Are you sure want to send data ? ') : SizedBox(
                    width: 200,
                    height: 200,
                    child: configPvd.wantToSendData == 2 ? Image.asset(configPvd.wantToSendData == 3 ? 'assets/images/serverError.png' : 'assets/images/success.png') :LoadingIndicator(
                      indicatorType: Indicator.pacman,
                    ),
                  ),
                  actions: [
                    if(configPvd.wantToSendData == 0)
                      InkWell(
                        onTap: ()async{
                          configPvd.editWantToSendData(1);
                          try{
                            configPvd.sendData();
                            configPvd.configFinish();
                            print('widget.customerID : ${widget.customerID}');
                            print('widget.userId : ${widget.userId}');
                            print('widget.controllerId : ${widget.controllerId}');
                            var body = {
                              "userId" : widget.customerID,
                              "createUser" : widget.userId,
                              "controllerId" : widget.controllerId,
                              "productLimit" : {
                                'oWeather' : configPvd.oWeather,
                                'oRoWeatherForStation' : configPvd.oRoWeatherForStation,
                                'totalTempSensor' : configPvd.totalTempSensor,
                                'connTempSensor' : configPvd.connTempSensor,
                                'totalSoilTempSensor' : configPvd.totalSoilTempSensor,
                                'connSoilTempSensor' : configPvd.connSoilTempSensor,
                                'totalHumidity' : configPvd.totalHumidity,
                                'connHumidity' : configPvd.connHumidity,
                                'totalCo2' : configPvd.totalCo2,
                                'connCo2' : configPvd.connCo2,
                                'totalLux' : configPvd.totalLux,
                                'connLux' : configPvd.connLux,
                                'totalLdr' : configPvd.totalLdr,
                                'connLdr' : configPvd.connLdr,
                                'totalWindSpeed' : configPvd.totalWindSpeed,
                                'connWindSpeed' : configPvd.connWindSpeed,
                                'totalWindDirection' : configPvd.totalWindDirection,
                                'connWindDirection' : configPvd.connWindDirection,
                                'totalRainGauge' : configPvd.totalRainGauge,
                                'connRainGauge' : configPvd.connRainGauge,
                                'totalLeafWetness' : configPvd.totalLeafWetness,
                                'connLeafWetness' : configPvd.connLeafWetness,
                                'totalWaterSource' : configPvd.totalWaterSource,
                                'totalWaterMeter' : configPvd.totalWaterMeter,
                                'totalPressureSwitch' : configPvd.totalPressureSwitch,
                                'totalDiffPressureSensor' : configPvd.totalDiffPressureSensor,
                                'totalWaterMeter' : configPvd.totalWaterMeter,
                                'totalSourcePump' : configPvd.totalSourcePump,
                                'totalIrrigationPump' : configPvd.totalIrrigationPump,
                                'totalInjector' : configPvd.totalInjector,
                                'totalDosingMeter' : configPvd.totalDosingMeter,
                                'totalBooster' : configPvd.totalBooster,
                                'totalCentralDosing' : configPvd.totalCentralDosing,
                                'totalFilter' : configPvd.totalFilter,
                                'total_D_s_valve' : configPvd.total_D_s_valve,
                                'total_p_sensor' : configPvd.total_p_sensor,
                                'totalCentralFiltration' : configPvd.totalCentralFiltration,
                                'totalValve' : configPvd.totalValve,
                                'totalMainValve' : configPvd.totalMainValve,
                                'totalIrrigationLine' : configPvd.totalIrrigationLine,
                                'totalLocalFiltration' : configPvd.totalLocalFiltration,
                                'totalLocalDosing' : configPvd.totalLocalDosing,
                                'totalRTU' : configPvd.totalRTU,
                                'totalRtuPlus' : configPvd.totalRtuPlus,
                                'totalOroSwitch' : configPvd.totalOroSwitch,
                                'totalOroSense' : configPvd.totalOroSense,
                                'totalOroSmartRTU' : configPvd.totalOroSmartRTU,
                                'totalOroSmartRtuPlus' : configPvd.totalOroSmartRtuPlus,
                                'totalOroLevel' : configPvd.totalOroLevel,
                                'totalOroPump' : configPvd.totalOroPump,
                                'totalOroExtend' : configPvd.totalOroExtend,
                                'i_o_types' : configPvd.i_o_types,
                                'totalAnalogSensor' : configPvd.totalAnalogSensor,
                                'totalContact' : configPvd.totalContact,
                                'totalAgitator' : configPvd.totalAgitator,
                                'totalSelector' : configPvd.totalSelector,
                                'totalPhSensor' : configPvd.totalPhSensor,
                                'totalEcSensor' : configPvd.totalEcSensor,
                                'totalMoistureSensor' : configPvd.totalMoistureSensor,
                                'totalLevelSensor' : configPvd.totalLevelSensor,
                                'totalFan' : configPvd.totalFan,
                                'totalFogger' : configPvd.totalFogger,
                                'oRtu' : configPvd.oRtu,
                                'oRtuPlus' : configPvd.oRtuPlus,
                                'oSrtu' : configPvd.oSrtu,
                                'oSrtuPlus' : configPvd.oSrtuPlus,
                                'oSwitch' : configPvd.oSwitch,
                                'oSense' : configPvd.oSense,
                                'oLevel' : configPvd.oLevel,
                                'oPump' : configPvd.oPump,
                                'oPumpPlus' : configPvd.oPumpPlus,
                                'oExtend' : configPvd.oExtend,
                                'rtuForLine' : configPvd.rtuForLine,
                                'rtuPlusForLine' : configPvd.rtuPlusForLine,
                                'OroExtendForLine' : configPvd.OroExtendForLine,
                                'switchForLine' : configPvd.switchForLine,
                                'OroSmartRtuForLine' : configPvd.OroSmartRtuForLine,
                                'OroSmartRtuPlusForLine' : configPvd.OroSmartRtuPlusForLine,
                                'OroSenseForLine' : configPvd.OroSenseForLine,
                                'OroLevelForLine' : configPvd.OroLevelForLine,
                                'waterSource' : configPvd.waterSource,
                                'weatherStation' : configPvd.weatherStation,
                                'central_dosing_site_list' : configPvd.central_dosing_site_list,
                                'central_filtration_site_list' : configPvd.central_filtration_site_list,
                                'irrigation_pump_list' : configPvd.irrigation_pump_list,
                                'water_source_list' : configPvd.water_source_list,
                                'I_O_autoIncrement' : configPvd.I_O_autoIncrement,
                                'oldData' : configPvd.serverData['productLimit'],
                              },
                              "sourcePump" : configPvd.sourcePumpUpdated,
                              "irrigationPump" : configPvd.irrigationPumpUpdated,
                              "centralFertilizer" : configPvd.centralDosingUpdated,
                              "centralFilter" : configPvd.centralFiltrationUpdated,
                              "irrigationLine" : configPvd.irrigationLines,
                              "localFertilizer" : configPvd.localDosingUpdated,
                              "localFilter" : configPvd.localFiltrationUpdated,
                              "weatherStation" : configPvd.weatherStation,
                              "mappingOfOutput" : {},
                              "mappingOfInput" : {},
                              'hardware' : configPvd.sendData(),
                              'names' : configPvd.configFinish(),
                              'isNewConfig' : configPvd.isNew == true ? '1' : '0',
                            };
                            print('response body : $body');
                            HttpService service = HttpService();
                            print('body : ${convert.jsonEncode(body)}');
                            var response = await service.postRequest('createUserConfigMaker', body);
                            // print(configPvd.sendData());
                            var jsonData = convert.jsonDecode(response.body);
                            print('response code : ${jsonData['code']}');
                            print('response data : $jsonData');
                            print('AppToFirmware/${widget.controllerId}');
                            print('AppToFirmware/${widget.imeiNo}');
                            MQTTManager().publish(convert.jsonEncode(configPvd.sendData()),'AppToFirmware/${widget.imeiNo}');
                            // MqttWebClient().publishMessage('AppToFirmware/${widget.imeiNo}', convert.jsonEncode(configPvd.sendData()));
                            if(jsonData['code']  == 200){
                              Future.delayed(Duration(seconds: 1), () {
                                configPvd.editWantToSendData(2);
                              });

                            }else{
                              configPvd.editWantToSendData(3);
                            }
                          }catch(e){
                            print(e.toString());
                            Future.delayed(Duration(seconds: 1), () {
                              configPvd.editWantToSendData(3);
                            });
                          }
                          CreateJsonFile store = CreateJsonFile();
                          // store.writeDataInJsonFile('configFile', configPvd.sendData());

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
                    if([2,3].contains(configPvd.wantToSendData))
                      InkWell(
                        onTap: (){
                          configPvd.editWantToSendData(0);
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
