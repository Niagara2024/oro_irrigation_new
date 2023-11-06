import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';


class StartPageConfigMaker extends StatefulWidget {
  const StartPageConfigMaker({super.key});
  @override
  State<StartPageConfigMaker> createState() => _StartPageConfigMakerState();
}

class _StartPageConfigMakerState extends State<StartPageConfigMaker> {
  bool isHovered = false;
  bool isHovered1 = false;
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Container(
      color: Color(0XFFF3F3F3),
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        isHovered = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isHovered = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: (){
                        // print(configPvd.oldData.runtimeType);
                        fetchData(configPvd.oldData,configPvd);
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: isHovered == true ? Border.all(color: myTheme.primaryColor,width: 5) : null,
                          color: isHovered == false ? Colors.white : Colors.blue,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/images/get data.png')),
                            Text('Get Data'),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              Column(
                children: [
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        isHovered1 = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        isHovered1 = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: (){

                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: isHovered1 == true ? Border.all(color: myTheme.primaryColor,width: 5) : null,
                          color: isHovered1 == false ? Colors.white : Colors.blue,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset('assets/images/start_config.png')),
                            Text('Start Config'),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );

  }

  List<String> returnTitleAndImage(int index){
    print('index : ${index}');
    if(index == 0){
      return ['Get Data', 'assets/images/get data.png'];
    }else{
      return ['Start Config', 'assets/images/start_config.png'];
    }
  }

  String returnDeviceName(String title){
    if(title == '2'){
      return 'ORO Smart RTU';
    }else if(title == '3'){
      return 'ORO RTU';
    }else if(title == '5'){
      return 'ORO Switch';
    }else if(title == '7'){
      return 'ORO Sense';
    }else{
      return '-';
    }
  }
  void fetchData(Map<String, dynamic> myData, ConfigMakerProvider configPvd){
    for(var i in myData['output'].entries){
      if(i.key.contains('all_AI')){
        for(var j in i.value.entries){
          switch(j.key){
            case ('autoIncrement'):{
              configPvd.updateAI(['autoIncrement',j.value]);
              break;
            }
            case ('C_D_autoIncrement'):{
              configPvd.updateAI(['C_D_autoIncrement',j.value]);
              break;
            }
            case ('C_F_autoIncrement'):{
              configPvd.updateAI(['C_F_autoIncrement',j.value]);
              break;
            }
            case ('P_autoIncrement'):{
              configPvd.updateAI(['P_autoIncrement',j.value]);
              break;
            }
            case ('I_O_autoIncrement'):{
              configPvd.updateAI(['I_O_autoIncrement',j.value]);
              break;
            }
            case ('CD_channel_autoIncrement'):{
              configPvd.updateAI(['CD_channel_autoIncrement',j.value]);
              break;
            }
          }
        }
      }
      if(i.key.contains('l')){
        print("myData['output'] : ${myData['output']}");
        configPvd.irrigationLinesFunctionality(['addIrrigationLine']);
        configPvd.irrigationLinesFunctionality([int.parse(i.key.split('l')[1]) - 1,]);
        for(var j in i.value.entries){
          print('j.key : ${j.key}  line : ${i.key}');
          switch(j.key){
            case ('AI'):{
              configPvd.irrigationLinesFunctionality(['updateAI',int.parse(i.key.split('l')[1]) - 1,int.parse(j.value)]);
              break;
            }
            case ('v'):{
              configPvd.irrigationLinesFunctionality(['editValve',int.parse(i.key.split('l')[1]) - 1,j.value.split('|').length.toString()]);
              break;
            }
            case ('mv'):{
              configPvd.irrigationLinesFunctionality(['editMainValve',int.parse(i.key.split('l')[1]) - 1,j.value.split('|').length.toString()]);
              break;
            }
            case ('inj'):{
              if(j.value.length != 0){
                if(j.value.contains('|')){
                  configPvd.irrigationLinesFunctionality(['editLocalDosing',int.parse(i.key.split('l')[1]) - 1,true,1,j.value.split('|').length,false,false]);
                  for(var ld1 = 0;ld1 < configPvd.localDosing.length;ld1++){
                    if(configPvd.localDosing[ld1][configPvd.localDosing[ld1].length - 1][1] == int.parse(i.key.split('l')[1])){
                      var val = j.value.split('|');
                      for(var bp in val){
                        var forWhichInj = int.parse(bp.split(',')[0]);
                        configPvd.localDosingFunctionality(['editChannelNumber',ld1,forWhichInj - 1,bp.split(',')[4]]);
                      }
                    }
                  }
                }else{
                  configPvd.irrigationLinesFunctionality(['editLocalDosing',int.parse(i.key.split('l')[1]) - 1,true,1,j.value.split('|').length,false,false]);
                  for(var ld1 = 0;ld1 < configPvd.localDosing.length;ld1++){
                    if(configPvd.localDosing[ld1][configPvd.localDosing[ld1].length - 1][1] == int.parse(i.key.split('l')[1])){
                      var val = j.value.split('|');
                      for(var bp in val){
                        var forWhichInj = int.parse(bp.split(',')[0]);
                        configPvd.localDosingFunctionality(['editChannelNumber',ld1,forWhichInj - 1,bp.split(',')[4]]);
                      }
                    }
                  }
                }
              }
              break;
            }
            case ('booster'):{
              if(j.value.length != 0){
                if(j.value.contains('|')){
                  for(var ld1 = 0;ld1 < configPvd.localDosing.length;ld1++){
                    if(configPvd.localDosing[ld1][configPvd.localDosing[ld1].length - 1][1] == int.parse(i.key.split('l')[1])){
                      var val = j.value.split('|');
                      for(var bp in val){
                        var forWhichInj = int.parse(bp.split(',')[0]);
                        configPvd.localDosingFunctionality(['editBoosterPump',ld1,forWhichInj - 1,true]);
                      }
                    }
                  }
                }else{
                  for(var ld1 = 0;ld1 < configPvd.localDosing.length;ld1++){
                    if(configPvd.localDosing[ld1][configPvd.localDosing[ld1].length - 1][1] == int.parse(i.key.split('l')[1])){
                      configPvd.localDosingFunctionality(['editBoosterPump',ld1,int.parse(j.value.split(',')[0]) - 1,true]);
                    }
                  }
                }
              }
              break;
            }
            case ('filt'):{
              if(j.value.length != 0){
                configPvd.irrigationLinesFunctionality(['editLocalFiltration',int.parse(i.key.split('l')[1]) - 1,true]);
              }
              if(j.value.contains('|')){
                for(var lf = 0;lf < configPvd.localFiltration.length;lf++){
                  if(configPvd.localFiltration[lf][0].toString() == i.key.split('l')[1]){
                    configPvd.localFiltrationFunctionality(['editFilter',lf,j.value.split('|').length.toString()]);
                  }
                }
              }
              break;
            }

            case ('d_v'):{
              if(j.value.length != 0){
                for(var lf = 0;lf < configPvd.localFiltration.length;lf++){
                  if(configPvd.localFiltration[lf][0].toString() == i.key.split('l')[1]){
                    configPvd.localFiltrationFunctionality(['editDownStreamValve',lf,true]);
                  }
                }
              }
              break;
            }
            case ('RF'):{
              var RF = j.value.split('+');
              for(var l in RF){
                var colonSplit = l.split(':');
                if (colonSplit.length == 2) {
                  var keyPart = colonSplit[0].trim();
                  var getVal = colonSplit[1].toString();
                  if(getVal.contains('[')){
                    var count = '';
                    List<int> rfList = [];
                    bool arrayStart = false;
                    for(var i in getVal.split('')){
                      if(i == '['){
                        arrayStart = true;
                      }
                      if(arrayStart == false){
                        count += i;
                      }else{
                        if(i != '[' && i != ']' && i != ',' && i != '' && i != ' '){
                          rfList.add(int.parse(i));
                        }
                      }
                    }
                    if(count != ''){
                      switch (keyPart){
                        case ('OSRTU'):{
                          configPvd.irrigationLinesFunctionality(['editOroSmartRtu', int.parse(i.key.split('l')[1]) - 1, count]);
                          configPvd.editRfList(['OSRTU',int.parse(i.key.split('l')[1]) - 1,rfList]);
                          break;
                        }
                        case ('ORTU'):{
                          configPvd.irrigationLinesFunctionality(['editRTU', int.parse(i.key.split('l')[1]) - 1, count]);
                          configPvd.editRfList(['ORTU',int.parse(i.key.split('l')[1]) - 1,rfList]);
                          break;
                        }
                        case ('OSWTCH'):{
                          configPvd.irrigationLinesFunctionality(['editOroSwitch', int.parse(i.key.split('l')[1]) - 1, count]);
                          configPvd.editRfList(['OSWTCH',int.parse(i.key.split('l')[1]) - 1,rfList]);
                          break;
                        }
                        case ('OSENSE'):{
                          configPvd.irrigationLinesFunctionality(['editOroSense', int.parse(i.key.split('l')[1]) - 1, count]);
                          configPvd.editRfList(['OSENSE',int.parse(i.key.split('l')[1]) - 1,rfList]);
                          break;
                        }
                      }
                    }
                  }else {
                    if(keyPart == 'CD'){
                      configPvd.irrigationLinesFunctionality(['editCentralDosing', int.parse(i.key.split('l')[1]) - 1, colonSplit[1]]);
                    }else if(keyPart == 'CF'){
                      configPvd.irrigationLinesFunctionality(['editCentralFiltration', int.parse(i.key.split('l')[1]) - 1, colonSplit[1]]);
                    }
                    else if(keyPart == 'IP'){
                      configPvd.irrigationLinesFunctionality(['editIrrigationPump', int.parse(i.key.split('l')[1]) - 1, colonSplit[1]]);
                    }
                  }
                }
              }
              break;
            }
            default : {
              break;
            }

          }
        }
      }
      if(i.key.contains('CD')){
        for(var cd in i.value.entries){
          switch (cd.key){
            case ('inj'):{
              int AI = 0;
              for(var cd in i.value.entries){
                if(cd.key == 'AI'){
                  AI = int.parse(cd.value);
                }
              }
              if(cd.value.length != 0){
                if(cd.value.contains('|')){
                  configPvd.serialNumber('CentralDosing',AI - 1);
                  configPvd.centralDosingFunctionality(['addBatch_CD',1,cd.value.split('|').length,false,false]);
                  var injList = cd.value.split('|');
                  for(var item = 0;item < injList.length;item++){
                    var channel = injList[item].split(',');
                    configPvd.centralDosingFunctionality(['editChannelNumber',int.parse(i.key.split('CD')[1]) - 1, item , channel[4]]);
                  }
                }
                if(!cd.value.contains('|')){
                  configPvd.serialNumber('CentralDosing',AI - 1);
                  configPvd.centralDosingFunctionality(['addCentralDosing']);
                  configPvd.centralDosingFunctionality(['editChannelNumber',int.parse(i.key.split('CD')[1]) - 1, 0 , cd.value.split(',')[4]]);

                }
              }
              break;
            }
            case ('booster'):{
              if(cd.value.length != 0){
                if(cd.value.contains('|')){
                  var injList = cd.value.split('|');
                  for(var item = 0;item < injList.length;item++){
                    configPvd.centralDosingFunctionality(['editBooster',int.parse(i.key.split('CD')[1]) - 1, item , true]);
                  }
                }else{
                  configPvd.centralDosingFunctionality(['editBooster',int.parse(i.key.split('CD')[1]) - 1, 0 , true]);
                }
              }
            }
          }
        }
      }
      if(i.key.contains('CF')){
        for(var cf in i.value.entries){
          switch (cf.key){
            case ('filt'):{
              int AI = 0;
              for(var cf in i.value.entries){
                if(cf.key == 'AI'){
                  AI = int.parse(cf.value);
                }
              }
              if(cf.value.length != 0){
                configPvd.serialNumber('CentralFiltration',AI - 1);
                configPvd.centralFiltrationFunctionality(['addCentralFiltration']);
                if(cf.value.contains('|')){
                  configPvd.centralFiltrationFunctionality(['editFilters',int.parse(i.key.split('CF')[1]) - 1,cf.value.split('|').length.toString()]);
                }
                else{
                  configPvd.centralFiltrationFunctionality(['editFilters',int.parse(i.key.split('CF')[1]) - 1,'1']);
                }
              }
              break;
            }
            case ('d_v'):{
              if(cf.value.length != 0){
                configPvd.centralFiltrationFunctionality(['editDownStreamValve',int.parse(i.key.split('CF')[1]) - 1,true]);
              }
            }
          }
        }
      }
      if(i.key.contains('SP')){
        var listOfSp = i.value.split('|');
        for(var sp = 0;sp < listOfSp.length;sp++){
          var pump = listOfSp[sp].split(',');
          configPvd.serialNumber('sourcePump',int.parse(pump[pump.length - 2]) - 1);
          configPvd.sourcePumpFunctionality(['addSourcePump']);
          var src = listOfSp[sp].split(',');
          configPvd.sourcePumpFunctionality(['editWaterSource_sp',sp,src[src.length - 3]]);
        }
      }
      if(i.key.contains('IP')){
        var listOfIp = i.value.split('|');
        for(var ip = 0;ip < listOfIp.length;ip++){
          var pump = listOfIp[ip].split(',');
          configPvd.serialNumber('irrigationPump',int.parse(pump[pump.length - 2]) - 1);
          configPvd.irrigationPumpFunctionality(['addIrrigationPump']);
        }
      }
    }
    for(var i in myData['output'].entries){
      if(i.key.contains('l')){
        for(var j in i.value.entries){
          if(j.key == 'RF'){
            var RF = j.value.split('+');
            for(var l in RF){
              var colonSplit = l.split(':');
              if(colonSplit[0] == 'CD'){
                int index = int.parse(i.key.split('l')[1]) - 1;
                configPvd.irrigationLinesFunctionality(['editCentralDosing',index, colonSplit[1]]);
              }else if(colonSplit[0] == 'CF'){
                int index = int.parse(i.key.split('l')[1]) - 1;
                configPvd.irrigationLinesFunctionality(['editCentralFiltration',index, colonSplit[1]]);
              }
            }
          }
        }
      }
    }
    for(var i in myData['input'].entries){
      if(i.key.contains('SP/wm')){
        if(i.value != ''){
          var wmList = i.value.split('|');
          for(var wm in wmList){
            int index = int.parse(wm.split(',')[0]) - 1;
            configPvd.sourcePumpFunctionality(['editWaterMeter',index,true]);
          }
        }
      }
      if(i.key.contains('IP/wm')){
        if(i.value != ''){
          var wmList = i.value.split('|');
          for(var i in wmList){
            int index = int.parse(i.split(',')[0]) - 1;
            configPvd.irrigationPumpFunctionality(['editWaterMeter',index,true]);
          }
        }
      }
      if(i.key.contains('CD')){
        for(var cd in i.value.entries){
          switch (cd.key){
            case ('d_meter'):{
              if(cd.value.length != 0){
                if(cd.value.contains('|')){
                  var injList = cd.value.split('|');
                  for(var item = 0;item < injList.length;item++){
                    configPvd.centralDosingFunctionality(['editDosingMeter',int.parse(i.key.split('CD')[1]) - 1, item , true]);
                  }
                }else{
                  configPvd.centralDosingFunctionality(['editDosingMeter',int.parse(i.key.split('CD')[1]) - 1, 0 , true]);
                }
              }
            }
          }
        }
      }
      if(i.key.contains('CF')){
        for(var cf in i.value.entries){
          switch (cf.key){
            case ('PS_IN'):{
              if(cf.value.length != 0){
                configPvd.centralFiltrationFunctionality(['editPressureSensor',int.parse(i.key.split('CF')[1]) - 1,true]);
              }
              break;
            }
            case ('PS_OUT'):{
              if(cf.value.length != 0){
                configPvd.centralFiltrationFunctionality(['editPressureSensor_out',int.parse(i.key.split('CF')[1]) - 1,true]);
              }
            }
          }
        }
      }
      if(i.key.contains('l')){
        for(var j in i.value.entries){
          switch(j.key){
            case ('PS'):{
              if(j.value.length != 0){
                configPvd.irrigationLinesFunctionality(['editPressureSensor',int.parse(i.key.split('l')[1]) - 1,true]);
              }
              break;
            }
            case ('wm'):{
              if(j.value.length != 0){
                configPvd.irrigationLinesFunctionality(['editWaterMeter',int.parse(i.key.split('l')[1]) - 1,true]);
              }
              break;
            }
            case ('d_meter'):{
              if(j.value.length != 0){
                if(j.value.contains('|')){
                  for(var ld1 = 0;ld1 < configPvd.localDosing.length;ld1++){
                    if(configPvd.localDosing[ld1][configPvd.localDosing[ld1].length - 1][1] == int.parse(i.key.split('l')[1])){
                      var val = j.value.split('|');
                      for(var bp in val){
                        var forWhichInj = int.parse(bp.split(',')[0]);
                        configPvd.localDosingFunctionality(['editDosingMeter',ld1,forWhichInj - 1,true]);
                      }
                    }
                  }
                }else{
                  for(var ld1 = 0;ld1 < configPvd.localDosing.length;ld1++){
                    if(configPvd.localDosing[ld1][configPvd.localDosing[ld1].length - 1][1] == int.parse(i.key.split('l')[1])){
                      configPvd.localDosingFunctionality(['editDosingMeter',ld1,0,true]);
                    }
                  }
                }
              }
              break;
            }
            case ('PS_IN'):{
              if(j.value.length != 0){
                for(var lf = 0;lf < configPvd.localFiltration.length;lf++){
                  if(configPvd.localFiltration[lf][0].toString() == i.key.split('l')[1]){
                    configPvd.localFiltrationFunctionality(['editDiffPressureSensor',lf,true]);
                  }
                }
              }
              break;
            }
            case ('PS_OUT'):{
              if(j.value.length != 0){
                for(var lf = 0;lf < configPvd.localFiltration.length;lf++){
                  if(configPvd.localFiltration[lf][0].toString() == i.key.split('l')[1]){
                    configPvd.localFiltrationFunctionality(['editDiffPressureSensor_out',lf,true]);
                  }
                }
              }
              break;
            }
          }
        }
      }
    }
    configPvd.editRfList1();
    configPvd.refreshMapOfOutputs();
    configPvd.refreshMapOfInputs();
    for(var i in myData['output'].entries){
      if(i.key.contains('l')){
        for(var j in i.value.entries){
          print('yes here');
          print(j.key);
          switch(j.key){
            case ('v'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = j.value.split('|');
              for(var v = 0; v < fullList.length;v++){
                var valve = fullList[v].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_valve',int.parse(i.key.split('l')[1]) - 1,AI,'valve',v,1,returnDeviceName(valve[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_valve',int.parse(i.key.split('l')[1]) - 1,AI,'valve',v,2,valve[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_valve',int.parse(i.key.split('l')[1]) - 1,AI,'valve',v,3,valve[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_valve',int.parse(i.key.split('l')[1]) - 1,AI,'valve',v,4,valve[4]]);
              }
              break;
            }
            case ('mv'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = j.value.split('|');
              for(var mv = 0; mv < fullList.length;mv++){
                var m_valve = fullList[mv].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_main_valve',int.parse(i.key.split('l')[1]) - 1,AI,'main_valve',mv,1,returnDeviceName(m_valve[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_main_valve',int.parse(i.key.split('l')[1]) - 1,AI,'main_valve',mv,2,m_valve[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_main_valve',int.parse(i.key.split('l')[1]) - 1,AI,'main_valve',mv,3,m_valve[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_main_valve',int.parse(i.key.split('l')[1]) - 1,AI,'main_valve',mv,4,m_valve[4]]);
              }
              break;
            }
            case ('inj'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = j.value.split('|');
              for(var inj = 0; inj < fullList.length;inj++){
                var injector = fullList[inj].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_injector',int.parse(i.key.split('l')[1]) - 1,AI,'injector',inj,1,returnDeviceName(injector[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_injector',int.parse(i.key.split('l')[1]) - 1,AI,'injector',inj,2,injector[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_injector',int.parse(i.key.split('l')[1]) - 1,AI,'injector',inj,3,injector[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_injector',int.parse(i.key.split('l')[1]) - 1,AI,'injector',inj,4,injector[4]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_injector',int.parse(i.key.split('l')[1]) - 1,AI,'injector',inj,5,injector[5]]);
              }
              break;
            }
            case ('booster'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = j.value.split('|');
              for(var bp = 0; bp < fullList.length;bp++){
                var booster = fullList[bp].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_Booster',int.parse(i.key.split('l')[1]) - 1,AI,'Booster',bp,1,returnDeviceName(booster[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_Booster',int.parse(i.key.split('l')[1]) - 1,AI,'Booster',bp,2,booster[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_Booster',int.parse(i.key.split('l')[1]) - 1,AI,'Booster',bp,3,booster[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_Booster',int.parse(i.key.split('l')[1]) - 1,AI,'Booster',bp,4,booster[4]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_Booster',int.parse(i.key.split('l')[1]) - 1,AI,'Booster',bp,5,booster[5]]);
              }
              break;
            }
            case ('filt'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = j.value.split('|');
              for(var bp = 0; bp < fullList.length;bp++){
                var filter = fullList[bp].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_filter',int.parse(i.key.split('l')[1]) - 1,AI,'filter',bp,1,returnDeviceName(filter[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_filter',int.parse(i.key.split('l')[1]) - 1,AI,'filter',bp,2,filter[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_filter',int.parse(i.key.split('l')[1]) - 1,AI,'filter',bp,3,filter[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_filter',int.parse(i.key.split('l')[1]) - 1,AI,'filter',bp,4,filter[4]]);
              }
              break;
            }
            case ('d_v'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var d_valve = j.value.split(',');
              configPvd.mappingOfOutputsFunctionality(['m_o_D_valve',int.parse(i.key.split('l')[1]) - 1,AI,'D_valve',1,returnDeviceName(d_valve[1])]);
              configPvd.mappingOfOutputsFunctionality(['m_o_D_valve',int.parse(i.key.split('l')[1]) - 1,AI,'D_valve',2,d_valve[2]]);
              configPvd.mappingOfOutputsFunctionality(['m_o_D_valve',int.parse(i.key.split('l')[1]) - 1,AI,'D_valve',3,d_valve[3]]);
              configPvd.mappingOfOutputsFunctionality(['m_o_D_valve',int.parse(i.key.split('l')[1]) - 1,AI,'D_valve',4,d_valve[4]]);
              break;
            }
            default : {
              break;
            }

          }
        }
      }
      if(i.key.contains('CD')){
        for(var cd in i.value.entries){
          switch (cd.key){
            case ('inj'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = cd.value.split('|');
              for(var bp = 0; bp < fullList.length;bp++){
                var injector = fullList[bp].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_injector',int.parse(i.key.split('CD')[1]) - 1,AI,'injector',bp,1,returnDeviceName(injector[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_injector',int.parse(i.key.split('CD')[1]) - 1,AI,'injector',bp,2,injector[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_injector',int.parse(i.key.split('CD')[1]) - 1,AI,'injector',bp,3,injector[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_injector',int.parse(i.key.split('CD')[1]) - 1,AI,'injector',bp,4,injector[4]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_injector',int.parse(i.key.split('CD')[1]) - 1,AI,'injector',bp,5,injector[5]]);
              }
              break;
            }
            case ('booster'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = cd.value.split('|');
              for(var bp = 0; bp < fullList.length;bp++){
                var booster = fullList[bp].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_booster',int.parse(i.key.split('CD')[1]) - 1,AI,'booster',bp,1,returnDeviceName(booster[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_booster',int.parse(i.key.split('CD')[1]) - 1,AI,'booster',bp,2,booster[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_booster',int.parse(i.key.split('CD')[1]) - 1,AI,'booster',bp,3,booster[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_booster',int.parse(i.key.split('CD')[1]) - 1,AI,'booster',bp,4,booster[4]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CD_booster',int.parse(i.key.split('CD')[1]) - 1,AI,'booster',bp,5,booster[5]]);
              }
              break;
            }
          }
        }
      }
      if(i.key.contains('CF')){
        for(var cf in i.value.entries){
          switch (cf.key){
            case ('filt'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = cf.value.split('|');
              for(var bp = 0; bp < fullList.length;bp++){
                var filter = fullList[bp].split(',');
                configPvd.mappingOfOutputsFunctionality(['m_o_CF_filter',int.parse(i.key.split('CF')[1]) - 1,AI,'filter',bp,1,returnDeviceName(filter[1])]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CF_filter',int.parse(i.key.split('CF')[1]) - 1,AI,'filter',bp,2,filter[2]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CF_filter',int.parse(i.key.split('CF')[1]) - 1,AI,'filter',bp,3,filter[3]]);
                configPvd.mappingOfOutputsFunctionality(['m_o_CF_filter',int.parse(i.key.split('CF')[1]) - 1,AI,'filter',bp,4,filter[4]]);
              }
              break;
            }
            case ('d_v'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var d_valve = cf.value.split(',');
              configPvd.mappingOfOutputsFunctionality(['m_o_CF_D_valve',int.parse(i.key.split('CF')[1]) - 1,AI,'D_S_valve',1,returnDeviceName(d_valve[1])]);
              configPvd.mappingOfOutputsFunctionality(['m_o_CF_D_valve',int.parse(i.key.split('CF')[1]) - 1,AI,'D_S_valve',2,d_valve[2]]);
              configPvd.mappingOfOutputsFunctionality(['m_o_CF_D_valve',int.parse(i.key.split('CF')[1]) - 1,AI,'D_S_valve',3,d_valve[3]]);
              configPvd.mappingOfOutputsFunctionality(['m_o_CF_D_valve',int.parse(i.key.split('CF')[1]) - 1,AI,'D_S_valve',4,d_valve[4]]);
              break;
            }
          }
        }
      }
      if(i.key.contains('SP')){
        var fullList = i.value.split('|');
        for(var bp = 0; bp < fullList.length;bp++){
          var sp = fullList[bp].split(',');
          configPvd.mappingOfOutputsFunctionality(['m_o_SP',int.parse(sp[0]) -1,sp[5],'pump',1,returnDeviceName(sp[1])]);
          configPvd.mappingOfOutputsFunctionality(['m_o_SP',int.parse(sp[0]) - 1,sp[5],'pump',2,sp[2]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_SP',int.parse(sp[0]) - 1,sp[5],'pump',3,sp[3]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_SP',int.parse(sp[0]) - 1,sp[5],'pump',4,sp[6]]);
        }
      }
      if(i.key.contains('IP')){
        var fullList = i.value.split('|');
        for(var bp = 0; bp < fullList.length;bp++){
          var ip = fullList[bp].split(',');
          configPvd.mappingOfOutputsFunctionality(['m_o_IP',int.parse(ip[0]) - 1,ip[4],'pump',1,returnDeviceName(ip[1])]);
          configPvd.mappingOfOutputsFunctionality(['m_o_IP',int.parse(ip[0]) - 1,ip[4],'pump',2,ip[2]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_IP',int.parse(ip[0]) - 1,ip[4],'pump',3,ip[3]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_IP',int.parse(ip[0]) - 1,ip[4],'pump',4,ip[5]]);
        }
      }
      if(i.key.contains('Fan')){
        print('came fan');
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfOutputsFunctionality(['m_o_fan',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfOutputsFunctionality(['m_o_fan',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_fan',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_fan',int.parse(CONT[0]) - 1,4,CONT[4]]);
        }
      }
      if(i.key.contains('Fogger')){
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfOutputsFunctionality(['m_o_fogger',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfOutputsFunctionality(['m_o_fogger',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_fogger',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_fogger',int.parse(CONT[0]) - 1,4,CONT[4]]);
        }
      }
      if(i.key.contains('Agitator')){
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfOutputsFunctionality(['m_o_agitator',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfOutputsFunctionality(['m_o_agitator',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_agitator',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfOutputsFunctionality(['m_o_agitator',int.parse(CONT[0]) - 1,4,CONT[4]]);
        }
      }
    }

    for(var i in myData['input'].entries){
      if(i.key.contains('SP/wm')){
        var fullList = i.value.split('|');
        print(configPvd.SP_MO);
        if(fullList.length != 0){
          for(var bp = 0; bp < fullList.length;bp++){
            var wm = fullList[bp].split(',');
            configPvd.mappingOfInputsFunctionality(['m_i_sp_wm',int.parse(wm[0]) -1,wm[5],'water_meter',1,returnDeviceName(wm[1])]);
            configPvd.mappingOfInputsFunctionality(['m_i_sp_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',2,wm[2]]);
            configPvd.mappingOfInputsFunctionality(['m_i_sp_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',3,wm[3]]);
            configPvd.mappingOfInputsFunctionality(['m_i_sp_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',4,wm[4]]);
            configPvd.mappingOfInputsFunctionality(['m_i_sp_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',5,wm[6]]);
          }
        }
      }
      if(i.key.contains('IP/wm')){
        var fullList = i.value.split('|');
        if(fullList.length != 0){
          for(var bp = 0; bp < fullList.length;bp++){
            var wm = fullList[bp].split(',');
            configPvd.mappingOfInputsFunctionality(['m_i_ip_wm',int.parse(wm[0]) -1,wm[5],'water_meter',1,returnDeviceName(wm[1])]);
            configPvd.mappingOfInputsFunctionality(['m_i_ip_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',2,wm[2]]);
            configPvd.mappingOfInputsFunctionality(['m_i_ip_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',3,wm[3]]);
            configPvd.mappingOfInputsFunctionality(['m_i_ip_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',4,wm[4]]);
            configPvd.mappingOfInputsFunctionality(['m_i_ip_wm',int.parse(wm[0]) - 1,wm[5],'water_meter',5,wm[6]]);
          }
        }
      }
      if(i.key.contains('CD')){
        for(var cd in i.value.entries){
          switch (cd.key){
            case ('d_meter'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = cd.value.split('|');
              for(var v = 0; v < fullList.length;v++){
                var d_m = fullList[v].split(',');
                configPvd.mappingOfInputsFunctionality(['m_i_CD_dosing_meter',int.parse(i.key.split('CD')[1]) - 1,AI,'dosing_meter',v,1,returnDeviceName(d_m[1])]);
                configPvd.mappingOfInputsFunctionality(['m_i_CD_dosing_meter',int.parse(i.key.split('CD')[1]) - 1,AI,'dosing_meter',v,2,d_m[2]]);
                configPvd.mappingOfInputsFunctionality(['m_i_CD_dosing_meter',int.parse(i.key.split('CD')[1]) - 1,AI,'dosing_meter',v,3,d_m[3]]);
                configPvd.mappingOfInputsFunctionality(['m_i_CD_dosing_meter',int.parse(i.key.split('CD')[1]) - 1,AI,'dosing_meter',v,4,d_m[4]]);
                configPvd.mappingOfInputsFunctionality(['m_i_CD_dosing_meter',int.parse(i.key.split('CD')[1]) - 1,AI,'dosing_meter',v,5,d_m[5]]);
                configPvd.mappingOfInputsFunctionality(['m_i_CD_dosing_meter',int.parse(i.key.split('CD')[1]) - 1,AI,'dosing_meter',v,6,d_m[6]]);
              }
            }
          }
        }
      }
      if(i.key.contains('CF')){
        for(var cf in i.value.entries){
          switch (cf.key){
            case ('PS_IN'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var wm = cf.value.split(',');
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor',1,returnDeviceName(wm[1])]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor',2,wm[2]]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor',3,wm[3]]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor',4,wm[4]]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor',5,wm[5]]);
              break;
            }
            case ('PS_OUT'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var wm = cf.value.split(',');
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor_out',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor_out',1,returnDeviceName(wm[1])]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor_out',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor_out',2,wm[2]]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor_out',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor_out',3,wm[3]]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor_out',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor_out',4,wm[4]]);
              configPvd.mappingOfInputsFunctionality(['m_i_CF_P_sensor_out',int.parse(i.key.split('CF')[1]) - 1,AI,'P_sensor_out',5,wm[5]]);
            }
          }
        }
      }
      if(i.key.contains('l')){
        for(var j in i.value.entries){
          switch(j.key){
            case ('P_S'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var p_s = j.value.split(',');
              configPvd.mappingOfInputsFunctionality(['m_i_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'pressure_sensor',1,returnDeviceName(p_s[1])]);
              configPvd.mappingOfInputsFunctionality(['m_i_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'pressure_sensor',2,p_s[2]]);
              configPvd.mappingOfInputsFunctionality(['m_i_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'pressure_sensor',3,p_s[3]]);
              configPvd.mappingOfInputsFunctionality(['m_i_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'pressure_sensor',4,p_s[4]]);
              configPvd.mappingOfInputsFunctionality(['m_i_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'pressure_sensor',5,p_s[5]]);
              break;
            }
            case ('wm'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var wm = j.value.split(',');
              configPvd.mappingOfInputsFunctionality(['m_i_water_meter',int.parse(i.key.split('l')[1]) - 1,AI,'water_meter',1,returnDeviceName(wm[1])]);
              configPvd.mappingOfInputsFunctionality(['m_i_water_meter',int.parse(i.key.split('l')[1]) - 1,AI,'water_meter',2,wm[2]]);
              configPvd.mappingOfInputsFunctionality(['m_i_water_meter',int.parse(i.key.split('l')[1]) - 1,AI,'water_meter',3,wm[3]]);
              configPvd.mappingOfInputsFunctionality(['m_i_water_meter',int.parse(i.key.split('l')[1]) - 1,AI,'water_meter',4,wm[4]]);
              configPvd.mappingOfInputsFunctionality(['m_i_water_meter',int.parse(i.key.split('l')[1]) - 1,AI,'water_meter',5,wm[5]]);
              break;
            }
            case ('d_meter'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var fullList = j.value.split('|');
              for(var v = 0; v < fullList.length;v++){
                var d_m = fullList[v].split(',');
                configPvd.mappingOfInputsFunctionality(['m_i_dosing_meter',int.parse(i.key.split('l')[1]) - 1,AI,'dosing_meter',v,1,returnDeviceName(d_m[1])]);
                configPvd.mappingOfInputsFunctionality(['m_i_dosing_meter',int.parse(i.key.split('l')[1]) - 1,AI,'dosing_meter',v,2,d_m[2]]);
                configPvd.mappingOfInputsFunctionality(['m_i_dosing_meter',int.parse(i.key.split('l')[1]) - 1,AI,'dosing_meter',v,3,d_m[3]]);
                configPvd.mappingOfInputsFunctionality(['m_i_dosing_meter',int.parse(i.key.split('l')[1]) - 1,AI,'dosing_meter',v,4,d_m[4]]);
                configPvd.mappingOfInputsFunctionality(['m_i_dosing_meter',int.parse(i.key.split('l')[1]) - 1,AI,'dosing_meter',v,5,d_m[5]]);
                configPvd.mappingOfInputsFunctionality(['m_i_dosing_meter',int.parse(i.key.split('l')[1]) - 1,AI,'dosing_meter',v,6,d_m[6]]);
              }
              break;
            }
            case ('PS_in'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var d_ps = j.value.split(',');
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor_out',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor_out',1,returnDeviceName(d_ps[1])]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor_out',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor_out',2,d_ps[2]]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor_out',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor_out',3,d_ps[3]]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor_out',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor_out',4,d_ps[4]]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor_out',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor_out',5,d_ps[5]]);
              break;
            }
            case ('PS_out'):{
              var AI = '';
              for(var j in i.value.entries) {
                if (j.key == 'AI') {
                  AI = j.value;
                }
              }
              var d_ps = j.value.split(',');
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor',1,returnDeviceName(d_ps[1])]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor',2,d_ps[2]]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor',3,d_ps[3]]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor',4,d_ps[4]]);
              configPvd.mappingOfInputsFunctionality(['m_i_D_pressure_sensor',int.parse(i.key.split('l')[1]) - 1,AI,'D_pressure_sensor',5,d_ps[5]]);
              break;
            }
          }
        }
      }
      if(i.key.contains('AS')){
        var AS = i.value.split('|');
        for(var as in AS){
          var A_Sensor = as.split(',');
          configPvd.mappingOfInputsFunctionality(['m_i_analog_sensor',int.parse(A_Sensor[0]) - 1,1,returnDeviceName(A_Sensor[1])]);
          configPvd.mappingOfInputsFunctionality(['m_i_analog_sensor',int.parse(A_Sensor[0]) - 1,2,A_Sensor[2]]);
          configPvd.mappingOfInputsFunctionality(['m_i_analog_sensor',int.parse(A_Sensor[0]) - 1,3,A_Sensor[3]]);
          configPvd.mappingOfInputsFunctionality(['m_i_analog_sensor',int.parse(A_Sensor[0]) - 1,4,A_Sensor[4]]);
          configPvd.mappingOfInputsFunctionality(['m_i_analog_sensor',int.parse(A_Sensor[0]) - 1,5,A_Sensor[5]]);
        }
      }
      if(i.key.contains('CONT')){
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfInputsFunctionality(['m_i_contacts',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfInputsFunctionality(['m_i_contacts',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfInputsFunctionality(['m_i_contacts',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfInputsFunctionality(['m_i_contacts',int.parse(CONT[0]) - 1,4,CONT[4]]);
          configPvd.mappingOfInputsFunctionality(['m_i_contacts',int.parse(CONT[0]) - 1,5,CONT[5]]);
        }
      }
      if(i.key.contains('M_Sensor')){
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfInputsFunctionality(['m_i_moisture_sensor',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfInputsFunctionality(['m_i_moisture_sensor',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfInputsFunctionality(['m_i_moisture_sensor',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfInputsFunctionality(['m_i_moisture_sensor',int.parse(CONT[0]) - 1,4,CONT[4]]);
          configPvd.mappingOfInputsFunctionality(['m_i_moisture_sensor',int.parse(CONT[0]) - 1,5,CONT[5]]);
        }
      }
      if(i.key.contains('PH_Sensor')){
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfInputsFunctionality(['m_i_ph_sensor',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfInputsFunctionality(['m_i_ph_sensor',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfInputsFunctionality(['m_i_ph_sensor',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfInputsFunctionality(['m_i_ph_sensor',int.parse(CONT[0]) - 1,4,CONT[4]]);
          configPvd.mappingOfInputsFunctionality(['m_i_ph_sensor',int.parse(CONT[0]) - 1,5,CONT[5]]);
        }
      }
      if(i.key.contains('EC_Sensor')){
        var CT = i.value.split('|');
        for(var ct in CT){
          var CONT = ct.split(',');
          configPvd.mappingOfInputsFunctionality(['m_i_ec_sensor',int.parse(CONT[0]) - 1,1,returnDeviceName(CONT[1])]);
          configPvd.mappingOfInputsFunctionality(['m_i_ec_sensor',int.parse(CONT[0]) - 1,2,CONT[2]]);
          configPvd.mappingOfInputsFunctionality(['m_i_ec_sensor',int.parse(CONT[0]) - 1,3,CONT[3]]);
          configPvd.mappingOfInputsFunctionality(['m_i_ec_sensor',int.parse(CONT[0]) - 1,4,CONT[4]]);
          configPvd.mappingOfInputsFunctionality(['m_i_ec_sensor',int.parse(CONT[0]) - 1,5,CONT[5]]);
        }
      }
    }

    for(var i in myData['all_AI'].entries){
      print('i.key : ${i.key}');
      switch(i.key){
        case ('autoIncrement'):{
          print(i.value);
          configPvd.updateAI(['autoIncrement',i.value]);
          break;
        }
        case ('C_D_autoIncrement'):{
          configPvd.updateAI(['C_D_autoIncrement',i.value]);
          break;
        }
        case ('C_F_autoIncrement'):{
          configPvd.updateAI(['C_F_autoIncrement',i.value]);
          break;
        }
        case ('P_autoIncrement'):{
          configPvd.updateAI(['P_autoIncrement',i.value]);
          break;
        }
        case ('I_O_autoIncrement'):{
          configPvd.updateAI(['I_O_autoIncrement',i.value]);
          break;
        }
        case ('CD_channel_autoIncrement'):{
          configPvd.updateAI(['CD_channel_autoIncrement',i.value]);
          break;
        }
      }
    }

    print('configPvd.autoIncrement : ${configPvd.autoIncrement}');
    print('configPvd.C_D_autoIncrement : ${configPvd.C_D_autoIncrement}');
    print('configPvd.C_F_autoIncrement : ${configPvd.C_F_autoIncrement}');
    print('configPvd.P_autoIncrement : ${configPvd.P_autoIncrement}');
    print('configPvd.I_O_autoIncrement : ${configPvd.I_O_autoIncrement}');
    print('configPvd.CD_channel_autoIncrement : ${configPvd.CD_channel_autoIncrement}');
    // print('configPvd.centralDosing : ${configPvd.centralDosing}');
    // print('configPvd.CD_for_MO : ${configPvd.CD_for_MO}');
    // print('configPvd.localDosing : ${configPvd.localDosing}');
    // print('configPvd.mappingOfOutputs} : ${configPvd.mappingOfOutputs}');
    // print('configPvd.mappingOfInputs : ${configPvd.mappingOfInputs}');
  }
}
