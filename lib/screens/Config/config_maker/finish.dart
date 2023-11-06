import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../Models/create_json_file.dart';
import '../../../constants/http_service.dart';
import '../../../constants/mqtt_manager.dart';
import '../../../constants/mqtt_service.dart';
import '../../../state_management/config_maker_provider.dart';


class FinishPageConfigMaker extends StatefulWidget {
  const FinishPageConfigMaker({super.key, required this.customerId, required this.controllerId, required this.userId, required this.imeiNo});
  final int customerId, controllerId, userId;
  final String imeiNo;

  @override
  State<FinishPageConfigMaker> createState() => _FinishPageConfigMakerState();
}

class _FinishPageConfigMakerState extends State<FinishPageConfigMaker> {
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    // var mqttPvd = Provider.of<MqttProvider>(context, listen: true);

    return Center(
      child: ElevatedButton(
        onPressed: ()async{
          // configPvd.hardWarePayLoad();
          HttpService service = HttpService();
          try{
            /*print('sr : ${jsonEncode({
              "userId" : widget.customerId,
              "controllerId" : widget.controllerId,
              // "pumps" : configPvd.my_payload['200'][0]['201'],
              "pumps" : [],
              // "irrigationLine" : configPvd.my_payload['200'][1]['202'],
              "irrigationLine" : [],
              // "dosing" : configPvd.my_payload['200'][2]['203'],
              "dosing" : [],
              // "backwash" : configPvd.my_payload['200'][3]['204'],
              "backwash" : [],
              // "weatherStation" : configPvd.my_payload['200'][4]['205'],
              "weatherStation" : [],
              // "inputOutput" : configPvd.my_payload['200'][5]['206'],
              "inputOutput" : [],
              "inputOutputSw" : configPvd.sendData(),
              "createUser" : widget.userId,
            })}');*/
            var response = await service.postRequest('createUserConfigMaker', {
              "userId" : widget.customerId,
              "controllerId" : widget.controllerId,
              // "pumps" : configPvd.my_payload['200'][0]['201'],
              "pumps" : '',
              // "irrigationLine" : configPvd.my_payload['200'][1]['202'],
              "irrigationLine" : '',
              // "dosing" : configPvd.my_payload['200'][2]['203'],
              "dosing" : '',
              // "backwash" : configPvd.my_payload['200'][3]['204'],
              "backwash" : '',
              // "weatherStation" : configPvd.my_payload['200'][4]['205'],
              "weatherStation" : '',
              // "inputOutput" : configPvd.my_payload['200'][5]['206'],
              "inputOutput" : configPvd.map_i_o,
              "inputOutputSw" : configPvd.sendData(),
              "createUser" : widget.userId,
            });
            var jsonData = jsonDecode(response.body);
            //print('jsonData : ${jsonData['code']}');

            String payLoad = jsonEncode({
              "200": [
                {"201": ''},
                {"202": ''},
                {"203": ''},
                {"204": ''},
                {"205": ''},
                {"206": configPvd.map_i_o},
              ]
            });

            MqttService().publishMessage('AppToFirmware/${widget.imeiNo}', payLoad);

          }catch(e){
            print(e.toString());
          }
          // configPvd.hardWarePayLoad();
          // CreateJsonFile store = CreateJsonFile();
          // store.writeDataInJsonFile('configFile', configPvd.sendData());
        },
        child: Text('Send'),
      ),
    );
  }
}
