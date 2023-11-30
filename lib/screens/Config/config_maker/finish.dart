import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:provider/provider.dart';

import '../../../Models/create_json_file.dart';
import '../../../constants/http_service.dart';
import '../../../constants/mqtt_web_client.dart';
import '../../../state_management/config_maker_provider.dart';


class FinishPageConfigMaker extends StatefulWidget {
  const FinishPageConfigMaker({super.key, required this.userId, required this.customerID, required this.controllerId});
  final int userId, controllerId, customerID;

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
        child: ElevatedButton(
          onPressed: ()async{
            try{
              configPvd.sendData();
              configPvd.configFinish();
              var body = {
                "userId" : widget.customerID,
                "createUser" : widget.userId,
                "controllerId" : widget.controllerId,
                "productLimit" : {
                  'totalWaterSource' : configPvd.totalWaterSource,
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
                  'totalOroSwitch' : configPvd.totalOroSwitch,
                  'totalOroSense' : configPvd.totalOroSense,
                  'totalOroSmartRTU' : configPvd.totalOroSmartRTU,
                  'totalOroLevel' : configPvd.totalOroLevel,
                  'totalOroPump' : configPvd.totalOroPump,
                  'totalOroExtend' : configPvd.totalOroExtend,
                  'i_o_types' : configPvd.i_o_types,
                  'totalAnalogSensor' : configPvd.totalAnalogSensor,
                  'totalContact' : configPvd.totalContact,
                  'totalAgitator' : configPvd.totalAgitator,
                  'totalPhSensor' : configPvd.totalPhSensor,
                  'totalEcSensor' : configPvd.totalEcSensor,
                  'totalMoistureSensor' : configPvd.totalMoistureSensor,
                  'totalLevelSensor' : configPvd.totalLevelSensor,
                  'totalFan' : configPvd.totalFan,
                  'totalFogger' : configPvd.totalFogger,
                  'oRtu' : configPvd.oRtu,
                  'oSrtu' : configPvd.oSrtu,
                  'oSwitch' : configPvd.oSwitch,
                  'oSense' : configPvd.oSense,
                  'oLevel' : configPvd.oLevel,
                  'oPump' : configPvd.oPump,
                  'oExtend' : configPvd.oExtend,
                  'rtuForLine' : configPvd.rtuForLine,
                  'OroExtendForLine' : configPvd.OroExtendForLine,
                  'switchForLine' : configPvd.switchForLine,
                  'OroSmartRtuForLine' : configPvd.OroSmartRtuForLine,
                  'OroSenseForLine' : configPvd.OroSenseForLine,
                  'OroLevelForLine' : configPvd.OroLevelForLine,
                  'waterSource' : configPvd.waterSource,
                  'weatherStation' : configPvd.weatherStation,
                  'central_dosing_site_list' : configPvd.central_dosing_site_list,
                  'central_filtration_site_list' : configPvd.central_filtration_site_list,
                  'irrigation_pump_list' : configPvd.irrigation_pump_list,
                  'water_source_list' : configPvd.water_source_list,
                  'I_O_autoIncrement' : configPvd.I_O_autoIncrement,
                },
                "sourcePump" : configPvd.sourcePumpUpdated,
                "irrigationPump" : configPvd.irrigationPumpUpdated,
                "centralFertilizer" : configPvd.centralDosingUpdated,
                "centralFilter" : configPvd.centralFiltrationUpdated,
                "irrigationLine" : configPvd.irrigationLines,
                "localFertilizer" : configPvd.localDosingUpdated,
                "localFilter" : configPvd.localFiltrationUpdated,
                "weatherStation" : {},
                "mappingOfOutput" : {},
                "mappingOfInput" : {},
                'hardware' : configPvd.sendData(),
                'names' : configPvd.configFinish(),
                'isNewConfig' : configPvd.isNew == true ? '1' : '0',
              };
              print('response body : $body');
              HttpService service = HttpService();
              var response = await service.postRequest('createUserConfigMaker', body);

              //print(configPvd.sendData());
              var jsonData = jsonDecode(response.body);
              print('response code : ${jsonData['code']}');
              print('response data : $jsonData');
            }catch(e){
              print(e.toString());
            }
            CreateJsonFile store = CreateJsonFile();
            // store.writeDataInJsonFile('configFile', configPvd.sendData());
            MqttWebClient().publishMessage('AppToFirmware/${widget.controllerId}', jsonEncode(configPvd.sendData()));
          },
          child: Text('Send'),
        ),
      ),
    );
  }
}
