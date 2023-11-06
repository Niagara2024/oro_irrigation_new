import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfigMakerProvider extends ChangeNotifier{

  List<List<dynamic>> tabs = [
    ['Start','',Icons.play_circle_filled],
    ['Source','Pump',Icons.water],
    ['Irrigation','Pump',Icons.waterfall_chart],
    ['Central','Dosing',Icons.local_drink],
    ['Central','Filtration',Icons.filter_alt],
    ['Irrigation','Lines',Icons.timeline],
    ['Local','Dosing',Icons.local_hospital],
    ['Local','Filtration',Icons.filter_vintage],
    ['Weather','Station',Icons.track_changes],
    ['Mapping','of Output',Icons.compare_arrows],
    ['Mapping','of Input',Icons.compare_arrows],
    ['Finish','',Icons.check_circle],
  ];
  dynamic oldData = {};
  int totalWaterSource = 0;
  int totalWaterMeter = 0;
  int totalSourcePump = 0;
  int totalIrrigationPump = 0;
  int totalInjector = 0;
  int totalDosingMeter = 0;
  int totalBooster = 0;
  int totalCentralDosing = 0;
  int totalFilter = 0;
  int total_D_s_valve = 0;
  int total_p_sensor = 0;
  int totalCentralFiltration = 0;
  int totalValve = 0;
  int totalMainValve = 0;
  int totalIrrigationLine = 0;
  int totalLocalFiltration = 0;
  int totalLocalDosing = 0;
  int totalRTU = 0;
  int totalOroSwitch = 0;
  int totalOroSense = 0;
  int totalOroSmartRTU = 0;
  List<String> i_o_types = ['-','A-I','D-I','P-I','RS485','12C'];
  List<List<String>> totalAnalogSensor = [];
  List<List<String>> totalContact = [];
  List<List<String>> totalAgitator = [];
  List<List<String>> totalPhSensor = [];
  List<List<String>> totalEcSensor = [];
  List<List<String>> totalMoistureSensor = [];
  List<List<String>> totalFan = [];
  List<List<String>> totalFogger = [];
  List<dynamic> rtuForLine = [1,2,3,4,5,6,7];
  List<dynamic> switchForLine = [1,2,3,4,5,6,7,8,9,10,11];
  List<dynamic> OroSmartRtuForLine = [1,2,3,4,5];
  List<dynamic> OroSenseForLine = [1,2,3,4,5,6,7,8,9,10,11,12];
  List<dynamic> rtuForLine_others = [1,2,3,4,5,6,7];
  List<dynamic> switchForLine_others = [1,2,3,4,5,6,7,8,9,10,11];
  List<dynamic> OroSmartRtuForLine_others = [1,2,3,4,5];
  List<dynamic> OroSenseForLine_others = [1,2,3,4,5,6,7,8,9,10,11,12];
  bool sourcePumpSelection = false;
  bool sourcePumpSelectAll = false;
  List<String> waterSource = ['-','A', 'B', 'C', 'D', 'E', 'F'];
  List<List<dynamic>> sourcePump = [];
  List<List<dynamic>> irrigationPump = [];
  List<List<List<dynamic>>> centralDosing = [];
  List<List<dynamic>> centralFiltration = [];
  List<Map<String,dynamic>> irrigationLines = [ ];
  List<List<List<dynamic>>> localDosing = [];
  List<List<dynamic>> localFiltration = [];
  List<String> weatherStation = ['niagara ws'];
  List<Map<String,dynamic>> mappingOfOutputs = [];
  List<Map<String,dynamic>> mappingOfInputs = [];
  List<Map<String,dynamic>> previousDataOfM_O = [];
  List<Map<String,dynamic>> previousDataOfM_I = [];
  bool irrigationPumpSelection = false;
  bool irrigationPumpSelectAll = false;
  bool c_dosingSelection = false;
  bool c_dosingSelectAll = false;
  bool l_dosingSelection = false;
  bool l_dosingSelectAll = false;
  bool l_filtrationSelection = false;
  bool l_filtrationSelectALL = false;
  bool focus = false;
  bool centralFiltrationSelection = false;
  bool centralFiltrationSelectAll = false;
  bool irrigationSelection = false;
  bool irrigationSelectAll = false;
  bool loadIrrigationLine = false;
  List<String> central_dosing_site_list = ['-',];
  List<String> central_filtration_site_list = ['-',];
  List<String> water_source_list = ['-',];
  List<dynamic> overAll = [];
  int selection = 0;
  int autoIncrement = 0;
  int C_D_autoIncrement = 0;
  int C_F_autoIncrement = 0;
  int P_autoIncrement = 0;
  int I_O_autoIncrement = 0;
  int CD_channel_autoIncrement = 0;
  List<Map<String,dynamic>> CD_for_MO = [];
  List<Map<String, dynamic>> IP_MO = [];
  List<Map<String,dynamic>> SP_MO = [];
  List<Map<String,dynamic>> CF_for_MO = [];
  String map_i_o = '';

  void clearConfig(){
    oldData = {};
    totalWaterSource = 0;
    totalWaterMeter = 0;
    totalSourcePump = 0;
    totalIrrigationPump = 0;
    totalInjector = 0;
    totalDosingMeter = 0;
    totalBooster = 0;
    totalCentralDosing = 0;
    totalFilter = 0;
    total_D_s_valve = 0;
    total_p_sensor = 0;
    totalCentralFiltration = 0;
    totalValve = 0;
    totalMainValve = 0;
    totalIrrigationLine = 0;
    totalLocalFiltration = 0;
    totalLocalDosing = 0;
    totalRTU = 0;
    totalOroSwitch = 0;
    totalOroSense = 0;
    totalOroSmartRTU = 0;
    i_o_types = ['-','A-I','D-I','P-I','RS485','12C'];
    totalAnalogSensor = [];
    totalContact = [];
    totalAgitator = [];
    totalPhSensor = [];
    totalEcSensor = [];
    totalMoistureSensor = [];
    totalFan = [];
    totalFogger = [];
    rtuForLine = [1,2,3,4,5,6,7];
    switchForLine = [1,2,3,4,5,6,7,8,9,10,11];
    OroSmartRtuForLine = [1,2,3,4,5];
    OroSenseForLine = [1,2,3,4,5,6,7,8,9,10,11,12];
    rtuForLine_others = [1,2,3,4,5,6,7];
    switchForLine_others = [1,2,3,4,5,6,7,8,9,10,11];
    OroSmartRtuForLine_others = [1,2,3,4,5];
    OroSenseForLine_others = [1,2,3,4,5,6,7,8,9,10,11,12];
    sourcePumpSelection = false;
    sourcePumpSelectAll = false;
    waterSource = ['-','A', 'B', 'C', 'D', 'E', 'F'];
    sourcePump = [];
    irrigationPump = [];
    centralDosing = [];
    centralFiltration = [];
    irrigationLines = [ ];
    localDosing = [];
    localFiltration = [];
    weatherStation = ['niagara ws'];
    mappingOfOutputs = [];
    mappingOfInputs = [];
    previousDataOfM_O = [];
    previousDataOfM_I = [];
    irrigationPumpSelection = false;
    irrigationPumpSelectAll = false;
    c_dosingSelection = false;
    c_dosingSelectAll = false;
    l_dosingSelection = false;
    l_dosingSelectAll = false;
    l_filtrationSelection = false;
    l_filtrationSelectALL = false;
    focus = false;
    centralFiltrationSelection = false;
    centralFiltrationSelectAll = false;
    irrigationSelection = false;
    irrigationSelectAll = false;
    loadIrrigationLine = false;
    central_dosing_site_list = ['-'];
    central_filtration_site_list = ['-'];
    water_source_list = ['-',];
    overAll = [];
    selection = 0;
    autoIncrement = 0;
    C_D_autoIncrement = 0;
    C_F_autoIncrement = 0;
    P_autoIncrement = 0;
    I_O_autoIncrement = 0;
    CD_channel_autoIncrement = 0;
    CD_for_MO = [];
    IP_MO = [];
    SP_MO = [];
    CF_for_MO = [];
    map_i_o = '';
    notifyListeners();
  }
  void fetchAll(dynamic data){
    for(var i in data.entries){
      if(i.key == 'configMaker'){
        if(i.value.length != 0){
          var mydata = jsonDecode(i.value[0]['inputOutput']);
          oldData = mydata;
        }
      }
      if(i.key == 'referenceNo'){
        print('siv : ${i.value}');
        for(var j in i.value.entries){
          print(j.key);
          switch(j.key){
            case ('ORO LEVEL'):{

              break;
            }
            case ('ORO Sense'):{
              OroSenseForLine = j.value;
              totalOroSense = j.value.length;
              OroSenseForLine_others = j.value;
              break;
            }
            case ('ORO Extend'):{
              break;
            }
            case ('ORO SWITCH'):{
              switchForLine = j.value;
              totalOroSwitch = j.value.length;
              switchForLine_others = j.value;
              break;
            }
            case ('ORO RTU'):{
              rtuForLine = j.value;
              totalRTU = j.value.length;
              rtuForLine_others = j.value;
              break;
            }
            case ('ORO SMART RTU'):{
              OroSmartRtuForLine = j.value;
              totalOroSmartRTU = j.value.length;
              OroSmartRtuForLine_others = j.value;
              break;
            }
            default : {
              print('nothing');
            }
          }
        }
      }
      if(i.key == 'productLimit'){
        for(var j in i.value){
          switch (j['product']){
            case ('Irrigation lines') : {
              totalIrrigationLine = j['quantity'];
              break;
            }
            case ('Central dosing sites') : {
              totalCentralDosing = j['quantity'];
              break;
            }
            case ('Central filtration sites') : {
              totalCentralFiltration = j['quantity'];
              break;
            }
            case ('Valve') : {
              totalValve = j['quantity'];
              break;
            }
            case ('Main Valve') : {
              totalMainValve = j['quantity'];
              break;
            }
            case ('Source Pump') : {
              totalSourcePump = j['quantity'];
              break;
            }
            case ('Irrigation Pump') : {
              totalIrrigationPump = j['quantity'];
              break;
            }
            case ('Filters') : {
              totalFilter = j['quantity'];
              break;
            }
            case ('Dosing Channel') : {
              totalInjector = j['quantity'];
              break;
            }
            case ('Dosing Booster') : {
              totalBooster = j['quantity'];
              break;
            }
            case ('Analog Sensors') : {
              for(var k = 0;k < j['quantity'];k++){
                totalAnalogSensor.add(['Analog Sensor ${k+1}','-','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('Contacts') : {
              for(var k = 0;k < j['quantity'];k++){
                totalContact.add(['Contact ${k+1}','-','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('Agitator') : {
              for(var k = 0;k < j['quantity'];k++){
                totalAgitator.add(['Agitator ${k+1}','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('pH sensor') : {
              for(var k = 0;k < j['quantity'];k++){
                totalPhSensor.add(['PH sensor ${k+1}','-','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('Ec sensor') : {
              for(var k = 0;k < j['quantity'];k++){
                totalEcSensor.add(['EC sensor ${k+1}','-','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('Fan') : {
              for(var k = 0;k < j['quantity'];k++){
                totalFan.add(['Fan ${k+1}','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('Fogger') : {
              for(var k = 0;k < j['quantity'];k++){
                totalFogger.add(['Fogger ${k+1}','-','-','-','${returnI_O_AutoIncrement()}']);
              }
              break;
            }
            case ('Pressure sensor') : {
              total_p_sensor = j['quantity'];
              break;
            }
            case ('Dosing meter') : {
              totalDosingMeter = j['quantity'];
              break;
            }
            case ('Water Meter') : {
              totalWaterMeter = j['quantity'];
              break;
            }
          }
        }
      }
    }
    notifyListeners();
  }


  // int I_P_autoIncrement = 0;
  int initialIndex = 0;
  void editInitialIndex(int index){
    initialIndex = index;
    notifyListeners();
  }

  void cancelSelection(){
    selection = 0;
    notifyListeners();
  }
  int returnCD_channel_autoIncrement(){
    CD_channel_autoIncrement += 1;
    int val = CD_channel_autoIncrement;
    notifyListeners();
    return val;
  }

  void editLoadIL(bool value){
    Future.delayed(Duration(seconds: 1), () {
      loadIrrigationLine = value;
      notifyListeners();
    });
  }
  void serialNumber(String title,int val){
    switch (title){
      case('sourcePump') : {
        P_autoIncrement = val;
        break;
      }
      case('irrigationPump') : {
        P_autoIncrement = val;
        break;
      }
      case('CentralFiltration') : {
        C_F_autoIncrement = val;
        break;
      }
      case('CentralDosing') : {
        C_D_autoIncrement = val;
        break;
      }
    }
    notifyListeners();
  }
  void refreshCentralDosingList(){
    central_dosing_site_list = ['-'];
    for(var i = 0;i < centralDosing.length; i++){
      central_dosing_site_list.add('${i + 1}');
    }
    for(var i = 0;i < irrigationLines.length;i++){
      if(!central_dosing_site_list.contains(irrigationLines[i]['Central_dosing_site'])){
        irrigationLines[i]['Central_dosing_site'] = '-';
      }
    }
    notifyListeners();
  }
  void refreshCentralFiltrationList(){
    central_filtration_site_list = ['-'];
    for(var i = 0;i < centralFiltration.length; i++){
      central_filtration_site_list.add('${i + 1}');
    }
    for(var i = 0;i < irrigationLines.length;i++){
      if(!central_filtration_site_list.contains(irrigationLines[i]['Central_filtration_site'])){
        irrigationLines[i]['Central_filtration_site'] = '-';
      }
    }
    notifyListeners();
  }
  int returnI_O_AutoIncrement(){
    I_O_autoIncrement += 1;
    int val = I_O_autoIncrement;
    notifyListeners();
    return val;
  }

  void sourcePumpFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('editsourcePumpSelection') : {
        sourcePumpSelection = list[1];
        if(list[1] == true){
          for(var i = 0;i < sourcePump.length;i ++){
            sourcePump[i][2] = 'unselect';
          }
        }
        break;
      }
      case ('editsourcePumpSelectAll') : {
        sourcePumpSelectAll = list[1];
        if(list[1] == true){
          selection = 0;
          for(var i = 0;i < sourcePump.length;i ++){
            selection = selection + 1;
            sourcePump[i][2] = 'select';
          }
        }else{
          selection = 0;
          for(var i = 0;i < sourcePump.length;i ++){
            sourcePump[i][2] = 'unselect';
          }
        }
        break;
      }
      case ('editWaterMeter') : {
        if(totalWaterMeter > 0){
          for(var i in SP_MO){
            for(var j in i.entries){
              if(j.key == '${sourcePump[list[1]][3]}'){
                j.value['water_meter'][0] = list[2];
              }
            }
          }
          sourcePump[list[1]][1] = list[2];
          if(list[2] == true){
            totalWaterMeter = totalWaterMeter - 1;
          }else{
            totalWaterMeter = totalWaterMeter + 1;
          }

        }
        if(totalWaterMeter == 0){
          if(list[2] == false){
            sourcePump[list[1]][1] = list[2];
            totalWaterMeter = totalWaterMeter + 1;
          }
        }
        break;
      }
      case ('addSourcePump') : {
        if(totalSourcePump > 0){
          P_autoIncrement += 1;
          sourcePump.add(['-', false,'unselect', P_autoIncrement]);
          SP_MO.add({
            '${P_autoIncrement}' : {
              'pump' : ['1','-','-','-','${returnI_O_AutoIncrement()}'],
              'water_meter' : [false,'-','-','-','-','${returnI_O_AutoIncrement()}'],
            }
          });
          totalSourcePump = totalSourcePump - 1;
        }
        break;
      }
      case ('editWaterSource_sp') : {
        sourcePump[list[1]][0] = list[2];
        break;
      }
      case ('selectSourcePump') : {
        if(list[2] == true){
          sourcePump[list[1]][2] = 'select';
          selection = selection + 1;
        }else{
          sourcePump[list[1]][2] = 'unselect';
          selection = selection - 1;
        }
        break;
      }
      case ('deleteSourcePump') : {
        var SP_MO_copy = List.from(SP_MO);
        for(var i = sourcePump.length -1 ; i >= 0; i--){
          if(sourcePump[i][2] == 'select'){
            for(var j in SP_MO_copy){
              for(var k in j.entries){
                if(k.key == '${sourcePump[i][3]}'){
                  SP_MO.remove(j);
                }
              }
            }
            if(sourcePump[i][1] == true){
              totalWaterMeter = totalWaterMeter + 1;
            }
            sourcePump.removeAt(i);
            totalSourcePump = totalSourcePump + 1;
          }
        }
        sourcePumpSelectAll = false;
        sourcePumpSelection = false;
        break;
      }
      default : {
        break;
      }
    }
    notifyListeners();
  }
  void irrigationPumpFunctionality(List<dynamic> list){
    switch (list[0]){
      case 'addIrrigationPump': {
        if(totalIrrigationPump > 0){
          P_autoIncrement += 1;
          irrigationPump.add([false, ['unselect',P_autoIncrement]]);
          IP_MO.add({
            '${P_autoIncrement}' : {
              'pump' : ['1','-','-','-','${returnI_O_AutoIncrement()}'],
              'water_meter' : [false,'-','-','-','-','${returnI_O_AutoIncrement()}']
            }
          });
          totalIrrigationPump = totalIrrigationPump - 1;
        }
        break;
      }
      case 'editIrrigationPumpSelection' : {
        irrigationPumpSelection = list[1];
        if(list[1] == true){
          for(var i = 0;i < irrigationPump.length;i ++){
            irrigationPump[i][1][0] = 'unselect';
          }
        }
        break;
      }
      case 'editIrrigationPumpSelectAll' : {
        irrigationPumpSelectAll = list[1];
        if(list[1] == true){
          selection = 0;
          for(var i = 0;i < irrigationPump.length;i ++){
            irrigationPump[i][1][0] = 'select';
            selection += 1;
          }
        }else{
          for(var i = 0;i < irrigationPump.length;i ++){
            irrigationPump[i][1][0] = 'unselect';
            selection = 0;
          }
        }
        break;
      }
      case 'editWaterMeter' : {
        if(totalWaterMeter > 0){
          for(var i in IP_MO){
            for(var j in i.entries){
              if(j.key == '${irrigationPump[list[1]][1][1]}'){
                j.value['water_meter'][0] = list[2];
              }
            }
          }
          irrigationPump[list[1]][0] = list[2];
          if(list[2] == true){
            totalWaterMeter = totalWaterMeter - 1;
          }else{
            totalWaterMeter = totalWaterMeter + 1;
          }

        }
        if(totalWaterMeter == 0){
          if(list[2] == false){
            irrigationPump[list[1]][0] = list[2];
            totalWaterMeter = totalWaterMeter + 1;
          }
        }
        break;
      }
      case 'selectIrrigationPump' : {
        if(irrigationPump[list[1]][1][0] == 'select'){
          irrigationPump[list[1]][1][0] = 'unselect';
          selection -= 1;
        }else{
          irrigationPump[list[1]][1][0] = 'select';
          selection += 1;
        }
        break;
      }
      case 'deleteIrrigationPump' : {
        var IP_MO_copy = List.from(IP_MO);
        for(var i = irrigationPump.length -1 ; i >= 0; i--){
          if(irrigationPump[i][1][0] == 'select'){
            for(var j in IP_MO_copy){
              for(var k in j.entries){
                if(k.key == '${irrigationPump[i][1][1]}'){
                  IP_MO.remove(j);
                }
              }
            }
            if(irrigationPump[i][0] == true){
              totalWaterMeter = totalWaterMeter + 1;
            }
            for(var j in irrigationLines){
              if(j['irrigationPump'] == '${i + 1}'){
                j['irrigationPump'] = '-';
              }
            }
            irrigationPump.removeAt(i);
            totalIrrigationPump = totalIrrigationPump + 1;
          }
        }
        irrigationPumpSelection = false;
        irrigationPumpSelectAll = false;
        break;
      }
      default : {
        break;
      }
    }
    notifyListeners();

  }

  void centralDosingFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addCentralDosing') : {
        if(totalCentralDosing > 0 && totalInjector > 0){
          C_D_autoIncrement += 1;
          var channelSI = returnCD_channel_autoIncrement();
          centralDosing.add([[1,false,false,'${channelSI}'],['unselect',C_D_autoIncrement]]);
          CD_for_MO.add({
            '${C_D_autoIncrement}' : {
              'injector' : [['1','-','-','-','${channelSI}','${returnI_O_AutoIncrement()}']],
              'dosing_meter' : [[false,'-','-','-','-','${channelSI}','${returnI_O_AutoIncrement()}']],
              'booster' : [[false,'-','-','-','${channelSI}','${returnI_O_AutoIncrement()}']],
            }
          });
          totalCentralDosing = totalCentralDosing - 1;
          totalInjector = totalInjector - 1;
          refreshCentralDosingList();
        }
        break;
      }
      case ('addBatch_CD') : {
        if(totalCentralDosing > 0 && totalInjector > 0){
          for(var i = 0;i < list[1];i++){
            totalCentralDosing -= 1;
            List<List<dynamic>> myList = [];
            List<List<dynamic>> injector = [];
            List<List<dynamic>> d_meter = [];
            List<List<dynamic>> booster = [];
            C_D_autoIncrement += 1;
            for(var j = 0;j < list[2];j++){
              totalInjector = totalInjector - 1;
              if(list[3] == true){
                totalDosingMeter = totalDosingMeter - 1;
              }
              if(list[4] == true){
                totalBooster = totalBooster - 1;
              }
              var channelAI = returnCD_channel_autoIncrement();
              myList.add([j+1,list[3],list[4],'${channelAI}']);
              injector.add(['${j+1}','-','-','-','${channelAI}','${returnI_O_AutoIncrement()}']);
              d_meter.add([list[3],'-','-','-','-','${channelAI}','${returnI_O_AutoIncrement()}']);
              booster.add([list[4],'-','-','-','${channelAI}','${returnI_O_AutoIncrement()}']);
            }
            myList.add(['unselect',C_D_autoIncrement]);
            CD_for_MO.add({
              '${C_D_autoIncrement}' : {
                'injector' : injector,
                'dosing_meter' : d_meter,
                'booster' : booster,
              }
            });
            centralDosing.add(myList);
            refreshCentralDosingList();
          }
        }
        break;
      }
      case ('c_dosingSelection') : {
        c_dosingSelection = list[1];
        break;
      }
      case ('c_dosingSelectAll') : {
        c_dosingSelectAll = list[1];
        if(list[1] == true){
          selection = 0;
          for(var i = 0;i < centralDosing.length;i ++){
            centralDosing[i][centralDosing[i].length - 1] = ['select'];
            selection += 1;
          }
        }else{
          for(var i = 0;i < centralDosing.length;i ++){
            centralDosing[i][centralDosing[i].length - 1] = ['unselect'];
            selection = 0;
          }
        }
        break;
      }
      case ('editDosingMeter') : {
        if(totalDosingMeter > 0){
          for(var i in CD_for_MO){
            for(var j in i.entries){
              if(j.key == '${centralDosing[list[1]][centralDosing[list[1]].length - 1][1]}'){
                j.value['dosing_meter'][list[2]][0] = list[3];
              }
            }
          }
          centralDosing[list[1]][list[2]][1] = list[3];
          if(list[3] == true){
            totalDosingMeter = totalDosingMeter - 1;
          }else{
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        if(totalDosingMeter == 0){
          if(list[3] == false){
            centralDosing[list[1]][list[2]][1] = list[3];
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        break;
      }
      case ('editChannelNumber') : {
        centralDosing[list[1]][list[2]][3] = list[3];
        break;
      }
      case ('editBooster') : {
        if(totalBooster > 0){
          for(var i in CD_for_MO){
            for(var j in i.entries){
              if(j.key == '${centralDosing[list[1]][centralDosing[list[1]].length - 1][1]}'){
                j.value['booster'][list[2]][0] = list[3];
              }
            }
          }
          centralDosing[list[1]][list[2]][2] = list[3];
          if(list[3] == true){
            totalBooster = totalBooster - 1;
          }else{
            totalBooster = totalBooster + 1;
          }
        }
        if(totalBooster == 0){
          if(list[3] == false){
            centralDosing[list[1]][list[2]][2] = list[3];
            totalBooster = totalBooster + 1;
          }
        }
        break;
      }
      case ('selectCentralDosing') : {
        if(centralDosing[list[1]][centralDosing[list[1]].length - 1][0] == 'unselect'){
          centralDosing[list[1]][centralDosing[list[1]].length - 1][0] = 'select';
          selection += 1;
        }else{
          centralDosing[list[1]][centralDosing[list[1]].length - 1][0] = 'unselect';
          selection -= 1;
        }
        break;
      }
      case ('deleteCentralDosing') : {
        var CD_for_MO_copy = List.from(CD_for_MO);
        for(var i = centralDosing.length - 1; i >= 0; i--){
          if(centralDosing[i][centralDosing[i].length - 1][0] == 'select'){
            for(var j in CD_for_MO_copy) { // Iterate over the copy
              for (var k in j.entries) {
                if (k.key == '${centralDosing[i][centralDosing[i].length - 1][1]}') {
                  CD_for_MO.remove(j); // Modify the original list
                }
              }
            }
            for(var j = 0; j< centralDosing[i].length;j++){
              if(j != centralDosing[i].length - 1){
                if(centralDosing[i][j][1] == true){
                  totalDosingMeter = totalDosingMeter + 1;
                }
                if(centralDosing[i][j][2] == true){
                  totalBooster = totalBooster + 1;
                }
              }
            }
            centralDosing.removeAt(i);
            totalCentralDosing = totalCentralDosing + 1;
            totalInjector = totalInjector + 1;
            refreshCentralDosingList();
          }
        }
        break;
      }
      default : {
        break;
      }
    }
    notifyListeners();

  }
  void centralFiltrationFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addCentralFiltration') : {
        if(totalCentralFiltration > 0 && totalFilter > 0){
          C_F_autoIncrement += 1;
          CF_for_MO.add({
            '${C_F_autoIncrement}' : {
              'filter' : [['1','-','-','-','${returnI_O_AutoIncrement()}']],
              'D_S_valve' : [false,'-','-','-','${returnI_O_AutoIncrement()}'],
              'P_sensor' : [false,'-','-','-','-','${returnI_O_AutoIncrement()}'],
              'P_sensor_out' : [false,'-','-','-','-','${returnI_O_AutoIncrement()}']
            }
          });
          centralFiltration.add(['1',false,false,false,['unselect',C_F_autoIncrement]]);
          totalCentralFiltration = totalCentralFiltration - 1;
          totalFilter = totalFilter - 1;
          refreshCentralFiltrationList();
        }
        break;
      }
      case ('centralFiltrationSelection') : {
        centralFiltrationSelection = list[1];
        break;
      }
      case ('editFocus') : {
        focus = list[1];
        break;
      }
      case ('centralFiltrationSelectAll') : {
        centralFiltrationSelectAll = list[1];
        if(list[1] == true){
          for(var i = 0;i < centralFiltration.length;i ++){
            centralFiltration[i][4][0] = 'select';
          }
        }else{
          for(var i = 0;i < centralFiltration.length;i ++){
            centralFiltration[i][4][0] = 'unselect';
          }
        }
        break;
      }
      case ('editFilters') : {
        if(totalFilter > -1){
          if(centralFiltration[list[1]][0] != ''){
            totalFilter = totalFilter + int.parse(centralFiltration[list[1]][0]);
            if(list[2] == ''){
              totalFilter = totalFilter - 0;
            }else{
              if(list[2] == '0'){
                totalFilter = totalFilter - 1;
              }else{
                totalFilter = totalFilter - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalFilter = totalFilter - 1;
            }else{
              totalFilter = totalFilter - int.parse(list[2]);
            }
          }
          centralFiltration[list[1]][0] = list[2];
          if(list[2] != ''){
            List<List<String>> myList = [];
            for(var i in CF_for_MO){
              for(var j in i.entries){
                if(j.key == '${centralFiltration[list[1]][4][1]}'){
                  if(j.value['filter'].length > int.parse(list[2])){
                    for(var k = 0;k < int.parse(list[2]);k++){
                      myList.add(j.value['filter'][k]);
                    }
                    j.value['filter'] = myList;
                  }else{
                    for(var k = 0;k < int.parse(list[2]) - j.value['filter'].length;k++){
                      myList.add(['${j.value['filter'].length + k + 1}','-','-','-','${returnI_O_AutoIncrement()}']);
                    }
                    for(var i in myList){
                      j.value['filter'].add(i);
                    }
                  }
                }
              }
            }
          }
        }
        break;
      }
      case ('editDownStreamValve') : {
        if(total_D_s_valve > 0){
          for(var i in CF_for_MO){
            for(var j in i.entries){
              if(j.key == '${centralFiltration[list[1]][4][1]}'){
                j.value['D_S_valve'][0] = list[2];
              }
            }
          }
          centralFiltration[list[1]][1] = list[2];
          if(list[2] == true){
            total_D_s_valve = total_D_s_valve - 1;
          }else{
            total_D_s_valve = total_D_s_valve + 1;
          }

        }
        if(total_D_s_valve == 0){
          if(list[2] == false){
            centralFiltration[list[1]][1] = list[2];
            total_D_s_valve = total_D_s_valve + 1;
          }
        }
        break;
      }
      case ('editPressureSensor') : {
        if(total_p_sensor > 0){
          for(var i in CF_for_MO){
            for(var j in i.entries){
              if(j.key == '${centralFiltration[list[1]][4][1]}'){
                j.value['P_sensor'][0] = list[2];
              }
            }
          }
          centralFiltration[list[1]][2] = list[2];
          if(list[2] == true){
            total_p_sensor = total_p_sensor - 1;
          }else{
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            centralFiltration[list[1]][2] = list[2];
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('editPressureSensor_out') : {
        if(total_p_sensor > 0){
          for(var i in CF_for_MO){
            for(var j in i.entries){
              if(j.key == '${centralFiltration[list[1]][4][1]}'){
                j.value['P_sensor_out'][0] = list[2];
              }
            }
          }
          centralFiltration[list[1]][3] = list[2];
          if(list[2] == true){
            total_p_sensor = total_p_sensor - 1;
          }else{
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            centralFiltration[list[1]][3] = list[2];
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('selectCentralFiltration') : {
        if(centralFiltration[list[1]][4][0] == 'select'){
          centralFiltration[list[1]][4][0] = 'unselect';
        }else{
          centralFiltration[list[1]][4][0] = 'select';
        }
        break;
      }
      case ('deleteCentralFiltration') : {
        var CF_for_MO_copy = List.from(CF_for_MO);
        for(var i = centralFiltration.length -1 ; i >= 0; i--){
          if(centralFiltration[i][4][0] == 'select'){
            for(var j in CF_for_MO_copy){
              for(var k in j.entries){
                if(k.key == '${centralFiltration[i][4][1]}'){
                  CF_for_MO.remove(j);
                }
              }
            }
            if(centralFiltration[i][1] == true){
              total_D_s_valve = total_D_s_valve + 1;
            }
            if(centralFiltration[i][2] == true){
              total_p_sensor = total_p_sensor + 1;
            }
            if(centralFiltration[i][0] != ''){
              totalFilter = totalFilter + int.parse(centralFiltration[i][0]);
            }
            centralFiltration.removeAt(i);
            totalCentralFiltration = totalCentralFiltration + 1;
            refreshCentralFiltrationList();
          }
        }
        centralFiltrationSelectAll = false;
        centralFiltrationSelection = false;

        break;
      }
      default :{
        break;
      }
    }
    notifyListeners();
  }

  void editRfList(List<dynamic> list){
    switch (list[0]){
      case ('OSRTU'):{
        irrigationLines[list[1]]['myOroSmartRtu'] = list[2];
        break;
      }
      case ('ORTU'):{
        irrigationLines[list[1]]['myRTU'] = list[2];
        break;
      }
      case ('OSWTCH'):{
        irrigationLines[list[1]]['myOROswitch'] = list[2];
        break;
      }
      case ('OSENSE'):{
        irrigationLines[list[1]]['myOROsense'] = list[2];
        break;
      }
    }
    notifyListeners();
  }
  void editRfList1(){
    OroSmartRtuForLine = List.from(OroSmartRtuForLine_others);
    rtuForLine = List.from(rtuForLine_others);
    switchForLine = List.from(switchForLine_others);
    OroSenseForLine = List.from(OroSenseForLine_others);
    for(var i = 0;i < irrigationLines.length;i++){
      for(var j in irrigationLines[i]['myOroSmartRtu']){
        OroSmartRtuForLine.remove(j);
      }
      for(var j in irrigationLines[i]['myRTU']){
        rtuForLine.remove(j);
      }
      for(var j in irrigationLines[i]['myOROswitch']){
        switchForLine.remove(j);
      }
      for(var j in irrigationLines[i]['myOROsense']){
        OroSenseForLine.remove(j);
      }
    }
    notifyListeners();
  }
  void irrigationLinesFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addIrrigationLine'): {
        if(totalIrrigationLine > 0 && totalValve > 0){
          autoIncrement += 1;
          irrigationLines.add({
            'valve' : '1',
            'main_valve' : '',
            'Central_dosing_site' : '-',
            'Central_filtration_site' : '-',
            'Local_dosing_site' : false,
            'local_filtration_site' : false,
            'pressure_sensor' : false,
            'irrigationPump' : '-',
            'water_meter' : false,
            'ORO_Smart_RTU' : '',
            'RTU' : '',
            'ORO_switch' : '',
            'ORO_sense' : '',
            'isSelected' : 'unselect',
            'myRTU_list' : ['-'],
            'myOroSmartRtu' : [],
            'myRTU' : [],
            'myOROswitch' : [],
            'myOROsense' : [],
            'autoIncrement' : autoIncrement,
          },);
          totalIrrigationLine = totalIrrigationLine - 1;
          totalValve = totalValve - 1;
        }
        break;
      }
      case ('updateAI') : {
        irrigationLines[list[1]]['autoIncrement'] = list[2];
        break;
      }
      case ('editIrrigationSelectAll') : {
        irrigationSelectAll = list[1];
        if(list[1] == true){
          selection = 0;
          for(var i = 0;i < irrigationLines.length;i ++){
            irrigationLines[i]['isSelected'] = 'select';
            selection += 1;
          }
        }else{
          selection = 0;
          for(var i = 0;i < irrigationLines.length;i ++){
            irrigationLines[i]['isSelected'] = 'unselect';
          }
        }

        break;
      }
      case ('editIrrigationSelection') : {
        irrigationSelection = list[1];
        break;
      }
      case ('selectIrrigationLine'): {
        if(list[2] == true){
          irrigationLines[list[1]]['isSelected'] = 'select';
          selection += 1;
        }else{
          irrigationLines[list[1]]['isSelected'] = 'unselect';
          selection -= 1;
        }

        break;
      }
      case 'deleteIrrigationLine': {
        irrigationSelection = false;
        irrigationSelectAll = false;
        for (var i = irrigationLines.length - 1; i >= 0; i--) {
          if (irrigationLines[i]['isSelected'] == 'select') {
            if(irrigationLines[i]['Local_dosing_site'] == true){
              totalInjector += 1;
              for(var j = localDosing.length - 1;j >= 0;j--){
                if(localDosing[j][localDosing[j].length -1][1] == i+1){
                  for(var ld = 0; ld < localDosing[j].length - 1;ld++){
                    if(localDosing[j][ld][1] == true){
                      totalDosingMeter += 1;
                    }
                    if(localDosing[j][ld][2] == true){
                      totalBooster += 1;
                    }
                  }
                  localDosing.removeAt(j);
                }

              }
            }
            if(irrigationLines[i]['local_filtration_site'] == true){
              totalFilter += 1;
              for(var j = 0;j < localFiltration.length;j++){
                if(localFiltration[j][0] == i+1){
                  if(localFiltration[j][2] == true){
                    total_D_s_valve += 1;
                  }
                  if(localFiltration[j][3] == true){
                    total_p_sensor += 1;
                  }
                  localFiltration.removeAt(j);
                }
              }
            }
            if(irrigationLines[i]['myOroSmartRtu'].length != 0){
              for(var i in irrigationLines[i]['myOroSmartRtu']){
                OroSmartRtuForLine.add(i);
              }
              OroSmartRtuForLine.sort();
            }
            if(irrigationLines[i]['myRTU'].length != 0){
              for(var i in irrigationLines[i]['myRTU']){
                rtuForLine.add(i);
              }
              rtuForLine.sort();
            }
            if(irrigationLines[i]['myOROswitch'].length != 0){
              for(var i in irrigationLines[i]['myOROswitch']){
                switchForLine.add(i);
              }
              switchForLine.sort();
            }
            if(irrigationLines[i]['ORO_Smart_RTU'].length != 0){
              totalOroSmartRTU = totalOroSmartRTU + int.parse(irrigationLines[i]['ORO_Smart_RTU']);
            }
            if(irrigationLines[i]['RTU'].length != 0){
              totalRTU = totalRTU + int.parse(irrigationLines[i]['RTU']);
            }
            if(irrigationLines[i]['ORO_switch'].length != 0){
              totalOroSwitch = totalOroSwitch + int.parse(irrigationLines[i]['ORO_switch']);
            }
            if(irrigationLines[i]['ORO_sense'].length != 0){
              totalOroSense = totalOroSense + int.parse(irrigationLines[i]['ORO_sense']);
            }
            totalValve = totalValve + int.parse(irrigationLines[i]['valve']);
            totalIrrigationLine = totalIrrigationLine + 1;
            irrigationLines.removeAt(i);
          }
        }
        break;
      }
      case ('editValve'): {
        if(totalValve > -1){
          if(irrigationLines[list[1]]['valve'] != ''){
            totalValve = totalValve + int.parse(irrigationLines[list[1]]['valve']);
            if(list[2] == ''){
              totalValve = totalValve - 0;
            }else{
              if(list[2] == '0'){
                totalValve = totalValve - 1;
              }else{
                totalValve = totalValve - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalValve = totalValve - 1;
            }else{
              totalValve = totalValve - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['valve'] = list[2];
        }
        print('function finished for valve');
        break;
      }
      case ('editMainValve'): {
        if(totalMainValve > -1){
          if(irrigationLines[list[1]]['main_valve'] != ''){
            totalMainValve = totalMainValve + int.parse(irrigationLines[list[1]]['main_valve']);
            if(list[2] == ''){
              totalMainValve = totalMainValve - 0;
            }else{
              if(list[2] == '0'){
                totalMainValve = totalMainValve - 1;
              }else{
                totalMainValve = totalMainValve - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalMainValve = totalMainValve - 1;
            }else{
              totalMainValve = totalMainValve - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['main_valve'] = list[2];
        }
        break;
      }
      case ('editOroSmartRtu'): {
        if(totalOroSmartRTU > -1){
          if(irrigationLines[list[1]]['ORO_Smart_RTU'] != ''){
            totalOroSmartRTU = totalOroSmartRTU + int.parse(irrigationLines[list[1]]['ORO_Smart_RTU']);
            if(list[2] == ''){
              totalOroSmartRTU = totalOroSmartRTU - 0;
            }else{
              if(list[2] == '0'){
                totalOroSmartRTU = totalOroSmartRTU - 1;
              }else{
                totalOroSmartRTU = totalOroSmartRTU - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalOroSmartRTU = totalOroSmartRTU - 1;
            }else{
              totalOroSmartRTU = totalOroSmartRTU - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['ORO_Smart_RTU'] = list[2];
          if(irrigationLines[list[1]]['myOroSmartRtu'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myOroSmartRtu'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myOroSmartRtu'].add(OroSmartRtuForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myOroSmartRtu']){
              if(OroSmartRtuForLine.contains(i)){
                OroSmartRtuForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myOroSmartRtu'][0]);
              irrigationLines[list[1]]['myOroSmartRtu'].remove(irrigationLines[list[1]]['myOroSmartRtu'][0]);
            }
            for(var i in irrigationLines[list[1]]['myOroSmartRtu']){
              OroSmartRtuForLine.add(i);
            }
            irrigationLines[list[1]]['myOroSmartRtu'] = list1;
            OroSmartRtuForLine.sort();
          }else{
            OroSmartRtuForLine += irrigationLines[list[1]]['myOroSmartRtu'];
            irrigationLines[list[1]]['myOroSmartRtu'] = [];
            OroSmartRtuForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['ORO_Smart_RTU'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('ORO Smart RTU')){
              irrigationLines[list[1]]['myRTU_list'].remove('ORO Smart RTU');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('ORO Smart RTU')){
              irrigationLines[list[1]]['myRTU_list'].add('ORO Smart RTU');
            }
          }
        }
        break;
      }
      case ('editRTU'): {
        if(totalRTU > -1){
          if(irrigationLines[list[1]]['RTU'] != ''){
            totalRTU = totalRTU + int.parse(irrigationLines[list[1]]['RTU']);
            if(list[2] == ''){
              totalRTU = totalRTU - 0;
            }else{
              if(list[2] == '0'){
                totalRTU = totalRTU - 1;
              }else{
                totalRTU = totalRTU - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalRTU = totalRTU - 1;
            }else{
              totalRTU = totalRTU - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['RTU'] = list[2];
          if(irrigationLines[list[1]]['myRTU'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myRTU'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myRTU'].add(rtuForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myRTU']){
              if(rtuForLine.contains(i)){
                rtuForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myRTU'][0]);
              irrigationLines[list[1]]['myRTU'].remove(irrigationLines[list[1]]['myRTU'][0]);
            }
            for(var i in irrigationLines[list[1]]['myRTU']){
              rtuForLine.add(i);
            }
            irrigationLines[list[1]]['myRTU'] = list1;
            rtuForLine.sort();
          }else{
            rtuForLine += irrigationLines[list[1]]['myRTU'];
            irrigationLines[list[1]]['myRTU'] = [];
            rtuForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['RTU'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('ORO RTU')){
              irrigationLines[list[1]]['myRTU_list'].remove('ORO RTU');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('ORO RTU')){
              irrigationLines[list[1]]['myRTU_list'].add('ORO RTU');
            }
          }
        }
        ///////////////////////////////////////////////////////////////////////////////////////
        break;
      }
      case ('editOroSwitch'): {
        if(totalOroSwitch > -1){
          if(irrigationLines[list[1]]['ORO_switch'] != ''){
            totalOroSwitch = totalOroSwitch + int.parse(irrigationLines[list[1]]['ORO_switch']);
            if(list[2] == ''){
              totalOroSwitch = totalOroSwitch - 0;
            }else{
              if(list[2] == '0'){
                totalOroSwitch = totalOroSwitch - 1;
              }else{
                totalOroSwitch = totalOroSwitch - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalOroSwitch = totalOroSwitch - 1;
            }else{
              totalOroSwitch = totalOroSwitch - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['ORO_switch'] = list[2];

          /////////////////////////////////////////////
          if(irrigationLines[list[1]]['myOROswitch'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myOROswitch'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myOROswitch'].add(switchForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myOROswitch']){
              if(switchForLine.contains(i)){
                switchForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myOROswitch'][0]);
              irrigationLines[list[1]]['myOROswitch'].remove(irrigationLines[list[1]]['myOROswitch'][0]);
            }
            for(var i in irrigationLines[list[1]]['myOROswitch']){
              switchForLine.add(i);
            }
            irrigationLines[list[1]]['myOROswitch'] = list1;
            switchForLine.sort();
          }else{
            switchForLine += irrigationLines[list[1]]['myOROswitch'];
            irrigationLines[list[1]]['myOROswitch'] = [];
            switchForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['ORO_switch'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('ORO Switch')){
              irrigationLines[list[1]]['myRTU_list'].remove('ORO Switch');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('ORO Switch')){
              irrigationLines[list[1]]['myRTU_list'].add('ORO Switch');
            }
          }
        }
        break;
      }
      case ('editOroSense'): {
        if(totalOroSense > -1){
          if(irrigationLines[list[1]]['ORO_sense'] != ''){
            totalOroSense = totalOroSense + int.parse(irrigationLines[list[1]]['ORO_sense']);
            if(list[2] == ''){
              totalOroSense = totalOroSense - 0;
            }else{
              if(list[2] == '0'){
                totalOroSense = totalOroSense - 1;
              }else{
                totalOroSense = totalOroSense - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalOroSense = totalOroSense - 1;
            }else{
              totalOroSense = totalOroSense - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['ORO_sense'] = list[2];
          if(irrigationLines[list[1]]['myOROsense'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myOROsense'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myOROsense'].add(OroSenseForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myOROsense']){
              if(OroSenseForLine.contains(i)){
                OroSenseForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myOROsense'][0]);
              irrigationLines[list[1]]['myOROsense'].remove(irrigationLines[list[1]]['myOROsense'][0]);
            }
            for(var i in irrigationLines[list[1]]['myOROsense']){
              OroSenseForLine.add(i);
            }
            irrigationLines[list[1]]['myOROsense'] = list1;
            OroSenseForLine.sort();
          }else{
            OroSenseForLine += irrigationLines[list[1]]['myOROsense'];
            irrigationLines[list[1]]['myOROsense'] = [];
            OroSenseForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['ORO_sense'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('ORO Sense')){
              irrigationLines[list[1]]['myRTU_list'].remove('ORO Sense');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('ORO Sense')){
              irrigationLines[list[1]]['myRTU_list'].add('ORO Sense');
            }
          }
        }
        break;
      }
      case ('editLocalDosing'): {
        irrigationLines[list[1]]['Local_dosing_site'] = list[2];
        if(list[2] == true){
          localDosingFunctionality(['addLocalDosing',list[3],list[4],list[5],list[6],list[1]]);
        }else{
          localDosingFunctionality(['deleteLocalDosingFromLine',list[1]]);
        }
        break;
      }
      case ('editLocalFiltration'): {
        irrigationLines[list[1]]['local_filtration_site'] = list[2];
        if(list[2] == true){
          localFiltrationFunctionality(['addFiltrationDosing',list[1]]);
        }else{
          localFiltrationFunctionality(['deleteLocalFiltrationFromLine',list[1]]);
        }
        break;
      }
      case ('editPressureSensor'): {
        if(total_p_sensor > 0){
          irrigationLines[list[1]]['pressure_sensor'] = list[2];
          if(list[2] == true){
            total_p_sensor = total_p_sensor - 1;
          }else{
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            irrigationLines[list[1]]['pressure_sensor'] = list[2];
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('editCentralDosing'): {
        irrigationLines[list[1]]['Central_dosing_site'] = list[2];
        break;
      }
      case ('editCentralFiltration'): {
        irrigationLines[list[1]]['Central_filtration_site'] = list[2];
        break;
      }
      case ('editIrrigationPump'): {
        irrigationLines[list[1]]['irrigationPump'] = list[2];
        break;
      }
      case ('editWaterMeter'): {
        if(totalWaterMeter > 0){
          irrigationLines[list[1]]['water_meter'] = list[2];
          if(list[2] == true){
            totalWaterMeter = totalWaterMeter - 1;
          }else{
            totalWaterMeter = totalWaterMeter + 1;
          }

        }
        if(totalWaterMeter == 0){
          if(list[2] == false){
            irrigationLines[list[1]]['water_meter'] = list[2];
            totalWaterMeter = totalWaterMeter + 1;
          }
        }
        break;
      }
    }
    notifyListeners();
  }

  void localDosingFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addLocalDosing'):{
        if(totalInjector > 0){
          for(var i = 0;i < list[1];i++){
            List<List<dynamic>> myList = [];
            for(var j = 0;j < list[2];j++){
              totalInjector = totalInjector - 1;
              if(list[3] == true){
                totalDosingMeter = totalDosingMeter - 1;
              }
              if(list[4] == true){
                totalBooster = totalBooster - 1;
              }
              myList.add([j+1,list[3],list[4],'${returnCD_channel_autoIncrement()}']);
            }
            myList.add(['unselect',list[5]+1]);
            localDosing.add(myList);
          }
        }
        var myList = [];
        List<List<List<dynamic>>> dummyLd = [];
        for(var ld = 0;ld < localDosing.length;ld++){
          myList.add(localDosing[ld][localDosing[ld].length -1][1]);
        }
        myList.sort();
        for(var i in myList){
          for(var ld = 0;ld < localDosing.length;ld++){
            if(localDosing[ld][localDosing[ld].length -1][1] == i){
              dummyLd.add(localDosing[ld]);
            }
          }
        }
        localDosing = dummyLd;
        break;
      }
      case ('edit_l_DosingSelection'):{
        l_dosingSelection = list[1];
        break;
      }
      case ('edit_l_DosingSelectAll'):{
        l_dosingSelectAll = list[1];
        break;
      }
      case ('editDosingMeter') :{
        if(totalDosingMeter > 0){
          localDosing[list[1]][list[2]][1] = list[3];
          if(list[3] == true){
            totalDosingMeter = totalDosingMeter - 1;
          }else{
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        if(totalDosingMeter == 0){
          if(list[3] == false){
            localDosing[list[1]][list[2]][1] = list[3];
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        break;
      }
      case ('editBoosterPump') :{
        if(totalBooster > 0){
          localDosing[list[1]][list[2]][2] = list[3];
          if(list[3] == true){
            totalBooster = totalBooster - 1;
          }else{
            totalBooster = totalBooster + 1;
          }
        }
        if(totalBooster == 0){
          if(list[3] == false){
            localDosing[list[1]][list[2]][2] = list[3];
            totalBooster = totalBooster + 1;
          }
        }
        break;
      }
      case ('editChannelNumber') :{
        localDosing[list[1]][list[2]][3] = list[3];
        break;
      }
      case ('selectLocalDosing') :{
        if(localDosing[list[1]][localDosing[list[1]].length - 1][0] == 'unselect'){
          localDosing[list[1]][localDosing[list[1]].length - 1][0] = 'select';
          selection += 1;
        }else{
          localDosing[list[1]][localDosing[list[1]].length - 1][0] = 'unselect';
          selection -= 1;
        }
        break;
      }
      case ('deleteLocalDosing') : {
        selection = 0;
        for(var i = localDosing.length - 1; i >= 0; i--){
          if(localDosing[i][localDosing[i].length - 1][0] == 'select'){
            for(var il = 0;il < irrigationLines.length;il++){
              if(il + 1 == localDosing[i][localDosing[i].length - 1][1]){
                irrigationLines[il]['Local_dosing_site'] = false;
              }
            }
            for(var j = 0; j< localDosing[i].length;j++){
              if(j != localDosing[i].length - 1){
                if(localDosing[i][j][1] == true){
                  totalDosingMeter = totalDosingMeter + 1;
                }
                if(localDosing[i][j][2] == true){
                  totalBooster = totalBooster + 1;
                }
              }
            }
            localDosing.removeAt(i);
            totalInjector = totalInjector + 1;
          }
        }
        break;
      }
      case ('deleteLocalDosingFromLine') : {
        for(var i = 0;i < localDosing.length;i++){
          if(localDosing[i][localDosing[i].length - 1][1] == list[1]+1){
            for(var j = 0; j< localDosing[i].length - 1;j++){
              if(localDosing[i][j][1] == true){
                totalDosingMeter = totalDosingMeter + 1;
              }
              if(localDosing[i][j][2] == true){
                totalBooster = totalBooster + 1;
              }
            }
            localDosing.removeAt(i);
            totalInjector = totalInjector + 1;
          }
        }
        break;
      }
      default :{
        break;
      }
    }
    notifyListeners();
  }

  void localFiltrationFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addFiltrationDosing'):{
        totalFilter -= 1;
        localFiltration.add([list[1] + 1,'1',false,false,false,'unselect']);
        localFiltration.sort((a, b) => a[0].compareTo(b[0]));
        break;
      }
      case ('edit_l_filtrationSelection'):{
        l_filtrationSelection = list[1];
        break;
      }
      case ('edit_l_filtrationSelectALL'):{
        l_filtrationSelectALL = list[1];
        break;
      }
      case ('editFilter') :{
        if(totalFilter > -1){
          if(localFiltration[list[1]][1] != ''){
            totalFilter = totalFilter + int.parse(localFiltration[list[1]][1]);
            if(list[2] == ''){
              totalFilter = totalFilter - 0;
            }else{
              if(list[2] == '0'){
                totalFilter = totalFilter - 1;
              }else{
                totalFilter = totalFilter - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalFilter = totalFilter - 1;
            }else{
              totalFilter = totalFilter - int.parse(list[2]);
            }
          }
          localFiltration[list[1]][1] = list[2];
        }
        break;
      }
      case ('editDownStreamValve') :{
        if(list[2] == true){
          total_D_s_valve -= 1;
        }else{
          total_D_s_valve += 1;
        }
        localFiltration[list[1]][2] = list[2];
        break;
      }
      case ('editDiffPressureSensor') :{
        if(list[2] == true){
          total_p_sensor -= 1;
        }else{
          total_p_sensor += 1;
        }
        localFiltration[list[1]][3] = list[2];
        break;
      }
      case ('editDiffPressureSensor_out') :{
        if(list[2] == true){
          total_p_sensor -= 1;
        }else{
          total_p_sensor += 1;
        }
        localFiltration[list[1]][4] = list[2];
        break;
      }
      case ('selectLocalFiltration') :{
        if(localFiltration[list[1]][5] == 'select'){
          localFiltration[list[1]][5] = 'unselect';
        }else{
          localFiltration[list[1]][5] = 'select';
        }
        break;
      }
      case ('deleteLocalFiltrationFromLine') : {
        for(var i = 0;i < localFiltration.length;i++){
          if(localFiltration[i][0] == list[1] + 1){
            irrigationLines[localFiltration[i][0] - 1]['local_filtration_site'] = false;
            localFiltration.removeAt(i);
            totalFilter += 1;
          }
        }
        break;
      }
      case ('deleteLocalFiltration') : {
        for(var i = localFiltration.length - 1; i >= 0; i--){
          if(localFiltration[i][5] == 'select'){
            irrigationLines[localFiltration[i][0] - 1]['local_filtration_site'] = false;
            localFiltration.removeAt(i);
            totalLocalFiltration = totalLocalFiltration + 1;
          }
        }
        break;
      }
      default :{
        break;
      }
    }
    notifyListeners();
  }
  void doDefaultOptionForMO(List<dynamic> list,String title){
    switch(title){
      case ('m_o_length_6'):{
        if(list[5] == 1){
          print('second time : ${list}');
          print("previousDataOfM_O[list[1]][list[2]][list[3]][list[4]] ; ${previousDataOfM_O[list[1]]}");
          if(previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][2] = '-';
            previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        if(list[5] == 2){
          if(previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        break;
      }
      case ('m_o_length_5'):{
        if(list[4] == 1){
          if(previousDataOfM_O[list[1]][list[2]][list[3]][list[4]] != list[5]){
            previousDataOfM_O[list[1]][list[2]][list[3]][2] = '-';
            previousDataOfM_O[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        if(list[4] == 2){
          if(previousDataOfM_O[list[1]][list[2]][list[3]][list[4]] != list[5]){
            previousDataOfM_O[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        break;
      }
      case ('CD_for_MO_length_6'):{
        if(list[5] == 1){
          if(CD_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            CD_for_MO[list[1]][list[2]][list[3]][list[4]][2] = '-';
            CD_for_MO[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        if(list[5] == 2){
          if(CD_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            CD_for_MO[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        break;
      }
      case ('CF_for_MO_length_5'):{
        if(list[4] == 1){
          if(CF_for_MO[list[1]][list[2]][list[3]][list[4]] != list[5]){
            CF_for_MO[list[1]][list[2]][list[3]][2] = '-';
            CF_for_MO[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        if(list[4] == 2){
          if(CF_for_MO[list[1]][list[2]][list[3]][list[4]] != list[5]){
            CF_for_MO[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        break;
      }
      case ('CF_for_MO_length_6'):{
        if(list[5] == 1){
          if(CF_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            CF_for_MO[list[1]][list[2]][list[3]][list[4]][2] = '-';
            CF_for_MO[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        if(list[5] == 2){
          if(CF_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            CF_for_MO[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        break;
      }
      case ('SP_MO_length_5'):{
        if(list[4] == 1){
          if(SP_MO[list[1]][list[2]][list[3]][list[4]] != list[5]){
            SP_MO[list[1]][list[2]][list[3]][2] = '-';
            SP_MO[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        if(list[4] == 2){
          if(SP_MO[list[1]][list[2]][list[3]][list[4]] != list[5]){
            SP_MO[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        break;
      }
      case ('IP_MO_length_5'):{
        if(list[4] == 1){
          if(IP_MO[list[1]][list[2]][list[3]][list[4]] != list[5]){
            IP_MO[list[1]][list[2]][list[3]][2] = '-';
            IP_MO[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        if(list[4] == 2){
          if(IP_MO[list[1]][list[2]][list[3]][list[4]] != list[5]){
            IP_MO[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        break;
      }
    }
  }
  void mappingOfOutputsFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('m_o_valve'):{
        print('${list}');
        doDefaultOptionForMO(list,'m_o_length_6');
        previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_main_valve'):{
        doDefaultOptionForMO(list,'m_o_length_6');
        previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_injector'):{
        doDefaultOptionForMO(list,'m_o_length_6');
        previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_Booster'):{
        doDefaultOptionForMO(list,'m_o_length_6');
        previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }

      case ('m_o_filter'):{
        doDefaultOptionForMO(list,'m_o_length_6');
        previousDataOfM_O[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_D_valve'):{
        doDefaultOptionForMO(list,'m_o_length_5');
        previousDataOfM_O[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_CD_injector'):{
        doDefaultOptionForMO(list,'CD_for_MO_length_6');
        CD_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_CD_booster'):{
        doDefaultOptionForMO(list,'CD_for_MO_length_6');
        CD_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_CD_agitator'):{
        doDefaultOptionForMO(list,'CD_for_MO_length_6');
        CD_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_CF_filter'):{
        doDefaultOptionForMO(list,'CF_for_MO_length_6');
        CF_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_o_CF_D_valve'):{
        doDefaultOptionForMO(list,'CF_for_MO_length_5');
        CF_for_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_SP'):{
        doDefaultOptionForMO(list,'SP_MO_length_5');
        SP_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_IP'):{
        doDefaultOptionForMO(list,'IP_MO_length_5');
        IP_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_fan'):{
        if(list[2] == 1){
          if(totalFan[list[1]][list[2]] != list[3]){
            totalFan[list[1]][2] = '-';
            totalFan[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalFan[list[1]][list[2]] != list[3]){
            totalFan[list[1]][3] = '-';
          }
        }
        totalFan[list[1]][list[2]] = list[3];
        break;
      }
      case ('m_o_fogger'):{
        if(list[2] == 1){
          if(totalFogger[list[1]][list[2]] != list[3]){
            totalFogger[list[1]][2] = '-';
            totalFogger[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalFogger[list[1]][list[2]] != list[3]){
            totalFogger[list[1]][3] = '-';
          }
        }
        totalFogger[list[1]][list[2]] = list[3];
        break;
      }
      case ('m_o_agitator'):{
        if(list[2] == 1){
          if(totalAgitator[list[1]][list[2]] != list[3]){
            totalAgitator[list[1]][2] = '-';
            totalAgitator[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalAgitator[list[1]][list[2]] != list[3]){
            totalAgitator[list[1]][3] = '-';
          }
        }
        totalAgitator[list[1]][list[2]] = list[3];
        break;
      }
    }
    notifyListeners();
  }
  void doDefaultOptionForMI(List<dynamic> list,String title){
    switch(title){
      case ('m_i_length_6'):{
        if(list[5] == 1){
          if(previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][2] = '-';
            previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        if(list[5] == 2){
          if(previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][list[5]] != list[6]){
            previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][3] = '-';
          }
        }
        break;
      }
      case ('m_i_length_5'):{
        if(list[4] == 1){
          if(previousDataOfM_I[list[1]][list[2]][list[3]][list[4]] != list[5]){
            previousDataOfM_I[list[1]][list[2]][list[3]][2] = '-';
            previousDataOfM_I[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        if(list[4] == 2){
          if(previousDataOfM_I[list[1]][list[2]][list[3]][list[4]] != list[5]){
            previousDataOfM_I[list[1]][list[2]][list[3]][3] = '-';
          }
        }
        break;
      }
    }
  }
  void mappingOfInputsFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('m_i_ORO_sense'):{
        doDefaultOptionForMI(list,'m_i_length_6');
        previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_i_pressure_sensor'):{
        doDefaultOptionForMI(list,'m_i_length_5');
        previousDataOfM_I[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_water_meter'):{
        doDefaultOptionForMI(list,'m_i_length_5');
        previousDataOfM_I[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_dosing_meter'):{
        doDefaultOptionForMI(list,'m_i_length_6');
        previousDataOfM_I[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_i_D_pressure_sensor'):{
        doDefaultOptionForMI(list,'m_i_length_5');
        previousDataOfM_I[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_D_pressure_sensor_out'):{
        doDefaultOptionForMI(list,'m_i_length_5');
        previousDataOfM_I[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_CD_dosing_meter'):{
        doDefaultOptionForMO(list,'CD_for_MO_length_6');
        CD_for_MO[list[1]][list[2]][list[3]][list[4]][list[5]] = list[6];
        break;
      }
      case ('m_i_CF_P_sensor'):{
        doDefaultOptionForMO(list,'CF_for_MO_length_5');
        CF_for_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_CF_P_sensor_out'):{
        doDefaultOptionForMO(list,'CF_for_MO_length_5');
        CF_for_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_sp_wm'):{
        doDefaultOptionForMO(list,'SP_MO_length_5');
        SP_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_ip_wm'):{
        doDefaultOptionForMO(list,'IP_MO_length_5');
        IP_MO[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_analog_sensor'):{
        if(list[2] == 1){
          if(totalAnalogSensor[list[1]][list[2]] != list[3]){
            totalAnalogSensor[list[1]][2] = '-';
            totalAnalogSensor[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalAnalogSensor[list[1]][list[2]] != list[3]){
            totalAnalogSensor[list[1]][3] = '-';
          }
        }
        totalAnalogSensor[list[1]][list[2]] = list[3];
        break;
      }
      case ('m_i_contacts'):{
        if(list[2] == 1){
          if(totalContact[list[1]][list[2]] != list[3]){
            totalContact[list[1]][2] = '-';
            totalContact[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalContact[list[1]][list[2]] != list[3]){
            totalContact[list[1]][3] = '-';
          }
        }
        totalContact[list[1]][list[2]] = list[3];
        break;
      }
      case ('m_i_ph_sensor'):{
        if(list[2] == 1){
          if(totalPhSensor[list[1]][list[2]] != list[3]){
            totalPhSensor[list[1]][2] = '-';
            totalPhSensor[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalPhSensor[list[1]][list[2]] != list[3]){
            totalPhSensor[list[1]][3] = '-';
          }
        }
        totalPhSensor[list[1]][list[2]] = list[3];
        break;
      }
      case ('m_i_ec_sensor'):{
        if(list[2] == 1){
          if(totalEcSensor[list[1]][list[2]] != list[3]){
            totalEcSensor[list[1]][2] = '-';
            totalEcSensor[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalEcSensor[list[1]][list[2]] != list[3]){
            totalEcSensor[list[1]][3] = '-';
          }
        }
        totalEcSensor[list[1]][list[2]] = list[3];
        break;
      }
      case ('m_i_moisture_sensor'):{
        if(list[2] == 1){
          if(totalMoistureSensor[list[1]][list[2]] != list[3]){
            totalMoistureSensor[list[1]][2] = '-';
            totalMoistureSensor[list[1]][3] = '-';
          }
        }
        if(list[2] == 2){
          if(totalMoistureSensor[list[1]][list[2]] != list[3]){
            totalMoistureSensor[list[1]][3] = '-';
          }
        }
        totalMoistureSensor[list[1]][list[2]] = list[3];
        break;
      }
    }
    notifyListeners();
  }
  List<dynamic> getList(dynamic object,String title,String match,String autoIncrement){
    var myList = [];
    for(var a in object[title]){
      var list = a[0].split(':');
      var list1 = match.split(':');
      if(list[1] == list1[1]){
        for(var i in irrigationLines){
          if(i['autoIncrement'].toString() == autoIncrement){
            // for rtus
            if(i['RTU'] == ''){
              if(a[1] == 'ORO RTU'){
                myList.add('-');
              }else{
                myList.add(a[1]);
              }
            }else if(i['ORO_switch'] == ''){
              if(a[1] == 'ORO Switch'){
                myList.add('-');
              }else{
                myList.add(a[1]);
              }
            }else if(i['ORO_Smart_RTU'] == ''){
              if(a[1] == 'ORO Smart RTU'){
                myList.add('-');
              }else{
                myList.add(a[1]);
              }
            }else if(i['ORO_sense'] == ''){
              if(a[1] == 'ORO Sense'){
                myList.add('-');
              }else{
                myList.add(a[1]);
              }
            }else{
              myList.add(a[1]);
            }
            //   for reference numbers
            if(a[1] == 'ORO RTU'){
              if(a[2] != '-'){
                if(i['myRTU'].contains(int.parse(a[2]))){
                  myList.add(a[2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(a[2]);
              }
            }else if(a[1] == 'ORO Switch'){
              if(a[2] != '-'){
                if(i['myOROswitch'].contains(int.parse(a[2]))){
                  myList.add(a[2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(a[2]);
              }
            }else if(a[1] == 'ORO Smart RTU'){
              if(a[2] != '-'){
                if(i['myOroSmartRtu'].contains(int.parse(a[2]))){
                  myList.add(a[2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(a[2]);
              }
            }else if(a[1] == 'ORO Sense'){
              if(a[2] != '-'){
                if(i['myOROsense'].contains(int.parse(a[2]))){
                  myList.add(a[2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(a[2]);
              }
            }else{
              myList.add(a[2]);
            }

          }
        }
        for(var ob = 3;ob < a.length;ob++){
          myList.add(a[ob]);
        }
        break;
      }
    }
    return myList;
  }
  List<dynamic> getList1(dynamic object,String title,String match,String autoIncrement){
    var myList = [];
    if(object[title].length == 0){
    }else{
      var list =  object[title][0].split(':');
      var list1 = match.split(':');
      if(list[1] == list1[1]){
        for(var i in irrigationLines){
          if(i['autoIncrement'].toString() == autoIncrement){
            // for rtus
            if(i['RTU'] == ''){
              if(object[title][1]== 'ORO RTU'){
                myList.add('-');
              }else{
                myList.add(object[title][1]);
              }
            }else if(i['ORO_switch'] == ''){
              if(object[title][1] == 'ORO Switch'){
                myList.add('-');
              }else{
                myList.add(object[title][1]);
              }
            }else if(i['ORO_Smart_RTU'] == ''){
              if(object[title][1] == 'ORO Smart RTU'){
                myList.add('-');
              }else{
                myList.add(object[title][1]);
              }
            }else if(i['ORO_sense'] == ''){
              if(object[title][1] == 'ORO Sense'){
                myList.add('-');
              }else{
                myList.add(object[title][1]);
              }
            }else{
              myList.add(object[title][1]);
            }
            //   for reference numbers
            if(object[title][1] == 'ORO RTU'){
              if(object[title][2] != '-'){
                if(i['myRTU'].contains(int.parse(object[title][2]))){
                  myList.add(object[title][2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(object[title][2]);
              }
            }else if(object[title][1] == 'ORO Switch'){
              if(object[title][2] != '-'){
                if(i['myOROswitch'].contains(int.parse(object[title][2]))){
                  myList.add(object[title][2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(object[title][2]);
              }
            }else if(object[title][1] == 'ORO Smart RTU'){
              if(object[title][2] != '-'){
                if(i['myOroSmartRtu'].contains(int.parse(object[title][2]))){
                  myList.add(object[title][2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(object[title][2]);
              }
            }else if(object[title][1] == 'ORO Sense'){
              if(object[title][2] != '-'){
                if(i['myOROsense'].contains(int.parse(object[title][2]))){
                  myList.add(object[title][2]);
                }else{
                  myList.add('-');
                }
              }else{
                myList.add(object[title][2]);
              }
            }else{
              myList.add(object[title][2]);
            }

          }
        }
        for(var ob = 3;ob < object[title].length;ob++){
          myList.add(object[title][ob]);
        }
      }
    }
    return myList;
  }
  List<dynamic> isThereOrNot(String match,String autoIncrement,String title){
    var myList = [];
    for(var i = 0;i < irrigationLines.length;i++){
      previousDataOfM_O.forEach((element) {
        if(element.containsKey('${autoIncrement}')){
          var object = element.values.first;
          switch(title){
            case ('valve'):{
              myList = getList(object,'valve',match,autoIncrement);
              break;
            }
            case ('main_valve'):{
              myList = getList(object,'main_valve',match,autoIncrement);
              break;
            }
            case ('injector') : {
              myList = getList(object,'injector',match,autoIncrement);
              break;
            }
            case ('Booster') : {
              myList = getList(object,'Booster',match,autoIncrement);
              break;
            }
            case ('filter'):{
              myList = getList(object,'filter',match,autoIncrement);
              break;
            }
            case ('D_valve') : {
              myList = getList1(object,'D_valve',match,autoIncrement);
              break;
            }
          }

        }
      });
    }
    return myList;
  }
  List<dynamic> isThereOrNotforIO(String match,String autoIncrement,String title){
    var myList = [];
    for(var i = 0;i < irrigationLines.length;i++){
      previousDataOfM_I.forEach((element) {
        if(element.containsKey('${autoIncrement}')){
          var object = element.values.first;
          switch(title){
            case ('pressure_sensor'):{
              myList = getList1(object,'pressure_sensor',match,autoIncrement);
              break;
            }
            case ('water_meter'):{
              myList = getList1(object,'water_meter',match,autoIncrement);
              break;
            }
            case ('ORO_sense'):{
              myList = getList(object,'ORO_sense',match,autoIncrement);
              break;
            }
            case ('dosing_meter'):{
              myList = getList(object,'dosing_meter',match,autoIncrement);
              break;
            }
            case ('D_pressure_sensor'):{
              myList = getList1(object,'D_pressure_sensor',match,autoIncrement);
              break;
            }
            case ('D_pressure_sensor_out'):{
              myList = getList1(object,'D_pressure_sensor_out',match,autoIncrement);
              break;
            }
          }

        }
      });
    }
    return myList;
  }
  void refreshMapOfOutputs(){
    mappingOfOutputs = [];
    overAll = [];
    for(var i = 0;i < irrigationLines.length;i++){
      mappingOfOutputs.add({
        '${irrigationLines[i]['autoIncrement']}' : {
          'valve' : [],
          'main_valve' : [],
          'injector' : [],
          'Booster' : [],
          'filter' : [],
          'D_valve' : [],
        }
      });
      for(var i1 = 0;i1 < int.parse(irrigationLines[i]['valve']);i1++){
        if(previousDataOfM_O.length == 0){
          mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['valve'].add(
              ['L ${i + 1} : V${i1+1}','-','-','-','${returnI_O_AutoIncrement()}']
          );
          overAll.add(['L ${i + 1} : V${i1+1}','-','-','-']);
        }else{
          var values = isThereOrNot('L ${i + 1} : V${i1+1}',irrigationLines[i]['autoIncrement'].toString(),'valve');
          if(values.isEmpty){
            mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['valve'].add(
                ['L ${i + 1} : V${i1+1}','-','-','-','${returnI_O_AutoIncrement()}']
            );
            overAll.add(['L ${i + 1} : V${i1+1}','-','-','-']);
          }else{
            mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['valve'].add(
                ['L ${i + 1} : V${i1+1}',values[0],values[1],values[2],values[3]]
            );
            overAll.add(['L ${i + 1} : V${i1+1}',values[0],values[1],values[2]]);
          }
        }


      }
      for(var i2 = 0;i2 < int.parse(irrigationLines[i]['main_valve'] != '' ? irrigationLines[i]['main_valve'] : '0');i2++){
        if(previousDataOfM_O.length == 0){
          mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['main_valve'].add(
              ['L ${i + 1} : MV${i2+1}','-','-','-','${returnI_O_AutoIncrement()}']
          );
          overAll.add(['L ${i + 1} : MV${i2+1}','-','-','-']);
        }else{
          var values = isThereOrNot('L ${i + 1} : MV${i2+1}',irrigationLines[i]['autoIncrement'].toString(),'main_valve');
          if(values.isEmpty){
            mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['main_valve'].add(
                ['L ${i + 1} : MV${i2+1}','-','-','-','${returnI_O_AutoIncrement()}']
            );
            overAll.add( ['L ${i + 1} : MV${i2+1}','-','-','-']);
          }else{
            mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['main_valve'].add(
                ['L ${i + 1} : MV${i2+1}',values[0],values[1],values[2],values[3]]
            );
            overAll.add( ['L ${i + 1} : MV${i2+1}',values[0],values[1],values[2]]);
          }
        }
      }
      if(irrigationLines[i]['Local_dosing_site'] == true){
        for(var ld = 0;ld < localDosing.length;ld++){
          if(localDosing[ld][localDosing[ld].length - 1][1] == i + 1){
            for(var k = 0;k < localDosing[ld].length - 1;k++){
              if(previousDataOfM_O.length == 0){
                mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['injector'].add(['L ${i + 1} : injector${k+1}','-','-','-','${localDosing[ld][k][3]}','${returnI_O_AutoIncrement()}']);
              }else{
                var values = isThereOrNot('L ${i + 1} : injector${k+1}',irrigationLines[i]['autoIncrement'].toString(),'injector');
                if(values.isEmpty){
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['injector'].add(['L ${i + 1} : injector${k+1}','-','-','-','${localDosing[ld][k][3]}','${returnI_O_AutoIncrement()}']);
                  overAll.add(['L ${i + 1} : injector${k+1}','-','-','-']);
                }else{
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['injector'].add(['L ${i + 1} : injector${k+1}',values[0],values[1],values[2],values[3],values[4]]);
                  overAll.add(['L ${i + 1} : injector${k+1}',values[0],values[1],values[2],values[3]]);
                }
              }
            }
          }
        }
      }
      if(irrigationLines[i]['Local_dosing_site'] == true){
        for(var ld = 0;ld < localDosing.length;ld++){
          if(localDosing[ld][localDosing[ld].length - 1][1] == i + 1){
            for(var k = 0;k < localDosing[ld].length - 1;k++){
              var ai = returnI_O_AutoIncrement();
              if(previousDataOfM_O.length == 0){
                if(localDosing[ld][k][2] == true){
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['Booster'].add(['L ${i + 1} : Booster${k+1}','-','-','-','${localDosing[ld][k][3]}','${ai}']);
                }
              }else{
                if(localDosing[ld][k][2] == true){
                  var values1 = isThereOrNot('L ${i + 1} : Booster${k+1}',irrigationLines[i]['autoIncrement'].toString(),'Booster');
                  if(values1.isEmpty){
                    mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['Booster'].add(['L ${i + 1} : Booster${k+1}','-','-','-','${localDosing[ld][k][3]}','${ai}']);
                    overAll.add(['L ${i + 1} : Booster${k+1}','-','-','-']);
                  }else{
                    mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['Booster'].add(['L ${i + 1} : Booster${k+1}',values1[0],values1[1],values1[2],values1[3],values1[4]]);
                    overAll.add(['L ${i + 1} : Booster${k+1}',values1[0],values1[1],values1[2]]);
                  }
                }
              }
            }
          }
        }
      }
      if(irrigationLines[i]['local_filtration_site'] == true){
        for(var j in localFiltration){
          if(j[0] == i + 1){
            for(var k = 0;k < int.parse(j[1]);k++){
              if(previousDataOfM_O.length == 0){
                mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['filter'].add(
                    ['L ${i + 1} : filter${k+1}','-','-','-','${returnI_O_AutoIncrement()}']
                );
                overAll.add(['L ${i + 1} : filter${k+1}','-','-','-']);
              }else{
                var values = isThereOrNot('L ${i + 1} : filter${k+1}',irrigationLines[i]['autoIncrement'].toString(),'filter');
                if(values.isEmpty){
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['filter'].add(
                      ['L ${i + 1} : filter${k+1}','-','-','-','${returnI_O_AutoIncrement()}']
                  );
                  overAll.add( ['L ${i + 1} : filter${k+1}','-','-','-']);
                }
                else{
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['filter'].add(
                      ['L ${i + 1} : filter${k+1}',values[0],values[1],values[2],values[3]]
                  );
                  overAll.add( ['L ${i + 1} : filter${k+1}',values[0],values[1],values[2]]);
                }
              }
            }
            if(j[2] == true){
              if(previousDataOfM_O.length == 0){
                mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['D_valve'] = ['L ${i + 1} : D_valve','-','-','-','${returnI_O_AutoIncrement()}'];
                overAll.add(['L ${i + 1} : D_valve','-','-','-']);
              }else{
                var values = isThereOrNot('L ${i + 1} : D_valve',irrigationLines[i]['autoIncrement'].toString(),'D_valve');
                if(values.isEmpty){
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['D_valve'] = ['L ${i + 1} : D_valve','-','-','-','${returnI_O_AutoIncrement()}'];
                  overAll.add(['L ${i + 1} : D_valve','-','-','-']);
                }else{
                  mappingOfOutputs[i]['${irrigationLines[i]['autoIncrement']}']['D_valve'] = ['L ${i + 1} : D_valve',values[0],values[1],values[2],values[3]];
                  overAll.add(['L ${i + 1} : D_valve',values[0],values[1],values[2]]);
                }
              }
            }
            break;
          }
        }
      }
    }
    previousDataOfM_O = mappingOfOutputs;
    notifyListeners();
  }
  var dummy = '';
  void refreshMapOfInputs(){
    mappingOfInputs = [];
    for(var i = 0;i < irrigationLines.length;i++){
      mappingOfInputs.add({
        '${irrigationLines[i]['autoIncrement']}' : {
          'pressure_sensor' : [],
          'water_meter' : [],
          'ORO_sense' : [],
          'dosing_meter' : [],
          'D_pressure_sensor' : [],
          'D_pressure_sensor_out' : [],
        }
      });
      if(irrigationLines[i]['pressure_sensor'] == true){
        if(previousDataOfM_I.length == 0 ){
          mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['pressure_sensor'] = ['L ${i + 1} : Pressure sensor','-','-','-','-','${returnI_O_AutoIncrement()}'];
        }else{
          var values = isThereOrNotforIO('L ${i + 1} : Pressure sensor',irrigationLines[i]['autoIncrement'].toString(),'pressure_sensor');
          if(values.isEmpty){
            mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['pressure_sensor'] = ['L ${i + 1} : Pressure sensor','-','-','-','-','${returnI_O_AutoIncrement()}'];
          }else{
            mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['pressure_sensor'] = ['L ${i + 1} : Pressure sensor',values[0],values[1],values[2],values[3],values[4]];
          }
        }
      }
      if(irrigationLines[i]['water_meter'] == true){
        if(previousDataOfM_I.length == 0 ){
          mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['water_meter'] = ['L ${i + 1} : water meter','-','-','-','-','${returnI_O_AutoIncrement()}'];
        }else{
          var values = isThereOrNotforIO('L ${i + 1} : water meter',irrigationLines[i]['autoIncrement'].toString(),'water_meter');
          if(values.isEmpty){
            mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['water_meter'] = ['L ${i + 1} : water meter','-','-','-','-','${returnI_O_AutoIncrement()}'];
          }else{
            mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['water_meter'] = ['L ${i + 1} : water meter',values[0],values[1],values[2],values[3],values[4]];
          }
        }
      }
      if(irrigationLines[i]['Local_dosing_site'] == true){
        for(var j = 0;j < localDosing.length;j++){
          if(localDosing[j][localDosing[j].length - 1][1] == i + 1){
            for(var k = 0;k < localDosing[j].length - 1;k++){
              if(previousDataOfM_I.length == 0){
                if(localDosing[j][k][1] == true){
                  mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['dosing_meter'].add(['L ${i + 1} : dosing_meter${k+1}','-','-','-','-','${localDosing[j][k][3]}','${returnI_O_AutoIncrement()}']);
                }
              }else{
                if(localDosing[j][k][1] == true){
                  var values1 = isThereOrNotforIO('L ${i + 1} : dosing_meter${k+1}',irrigationLines[i]['autoIncrement'].toString(),'dosing_meter');
                  if(values1.isEmpty){
                    mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['dosing_meter'].add(['L ${i + 1} : dosing_meter${k+1}','-','-','-','-','${localDosing[j][k][3]}','${returnI_O_AutoIncrement()}']);
                  }else{
                    mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['dosing_meter'].add(['L ${i + 1} : dosing_meter${k+1}',values1[0],values1[1],values1[2],values1[3],values1[4],values1[5]]);
                  }
                }
              }
            }
          }
        }
      }
      if(irrigationLines[i]['local_filtration_site'] == true){
        for(var j in localFiltration){
          if(j[0] == i + 1){
            if(j[3] == true){
              if(previousDataOfM_I.length == 0){
                mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['D_pressure_sensor'] = ['L ${i + 1} : D_pressure_sensor','-','-','-','-','${returnI_O_AutoIncrement()}'];
              }else{
                var values = isThereOrNotforIO('L ${i + 1} : D_pressure_sensor',irrigationLines[i]['autoIncrement'].toString(),'D_pressure_sensor');
                if(values.isEmpty){
                  mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['D_pressure_sensor'] = ['L ${i + 1} : D_pressure_sensor','-','-','-','-','${returnI_O_AutoIncrement()}'];
                }else{
                  mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['D_pressure_sensor'] = ['L ${i + 1} : D_pressure_sensor',values[0],values[1],values[2],values[3],values[4]];
                }
              }
            }
            break;
          }
        }
      }
      if(irrigationLines[i]['local_filtration_site'] == true){
        for(var j in localFiltration){
          if(j[0] == i + 1){
            if(j[4] == true){
              if(previousDataOfM_I.length == 0){
                mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['D_pressure_sensor_out'] = ['L ${i + 1} : D_pressure_sensor_out','-','-','-','-','${returnI_O_AutoIncrement()}'];
              }else{
                var values = isThereOrNotforIO('L ${i + 1} : D_pressure_sensor_out',irrigationLines[i]['autoIncrement'].toString(),'D_pressure_sensor_out');
                if(values.isEmpty){
                  mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['D_pressure_sensor_out'] = ['L ${i + 1} : D_pressure_sensor_out','-','-','-','-','${returnI_O_AutoIncrement()}'];
                }else{
                  mappingOfInputs[i]['${irrigationLines[i]['autoIncrement']}']['D_pressure_sensor_out'] = ['L ${i + 1} : D_pressure_sensor_out',values[0],values[1],values[2],values[3],values[4]];
                }
              }
            }
            break;
          }
        }
      }
    }
    previousDataOfM_I = mappingOfInputs;
    notifyListeners();
  }
  String returnDeviceType(String title){
    if(title == 'ORO Smart RTU'){
      return '2';
    }else if(title == 'ORO RTU'){
      return '3';
    }else if(title == 'ORO Switch'){
      return '5';
    }else if(title == 'ORO Sense'){
      return '7';
    }else{
      return '-';
    }
  }
  String numberORnot(String value){
    if(value != '-'){
      return value;
    }else{
      return '0';
    }
  }
  String returnDeviceType_HW(String title){
    if(title == 'ORO Smart RTU'){
      return '2';
    }else if(title == 'ORO RTU'){
      return '3';
    }else if(title == 'ORO Switch'){
      return '5';
    }else if(title == 'ORO Sense'){
      return '7';
    }else{
      return '0';
    }
  }

  dynamic sendData(){
    map_i_o = '';
    dynamic fullData = {
      'output' : {

      },
      'input' : {

      }
    };
    for(var i = 0; i < mappingOfOutputs.length;i++){
      fullData['output']['l${i+1}'] = {};
      fullData['output']['l${i+1}']['AI'] = '';
      for(var j in mappingOfOutputs[i].entries){
        if(j.value['valve'].length != 0){
          fullData['output']['l${i+1}']['v'] = '';
          if(fullData['output']['l${i+1}']['AI'] == ''){
            fullData['output']['l${i+1}']['AI'] = '${j.key}';
          }
          for(var k = 0;k < j.value['valve'].length;k++){
            fullData['output']['l${i+1}']['v'] += '${k+1},${returnDeviceType(j.value['valve'][k][1])},${j.value['valve'][k][2]},${j.value['valve'][k][3]},${j.value['valve'][k][4]}${k == j.value['valve'].length - 1 ? '' : '|'}' ;
            map_i_o += '${j.value['valve'][k][4]},VL.${i+1}.${k+1},${returnDeviceType_HW(j.value['valve'][k][1])},${numberORnot(j.value['valve'][k][2])},${numberORnot(j.value['valve'][k][3])},1;' ;
          }
        }

      }
      for(var j in mappingOfOutputs[i].entries){
        if(j.value['main_valve'].length != 0){
          fullData['output']['l${i+1}']['mv'] = '';
          for(var k = 0;k < j.value['main_valve'].length;k++){
            fullData['output']['l${i+1}']['mv'] += '${k+1},${returnDeviceType(j.value['main_valve'][k][1])},${j.value['main_valve'][k][2]},${j.value['main_valve'][k][3]},${j.value['main_valve'][k][4]}${k == j.value['main_valve'].length - 1 ? '' : '|'}' ;
            map_i_o += '${j.value['main_valve'][k][4]},MV.${i+1}.${k+1},${returnDeviceType_HW(j.value['main_valve'][k][1])},${numberORnot(j.value['main_valve'][k][2])},${numberORnot(j.value['main_valve'][k][3])},1;' ;
          }
        }
      }
      for(var j in mappingOfOutputs[i].entries){
        if(j.value['injector'].length != 0){
          fullData['output']['l${i+1}']['inj'] = '';
          for(var k = 0;k < j.value['injector'].length;k++){
            fullData['output']['l${i+1}']['inj'] += '${k+1},${returnDeviceType(j.value['injector'][k][1])},${j.value['injector'][k][2]},${j.value['injector'][k][3]},${j.value['injector'][k][4]},${j.value['injector'][k][5]}${k == j.value['injector'].length - 1 ? '' : '|'}' ;
            map_i_o += '${j.value['injector'][k][5]},FC.${i+1}.2.${k+1},${returnDeviceType_HW(j.value['injector'][k][1])},${numberORnot(j.value['injector'][k][2])},${numberORnot(j.value['injector'][k][3])},1;' ;
          }
        }
      }
      for(var j in mappingOfOutputs[i].entries){
        if(j.value['Booster'].length != 0){
          fullData['output']['l${i+1}']['booster'] = '';
          for(var k = 0;k < j.value['Booster'].length;k++){
            var bstr = j.value['Booster'][k][0].split(':');
            var bstrNo = bstr[1].split('Booster')[1];
            fullData['output']['l${i+1}']['booster'] += '${bstrNo},${returnDeviceType(j.value['Booster'][k][1])},${j.value['Booster'][k][2]},${j.value['Booster'][k][3]},${j.value['Booster'][k][4]},${j.value['Booster'][k][5]}${k == j.value['Booster'].length - 1 ? '' : '|'}' ;
            map_i_o += '${j.value['Booster'][k][5]},FB.${i+1}.2.${k+1},${returnDeviceType_HW(j.value['Booster'][k][1])},${numberORnot(j.value['Booster'][k][2])},${numberORnot(j.value['Booster'][k][3])},1;' ;
          }
        }
      }
      for(var j in mappingOfOutputs[i].entries){
        if(j.value['filter'].length != 0){
          fullData['output']['l${i+1}']['filt'] = '';
          for(var k = 0;k < j.value['filter'].length;k++){
            fullData['output']['l${i+1}']['filt'] += '${k+1},${returnDeviceType(j.value['filter'][k][1])},${j.value['filter'][k][2]},${j.value['filter'][k][3]},${j.value['filter'][k][4]}${k == j.value['filter'].length - 1 ? '' : '|'}' ;
            map_i_o += '${j.value['filter'][k][4]},FL.${i+1}.2.${k+1},${returnDeviceType_HW(j.value['filter'][k][1])},${numberORnot(j.value['filter'][k][2])},${numberORnot(j.value['filter'][k][3])},1;' ;

          }
        }
      }
      for(var j in mappingOfOutputs[i].entries){
        if(j.value['D_valve'].length != 0){
          fullData['output']['l${i+1}']['d_v'] = '';
          fullData['output']['l${i+1}']['d_v'] += '1,${returnDeviceType(j.value['D_valve'][1])},${j.value['D_valve'][2]},${j.value['D_valve'][3]},${j.value['D_valve'][4]}' ;
          map_i_o += '${j.value['D_valve'][4]},DS.${i+1}.2,${returnDeviceType_HW(j.value['D_valve'][1])},${numberORnot(j.value['D_valve'][2])},${numberORnot(j.value['D_valve'][3])},1;' ;

        }
      }
      for(var j in mappingOfOutputs[i].entries){
        for(var irr = 0;irr < irrigationLines.length;irr++){
          if(j.key == '${irrigationLines[irr]['autoIncrement']}'){
            fullData['output']['l${i+1}']['RF'] = '';
            fullData['output']['l${i+1}']['RF'] += "CD:${irrigationLines[irr]['Central_dosing_site']}+CF:${irrigationLines[irr]['Central_filtration_site']}+IP:${irrigationLines[irr]['irrigationPump']}+OSRTU:${irrigationLines[irr]['ORO_Smart_RTU']}${irrigationLines[irr]['myOroSmartRtu']}+ORTU:${irrigationLines[irr]['RTU']}${irrigationLines[irr]['myRTU']}+OSWTCH:${irrigationLines[irr]['ORO_switch']}${irrigationLines[irr]['myOROswitch']}+OSENSE:${irrigationLines[irr]['ORO_sense']}${irrigationLines[irr]['myOROsense']}";
            break;
          }
        }
      }
    }
    for(var i = 0; i < mappingOfInputs.length;i++){
      fullData['input']['l${i+1}'] = {};
      fullData['input']['l${i+1}']['AI'] = '';
      for(var j in mappingOfInputs[i].entries){
        if(j.value['pressure_sensor'].length != 0){
          if(fullData['input']['l${i+1}']['AI'] == ''){
            fullData['input']['l${i+1}']['AI'] = j.key;
          }
          fullData['input']['l${i+1}']['PS'] = '';
          fullData['input']['l${i+1}']['PS'] += '1,${returnDeviceType(j.value['pressure_sensor'][1])},${j.value['pressure_sensor'][2]},${j.value['pressure_sensor'][3]},${j.value['pressure_sensor'][4]},${j.value['pressure_sensor'][5]}' ;
          map_i_o += '${j.value['pressure_sensor'][5]},PS.${i+1},${returnDeviceType_HW(j.value['pressure_sensor'][1])},${numberORnot(j.value['pressure_sensor'][2])},${numberORnot(j.value['pressure_sensor'][3])},${j.value['pressure_sensor'][4]};' ;

        }
      }
      for(var j in mappingOfInputs[i].entries){
        if(j.value['water_meter'].length != 0){
          if(fullData['input']['l${i+1}']['AI'] == ''){
            fullData['input']['l${i+1}']['AI'] = j.key;
          }
          fullData['input']['l${i+1}']['wm'] = '';
          fullData['input']['l${i+1}']['wm'] += '1,${returnDeviceType(j.value['water_meter'][1])},${j.value['water_meter'][2]},${j.value['water_meter'][3]},${j.value['water_meter'][4]},${j.value['water_meter'][5]}' ;
          map_i_o += '${j.value['water_meter'][5]},LW.${i+1},${returnDeviceType_HW(j.value['water_meter'][1])},${numberORnot(j.value['water_meter'][2])},${numberORnot(j.value['water_meter'][3])},${j.value['water_meter'][4]};' ;

        }
      }
      for(var j in mappingOfInputs[i].entries){
        if(j.value['dosing_meter'].length != 0){
          if(fullData['input']['l${i+1}']['AI'] == ''){
            fullData['input']['l${i+1}']['AI'] = j.key;
          }
          fullData['input']['l${i+1}']['d_meter'] = '';
          for(var k = 0;k < j.value['dosing_meter'].length;k++){
            var bstr = j.value['dosing_meter'][k][0].split(':');
            var bstrNo = bstr[1].split('dosing_meter')[1];
            fullData['input']['l${i+1}']['d_meter'] += '${bstrNo},${returnDeviceType(j.value['dosing_meter'][k][1])},${j.value['dosing_meter'][k][2]},${j.value['dosing_meter'][k][3]},${j.value['dosing_meter'][k][4]},${j.value['dosing_meter'][k][5]},${j.value['dosing_meter'][k][6]}${k == j.value['dosing_meter'].length - 1 ? '' : '|'}' ;
            map_i_o += '${j.value['dosing_meter'][k][6]},FM.${i+1}.2.${k+1},${returnDeviceType_HW(j.value['dosing_meter'][k][1])},${numberORnot(j.value['dosing_meter'][k][2])},${numberORnot(j.value['dosing_meter'][k][3])},${j.value['dosing_meter'][k][4]};' ;
          }
        }
      }
      for(var j in mappingOfInputs[i].entries){
        if(j.value['D_pressure_sensor'].length != 0){
          if(fullData['input']['l${i+1}']['AI'] == ''){
            fullData['input']['l${i+1}']['AI'] = j.key;
          }
          fullData['input']['l${i+1}']['PS_IN'] = '1,${returnDeviceType(j.value['D_pressure_sensor'][1])},${j.value['D_pressure_sensor'][2]},${j.value['D_pressure_sensor'][3]},${j.value['D_pressure_sensor'][4]},${j.value['D_pressure_sensor'][5]}' ;
          map_i_o += '${j.value['D_pressure_sensor'][5]},PI.${i+1}.2.1,${returnDeviceType_HW(j.value['D_pressure_sensor'][1])},${numberORnot(j.value['D_pressure_sensor'][2])},${numberORnot(j.value['D_pressure_sensor'][3])},${j.value['D_pressure_sensor'][4]};' ;

        }
      }
      for(var j in mappingOfInputs[i].entries){
        if(j.value['D_pressure_sensor_out'].length != 0){
          if(fullData['input']['l${i+1}']['AI'] == ''){
            fullData['input']['l${i+1}']['AI'] = j.key;
          }
          fullData['input']['l${i+1}']['PS_OUT'] = '1,${returnDeviceType(j.value['D_pressure_sensor_out'][1])},${j.value['D_pressure_sensor_out'][2]},${j.value['D_pressure_sensor_out'][3]},${j.value['D_pressure_sensor_out'][4]},${j.value['D_pressure_sensor_out'][5]}' ;
          map_i_o += '${j.value['D_pressure_sensor_out'][5]},PO.${i+1}.2.1,${returnDeviceType_HW(j.value['D_pressure_sensor_out'][1])},${numberORnot(j.value['D_pressure_sensor_out'][2])},${numberORnot(j.value['D_pressure_sensor_out'][3])},${j.value['D_pressure_sensor_out'][4]};' ;
        }
      }
    }
    for(var i = 0;i < CD_for_MO.length;i++){
      fullData['output']['CD${i+1}'] = {};
      for(var j in CD_for_MO[i].entries){
        fullData['output']['CD${i+1}']['inj'] = '';
        fullData['output']['CD${i+1}']['AI'] = j.key;
        for(var k = 0;k < j.value['injector'].length;k++){
          fullData['output']['CD${i+1}']['inj'] += '${k+1},${returnDeviceType(j.value['injector'][k][1])},${j.value['injector'][k][2]},${j.value['injector'][k][3]},${j.value['injector'][k][4]},${j.value['injector'][k][5]}${k == j.value['injector'].length - 1 ? '' : '|'}' ;
          map_i_o += '${j.value['injector'][k][5]},FC.${i+1}.1.${k+1},${returnDeviceType_HW(j.value['injector'][k][1])},${numberORnot(j.value['injector'][k][2])},${numberORnot(j.value['injector'][k][3])},1;' ;
        }
      }
    }
    for(var i = 0;i < CD_for_MO.length;i++){
      bool anyOne = false;
      for(var l in CD_for_MO[i].entries){
        for(var k = 0;k < l.value['booster'].length;k++){
          if(l.value['booster'][k][0] == true){
            anyOne = true;
          }
        }
      }
      if(anyOne == true){
        fullData['output']['CD${i+1}']['booster'] = '';
        bool iamFirst = true;
        for(var l in CD_for_MO[i].entries){
          for(var k = 0;k < l.value['booster'].length;k++){
            if(l.value['booster'][k][0] == true){
              fullData['output']['CD${i+1}']['booster'] += '${iamFirst == false ? '|' : ''}${k+1},${returnDeviceType(l.value['booster'][k][1])},${l.value['booster'][k][2]},${l.value['booster'][k][3]},${l.value['booster'][k][4]},${l.value['booster'][k][5]}' ;
              map_i_o += '${l.value['booster'][k][5]},FB.${i+1}.1.${k+1},${returnDeviceType_HW(l.value['booster'][k][1])},${numberORnot(l.value['booster'][k][2])},${numberORnot(l.value['booster'][k][3])},1;' ;
              iamFirst = false;
            }
          }
        }
      }
    }
    for(var i = 0;i < CF_for_MO.length;i++){
      fullData['output']['CF${i+1}'] = {};
      for(var j in CF_for_MO[i].entries){
        fullData['output']['CF${i+1}']['AI'] = j.key;
        fullData['output']['CF${i+1}']['filt'] = '';
        for(var k = 0;k < j.value['filter'].length;k++){
          fullData['output']['CF${i+1}']['filt'] += '${k+1},${returnDeviceType(j.value['filter'][k][1])},${j.value['filter'][k][2]},${j.value['filter'][k][3]},${j.value['filter'][k][4]}${k == j.value['filter'].length - 1 ? '' : '|'}' ;
          map_i_o += '${j.value['filter'][k][4]},FL.${i+1}.1.${k+1},${returnDeviceType_HW(j.value['filter'][k][1])},${numberORnot(j.value['filter'][k][2])},${numberORnot(j.value['filter'][k][3])},1;' ;

        }
      }
      for(var j in CF_for_MO[i].entries){
        if(j.value['D_S_valve'][0] == true){
          fullData['output']['CF${i+1}']['d_v'] = '';
          fullData['output']['CF${i+1}']['d_v'] += '1,${returnDeviceType(j.value['D_S_valve'][1])},${j.value['D_S_valve'][2]},${j.value['D_S_valve'][3]},${j.value['D_S_valve'][4]}' ;
          map_i_o += '${j.value['D_S_valve'][4]},DS.${i+1}.1,${returnDeviceType_HW(j.value['D_S_valve'][1])},${numberORnot(j.value['D_S_valve'][2])},${numberORnot(j.value['D_S_valve'][3])},1;' ;
        }
      }
    }
    if(SP_MO.length != 0){
      fullData['output']['SP'] = '';
      for(var i = 0;i < SP_MO.length;i++){
        for(var j in SP_MO[i].entries){
          String src = '';
          for(var sp = 0;sp < sourcePump.length;sp++){
            if(sp+1 == i+1){
              src = sourcePump[sp][0];
            }
          }
          fullData['output']['SP'] += '${i+1},${returnDeviceType(j.value['pump'][1])},${j.value['pump'][2]},${j.value['pump'][3]},${src},${j.key},${j.value['pump'][4]}${i == SP_MO.length - 1 ? '' : '|'}' ;
          map_i_o += '${j.value['pump'][4]},SP.${i+1},${returnDeviceType_HW(j.value['pump'][1])},${numberORnot(j.value['pump'][2])},${numberORnot(j.value['pump'][3])},1;' ;

        }

      }
    }
    if(IP_MO.length != 0){
      fullData['output']['IP'] = '';
      for(var i = 0;i < IP_MO.length;i++){
        for(var j in IP_MO[i].entries){
          fullData['output']['IP'] += '${i+1},${returnDeviceType(j.value['pump'][1])},${j.value['pump'][2]},${j.value['pump'][3]},${j.key},${j.value['pump'][4]}${i == IP_MO.length - 1 ? '' : '|'}' ;
          map_i_o += '${j.value['pump'][4]},IP.${i+1},${returnDeviceType_HW(j.value['pump'][1])},${numberORnot(j.value['pump'][2])},${numberORnot(j.value['pump'][3])},1;' ;

        }

      }
    }
    for(var i = 0;i < CD_for_MO.length;i++){
      bool anyOne = false;
      for(var j in CD_for_MO[i].entries){
        for(var k = 0;k < j.value['dosing_meter'].length;k++){
          if(j.value['dosing_meter'][k][0] == true){
            anyOne = true;
          }
        }
        if(anyOne == true){
          fullData['input']['CD${i+1}'] = {};
          fullData['input']['CD${i+1}']['AI'] = j.key;
          fullData['input']['CD${i+1}']['d_meter'] = '';
          bool iamFirst = true;
          for(var k = 0;k < j.value['dosing_meter'].length;k++){
            if(j.value['dosing_meter'][k][0] == true){
              fullData['input']['CD${i+1}']['d_meter'] += '${iamFirst == false ? '|' : ''}${k+1},${returnDeviceType(j.value['dosing_meter'][k][1])},${j.value['dosing_meter'][k][2]},${j.value['dosing_meter'][k][3]},${j.value['dosing_meter'][k][4]},${j.value['dosing_meter'][k][5]},${j.value['dosing_meter'][k][6]}' ;
              map_i_o += '${j.value['dosing_meter'][k][6]},FM.${i+1}.1.${k+1},${returnDeviceType_HW(j.value['dosing_meter'][k][1])},${numberORnot(j.value['dosing_meter'][k][2])},${numberORnot(j.value['dosing_meter'][k][3])},${j.value['dosing_meter'][k][4]};' ;
              iamFirst = false;
            }
          }
        }
      }
    }
    for(var i = 0;i < CF_for_MO.length;i++){
      for(var j in CF_for_MO[i].entries){
        if(j.value['P_sensor'][0] == true || j.value['P_sensor_out'][0] == true){
          fullData['input']['CF${i+1}'] = {};
        }
      }
    }
    for(var i = 0;i < CF_for_MO.length;i++){
      for(var j in CF_for_MO[i].entries){

        if(j.value['P_sensor'][0] == true){
          fullData['input']['CF${i+1}']['AI'] = j.key;
          fullData['input']['CF${i+1}']['PS_IN'] = '';
          fullData['input']['CF${i+1}']['PS_IN'] += '1,${returnDeviceType(j.value['P_sensor'][1])},${j.value['P_sensor'][2]},${j.value['P_sensor'][3]},${j.value['P_sensor'][4]},${j.value['P_sensor'][5]}' ;
          map_i_o += '${j.value['P_sensor'][5]},PI.${i+1},${returnDeviceType_HW(j.value['P_sensor'][1])},${numberORnot(j.value['P_sensor'][2])},${numberORnot(j.value['P_sensor'][3])},${j.value['P_sensor'][4]};' ;
        }
      }
    }
    for(var i = 0;i < CF_for_MO.length;i++){
      for(var j in CF_for_MO[i].entries){
        if(j.value['P_sensor_out'][0] == true){
          fullData['input']['CF${i+1}']['AI'] = j.key;
          fullData['input']['CF${i+1}']['PS_OUT'] = '';
          fullData['input']['CF${i+1}']['PS_OUT'] += '1,${returnDeviceType(j.value['P_sensor_out'][1])},${j.value['P_sensor_out'][2]},${j.value['P_sensor_out'][3]},${j.value['P_sensor_out'][4]},${j.value['P_sensor_out'][5]}' ;
          map_i_o += '${j.value['P_sensor_out'][5]},PO.${i+1},${returnDeviceType_HW(j.value['P_sensor_out'][1])},${numberORnot(j.value['P_sensor_out'][2])},${numberORnot(j.value['P_sensor_out'][3])},${j.value['P_sensor_out'][4]};' ;
        }
      }
    }
    if(SP_MO.length != 0){
      var ipAnyOne = false;
      for(var i = 0;i < SP_MO.length;i++){
        for(var j in SP_MO[i].entries){
          if(j.value['water_meter'][0] == true){
            ipAnyOne = true;
          }
        }
      }
      if(ipAnyOne == true){
        fullData['input']['SP/wm'] = '';
        var wmList = [];
        for(var i = 0;i < SP_MO.length;i++){
          for(var j in SP_MO[i].entries){
            if(j.value['water_meter'][0] == true){
              wmList.add('${i+1},${returnDeviceType(j.value['water_meter'][1])},${j.value['water_meter'][2]},${j.value['water_meter'][3]},${j.value['water_meter'][4]},${j.key},${j.value['water_meter'][5]}');
              map_i_o += '${j.value['water_meter'][5]},SW.${i+1},${returnDeviceType_HW(j.value['water_meter'][1])},${numberORnot(j.value['water_meter'][2])},${numberORnot(j.value['water_meter'][3])},${j.value['water_meter'][4]};' ;
            }
          }
        }
        for(var i = 0;i< wmList.length;i++){
          fullData['input']['SP/wm'] += '${wmList[i]}${i == wmList.length - 1 ? '' : '|'}' ;
        }
      }
    }
    if(IP_MO.length != 0){
      var ipAnyOne = false;
      for(var i = 0;i < IP_MO.length;i++){
        for(var j in IP_MO[i].entries){
          if(j.value['water_meter'][0] == true){
            ipAnyOne = true;
          }
        }
      }
      if(ipAnyOne == true){
        fullData['input']['IP/wm'] = '';
        var wmList = [];
        for(var i = 0;i < IP_MO.length;i++){
          for(var j in IP_MO[i].entries){
            if(j.value['water_meter'][0] == true){
              wmList.add('${i+1},${returnDeviceType(j.value['water_meter'][1])},${j.value['water_meter'][2]},${j.value['water_meter'][3]},${j.value['water_meter'][4]},${j.key},${j.value['water_meter'][5]}');
              map_i_o += '${j.value['water_meter'][5]},IW.${i+1},${returnDeviceType_HW(j.value['water_meter'][1])},${numberORnot(j.value['water_meter'][2])},${numberORnot(j.value['water_meter'][3])},${j.value['water_meter'][4]};' ;
            }
          }
        }
        for(var i = 0;i< wmList.length;i++){
          fullData['input']['IP/wm'] += '${wmList[i]}${i == wmList.length - 1 ? '' : '|'}' ;
        }
      }
    }
    if(totalAnalogSensor.length != 0){
      fullData['input']['AS'] = '';
      for(var i = 0;i < totalAnalogSensor.length;i++){
        fullData['input']['AS'] += '${i+1},${returnDeviceType(totalAnalogSensor[i][1])},${totalAnalogSensor[i][2]},${totalAnalogSensor[i][3]},${totalAnalogSensor[i][4]},${totalAnalogSensor[i][5]}${i == totalAnalogSensor.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalAnalogSensor[i][5]},AS.${i+1},${returnDeviceType_HW(totalAnalogSensor[i][1])},${numberORnot(totalAnalogSensor[i][2])},${numberORnot(totalAnalogSensor[i][3])},${totalAnalogSensor[i][4]};' ;

      }
    }
    if(totalContact.length != 0){
      fullData['input']['CONT'] = '';
      for(var i = 0;i < totalContact.length;i++){
        fullData['input']['CONT'] += '${i+1},${returnDeviceType(totalContact[i][1])},${totalContact[i][2]},${totalContact[i][3]},${totalContact[i][4]},${totalContact[i][5]}${i == totalContact.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalContact[i][5]},CT.${i+1},${returnDeviceType_HW(totalContact[i][1])},${numberORnot(totalContact[i][2])},${numberORnot(totalContact[i][3])},${totalContact[i][4]};' ;

      }
    }
    if(totalMoistureSensor.length != 0){
      fullData['input']['M_Sensor'] = '';
      for(var i = 0;i < totalMoistureSensor.length;i++){
        fullData['input']['M_Sensor'] += '${i+1},${returnDeviceType(totalMoistureSensor[i][1])},${totalMoistureSensor[i][2]},${totalMoistureSensor[i][3]},${totalMoistureSensor[i][4]},${totalMoistureSensor[i][5]}${i == totalMoistureSensor.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalMoistureSensor[i][5]},SM.${i+1},${returnDeviceType_HW(totalMoistureSensor[i][1])},${numberORnot(totalMoistureSensor[i][2])},${numberORnot(totalMoistureSensor[i][3])},${totalMoistureSensor[i][4]};' ;

      }
    }
    if(totalPhSensor.length != 0){
      fullData['input']['PH_Sensor'] = '';
      for(var i = 0;i < totalPhSensor.length;i++){
        fullData['input']['PH_Sensor'] += '${i+1},${returnDeviceType(totalPhSensor[i][1])},${totalPhSensor[i][2]},${totalPhSensor[i][3]},${totalPhSensor[i][4]},${totalPhSensor[i][5]}${i == totalPhSensor.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalPhSensor[i][5]},PH.${i+1},${returnDeviceType_HW(totalPhSensor[i][1])},${numberORnot(totalPhSensor[i][2])},${numberORnot(totalPhSensor[i][3])},${totalPhSensor[i][4]};' ;

      }
    }
    if(totalEcSensor.length != 0){
      fullData['input']['EC_Sensor'] = '';
      for(var i = 0;i < totalEcSensor.length;i++){
        fullData['input']['EC_Sensor'] += '${i+1},${returnDeviceType(totalEcSensor[i][1])},${totalEcSensor[i][2]},${totalEcSensor[i][3]},${totalEcSensor[i][4]},${totalEcSensor[i][5]}${i == totalEcSensor.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalEcSensor[i][5]},EC.${i+1},${returnDeviceType_HW(totalEcSensor[i][1])},${numberORnot(totalEcSensor[i][2])},${numberORnot(totalEcSensor[i][3])},${totalEcSensor[i][4]};' ;

      }
    }
    if(totalFan.length != 0){
      fullData['output']['Fan'] = '';
      for(var i = 0;i < totalFan.length;i++){
        fullData['output']['Fan'] += '${i+1},${returnDeviceType(totalFan[i][1])},${totalFan[i][2]},${totalFan[i][3]},${totalFan[i][4]}${i == totalFan.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalFan[i][4]},FN.${i+1},${returnDeviceType_HW(totalFan[i][1])},${numberORnot(totalFan[i][2])},${numberORnot(totalFan[i][3])},1;' ;

      }
    }
    if(totalFogger.length != 0){
      fullData['output']['Fogger'] = '';
      for(var i = 0;i < totalFogger.length;i++){
        fullData['output']['Fogger'] += '${i+1},${returnDeviceType(totalFogger[i][1])},${totalFogger[i][2]},${totalFogger[i][3]},${totalFogger[i][4]}${i == totalFogger.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalFogger[i][4]},FG.${i+1},${returnDeviceType_HW(totalFogger[i][1])},${numberORnot(totalFogger[i][2])},${numberORnot(totalFogger[i][3])},1;' ;

      }
    }
    if(totalAgitator.length != 0){
      fullData['output']['Agitator'] = '';
      for(var i = 0;i < totalAgitator.length;i++){
        fullData['output']['Agitator'] += '${i+1},${returnDeviceType(totalAgitator[i][1])},${totalAgitator[i][2]},${totalAgitator[i][3]},${totalAgitator[i][4]}${i == totalAgitator.length - 1 ? '' : '|'}' ;
        map_i_o += '${totalAgitator[i][4]},AG.${i+1},${returnDeviceType_HW(totalAgitator[i][1])},${numberORnot(totalAgitator[i][2])},${numberORnot(totalAgitator[i][3])},1;' ;
      }
    }
    fullData['all_AI'] = {
      'autoIncrement' : autoIncrement,
      'C_D_autoIncrement' : C_D_autoIncrement,
      'C_F_autoIncrement' : C_F_autoIncrement,
      'P_autoIncrement' : P_autoIncrement,
      'I_O_autoIncrement' : I_O_autoIncrement,
      'CD_channel_autoIncrement' : CD_channel_autoIncrement,
    };
    print('output : ${jsonEncode(fullData['output'])}');
    print('input : ${jsonEncode(fullData['input'])}');
    // hardWarePayLoad();
    notifyListeners();
    return fullData;
  }

  void updateAI(dynamic list){
    switch(list[0]){
      case ('autoIncrement'):{
        autoIncrement = list[1];
        break;
      }
      case ('C_D_autoIncrement'):{
        C_D_autoIncrement = list[1];
        break;
      }
      case ('C_F_autoIncrement'):{
        C_F_autoIncrement = list[1];
        break;
      }
      case ('P_autoIncrement'):{
        P_autoIncrement = list[1];
        break;
      }
      case ('I_O_autoIncrement'):{
        I_O_autoIncrement = list[1];
        break;
      }
      case ('CD_channel_autoIncrement'):{
        CD_channel_autoIncrement = list[1];
        break;
      }
    }
    notifyListeners();
  }



  var Sourcereturn ='';
  String convertSourcepump(List<dynamic> sourcePump) {
    for (var i = 0; i < sourcePump.length; i++) {
      List<dynamic> innerList = sourcePump[i];
      if (innerList.length >2){
        String innerListsro = innerList[3].toString();
        int innerListpositionint = i + 1;
        String innerListposition = innerListpositionint.toString();
        String innerListwm = innerList[1] == true ? "1" : "0";
        Sourcereturn += "$innerListsro,1,$innerListposition,$innerListwm;";
      }
    }
    return Sourcereturn;
  }

  String convertIrrigationpump(List<dynamic> irrigationPump) {
    for (var i = 0; i < irrigationPump.length; i++) {
      List<dynamic> innerList = irrigationPump[i];
      String innerListsro = innerList[1][1].toString();
      int innerListpositionint = i + 1;
      String innerListposition = innerListpositionint.toString();
      String innerListwm = innerList[0] == true ? "1" : "0";
      Sourcereturn += "$innerListsro,2,$innerListposition,$innerListwm;";
    }
    return Sourcereturn;
  }

  String Dosingreturn = '';
  String convertCentralDosing(List<dynamic> irrigationline) {
    String value = '';
    String linevalue;

    for (var i = 0; i < irrigationline.length; i++) {
      if (i == (irrigationline[i].length - 1)) {
        linevalue = irrigationline[i][1].toString();
      } else {
        String srno = '';
        String booster = '';
        String fm = '';
        String ch = '';
        int j = 0;
        value = '';
        for (var j = 0; j < (irrigationline[i].length - 1); j++) {
          srno = irrigationline[i][j][3].toString();
          booster = irrigationline[i][j][2] == true ? "1" : "0";
          fm = irrigationline[i][j][1] == true ? "1" : "0";
          ch = irrigationline[i][j][0].toString();
          j = j + 1;
        }
        value += '$srno,1.${j},$booster,1.${j}.$ch,$fm';
      }

      Dosingreturn += '$value;';
    }
    return Dosingreturn;
  }

  String convertlocalDosing(List<dynamic> irrigationline) {
    String value = '';
    String linevalue;

    for (var i = 0; i < irrigationline.length; i++) {
      if (i == (irrigationline[i].length - 1)) {
        linevalue = irrigationline[i][1].toString();
      } else {
        String srno = '';
        String booster = '';
        String fm = '';
        String ch = '';
        int j = 0;
        value = '';
        for (var j = 0; j < (irrigationline[i].length - 1); j++) {
          srno = irrigationline[i][j][3].toString();
          booster = irrigationline[i][j][2] == true ? "1" : "0";
          fm = irrigationline[i][j][1] == true ? "1" : "0";
          ch = irrigationline[i][j][0].toString();
          j = j + 1;
        }
        value += '$srno,2.${j},$booster,2.${j}.$ch,$fm';
      }

      Dosingreturn += '$value;';
    }
    return Dosingreturn;
  }

  String irrigationreturn = '';
  String convertIrrigation(List<dynamic> irrigationline) {
    for (var i = 0; i < irrigationline.length; i++) {
      String autoIncrement = irrigationline[i]['autoIncrement'] == '-'
          ? "0"
          : irrigationline[i]['autoIncrement'].toString();
      String valve = irrigationline[i]['valve'] == '-'
          ? "0"
          : irrigationline[i]['valve'].toString();
      String main_valve1 = irrigationline[i]['main_valve'] == '-'
          ? "0"
          : irrigationline[i]['main_valve'].toString();
      String main_valve = '${i + 1}.$main_valve1';
      String Central_dosing_site =
      irrigationline[i]['Central_dosing_site'] == '-'
          ? "0"
          : irrigationline[i]['Central_dosing_site'].toString();
      String Central_filtration_site =
      irrigationline[i]['Central_filtration_site'] == '-'
          ? "0"
          : irrigationline[i]['Central_filtration_site'].toString();
      String Local_dosing_site =
      irrigationline[i]['Local_dosing_site'] == true ? "1" : "0";
      String local_filtration_site =
      irrigationline[i]['local_filtration_site'] == true ? "1" : "0";
      String pressure_sensor =
      irrigationline[i]['pressure_sensor'] == true ? "1" : "0";
      String irrigationPump = irrigationline[i]['irrigationPump'] == '-'
          ? "0"
          : irrigationline[i]['irrigationPump'].toString();
      String water_meter = irrigationline[i]['water_meter'] == true ? "1" : "0";
      String ORO_Smart_RTU = irrigationline[i]['ORO_Smart_RTU'] == '-'
          ? "0"
          : irrigationline[i]['ORO_Smart_RTU'].toString();
      String RTU = irrigationline[i]['RTU'] == '-'
          ? "0"
          : irrigationline[i]['RTU'].toString();
      String ORO_switch = irrigationline[i]['ORO_switch'] == '-'
          ? "0"
          : irrigationline[i]['ORO_switch'].toString();
      String ORO_sense = irrigationline[i]['ORO_sense'] == '-'
          ? "0"
          : irrigationline[i]['ORO_sense'].toString();

      irrigationreturn +=
      "$autoIncrement,$valve,$main_valve,$Central_dosing_site,$Central_filtration_site,$Local_dosing_site,$local_filtration_site,$pressure_sensor,$irrigationPump,$water_meter,$ORO_Smart_RTU,$RTU,$ORO_switch,$ORO_sense,0;";
    }
    return irrigationreturn;
  }
  var Srofilder = 0;

  String Filterreturn = '';
  String convertcentralfilter(List<dynamic> sourcePump) {
    if(sourcePump.length != 0){
      for (var i = 0; i < sourcePump.length; i++) {
        List<dynamic> innerList = sourcePump[i];
        String fsite = innerList[3][1].toString();
        String dwvalve = innerList[1] == true ? "1" : "0";
        String dprs = innerList[2] == true ? "1" : "0";
        int srno = i + 1;
        Srofilder = i + 1;
        Filterreturn += "$srno,1.$srno,$fsite,$dwvalve,$dprs;";
      }
    }
    return Filterreturn;
  }
  String convertlocalfilter(List<dynamic> sourcePump) {
    for (var i = 0; i < sourcePump.length; i++) {
      List<dynamic> innerList = sourcePump[i];
      if(innerList.length>0){
        String fsite = innerList[0].toString();
        String dwvalve = innerList[1] == true ? "1" : "0";
        String dprs = innerList[2] == true ? "1" : "0";
        int srno = Srofilder + i + 1;
        int ival = i + 1;
        Filterreturn += "$srno,2.$ival,$fsite,$dwvalve,$dprs;";
      }
    }
    return Filterreturn;
  }

  String rtunum(String name) {
    if (name == "Oro Gem") {
      return '1';
    } else if (name == "Oro Smart RTU") {
      return '2';
    } else if (name == "Oro RTU") {
      return '3';
    } else if (name == "Oro Pump") {
      return '4';
    } else if (name == "Oro Switch") {
      return '5';
    } else if (name == "Oro Level") {
      return '6';
    } else if (name == "Oro Sense") {
      return '7';
    } else if (name == "Oro Xtend") {
      return '8';
    } else if (name == "Oro Weather") {
      return '9';
    } else if (name == "Oro Gem Lite") {
      return '10';
    } else {
      return '0';
    }
  }

  String inputtypefun(String name) {
    if (name == "A-I") {
      return '2';
    } else if (name == "D-I") {
      return '3';
    } else if (name == "P-I") {
      return '4';
    } else if (name == "RS485") {
      return '5';
    } else if (name == "12C") {
      return '6';
    } else {
      return '0';
    }
  }
  String ioreturn = '';

  // String convertmapinputs(List<dynamic> minlist) {
  //   String value = '';
  //
  //
  //   List mapinnerlist = [
  //     'pressure_sensor',
  //     'water_meter',
  //     'ORO_sense',
  //     'dosing_meter',
  //     'D_pressure_sensor'
  //   ];
  //   for (var irr = 0; irr < minlist.length; irr++) {
  //
  //     String srno = '';
  //     String name = '';
  //     String deviceno = '';
  //     String rtu = '';
  //     String relayio = '';
  //     String inputtype = '';
  //     for (var maiinr = 0; maiinr < mapinnerlist.length; maiinr++) {
  //        value = '';
  //       String maiinrname = mapinnerlist[maiinr];
  //       List innerlist = minlist[irr]['${irr + 1}'][maiinrname];
  //
  //       if (maiinrname == 'D_pressure_sensor' ||
  //           maiinrname == 'pressure_sensor' ||
  //           maiinrname == 'water_meter') {
  //         if (innerlist.length > 0) {
  //           srno = innerlist[5] == '-' ? "0" : innerlist[5].toString();
  //           // name = innerlist[0] == '-' ? "0" : innerlist[0].toString();
  //           name = maiinrname == 'D_pressure_sensor' ? 'ds$maiinr' : maiinrname == 'pressure_sensor' ? 'ps$maiinr' : 'wm$maiinr';
  //           deviceno = innerlist[1] == '-' ? "0" : innerlist[1].toString();
  //           rtu = innerlist[2] == '-' ? "0" : innerlist[2].toString();
  //           relayio = innerlist[3] == '-' ? "0" : innerlist[3].toString();
  //           inputtype = innerlist[4] == '-' ? "0" : innerlist[4].toString();
  //           String rtudevicenum = rtunum(deviceno);
  //           String inputtypestr = inputtypefun(inputtype);
  //           value += '$srno,$name,$rtudevicenum,$rtu,$relayio,$inputtypestr;';
  //
  //         }
  //       } else {
  //         if (innerlist.length > 0) {
  //           for (var vsro = 0; vsro < innerlist.length; vsro++) {
  //             if (maiinrname == 'dosing_meter') {
  //               srno = innerlist[vsro][6] == '-'
  //                   ? "0"
  //                   : innerlist[vsro][6].toString();
  //             } else {
  //               srno = innerlist[vsro][5] == '-'
  //                   ? "0"
  //                   : innerlist[vsro][5].toString();
  //               name = 'l${irr}dm${vsro}';
  //             }
  //             // name = innerlist[vsro][0] == '-'
  //             //     ? "0"
  //             //     : innerlist[vsro][0].toString();
  //             deviceno = innerlist[vsro][1] == '-'
  //                 ? "0"
  //                 : innerlist[vsro][1].toString();
  //             rtu = innerlist[vsro][2] == '-'
  //                 ? "0"
  //                 : innerlist[vsro][2].toString();
  //             relayio = innerlist[vsro][3] == '-'
  //                 ? "0"
  //                 : innerlist[vsro][3].toString();
  //             inputtype = innerlist[vsro][4] == '-'
  //                 ? "0"
  //                 : innerlist[vsro][4].toString();
  //             String rtudevicenum = rtunum(deviceno);
  //             String inputtypestr = inputtypefun(inputtype);
  //              value += '$srno,$name,$rtudevicenum,$rtu,$relayio,$inputtypestr;';
  //           }
  //         }
  //       }
  //
  //     }
  //     ioreturn += '$value';
  //   }
  //
  //
  //   return ioreturn;
  // }


  String convertSP_MO(List<dynamic> sp) {
    String s_p = '';
    String i_p = '';
    for (var i = 0; i < sp.length; i++) {
      for (var j in sp[i].entries) {
        s_p = '';
        for (var k in j.value.entries) {
          if (k.key == 'pump') {
            s_p +=
            '${k.value[4]},SP${i + 1},${k.value[1]},${k.value[2]},${k.value[3]}${i == sp.length - 1 ? '' : ';'}';
          } else {
            if(k.value[0] == true){
              s_p +=
              '${k.value[5]},WM${i + 1},${k.value[1]},${k.value[2]},${k.value[3]}${i == sp.length - 1 ? '' : ';'}';
            }

          }
        }
        ioreturn += s_p;
      }
    }
    return ioreturn;
  }

  String convertIP_MO(List<dynamic> sp) {
    String s_p = '';
    String i_p = '';
    for (var i = 0; i < sp.length; i++) {
      for (var j in sp[i].entries) {
        s_p = '';
        for (var k in j.value.entries) {
          if (k.key == 'pump') {
            s_p +=
            '${k.value[4]},IP${i + 1},${k.value[1]},${k.value[2]},${k.value[3]}${i == sp.length - 1 ? '' : ';'}';
          } else {
            if(k.value[0] == true){
              s_p +=
              '${k.value[5]},WM${i + 1},${k.value[1]},${k.value[2]},${k.value[3]}${i == sp.length - 1 ? '' : ';'}';
            }

          }
        }
        ioreturn += s_p;
      }
    }
    return ioreturn;
  }

  String convertCD_MO(List<dynamic> cd) {
    String s_p = '';
    for (var i = 0; i < cd.length; i++) {
      for (var j in cd[i].entries) {
        s_p = '';
        String srno = '';
        String name = '';
        String deviceno = '';
        String rtu = '';
        String relayio = '';
        String inputtype = '';
        for (var k in j.value.entries) {
          if (k.key == 'injector') {
            for (var c = 0; c < k.value.length; c++) {
              srno = k.value[c][5] == '-' ? "0" : k.value[c][5].toString();
              name = 'INJ 1.${i+1}.${c+1}';
              deviceno = k.value[c][1] == '-' ? "0" : k.value[c][1].toString();
              rtu = k.value[c][2] == '-' ? "0" : k.value[c][2].toString();
              relayio = k.value[c][3] == '-' ? "0" : k.value[c][3].toString();
              String rtudevicenum = rtunum(deviceno);
              s_p += '$srno,$name,$rtudevicenum,$rtu,$relayio,1;';
            }
          } else if (k.key == 'booster') {
            for (var c = 0; c < k.value.length; c++) {
              if(k.value[c][0] == true){
                srno = k.value[c][5] == '-' ? "0" : k.value[c][5].toString();
                name = 'BP 1.${i+1}.${c+1}';
                deviceno = k.value[c][1] == '-' ? "0" : k.value[c][1].toString();
                rtu = k.value[c][2] == '-' ? "0" : k.value[c][2].toString();
                relayio = k.value[c][3] == '-' ? "0" : k.value[c][3].toString();
                String rtudevicenum = rtunum(deviceno);

                s_p += '$srno,$name,$rtudevicenum,$rtu,$relayio,1;';
              }

            }
          } else {
            for (var c = 0; c < k.value.length; c++) {
              if(k.value[c][0] == true){
                srno = k.value[c][6] == '-' ? "0" : k.value[c][6].toString();
                name = 'DM 1.${i+1}.${c+1}';
                deviceno = k.value[c][1] == '-' ? "0" : k.value[c][1].toString();
                rtu = k.value[c][2] == '-' ? "0" : k.value[c][2].toString();
                relayio = k.value[c][3] == '-' ? "0" : k.value[c][3].toString();
                String rtudevicenum = rtunum(deviceno);

                k.value[c][0] == true
                    ? s_p += '$srno,$name,$rtudevicenum,$rtu,$relayio,1;'
                    : '';
              }

            }
          }
        }
        ioreturn += s_p;
      }
    }
    return ioreturn;
  }

  String convertCF_MO(List<dynamic> cd) {
    String s_p = '';
    for (var i = 0; i < cd.length; i++) {
      for (var j in cd[i].entries) {
        s_p = '';
        String srno = '';
        String name = '';
        String deviceno = '';
        String rtu = '';
        String relayio = '';
        String inputtype = '';
        for (var k in j.value.entries) {
          if (k.key == 'filter') {
            for (var c = 0; c < k.value.length; c++) {
              srno = k.value[c][4] == '-' ? "0" : k.value[c][4].toString();
              name = 'filt ${i+1}.${c+1}';
              deviceno = k.value[c][1] == '-' ? "0" : k.value[c][1].toString();
              rtu = k.value[c][2] == '-' ? "0" : k.value[c][2].toString();
              relayio = k.value[c][3] == '-' ? "0" : k.value[c][3].toString();

              String rtudevicenum = rtunum(deviceno);

              s_p += '$srno,$name,$rtudevicenum,$rtu,$relayio,1;';
            }
          } else if (k.key == 'D_S_valve') {
            if(k.value[0] == true){
              srno = k.value[4] == '-' ? "0" : k.value[4].toString();
              name = 'DS-${i+1}';
              deviceno = k.value[1] == '-' ? "0" : k.value[1].toString();
              rtu = k.value[2] == '-' ? "0" : k.value[2].toString();
              relayio = k.value[3] == '-' ? "0" : k.value[3].toString();

              String rtudevicenum = rtunum(deviceno);

              k.value[0] == true
                  ? s_p += '$srno,$name,$rtudevicenum,$rtu,$relayio,1;'
                  : '';
            }

          } else if (k.key == 'P_sensor') {
            if(k.value[0] == true){
              srno = k.value[5] == '-' ? "0" : k.value[5].toString();
              name = 'PS-${i+1}';
              deviceno = k.value[1] == '-' ? "0" : k.value[1].toString();
              rtu = k.value[2] == '-' ? "0" : k.value[2].toString();
              relayio = k.value[3] == '-' ? "0" : k.value[3].toString();
              inputtype = k.value[4] == '-' ? "0" : k.value[4].toString();

              String rtudevicenum = rtunum(deviceno);
              String inputtypestr = inputtypefun(inputtype);

              k.value[0] == true
                  ? s_p +=
              '$srno,$name,$rtudevicenum,$rtu,$relayio,$inputtypestr;'
                  : '';
            }
          }
        }
        ioreturn += s_p;
      }
    }
    return ioreturn;
  }
  dynamic my_payload = '';
// void hardWarePayLoad(){
//   // String payloadsp = convertSourcepump(sourcePump);
//   // String payloadir = convertIrrigationpump(irrigationPump);
//   //
//   // String payloadirline = convertIrrigation(irrigationLines);
//   //
//   // String payloadcendosing = convertCentralDosing(centralDosing);
//   //
//   // String payloadlocdosing = convertlocalDosing(localDosing);
//
//   // String payloadcfilter = convertcentralfilter(centralFiltration);
//
//   // String payloadlocfilter = convertlocalfilter(localFiltration);
//
//   // String payloadmapip = convertmapinputs(mappingOfInputs);
//
//   // String payloadmapout = convertmappingoutput(mappingOfOutputs);
//
//   String payloadspmo = convertSP_MO(SP_MO);
//
//   String payloadipmo = convertIP_MO(IP_MO);
//
//   String payloadcdmo = convertCD_MO(CD_for_MO);
//
//   String payloadcfmo = convertCF_MO(CF_for_MO);
//
//   Map<String, List<dynamic>> payload = {
//     '200': [
//       {'201': payloadir},
//       {'202': payloadirline},
//       {'203': payloadlocdosing},
//       {'204': ''},
//       {'205': ''},
//       {'206': map_i_o},
//     ]
//   };
//   my_payload = payload;
//   // print('my_payload   :${my_payload}');
//   notifyListeners();
// }

}