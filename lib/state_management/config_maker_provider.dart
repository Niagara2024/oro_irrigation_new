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
  //batch variables
  var val = '1';
  var wmYesOrNo = false;
  var cdSite = '1';
  var injector = '1';
  var cfSite = '1';
  var filter = '1';
  int wantToSendData = 0;
  editWantToSendData(value){
    wantToSendData = value;
    notifyListeners();
  }
  editCfSite(value){
    cfSite = value;
    notifyListeners();
  }
  editFilter(value){
    filter = value;
    notifyListeners();
  }
  editTotalSite(value){
    cdSite = value;
    notifyListeners();
  }
  editInjector(value){
    injector = value;
    notifyListeners();
  }

  editVal(value){
    val = value;
    notifyListeners();
  }
  editWmYesOrNo(value){
    wmYesOrNo = value;
    notifyListeners();
  }

  Map<String,dynamic> names = {};
  //new
  List<dynamic> oWeather = [];
  List<dynamic> oRoWeatherForStation = [];
  int totalTempSensor = 0;
  List<dynamic> connTempSensor = [];
  int totalSoilTempSensor = 0;
  List<dynamic> connSoilTempSensor = [];
  int totalHumidity = 0;
  List<dynamic> connHumidity = [];
  int totalCo2 = 0;
  List<dynamic> connCo2 = [];
  int totalLux = 0;
  List<dynamic> connLux = [];
  int totalLdr = 0;
  List<dynamic> connLdr = [];
  int totalWindSpeed = 0;
  List<dynamic> connWindSpeed = [];
  int totalWindDirection = 0;
  List<dynamic> connWindDirection = [];
  int totalRainGauge = 0;
  List<dynamic> connRainGauge = [];
  int totalLeafWetness = 0;
  List<dynamic> connLeafWetness = [];
  //new
  bool isNew = true;
  dynamic oldData = {};
  dynamic serverData = {};
  List<dynamic> totalWaterSource = [];
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
  int totalRtuPlus = 0;
  int totalOroSwitch = 0;
  int totalOroSense = 0;
  int totalOroSmartRTU = 0;
  int totalOroSmartRtuPlus = 0;
  int totalOroLevel = 0;
  int totalOroPump = 0;
  int totalOroExtend = 0;
  List<dynamic> i_o_types = ['-','A-I','D-I','P-I','RS485','12C'];
  List<dynamic> totalAnalogSensor = [];
  List<dynamic> totalContact = [];
  List<dynamic> totalAgitator = [];
  List<dynamic> totalSelector = [];
  int totalPhSensor = 0;
  int totalPressureSwitch = 0;
  int totalDiffPressureSensor = 0;
  int totalEcSensor = 0;
  int totalMoistureSensor = 0;
  int totalLevelSensor = 0;
  int totalFan = 0;
  int totalFogger = 0;
  List<dynamic> oRtu = [];
  List<dynamic> oRtuPlus = [];
  List<dynamic> oSrtu = [];
  List<dynamic> oSrtuPlus = [];
  List<dynamic> oSwitch = [];
  List<dynamic> oSense = [];
  List<dynamic> oLevel = [];
  List<dynamic> oPump = [];
  List<dynamic> oPumpPlus = [];
  List<dynamic> oExtend = [];
  List<dynamic> rtuForLine = [];
  List<dynamic> rtuPlusForLine = [];
  List<dynamic> OroExtendForLine = [];
  List<dynamic> switchForLine = [];
  List<dynamic> OroSmartRtuForLine = [];
  List<dynamic> OroSmartRtuPlusForLine = [];
  List<dynamic> OroSenseForLine = [];
  List<dynamic> OroLevelForLine = [];
  bool sourcePumpSelection = false;
  bool sourcePumpSelectAll = false;
  List<dynamic> waterSource = [];
  List<dynamic> sourcePumpUpdated = [];
  List<dynamic> irrigationPumpUpdated = [];
  List<dynamic> centralDosingUpdated = [];
  List<dynamic> centralFiltrationUpdated = [];
  List<dynamic> irrigationLines = [ ];
  List<dynamic> localDosingUpdated = [];
  List<dynamic> localFiltrationUpdated = [];
  List<dynamic> weatherStation = [];
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
  List<dynamic> central_dosing_site_list = ['-',];
  List<dynamic> central_filtration_site_list = ['-',];
  List<dynamic> irrigation_pump_list = ['-',];
  List<dynamic> water_source_list = ['-',];
  List<dynamic> overAll = [];
  int selection = 0;
  int I_O_autoIncrement = 0;
  int selectedTab = 1;

  dynamic emptySensor(data){
    data['rtu'] = '-';
    data['rfNo'] = '-';
    data['input'] = '-';
    data['input_type'] = '-';
    return data;
  }

  void weatherStationFuntionality(list){
    switch (list[0]){
      case ('add') : {
        if(oRoWeatherForStation != 0){
          weatherStation.add({
            'sNo' : returnI_O_AutoIncrement(),
            'rfNo' : oRoWeatherForStation[0],
            'input' : '-',
            'input_type' : '-',
          });
          oRoWeatherForStation.removeAt(0);
        }

        break;
      }
      case ('delete') : {
        if(oRoWeatherForStation != 0){
          oRoWeatherForStation.add(weatherStation[list[1]]['rfNo']);
          weatherStation.removeAt(list[1]);
        }

        break;
      }
    }
    notifyListeners();
  }

  void editSelectedTab(int value){
    selectedTab = value;
    notifyListeners();
  }
  //Todo: clear config data

  void clearConfig(){
    oWeather = [];
    oRoWeatherForStation = [];
    totalTempSensor = 0;
    connTempSensor = [];
    totalSoilTempSensor = 0;
    connSoilTempSensor = [];
    totalHumidity = 0;
    connHumidity = [];
    totalCo2 = 0;
    connCo2 = [];
    totalLux = 0;
    connLux = [];
    totalLdr = 0;
    connLdr = [];
    totalWindSpeed = 0;
    connWindSpeed = [];
    totalWindDirection = 0;
    connWindDirection = [];
    totalRainGauge = 0;
    connRainGauge = [];
    totalLeafWetness = 0;
    connLeafWetness = [];
    oldData = {};
    totalWaterSource = [];
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
    totalOroLevel = 0;
    totalOroPump = 0;
    totalOroExtend = 0;
    i_o_types = ['-','A-I','D-I','P-I','RS485','12C'];
    totalAnalogSensor = [];
    totalContact = [];
    totalAgitator = [];
    totalSelector = [];
    totalPhSensor = 0;
    totalEcSensor = 0;
    totalMoistureSensor = 0;
    totalLevelSensor = 0;
    totalFan = 0;
    totalFogger = 0;
    oRtu = [];
    oSrtu = [];
    oSwitch = [];
    oSense = [];
    oLevel = [];
    oPump = [];
    oExtend = [];
    rtuForLine = [];
    OroExtendForLine = [];
    switchForLine = [];
    OroSmartRtuForLine = [];
    OroSenseForLine = [];
    OroLevelForLine = [];
    sourcePumpSelection = false;
    sourcePumpSelectAll = false;
    waterSource = ['-','A', 'B', 'C', 'D', 'E', 'F'];
    sourcePumpUpdated = [];
    irrigationPumpUpdated = [];
    centralDosingUpdated = [];
    centralFiltrationUpdated = [];
    irrigationLines = [ ];
    localDosingUpdated = [];
    localFiltrationUpdated = [];
    weatherStation = [];
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
    central_dosing_site_list = ['-'];
    central_filtration_site_list = ['-'];
    irrigation_pump_list = ['-'];
    water_source_list = ['-'];
    overAll = [];
    selection = 0;
    I_O_autoIncrement = 0;
    isNew = true;
    notifyListeners();
  }

  //Todo: initialize the remaining sensor

  int initialIndex = 0;
  void editInitialIndex(int index){
    initialIndex = index;
    notifyListeners();
  }

  void cancelSelection(){
    selection = 0;
    notifyListeners();
  }

  //TODO: refersh centralDosing
  void refreshCentralDosingList(){
    central_dosing_site_list = ['-'];
    for(var i = 0;i < centralDosingUpdated.length; i++){
      central_dosing_site_list.add('${i + 1}');
    }
    for(var i = 0;i < irrigationLines.length;i++){
      if(!central_dosing_site_list.contains(irrigationLines[i]['Central_dosing_site'])){
        irrigationLines[i]['Central_dosing_site'] = '-';
      }
    }
    notifyListeners();
  }

  //TODO: refersh centralFiltration
  void refreshCentralFiltrationList(){
    central_filtration_site_list = ['-'];
    for(var i = 0;i < centralFiltrationUpdated.length; i++){
      central_filtration_site_list.add('${i + 1}');
    }
    for(var i = 0;i < irrigationLines.length;i++){
      if(!central_filtration_site_list.contains(irrigationLines[i]['Central_filtration_site'])){
        irrigationLines[i]['Central_filtration_site'] = '-';
      }
    }
    notifyListeners();
  }
  //TODO: refersh irrigation pump
  void refreshIrrigationPumpList(){
    irrigation_pump_list = ['-'];
    for(var i = 0;i < irrigationPumpUpdated.length; i++){
      irrigation_pump_list.add('${i + 1}');
    }
    for(var i = 0;i < irrigationLines.length;i++){
      if(!irrigation_pump_list.contains(irrigationLines[i]['irrigationPump'])){
        irrigationLines[i]['irrigationPump'] = '-';
      }
    }
    notifyListeners();
  }

  //TODO: generating sno
  int returnI_O_AutoIncrement(){
    I_O_autoIncrement += 1;
    int val = I_O_autoIncrement;
    notifyListeners();
    return val;
  }

  //TODO: sourcePumpFunctionality

  void addingPump(List<dynamic> pump,int count,bool src,bool wm){
    if(count > 0){
      var add = false;
      var index = 0;
      for(var i in pump){
        if(i['deleted'] == true){
          i['deleted'] = false;
          i['pumpConnection'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'output' : '-',
            'current_selection' : '-',
          };
          i['oro_pump'] = false;
          i['oro_pump_plus'] = false;
          i['levelType'] = '-';
          i['levelSensor'] = {};
          i['selection'] = 'unselect';
          if(src == true){
            i['waterSource'] = '-';
          }
          i['waterMeter'] = {};
          add = true;
          index = pump.indexOf(i);
          break;
        }
      }
      if(add == false){
        pump.add({
          'sNo' : returnI_O_AutoIncrement(),
          'deleted' : false,
          'pumpConnection' : {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'output' : '-',
            'current_selection' : '-',
          },
          'oro_pump' : false,
          'oro_pump_plus' : false,
          'levelType' : '-',
          'levelSensor' : {},
          'selection' : 'unselect',
          if(src == true)
            'waterSource' : '-',
          'waterMeter' : {}
        });

      }
      if(wm == true){
        if(src == true){
          sourcePumpFunctionality(['editWaterMeter',add == true ? index : pump.length - 1,true]);
        }else{
          irrigationPumpFunctionality(['editWaterMeter',add == true ? index : pump.length - 1,true]);
        }
      }
      if(src == true){
        totalSourcePump -= 1;
      }else{
        totalIrrigationPump -= 1;
      }
    }
    notifyListeners();
  }
  void sourcePumpFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addSourcePump') : {
        addingPump(sourcePumpUpdated,totalSourcePump,true,false);
        break;
      }
      case ('addBatch') : {
        for(var i = 0;i < int.parse(list[1]);i++){
          addingPump(sourcePumpUpdated,totalSourcePump,true,list[2]);
        }
        break;
      }
      case ('editsourcePumpSelection') : {
        sourcePumpSelection = list[1];
        if(list[1] == true){
          for(var i = 0;i < sourcePumpUpdated.length;i ++){
            sourcePumpUpdated[i]['selection'] = 'unselect';
          }
        }
        break;
      }
      case ('editsourcePumpSelectAll') : {
        sourcePumpSelectAll = list[1];
        if(list[1] == true){
          selection = 0;
          for(var i = 0;i < sourcePumpUpdated.length;i ++){
            selection = selection + 1;
            sourcePumpUpdated[i]['selection'] = 'select';
          }
        }else{
          selection = 0;
          for(var i = 0;i < sourcePumpUpdated.length;i ++){
            sourcePumpUpdated[i]['selection'] = 'unselect';
          }
        }
        break;
      }
      case ('editLevelType_sp') : {
        if(list[2] == 'float level'){
          sourcePumpUpdated[list[1]]['TopTankHigh'] = {};
          sourcePumpUpdated[list[1]]['TopTankLow'] = {};
          sourcePumpUpdated[list[1]]['SumpTankHigh'] = {};
          sourcePumpUpdated[list[1]]['SumpTankLow'] = {};
        }else{
          sourcePumpUpdated[list[1]].remove('TopTankHigh');
          sourcePumpUpdated[list[1]].remove('TopTankLow');
          sourcePumpUpdated[list[1]].remove('SumpTankHigh');
          sourcePumpUpdated[list[1]].remove('SumpTankLow');
        }
        if(!['float level','-'].contains(list[2])){
          sourcePumpUpdated[list[1]]['levelSensor'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };
        }else{
          sourcePumpUpdated[list[1]]['levelSensor'] = {};
        }
        sourcePumpUpdated[list[1]]['levelType'] = list[2];
        break;
      }
      case ('reOrderPump') : {
        var data = sourcePumpUpdated[list[1]];
        sourcePumpUpdated.removeAt(list[1]);
        sourcePumpUpdated.insert(list[2], data);
        break;
      }
      case ('editWaterMeter') : {
        if(totalWaterMeter > 0){
          if(list[2] == true){
            sourcePumpUpdated[list[1]]['waterMeter'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
          }else{
            sourcePumpUpdated[list[1]]['waterMeter'] = {};
          }
          if(list[2] == true){
            totalWaterMeter = totalWaterMeter - 1;
          }else{
            totalWaterMeter = totalWaterMeter + 1;
          }

        }
        if(totalWaterMeter == 0){
          if(list[2] == false){
            sourcePumpUpdated[list[1]]['waterMeter'] = {};
            totalWaterMeter = totalWaterMeter + 1;
          }
        }
        break;
      }
      case ('editTopTankHigh') : {
        if(list[2] == true){
          sourcePumpUpdated[list[1]]['TopTankHigh'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          sourcePumpUpdated[list[1]]['TopTankHigh'] = {};
        }
        break;
      }
      case ('editTopTankLow') : {
        if(list[2] == true){
          sourcePumpUpdated[list[1]]['TopTankLow'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          sourcePumpUpdated[list[1]]['TopTankLow'] = {};
        }
        break;
      }
      case ('editSumpTankHigh') : {
        if(list[2] == true){
          sourcePumpUpdated[list[1]]['SumpTankHigh'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          sourcePumpUpdated[list[1]]['SumpTankHigh'] = {};
        }
        break;
      }
      case ('editSumpTankLow') : {
        if(list[2] == true){
          sourcePumpUpdated[list[1]]['SumpTankLow'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          sourcePumpUpdated[list[1]]['SumpTankLow'] = {};
        }
        break;
      }
      case ('editRelayCount_sp') : {
        if(list[2] == '1'){
          sourcePumpUpdated[list[1]].remove('off');
          sourcePumpUpdated[list[1]].remove('scr');
          sourcePumpUpdated[list[1]].remove('ecr');
        }
        else if(list[2] == '2'){
          if(sourcePumpUpdated[list[1]]['off'] == null){
            sourcePumpUpdated[list[1]]['off'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : sourcePumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          sourcePumpUpdated[list[1]].remove('scr');
          sourcePumpUpdated[list[1]].remove('ecr');
        }
        else if(list[2] == '3'){
          if(sourcePumpUpdated[list[1]]['off'] == null){
            sourcePumpUpdated[list[1]]['off'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : sourcePumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          if(sourcePumpUpdated[list[1]]['scr'] == null){
            sourcePumpUpdated[list[1]]['scr'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : sourcePumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
            sourcePumpUpdated[list[1]].remove('ecr');
          }
        }
        else if(list[2] == '4'){
          if(sourcePumpUpdated[list[1]]['off'] == null){
            sourcePumpUpdated[list[1]]['off'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : sourcePumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          if(sourcePumpUpdated[list[1]]['scr'] == null){
            sourcePumpUpdated[list[1]]['scr'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : sourcePumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          if(sourcePumpUpdated[list[1]]['ecr'] == null){
            sourcePumpUpdated[list[1]]['ecr'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : sourcePumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
        }
        sourcePumpUpdated[list[1]]['relayCount'] = list[2];
        break;
      }
      case ('editOroPump') : {
        if(list[2] == true){
          if(sourcePumpUpdated[list[1]]['oro_pump_plus'] == true){
            sourcePumpUpdated[list[1]]['oro_pump_plus'] = false;
          }
          if(sourcePumpUpdated[list[1]]['waterMeter'].isNotEmpty){
            sourcePumpFunctionality(['editWaterMeter',list[1],false]);
          }
          sourcePumpUpdated[list[1]].remove('pumpConnection');
          sourcePumpUpdated[list[1]]['relayCount'] = '1';

          sourcePumpUpdated[list[1]]['relayCount'] = '1';
          sourcePumpUpdated[list[1]]['on'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };
          sourcePumpUpdated[list[1]]['c1'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '${sourcePumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          sourcePumpUpdated[list[1]]['c2'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '${sourcePumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          sourcePumpUpdated[list[1]]['c3'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '${sourcePumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
        }else{

          sourcePumpUpdated[list[1]]['pumpConnection'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };

          sourcePumpUpdated[list[1]].remove('on');
          sourcePumpUpdated[list[1]].remove('off');
          sourcePumpUpdated[list[1]].remove('scr');
          sourcePumpUpdated[list[1]].remove('ecr');
          sourcePumpUpdated[list[1]].remove('c1');
          sourcePumpUpdated[list[1]].remove('c2');
          sourcePumpUpdated[list[1]].remove('c3');
        }
        sourcePumpUpdated[list[1]]['oro_pump'] = list[2];
        break;
      }
      case ('editOroPumpPlus') : {
        if(list[2] == true){
          if(sourcePumpUpdated[list[1]]['oro_pump'] == true){
            sourcePumpUpdated[list[1]]['oro_pump'] = false;
          }
          sourcePumpUpdated[list[1]].remove('pumpConnection');
          sourcePumpUpdated[list[1]]['relayCount'] = '1';

          sourcePumpUpdated[list[1]]['relayCount'] = '1';
          sourcePumpUpdated[list[1]]['on'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };
          sourcePumpUpdated[list[1]]['c1'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '${sourcePumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          sourcePumpUpdated[list[1]]['c2'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '${sourcePumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          sourcePumpUpdated[list[1]]['c3'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '${sourcePumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
        }else{
          sourcePumpFunctionality(['editLevelType_sp',list[1],'-']);
          sourcePumpUpdated[list[1]]['pumpConnection'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };

          sourcePumpUpdated[list[1]].remove('on');
          sourcePumpUpdated[list[1]].remove('off');
          sourcePumpUpdated[list[1]].remove('scr');
          sourcePumpUpdated[list[1]].remove('ecr');
          sourcePumpUpdated[list[1]].remove('c1');
          sourcePumpUpdated[list[1]].remove('c2');
          sourcePumpUpdated[list[1]].remove('c3');
        }
        sourcePumpUpdated[list[1]]['oro_pump_plus'] = list[2];
        break;
      }
      case ('editWaterSource_sp') : {
        sourcePumpUpdated[list[1]]['waterSource'] = list[2];
        break;
      }
      case ('selectSourcePump') : {
        if(list[2] == true){
          sourcePumpUpdated[list[1]]['selection'] = 'select';
          selection = selection + 1;
        }else{
          sourcePumpUpdated[list[1]]['selection'] = 'unselect';
          selection = selection - 1;
        }
        break;
      }
      case ('deleteSourcePump') : {
        List<Map<String, dynamic>> selectedPumps = [];
        for (var i = sourcePumpUpdated.length - 1; i >= 0; i--) {
          if (sourcePumpUpdated[i]['selection'] == 'select') {
            selectedPumps.add(sourcePumpUpdated[i]);

            if (sourcePumpUpdated[i]['waterMeter'].isNotEmpty) {
              totalWaterMeter = totalWaterMeter + 1;
            }
            totalSourcePump = totalSourcePump + 1;
          }
        }
        for (var selectedPump in selectedPumps) {
          if(isNew == false){
            sourcePumpUpdated[sourcePumpUpdated.indexOf(selectedPump)]['deleted'] = true;
          }else{
            sourcePumpUpdated.remove(selectedPump);
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
  //TODO: irrigationPumpFunctionality
  void irrigationPumpFunctionality(List<dynamic> list){
    switch (list[0]){
      case 'addIrrigationPump': {
        addingPump(irrigationPumpUpdated,totalIrrigationPump,false,false);
        print('pumpData : ${jsonEncode(irrigationPumpUpdated)}');
        break;
      }
      case ('addBatch') : {
        for(var i = 0;i < int.parse(list[1]);i++){
          addingPump(irrigationPumpUpdated,totalIrrigationPump,false,list[2]);
        }
        break;
      }
      case ('editLevelType_ip') : {
        if(list[2] == 'float level'){
          irrigationPumpUpdated[list[1]]['TopTankHigh'] = {};
          irrigationPumpUpdated[list[1]]['TopTankLow'] = {};
          irrigationPumpUpdated[list[1]]['SumpTankHigh'] = {};
          irrigationPumpUpdated[list[1]]['SumpTankLow'] = {};
        }else{
          irrigationPumpUpdated[list[1]].remove('TopTankHigh');
          irrigationPumpUpdated[list[1]].remove('TopTankLow');
          irrigationPumpUpdated[list[1]].remove('SumpTankHigh');
          irrigationPumpUpdated[list[1]].remove('SumpTankLow');
        }
        if(!['float level','-'].contains(list[2])){
          irrigationPumpUpdated[list[1]]['levelSensor'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };
          totalLevelSensor -= 1;
        }else{
          irrigationPumpUpdated[list[1]]['levelSensor'] = {};
          totalLevelSensor += 1;
        }
        irrigationPumpUpdated[list[1]]['levelType'] = list[2];
        break;
      }
      case 'editIrrigationPumpSelection' : {
        irrigationPumpSelection = list[1];
        if(list[1] == true){
          for(var i = 0;i < irrigationPumpUpdated.length;i ++){
            irrigationPumpUpdated[i]['selection'] = 'unselect';
          }
        }
        break;
      }
      case 'editIrrigationPumpSelectAll' : {
        irrigationPumpSelectAll = list[1];
        if(list[1] == true){
          selection = 0;
          for(var i = 0;i < irrigationPumpUpdated.length;i ++){
            irrigationPumpUpdated[i]['selection'] = 'select';
            selection += 1;
          }
        }else{
          for(var i = 0;i < irrigationPumpUpdated.length;i ++){
            irrigationPumpUpdated[i]['selection'] = 'unselect';
            selection = 0;
          }
        }
        break;
      }
      case ('reOrderPump') : {
        var data = irrigationPumpUpdated[list[1]];
        irrigationPumpUpdated.removeAt(list[1]);
        irrigationPumpUpdated.insert(list[2], data);
        break;
      }
      case 'editWaterMeter' : {
        if(totalWaterMeter > 0){
          if(list[2] == true){
            irrigationPumpUpdated[list[1]]['waterMeter'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
          }else{
            irrigationPumpUpdated[list[1]]['waterMeter'] = {};
          }
          if(list[2] == true){
            totalWaterMeter = totalWaterMeter - 1;
          }else{
            totalWaterMeter = totalWaterMeter + 1;
          }

        }
        if(totalWaterMeter == 0){
          if(list[2] == false){
            irrigationPumpUpdated[list[1]]['waterMeter'] = {};
            totalWaterMeter = totalWaterMeter + 1;
          }
        }
        break;
      }
      case 'selectIrrigationPump' : {
        if(irrigationPumpUpdated[list[1]]['selection'] == 'select'){
          irrigationPumpUpdated[list[1]]['selection'] = 'unselect';
          selection -= 1;
        }else{
          irrigationPumpUpdated[list[1]]['selection'] = 'select';
          selection += 1;
        }
        break;
      }
      case 'deleteIrrigationPump' : {
        List<Map<String, dynamic>> selectedPumps = [];
        for (var i = irrigationPumpUpdated.length - 1; i >= 0; i--) {
          if (irrigationPumpUpdated[i]['selection'] == 'select') {
            selectedPumps.add(irrigationPumpUpdated[i]);

            if (irrigationPumpUpdated[i]['waterMeter'].isNotEmpty) {
              totalWaterMeter = totalWaterMeter + 1;
            }
            totalIrrigationPump = totalIrrigationPump + 1;
          }
        }
        for (var selectedPump in selectedPumps) {
          if(isNew == false){
            irrigationPumpUpdated[irrigationPumpUpdated.indexOf(selectedPump)]['deleted'] = true;
            // irrigationPumpUpdated[irrigationPumpUpdated.indexOf(selectedPump)]['rtu'] = '-';
            // irrigationPumpUpdated[irrigationPumpUpdated.indexOf(selectedPump)]['rfNo'] = '-';
            // irrigationPumpUpdated[irrigationPumpUpdated.indexOf(selectedPump)]['output'] = '-';
          }else{
            irrigationPumpUpdated.remove(selectedPump);
          }
        }
        irrigationPumpSelection = false;
        irrigationPumpSelectAll = false;
        refreshIrrigationPumpList();
        break;
      }
      case ('editTopTankHigh') : {
        if(list[2] == true){
          irrigationPumpUpdated[list[1]]['TopTankHigh'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' :  '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          irrigationPumpUpdated[list[1]]['TopTankHigh'] = {};
        }
        break;
      }
      case ('editTopTankLow') : {
        if(list[2] == true){
          irrigationPumpUpdated[list[1]]['TopTankLow'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' :  '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          irrigationPumpUpdated[list[1]]['TopTankLow'] = {};
        }
        break;
      }
      case ('editSumpTankHigh') : {
        if(list[2] == true){
          irrigationPumpUpdated[list[1]]['SumpTankHigh'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' :  '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          irrigationPumpUpdated[list[1]]['SumpTankHigh'] = {};
        }
        break;
      }
      case ('editSumpTankLow') : {
        if(list[2] == true){
          irrigationPumpUpdated[list[1]]['SumpTankLow'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' :  '-',
            'rfNo' : '-',
            'input' : '-',
            'input_type' : '-',
          };

        }else{
          irrigationPumpUpdated[list[1]]['SumpTankLow'] = {};
        }
        break;
      }
      case ('editRelayCount_ip') : {
        if(list[2] == '1'){
          irrigationPumpUpdated[list[1]].remove('off');
          irrigationPumpUpdated[list[1]].remove('scr');
          irrigationPumpUpdated[list[1]].remove('ecr');
        }
        else if(list[2] == '2'){
          if(irrigationPumpUpdated[list[1]]['off'] == null){
            irrigationPumpUpdated[list[1]]['off'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : irrigationPumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          irrigationPumpUpdated[list[1]].remove('scr');
          irrigationPumpUpdated[list[1]].remove('ecr');
        }
        else if(list[2] == '3'){
          if(irrigationPumpUpdated[list[1]]['off'] == null){
            irrigationPumpUpdated[list[1]]['off'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : irrigationPumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          if(irrigationPumpUpdated[list[1]]['scr'] == null){
            irrigationPumpUpdated[list[1]]['scr'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : irrigationPumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
            irrigationPumpUpdated[list[1]].remove('ecr');
          }
        }
        else if(list[2] == '4'){
          if(irrigationPumpUpdated[list[1]]['off'] == null){
            irrigationPumpUpdated[list[1]]['off'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : irrigationPumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          if(irrigationPumpUpdated[list[1]]['scr'] == null){
            irrigationPumpUpdated[list[1]]['scr'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : irrigationPumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
          if(irrigationPumpUpdated[list[1]]['ecr'] == null){
            irrigationPumpUpdated[list[1]]['ecr'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : 'ORO Pump',
              'rfNo' : irrigationPumpUpdated[list[1]]['on']['rfNo'],
              'output' : '-',
              'output_type' : '1',
              'current_selection' : '-',
            };
          }
        }
        irrigationPumpUpdated[list[1]]['relayCount'] = list[2];
        break;
      }
      case ('editOroPump') : {
        if(list[2] == true){
          if(irrigationPumpUpdated[list[1]]['oro_pump_plus'] == true){
            irrigationPumpUpdated[list[1]]['oro_pump_plus'] = false;
          }
          if(irrigationPumpUpdated[list[1]]['waterMeter'].isNotEmpty){
            irrigationPumpFunctionality(['editWaterMeter',list[1],false]);
          }
          irrigationPumpUpdated[list[1]].remove('pumpConnection');
          irrigationPumpUpdated[list[1]]['relayCount'] = '1';

          irrigationPumpUpdated[list[1]]['relayCount'] = '1';
          irrigationPumpUpdated[list[1]]['on'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };
          irrigationPumpUpdated[list[1]]['c1'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '${irrigationPumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          irrigationPumpUpdated[list[1]]['c2'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '${irrigationPumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          irrigationPumpUpdated[list[1]]['c3'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'ORO Pump',
            'rfNo' : '${irrigationPumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
        }else{
          irrigationPumpUpdated[list[1]]['pumpConnection'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };

          irrigationPumpUpdated[list[1]].remove('on');
          irrigationPumpUpdated[list[1]].remove('off');
          irrigationPumpUpdated[list[1]].remove('scr');
          irrigationPumpUpdated[list[1]].remove('ecr');
          irrigationPumpUpdated[list[1]].remove('c1');
          irrigationPumpUpdated[list[1]].remove('c2');
          irrigationPumpUpdated[list[1]].remove('c3');
        }
        irrigationPumpUpdated[list[1]]['oro_pump'] = list[2];
        break;
      }
      case ('editOroPumpPlus') : {
        if(list[2] == true){
          irrigationPumpFunctionality(['editWaterMeter',list[1],false]);
          if(irrigationPumpUpdated[list[1]]['oro_pump'] == true){
            irrigationPumpUpdated[list[1]]['oro_pump'] = false;
          }
          irrigationPumpUpdated[list[1]].remove('pumpConnection');
          irrigationPumpUpdated[list[1]]['relayCount'] = '1';

          irrigationPumpUpdated[list[1]]['relayCount'] = '1';
          irrigationPumpUpdated[list[1]]['on'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };
          irrigationPumpUpdated[list[1]]['c1'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '${irrigationPumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          irrigationPumpUpdated[list[1]]['c2'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '${irrigationPumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
          irrigationPumpUpdated[list[1]]['c3'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : 'O-Pump-Plus',
            'rfNo' : '${irrigationPumpUpdated[list[1]]['on']['rfNo']}',
            'input' : '-',
            'input_type' : '-',
          };
        }else{
          irrigationPumpFunctionality(['editLevelType_ip',list[1],'-']);
          irrigationPumpUpdated[list[1]]['pumpConnection'] = {
            'sNo' : returnI_O_AutoIncrement(),
            'rtu' : '-',
            'rfNo' : '-',
            'output' : '-',
            'output_type' : '1',
            'current_selection' : '-',
          };

          irrigationPumpUpdated[list[1]].remove('on');
          irrigationPumpUpdated[list[1]].remove('off');
          irrigationPumpUpdated[list[1]].remove('scr');
          irrigationPumpUpdated[list[1]].remove('ecr');
          irrigationPumpUpdated[list[1]].remove('c1');
          irrigationPumpUpdated[list[1]].remove('c2');
          irrigationPumpUpdated[list[1]].remove('c3');
        }
        irrigationPumpUpdated[list[1]]['oro_pump_plus'] = list[2];
        break;
      }
      default : {
        break;
      }
    }
    refreshIrrigationPumpList();
    notifyListeners();

  }
  //TODO: addBatch injector
  List<Map<String,dynamic>> addBatchInjector(int count){
    List<Map<String,dynamic>> injector = [];
    for(var i = 0;i < count;i++){
      injector.add({
        'sNo' : returnI_O_AutoIncrement(),
        'Which_Booster_Pump' : '-',
        'rtu' : '-',
        'rfNo' : '-',
        'output' : '-',
        'output_type' : '1',
        'dosingMeter' : {},
        'levelSensor' : {},
        'injectorType' : 'Electrical',

      });
      totalInjector = totalInjector - 1;
    }
    return injector;
  }
  //TODO: centralDosingFunctionality
  void centralDosingFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addCentralDosing') : {
        if(totalCentralDosing > 0 && totalInjector > 0){
          var add = false;
          for(var i in centralDosingUpdated){
            if(i['deleted'] == true){
              i['deleted'] = false;
              i['selection'] = 'unselect';
              i['injector'] = [{
                'sNo' : returnI_O_AutoIncrement(),
                'Which_Booster_Pump' : '-',
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
                'dosingMeter' : {},
                'levelSensor' : {},
                'injectorType' : 'Electrical',
              }];
              i['boosterPump'] = '';
              i['boosterConnection'] = [];
              i['ec'] = '';
              i['ecConnection'] = [];
              i['ph'] = '';
              i['phConnection'] = [];
              i['pressureSwitch'] = {};
              add = true;
              break;
            }
          }
          if(add == false){
            centralDosingUpdated.add({
              'sNo' : returnI_O_AutoIncrement(),
              'selection' : 'unselect',
              'deleted' : false,
              'injector' : [{
                'sNo' : returnI_O_AutoIncrement(),
                'Which_Booster_Pump' : '-',
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
                'dosingMeter' : {},
                'levelSensor' : {},
                'injectorType' : 'Electrical',
              }],
              'boosterPump' : '',
              'boosterConnection' : [],
              'ec' : '',
              'ecConnection' : [],
              'ph' : '',
              'phConnection' : [],
              'pressureSwitch' : {},
            });
          }
          totalCentralDosing = totalCentralDosing - 1;
          totalInjector = totalInjector - 1;
          // refreshCentralDosingList();
        }
        break;
      }
      case ('addBatch_CD') : {
        if(totalCentralDosing > 0 && totalInjector > 0){
          for(var i = 0;i < list[1];i++){
            var useOld = false;
            totalCentralDosing -= 1;
            check : for(var cd in centralDosingUpdated){
              if(cd['deleted'] == true){
                cd['deleted'] = false;
                cd['selection'] = 'unselect';
                cd['injector'] = addBatchInjector(list[2]);
                cd['boosterPump'] = '';
                cd['boosterConnection'] = [];
                cd['ec'] = '';
                cd['ecConnection'] = [];
                cd['ph'] = '';
                cd['phConnection'] = [];
                cd['pressureSwitch'] = {};
                useOld = true;
                break check;
              }
            }
            if(useOld == false){
              centralDosingUpdated.add({
                'sNo' : returnI_O_AutoIncrement(),
                'selection' : 'unselect',
                'injector' : addBatchInjector(list[2]),
                'boosterPump' : '',
                'boosterConnection' : [],
                'ec' : '',
                'ecConnection' : [],
                'ph' : '',
                'phConnection' : [],
                'pressureSwitch' : {},
                'deleted' : false
              });
            }
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
          for(var i = 0;i < centralDosingUpdated.length;i ++){
            centralDosingUpdated[i]['selection'] = 'select';
            selection += 1;
          }
        }else{
          for(var i = 0;i < centralDosingUpdated.length;i ++){
            centralDosingUpdated[i]['selection'] = 'unselect';
            selection = 0;
          }
        }
        break;
      }
      case ('reOrderCdSite') : {
        var data = centralDosingUpdated[list[1]];
        centralDosingUpdated.removeAt(list[1]);
        centralDosingUpdated.insert(list[2], data);
        break;
      }
      case ('editInjectorType') : {
        centralDosingUpdated[list[1]]['injector'][list[2]]['injectorType'] = list[3];
        break;
      }
      case ('editLevelSensor') : {
        if(totalLevelSensor > 0){
          if(list[3] == true){
            centralDosingUpdated[list[1]]['injector'][list[2]]['levelSensor'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalLevelSensor = totalLevelSensor - 1;
          }else{
            centralDosingUpdated[list[1]]['injector'][list[2]]['levelSensor'] = {};
            totalLevelSensor = totalLevelSensor + 1;
          }
        }
        if(totalLevelSensor == 0){
          if(list[3] == false){
            centralDosingUpdated[list[1]]['injector'][list[2]]['levelSensor'] = {};
            totalLevelSensor = totalLevelSensor + 1;
          }
        }
        break;
      }
      case ('editDosingMeter') : {
        if(totalDosingMeter > 0){
          if(list[3] == true){
            centralDosingUpdated[list[1]]['injector'][list[2]]['dosingMeter'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalDosingMeter = totalDosingMeter - 1;
          }else{
            centralDosingUpdated[list[1]]['injector'][list[2]]['dosingMeter'] = {};
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        if(totalDosingMeter == 0){
          if(list[3] == false){
            centralDosingUpdated[list[1]]['injector'][list[2]]['dosingMeter'] = {};
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        break;
      }
      case ('editPressureSwitch') : {
        if(totalPressureSwitch > 0){
          if(list[2] == true){
            centralDosingUpdated[list[1]]['pressureSwitch'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalPressureSwitch = totalPressureSwitch - 1;
          }else{
            centralDosingUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        if(totalPressureSwitch == 0){
          if(list[2] == false){
            centralDosingUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        break;
      }
      case ('selectCentralDosing') : {
        if(centralDosingUpdated[list[1]]['selection'] == 'unselect'){
          centralDosingUpdated[list[1]]['selection'] = 'select';
          selection += 1;
        }else{
          centralDosingUpdated[list[1]]['selection'] = 'unselect';
          selection -= 1;
        }
        break;
      }
      case ('deleteCentralDosing') : {
        List<Map<String, dynamic>> selectedSite = [];
        for (var i = centralDosingUpdated.length - 1; i >= 0; i--) {
          if (centralDosingUpdated[i]['selection'] == 'select') {
            selectedSite.add(centralDosingUpdated[i]);
          }
        }
        for (var cdSite in selectedSite) {
          totalInjector = totalInjector + cdSite['injector'].length as int;
          totalBooster = totalBooster + cdSite['boosterConnection'].length as int;
          totalEcSensor = totalEcSensor + cdSite['ecConnection'].length as int;
          totalPhSensor = totalPhSensor + cdSite['phConnection'].length as int;
          if(cdSite['pressureSwitch'].isNotEmpty){
            totalPressureSwitch = totalPressureSwitch + 1;
          }
          for(var i in cdSite['injector']){
            if(i['dosingMeter'].isNotEmpty){
              totalDosingMeter = totalDosingMeter + 1;
            }
          }
          if(isNew == false){
            centralDosingUpdated[centralDosingUpdated.indexOf(cdSite)]['deleted'] = true;
          }else{
            centralDosingUpdated.remove(cdSite);
          }
          totalCentralDosing = totalCentralDosing + 1;
        }
        refreshCentralDosingList();
        break;
      }

      case ('editBoosterPumpSelection'):{
        if(centralDosingUpdated[list[1]]['boosterPump'] == ''){
          centralDosingUpdated[list[1]]['boosterConnection'] = [];
          for(var inj = 0;inj < centralDosingUpdated[list[1]]['injector'].length;inj++){
            centralDosingUpdated[list[1]]['injector'][inj]['Which_Booster_Pump'] = '-';
          }
        }else{
          if(int.parse(centralDosingUpdated[list[1]]['boosterPump']) > centralDosingUpdated[list[1]]['boosterConnection'].length){
            int count = (int.parse(centralDosingUpdated[list[1]]['boosterPump'])- centralDosingUpdated[list[1]]['boosterConnection'].length) as int;
            for(var i = 0; i < count;i++){
              centralDosingUpdated[list[1]]['boosterConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              });
            }
          }else{
            int count = (centralDosingUpdated[list[1]]['boosterConnection'].length - int.parse(centralDosingUpdated[list[1]]['boosterPump']));
            for(var i = 0; i < count;i++){
              for(var inj = 0;inj < centralDosingUpdated[list[1]]['injector'].length;inj++){
                if(centralDosingUpdated[list[1]]['injector'][inj]['Which_Booster_Pump'].contains('${centralDosingUpdated[list[1]]['boosterConnection'].length}')){
                  centralDosingUpdated[list[1]]['injector'][inj]['Which_Booster_Pump'] = '-';
                }
              }
              centralDosingUpdated[list[1]]['boosterConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editEcSelection'):{
        if(centralDosingUpdated[list[1]]['ec'] == ''){
          centralDosingUpdated[list[1]]['ecConnection'] = [];
        }else{
          if(int.parse(centralDosingUpdated[list[1]]['ec']) > centralDosingUpdated[list[1]]['ecConnection'].length){
            int count = (int.parse(centralDosingUpdated[list[1]]['ec'])- centralDosingUpdated[list[1]]['ecConnection'].length) as int;
            for(var i = 0; i < count;i++){
              centralDosingUpdated[list[1]]['ecConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'input' : '-',
                'input_type' : '-',
              });
            }
          }else{
            int count = (centralDosingUpdated[list[1]]['ecConnection'].length - int.parse(centralDosingUpdated[list[1]]['ec']));
            for(var i = 0; i < count;i++){
              centralDosingUpdated[list[1]]['ecConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editPhSelection'):{
        if(centralDosingUpdated[list[1]]['ph'] == ''){
          centralDosingUpdated[list[1]]['phConnection'] = [];
        }else{
          if(int.parse(centralDosingUpdated[list[1]]['ph']) > centralDosingUpdated[list[1]]['phConnection'].length){
            int count = (int.parse(centralDosingUpdated[list[1]]['ph'])- centralDosingUpdated[list[1]]['phConnection'].length) as int;
            for(var i = 0; i < count;i++){
              centralDosingUpdated[list[1]]['phConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'input' : '-',
                'input_type' : '-',
              });
            }
          }else{
            int count = (centralDosingUpdated[list[1]]['phConnection'].length - int.parse(centralDosingUpdated[list[1]]['ph']));
            for(var i = 0; i < count;i++){
              centralDosingUpdated[list[1]]['phConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editBoosterPump'): {
        if(totalBooster > -1){
          if(centralDosingUpdated[list[1]]['boosterPump'] != ''){
            totalBooster = totalBooster + int.parse(centralDosingUpdated[list[1]]['boosterPump']);
            if(list[2] == ''){
              totalBooster = totalBooster - 0;
            }else{
              if(list[2] == '0'){
                totalBooster = totalBooster - 1;
              }else{
                totalBooster = totalBooster - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalBooster = totalBooster - 1;
            }else{
              totalBooster = totalBooster - int.parse(list[2]);
            }
          }
          centralDosingUpdated[list[1]]['boosterPump'] = list[2];
        }
        break;
      }
      case ('boosterSelectionForInjector'): {
        centralDosingUpdated[list[1]]['injector'][list[2]]['Which_Booster_Pump'] = list[3];
        break;
      }
      case ('editEcSensor'): {
        if(totalEcSensor > -1){
          if(centralDosingUpdated[list[1]]['ec'] != ''){
            totalEcSensor = totalEcSensor + int.parse(centralDosingUpdated[list[1]]['ec']);
            if(list[2] == ''){
              totalEcSensor = totalEcSensor - 0;
            }else{
              if(list[2] == '0'){
                totalEcSensor = totalEcSensor - 1;
              }else{
                totalEcSensor = totalEcSensor - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalEcSensor = totalEcSensor - 1;
            }else{
              totalEcSensor = totalEcSensor - int.parse(list[2]);
            }
          }
          centralDosingUpdated[list[1]]['ec'] = list[2];
        }
        break;
      }
      case ('editPhSensor'): {
        if(totalPhSensor > -1){
          if(centralDosingUpdated[list[1]]['ph'] != ''){
            totalPhSensor = totalPhSensor + int.parse(centralDosingUpdated[list[1]]['ph']);
            if(list[2] == ''){
              totalPhSensor = totalPhSensor - 0;
            }else{
              if(list[2] == '0'){
                totalPhSensor = totalPhSensor - 1;
              }else{
                totalPhSensor = totalPhSensor - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalPhSensor = totalPhSensor - 1;
            }else{
              totalPhSensor = totalPhSensor - int.parse(list[2]);
            }
          }
          centralDosingUpdated[list[1]]['ph'] = list[2];
        }
        break;
      }

      default : {
        break;
      }
    }
    refreshCentralDosingList();
    notifyListeners();

  }
  //TODO: centralFiltrationFunctionality
  void centralFiltrationFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addCentralFiltration') : {
        if(totalCentralFiltration > 0 && totalFilter > 0){
          var add = false;
          for(var i in centralFiltrationUpdated){
            if(i['deleted'] == true){
              i['deleted'] = false;
              i['selection'] = 'unselect';
              i['filter'] = '1';
              i['filterConnection'] = [{
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              }];
              i['dv'] = {};
              i['pressureIn'] = {};
              i['pressureOut'] = {};
              i['pressureSwitch'] = {};
              i['diffPressureSensor'] = {};
              add = true;
              break;
            }
          }
          if(add == false){
            centralFiltrationUpdated.add(
                {
                  'sNo' : returnI_O_AutoIncrement(),
                  'selection' : 'unselect',
                  'filter' : '1',
                  'filterConnection' : [{
                    'sNo' : returnI_O_AutoIncrement(),
                    'rtu' : '-',
                    'rfNo' : '-',
                    'output' : '-',
                    'output_type' : '1',
                  }],
                  'dv' : {},
                  'pressureIn' : {},
                  'pressureOut' : {},
                  'pressureSwitch' : {},
                  'diffPressureSensor' : {},
                  'deleted' : false,
                }
            );
          }
          totalCentralFiltration = totalCentralFiltration - 1;
          totalFilter = totalFilter - 1;
        }
        break;
      }
      case ('addBatch_CF') : {
        for(var i = 0;i < list[1];i++){
          if(totalCentralFiltration > 0 && totalFilter > 0){
            var add = false;
            var flList = [];
            for(var count = 0;count < list[2];count++){
              flList.add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              });
            }
            for(var i in centralFiltrationUpdated){
              if(i['deleted'] == true){
                i['deleted'] = false;
                i['selection'] = 'unselect';
                i['filter'] = '${list[2]}';
                i['filterConnection'] = flList;
                i['dv'] = {};
                i['pressureIn'] = {};
                i['pressureOut'] = {};
                i['pressureSwitch'] = {};
                i['diffPressureSensor'] = {};
                add = true;
                break;
              }
            }
            if(add == false){
              centralFiltrationUpdated.add(
                  {
                    'sNo' : returnI_O_AutoIncrement(),
                    'selection' : 'unselect',
                    'filter' : '${list[2]}',
                    'filterConnection' : flList,
                    'dv' : {},
                    'pressureIn' : {},
                    'pressureOut' : {},
                    'pressureSwitch' : {},
                    'diffPressureSensor' : {},
                    'deleted' : false,
                  }
              );
            }
            totalCentralFiltration = totalCentralFiltration - 1;
            totalFilter = totalFilter - (list[2] as int);
          }
        }

        break;
      }
      case ('editPressureSwitch') : {
        if(totalPressureSwitch > 0){
          if(list[2] == true){
            centralFiltrationUpdated[list[1]]['pressureSwitch'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalPressureSwitch = totalPressureSwitch - 1;
          }else{
            centralFiltrationUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        if(totalPressureSwitch == 0){
          if(list[2] == false){
            centralFiltrationUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        break;
      }
      case ('editDiffPressureSensor') : {
        if(totalDiffPressureSensor > 0){
          if(list[2] == true){
            centralFiltrationUpdated[list[1]]['diffPressureSensor'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalDiffPressureSensor = totalDiffPressureSensor - 1;
          }else{
            centralFiltrationUpdated[list[1]]['diffPressureSensor'] = {};
            totalDiffPressureSensor = totalDiffPressureSensor + 1;
          }
        }
        if(totalDiffPressureSensor == 0){
          if(list[2] == false){
            centralFiltrationUpdated[list[1]]['diffPressureSensor'] = {};
            totalDiffPressureSensor = totalDiffPressureSensor + 1;
          }
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
      case ('reOrderCfSite') : {
        var data = centralFiltrationUpdated[list[1]];
        centralFiltrationUpdated.removeAt(list[1]);
        centralFiltrationUpdated.insert(list[2], data);
        break;
      }
      case ('centralFiltrationSelectAll') : {
        centralFiltrationSelectAll = list[1];
        if(list[1] == true){
          for(var i = 0;i < centralFiltrationUpdated.length;i ++){
            centralFiltrationUpdated[i]['selection'] = 'select';
          }
        }else{
          for(var i = 0;i < centralFiltrationUpdated.length;i ++){
            centralFiltrationUpdated[i]['selection'] = 'unselect';
          }
        }
        break;
      }
      case ('editFilter') : {
        if(totalFilter > -1){
          if(centralFiltrationUpdated[list[1]]['filter'] != ''){
            totalFilter = totalFilter + int.parse(centralFiltrationUpdated[list[1]]['filter']);
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
          centralFiltrationUpdated[list[1]]['filter'] = list[2];
        }
        break;
      }
      case ('editFilterSelection'):{
        if(centralFiltrationUpdated[list[1]]['filter'] == ''){
          centralFiltrationUpdated[list[1]]['filterConnection'] = [];
        }else{
          if(int.parse(centralFiltrationUpdated[list[1]]['filter']) > centralFiltrationUpdated[list[1]]['filterConnection'].length){
            int count = (int.parse(centralFiltrationUpdated[list[1]]['filter'])- centralFiltrationUpdated[list[1]]['filterConnection'].length) as int;
            for(var i = 0; i < count;i++){
              centralFiltrationUpdated[list[1]]['filterConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              });
            }
          }else{
            int count = (centralFiltrationUpdated[list[1]]['filterConnection'].length - int.parse(centralFiltrationUpdated[list[1]]['filter']));
            for(var i = 0; i < count;i++){
              centralFiltrationUpdated[list[1]]['filterConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editDownStreamValve') : {
        if(total_D_s_valve > 0){
          if(list[2] == true){
            centralFiltrationUpdated[list[1]]['dv'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'output' : '-',
              'output_type' : '1',
            };
            total_D_s_valve = total_D_s_valve - 1;
          }else{
            centralFiltrationUpdated[list[1]]['dv'] = {};
            total_D_s_valve = total_D_s_valve + 1;
          }

        }
        if(total_D_s_valve == 0){
          if(list[2] == false){
            centralFiltrationUpdated[list[1]]['dv'] = {};
            total_D_s_valve = total_D_s_valve + 1;
          }
        }
        break;
      }
      case ('editPressureSensor') : {
        if(total_p_sensor > 0){
          if(list[2] == true){
            centralFiltrationUpdated[list[1]]['pressureIn'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            total_p_sensor = total_p_sensor - 1;
          }else{
            centralFiltrationUpdated[list[1]]['pressureIn'] = {};
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            centralFiltrationUpdated[list[1]]['pressureIn'] = {};
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('editPressureSensor_out') : {
        if(total_p_sensor > 0){
          if(list[2] == true){
            centralFiltrationUpdated[list[1]]['pressureOut'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            total_p_sensor = total_p_sensor - 1;
          }else{
            centralFiltrationUpdated[list[1]]['pressureOut'] = {};
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            centralFiltrationUpdated[list[1]]['pressureOut'] = {};
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('selectCentralFiltration') : {
        if(centralFiltrationUpdated[list[1]]['selection'] == 'select'){
          centralFiltrationUpdated[list[1]]['selection'] = 'unselect';
        }else{
          centralFiltrationUpdated[list[1]]['selection'] = 'select';
        }
        break;
      }
      case ('deleteCentralFiltration') : {
        List<Map<String, dynamic>> selectedSite = [];
        for (var i = centralFiltrationUpdated.length - 1; i >= 0; i--) {
          if (centralFiltrationUpdated[i]['selection'] == 'select') {
            selectedSite.add(centralFiltrationUpdated[i]);
          }
        }
        for (var cfSite in selectedSite) {
          if(cfSite['dv'].isNotEmpty){
            total_D_s_valve = total_D_s_valve + 1;
          }
          if(cfSite['pressureIn'].isNotEmpty){
            total_p_sensor = total_p_sensor + 1;
          }
          if(cfSite['pressureOut'].isNotEmpty){
            total_p_sensor = total_p_sensor + 1;
          }
          if(cfSite['pressureSwitch'].isNotEmpty){
            totalPressureSwitch = totalPressureSwitch + 1;
          }
          if(cfSite['diffPressureSensor'].isNotEmpty){
            totalDiffPressureSensor = totalDiffPressureSensor + 1;
          }
          if(cfSite['filter'] != ''){
            totalFilter = totalFilter + int.parse(cfSite['filter']);
          }
          if(isNew == false){
            centralFiltrationUpdated[centralFiltrationUpdated.indexOf(cfSite)]['deleted'] = true;
          }else{
            centralFiltrationUpdated.remove(cfSite);
          }
          totalCentralFiltration = totalCentralFiltration + 1;
        }
        centralFiltrationSelectAll = false;
        centralFiltrationSelection = false;
        break;
      }
      default :{
        break;
      }
    }
    refreshCentralFiltrationList();
    notifyListeners();
  }
  //TODO: editRfList
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
  void updateIfRefNoEmptyChild(List<dynamic> data,String rtu,List<dynamic> rf,List<dynamic> updatedRF){
    for(var i in data){
      if(rf.length == 0){
        if(i['rtu'] == rtu){
          i['rtu'] = '-';
          i['rfNo'] = '-';
          i['output'] = '-';
        }
      }else{
        if(i['rtu'] == rtu){
          if(!updatedRF.contains(i['rfNo'])){
            i['rfNo'] = '-';
            i['output'] = '-';
          }
        }
      }
    }
  }
  void updateIfRefNoEmpty(int line,String rtu,List<dynamic> rf){
    var updatedRF = [];
    for(var i in rf){
      updatedRF.add('${i}');
    }
    updateIfRefNoEmptyChild(irrigationLines[line]['valveConnection'],rtu,rf,updatedRF);
    updateIfRefNoEmptyChild(irrigationLines[line]['main_valveConnection'],rtu,rf,updatedRF);
    updateIfRefNoEmptyChild(irrigationLines[line]['foggerConnection'],rtu,rf,updatedRF);
    updateIfRefNoEmptyChild(irrigationLines[line]['fanConnection'],rtu,rf,updatedRF);
    ld : for(var i = 0;i < localDosingUpdated.length;i++){
      if(localDosingUpdated[i]['sNo'] == irrigationLines[line]['sNo']){
        updateIfRefNoEmptyChild(localDosingUpdated[i]['injector'],rtu,rf,updatedRF);
        updateIfRefNoEmptyChild(localDosingUpdated[i]['boosterConnection'],rtu,rf,updatedRF);
        break ld;
      }
    }
    lf : for(var i = 0;i < localFiltrationUpdated.length;i++){
      if(localFiltrationUpdated[i]['sNo'] == irrigationLines[line]['sNo']){
        updateIfRefNoEmptyChild(localFiltrationUpdated[i]['filterConnection'],rtu,rf,updatedRF);
        localFiltrationUpdated[i]['dv'].isNotEmpty ? updateIfRefNoEmptyChild([localFiltrationUpdated[i]['dv']],rtu,rf,updatedRF) : print('dv empty');
        break lf;
      }
    }
  }
  //TODO: irrigationLinesFunctionality
  void irrigationLinesFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addIrrigationLine'): {
        if(totalIrrigationLine > 0 && totalValve > 0){
          var add = false;
          for(var i in irrigationLines){
            if(i['deleted'] == true){
              i['deleted'] = false;
              i['valve'] = '1';
              i['valveConnection'] = [
                {
                  'sNo' : returnI_O_AutoIncrement(),
                  'rtu' : '-',
                  'rfNo' : '-',
                  'output' : '-',
                  'output_type' : '1',
                }
              ];
              i['main_valve'] = '';
              i['main_valveConnection'] = [];
              i['moistureSensor'] = '';
              i['moistureSensorConnection'] = [];
              i['levelSensor'] = '';
              i['levelSensorConnection'] = [];
              i['fogger'] = '';
              i['foggerConnection'] = [];
              i['fan'] = '';
              i['fanConnection'] = [];
              i['Central_dosing_site'] = '-';
              i['Central_filtration_site'] = '-';
              i['Local_dosing_site'] = false;
              i['local_filtration_site'] = false;
              i['pressureIn'] = {};
              i['pressureOut'] = {};
              i['irrigationPump'] = '-';
              i['water_meter'] = {};
              i['ORO_Smart_RTU'] = '';
              i['ORO_Smart_RTU_Plus'] = '';
              i['RTU'] = '';
              i['RTU_Plus'] = '';
              i['ORO_switch'] = '';
              i['ORO_sense'] = '';
              i['ORO_level'] = '';
              i['isSelected'] = 'unselect';
              i['myRTU_list'] = ['-'];
              i['myOroSmartRtu'] = [];
              i['myOroSmartRtuPlus'] = [];
              i['myRTU'] = [];
              i['myRtuPlus'] = [];
              i['myOROswitch'] = [];
              i['myOROsense'] = [];
              i['myOROlevel'] = [];
              add = true;
              break;
            }
          }
          if(add == false){
            irrigationLines.add({
              'sNo' : returnI_O_AutoIncrement(),
              'valve' : '1',
              'deleted' : false,
              'valveConnection' : [
                {
                  'sNo' : returnI_O_AutoIncrement(),
                  'rtu' : '-',
                  'rfNo' : '-',
                  'output' : '-',
                  'output_type' : '1',
                }
              ],
              'main_valve' : '',
              'main_valveConnection' : [],
              'moistureSensor' : '',
              'moistureSensorConnection' : [],
              'levelSensor' : '',
              'levelSensorConnection' : [],
              'fogger' : '',
              'foggerConnection' : [],
              'fan' : '',
              'fanConnection' : [],
              'Central_dosing_site' : '-',
              'Central_filtration_site' : '-',
              'Local_dosing_site' : false,
              'local_filtration_site' : false,
              'pressureIn' : {},
              'pressureOut' : {},
              'irrigationPump' : '-',
              'water_meter' : {},
              'ORO_Smart_RTU' : '',
              'ORO_Smart_RTU_Plus' : '',
              'RTU' : '',
              'RTU_Plus' : '',
              'ORO_switch' : '',
              'ORO_sense' : '',
              'ORO_level' : '',
              'isSelected' : 'unselect',
              'myRTU_list' : ['-'],
              'myOroSmartRtu' : [],
              'myOroSmartRtuPlus' : [],
              'myRTU' : [],
              'myRtuPlus' : [],
              'myOROswitch' : [],
              'myOROsense' : [],
              'myOROlevel' : [],
            },);
          }
          totalIrrigationLine = totalIrrigationLine - 1;
          totalValve = totalValve - 1;
        }
        break;
      }
      case ('updateAI') : {
        irrigationLines[list[1]]['sNo'] = list[2];
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
        List<int> ld = [];
        List<int> lf = [];
        irrigationSelection = false;
        irrigationSelectAll = false;
        for (var i = irrigationLines.length - 1; i >= 0; i--) {
          if (irrigationLines[i]['isSelected'] == 'select') {
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
            total_p_sensor = total_p_sensor + (irrigationLines[i]['pressureIn'].isEmpty ? 0 : 1);
            total_p_sensor = total_p_sensor + (irrigationLines[i]['pressureOut'].isEmpty ? 0 : 1);
            totalWaterMeter = totalWaterMeter + (irrigationLines[i]['water_meter'].isEmpty ? 0 : 1);
            totalMainValve = totalMainValve + irrigationLines[i]['main_valveConnection'].length as int;
            totalMoistureSensor = totalMoistureSensor + irrigationLines[i]['moistureSensorConnection'].length as int;
            totalLevelSensor = totalLevelSensor + irrigationLines[i]['levelSensorConnection'].length as int;
            totalFogger = totalFogger + irrigationLines[i]['foggerConnection'].length as int;
            totalFan = totalFan + irrigationLines[i]['fanConnection'].length as int;
            totalValve = totalValve + int.parse(irrigationLines[i]['valve']);
            totalIrrigationLine = totalIrrigationLine + 1;
            ld.add(irrigationLines[i]['sNo']);
            lf.add(irrigationLines[i]['sNo']);
            if(isNew == false){
              irrigationLines[i]['deleted'] = true;
            }else{
              irrigationLines.removeAt(i);
            }
          }
        }
        for(var i in ld){
          localDosingFunctionality(['deleteLocalDosingFromLine',i]);
        }
        for(var i in lf){
          localFiltrationFunctionality(['deleteLocalFiltrationFromLine',i]);
        }
        break;
      }
      case ('reOrderIl') : {
        var data = irrigationLines[list[1]];
        irrigationLines.removeAt(list[1]);
        irrigationLines.insert(list[2], data);
        break;
      }
      case ('editValveConnection'):{
        if(irrigationLines[list[1]]['valve'] == ''){
          irrigationLines[list[1]]['valveConnection'] = [];
        }else{
          if(int.parse(irrigationLines[list[1]]['valve']) > irrigationLines[list[1]]['valveConnection'].length){
            int count = (int.parse(irrigationLines[list[1]]['valve'])- irrigationLines[list[1]]['valveConnection'].length) as int;
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['valveConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              });
            }
          }else{
            int count = (irrigationLines[list[1]]['valveConnection'].length - int.parse(irrigationLines[list[1]]['valve']));
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['valveConnection'].removeLast();
            }
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
        break;
      }
      case ('editMainValveConnection'):{
        if(irrigationLines[list[1]]['main_valve'] == ''){
          irrigationLines[list[1]]['main_valveConnection'] = [];
        }else{
          if(int.parse(irrigationLines[list[1]]['main_valve']) > irrigationLines[list[1]]['main_valveConnection'].length){
            int count = (int.parse(irrigationLines[list[1]]['main_valve'])- irrigationLines[list[1]]['main_valveConnection'].length) as int;
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['main_valveConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '-',
              });
            }
          }else{
            int count = (irrigationLines[list[1]]['main_valveConnection'].length - int.parse(irrigationLines[list[1]]['main_valve']));
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['main_valveConnection'].removeLast();
            }
          }
        }
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
      case ('editMoistureSensorConnection'):{
        if(irrigationLines[list[1]]['moistureSensor'] == ''){
          irrigationLines[list[1]]['moistureSensorConnection'] = [];
        }else{
          if(int.parse(irrigationLines[list[1]]['moistureSensor']) > irrigationLines[list[1]]['moistureSensorConnection'].length){
            int count = (int.parse(irrigationLines[list[1]]['moistureSensor'])- irrigationLines[list[1]]['moistureSensorConnection'].length) as int;
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['moistureSensorConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'input' : '-',
                'input_type' : '-',
              });
            }
          }else{
            int count = (irrigationLines[list[1]]['moistureSensorConnection'].length - int.parse(irrigationLines[list[1]]['moistureSensor']));
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['moistureSensorConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editMoistureSensor'): {
        if(totalMoistureSensor > -1){
          if(irrigationLines[list[1]]['moistureSensor'] != ''){
            totalMoistureSensor = totalMoistureSensor + int.parse(irrigationLines[list[1]]['moistureSensor']);
            if(list[2] == ''){
              totalMoistureSensor = totalMoistureSensor - 0;
            }else{
              if(list[2] == '0'){
                totalMoistureSensor = totalMoistureSensor - 1;
              }else{
                totalMoistureSensor = totalMoistureSensor - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalMoistureSensor = totalMoistureSensor - 1;
            }else{
              totalMoistureSensor = totalMoistureSensor - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['moistureSensor'] = list[2];
        }
        break;
      }
      case ('editLevelSensorConnection'):{
        if(irrigationLines[list[1]]['levelSensor'] == ''){
          irrigationLines[list[1]]['levelSensorConnection'] = [];
        }else{
          if(int.parse(irrigationLines[list[1]]['levelSensor']) > irrigationLines[list[1]]['levelSensorConnection'].length){
            int count = (int.parse(irrigationLines[list[1]]['levelSensor'])- irrigationLines[list[1]]['levelSensorConnection'].length) as int;
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['levelSensorConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'input' : '-',
                'input_type' : '-',
              });
            }
          }else{
            int count = (irrigationLines[list[1]]['levelSensorConnection'].length - int.parse(irrigationLines[list[1]]['levelSensor']));
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['levelSensorConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editLevelSensor'): {
        if(totalLevelSensor > -1){
          if(irrigationLines[list[1]]['levelSensor'] != ''){
            totalLevelSensor = totalLevelSensor + int.parse(irrigationLines[list[1]]['levelSensor']);
            if(list[2] == ''){
              totalLevelSensor = totalLevelSensor - 0;
            }else{
              if(list[2] == '0'){
                totalLevelSensor = totalLevelSensor - 1;
              }else{
                totalLevelSensor = totalLevelSensor - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalLevelSensor = totalLevelSensor - 1;
            }else{
              totalLevelSensor = totalLevelSensor - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['levelSensor'] = list[2];
        }
        break;
      }
      case ('editFoggerConnection'):{
        if(irrigationLines[list[1]]['fogger'] == ''){
          irrigationLines[list[1]]['foggerConnection'] = [];
        }else{
          if(int.parse(irrigationLines[list[1]]['fogger']) > irrigationLines[list[1]]['foggerConnection'].length){
            int count = (int.parse(irrigationLines[list[1]]['fogger'])- irrigationLines[list[1]]['foggerConnection'].length) as int;
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['foggerConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '-',
              });
            }
          }else{
            int count = (irrigationLines[list[1]]['foggerConnection'].length - int.parse(irrigationLines[list[1]]['fogger']));
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['foggerConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editFogger'): {
        if(totalFogger > -1){
          if(irrigationLines[list[1]]['fogger'] != ''){
            totalFogger = totalFogger + int.parse(irrigationLines[list[1]]['fogger']);
            if(list[2] == ''){
              totalFogger = totalFogger - 0;
            }else{
              if(list[2] == '0'){
                totalFogger = totalFogger - 1;
              }else{
                totalFogger = totalFogger - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalFogger = totalFogger - 1;
            }else{
              totalFogger = totalFogger - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['fogger'] = list[2];
        }
        break;
      }
      case ('editFanConnection'):{
        if(irrigationLines[list[1]]['fan'] == ''){
          irrigationLines[list[1]]['fanConnection'] = [];
        }else{
          if(int.parse(irrigationLines[list[1]]['fan']) > irrigationLines[list[1]]['fanConnection'].length){
            int count = (int.parse(irrigationLines[list[1]]['fan'])- irrigationLines[list[1]]['fanConnection'].length) as int;
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['fanConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '-',
              });
            }
          }else{
            int count = (irrigationLines[list[1]]['fanConnection'].length - int.parse(irrigationLines[list[1]]['fan']));
            for(var i = 0; i < count;i++){
              irrigationLines[list[1]]['fanConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editFan'): {
        if(totalFan > -1){
          if(irrigationLines[list[1]]['fan'] != ''){
            totalFan = totalFan + int.parse(irrigationLines[list[1]]['fan']);
            if(list[2] == ''){
              totalFan = totalFan - 0;
            }else{
              if(list[2] == '0'){
                totalFan = totalFan - 1;
              }else{
                totalFan = totalFan - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalFan = totalFan - 1;
            }else{
              totalFan = totalFan - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['fan'] = list[2];
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
            if(irrigationLines[list[1]]['myRTU_list'].contains('ORO Smart')){
              irrigationLines[list[1]]['myRTU_list'].remove('ORO Smart');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('ORO Smart')){
              irrigationLines[list[1]]['myRTU_list'].add('ORO Smart');
            }
          }
        }
        updateIfRefNoEmpty(list[1],'ORO Smart',irrigationLines[list[1]]['myOroSmartRtu']);
        break;
      }
      case ('editOroSmartRtuPlus'): {
        if(totalOroSmartRtuPlus > -1){
          if(irrigationLines[list[1]]['ORO_Smart_RTU_Plus'] != ''){
            totalOroSmartRtuPlus = totalOroSmartRtuPlus + int.parse(irrigationLines[list[1]]['ORO_Smart_RTU_Plus']);
            if(list[2] == ''){
              totalOroSmartRtuPlus = totalOroSmartRtuPlus - 0;
            }else{
              if(list[2] == '0'){
                totalOroSmartRtuPlus = totalOroSmartRtuPlus - 1;
              }else{
                totalOroSmartRtuPlus = totalOroSmartRtuPlus - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalOroSmartRtuPlus = totalOroSmartRtuPlus - 1;
            }else{
              totalOroSmartRtuPlus = totalOroSmartRtuPlus - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['ORO_Smart_RTU_Plus'] = list[2];
          if(irrigationLines[list[1]]['myOroSmartRtuPlus'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myOroSmartRtuPlus'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myOroSmartRtuPlus'].add(OroSmartRtuPlusForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myOroSmartRtuPlus']){
              if(OroSmartRtuPlusForLine.contains(i)){
                OroSmartRtuPlusForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myOroSmartRtuPlus'][0]);
              irrigationLines[list[1]]['myOroSmartRtuPlus'].remove(irrigationLines[list[1]]['myOroSmartRtuPlus'][0]);
            }
            for(var i in irrigationLines[list[1]]['myOroSmartRtuPlus']){
              OroSmartRtuPlusForLine.add(i);
            }
            irrigationLines[list[1]]['myOroSmartRtuPlus'] = list1;
            OroSmartRtuPlusForLine.sort();
          }else{
            OroSmartRtuPlusForLine += irrigationLines[list[1]]['myOroSmartRtuPlus'];
            irrigationLines[list[1]]['myOroSmartRtuPlus'] = [];
            OroSmartRtuPlusForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['ORO_Smart_RTU_Plus'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('O-Smart-Plus')){
              irrigationLines[list[1]]['myRTU_list'].remove('O-Smart-Plus');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('O-Smart-Plus')){
              irrigationLines[list[1]]['myRTU_list'].add('O-Smart-Plus');
            }
          }
        }
        updateIfRefNoEmpty(list[1],'O-Smart-Plus',irrigationLines[list[1]]['myOroSmartRtuPlus']);
        break;
      }
      case ('editRtuPlus'): {
        if(totalRtuPlus > -1){
          if(irrigationLines[list[1]]['RTU_Plus'] != ''){
            totalRtuPlus = totalRtuPlus + int.parse(irrigationLines[list[1]]['RTU_Plus']);
            if(list[2] == ''){
              totalRtuPlus = totalRtuPlus - 0;
            }else{
              if(list[2] == '0'){
                totalRtuPlus = totalRtuPlus - 1;
              }else{
                totalRtuPlus = totalRtuPlus - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalRtuPlus = totalRtuPlus - 1;
            }else{
              totalRtuPlus = totalRtuPlus - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['RTU_Plus'] = list[2];
          if(irrigationLines[list[1]]['myRtuPlus'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myRtuPlus'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myRtuPlus'].add(rtuPlusForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myRtuPlus']){
              if(rtuPlusForLine.contains(i)){
                rtuPlusForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myRtuPlus'][0]);
              irrigationLines[list[1]]['myRtuPlus'].remove(irrigationLines[list[1]]['myRtuPlus'][0]);
            }
            for(var i in irrigationLines[list[1]]['myRtuPlus']){
              rtuPlusForLine.add(i);
            }
            irrigationLines[list[1]]['myRtuPlus'] = list1;
            rtuPlusForLine.sort();
          }else{
            rtuPlusForLine += irrigationLines[list[1]]['myRtuPlus'];
            irrigationLines[list[1]]['myRtuPlus'] = [];
            rtuPlusForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['RTU_Plus'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('O-RTU-Plus')){
              irrigationLines[list[1]]['myRTU_list'].remove('O-RTU-Plus');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('O-RTU-Plus')){
              irrigationLines[list[1]]['myRTU_list'].add('O-RTU-Plus');
            }
          }
        }
        updateIfRefNoEmpty(list[1],'O-RTU-Plus',irrigationLines[list[1]]['myRtuPlus']);
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
        updateIfRefNoEmpty(list[1],'ORO RTU',irrigationLines[list[1]]['myRTU']);
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
        updateIfRefNoEmpty(list[1],'ORO Switch',irrigationLines[list[1]]['myOROswitch']);
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
        updateIfRefNoEmpty(list[1],'ORO Sense',irrigationLines[list[1]]['myOROsense']);
        break;
      }
      case ('editOroLevel'): {
        if(totalOroLevel > -1){
          if(irrigationLines[list[1]]['ORO_level'] != ''){
            totalOroLevel = totalOroLevel + int.parse(irrigationLines[list[1]]['ORO_level']);
            if(list[2] == ''){
              totalOroLevel = totalOroLevel - 0;
            }else{
              if(list[2] == '0'){
                totalOroLevel = totalOroLevel - 1;
              }else{
                totalOroLevel = totalOroLevel - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalOroLevel = totalOroLevel - 1;
            }else{
              totalOroLevel = totalOroLevel - int.parse(list[2]);
            }
          }
          irrigationLines[list[1]]['ORO_level'] = list[2];
          if(irrigationLines[list[1]]['myOROlevel'].length < int.parse(list[2] == '' ? '0' : list[2])){
            int beforeLength = irrigationLines[list[1]]['myOROlevel'].length;
            for(var i = 0;i < int.parse(list[2]) - beforeLength;i++){
              irrigationLines[list[1]]['myOROlevel'].add(OroLevelForLine[i]);
            }
            for(var i in  irrigationLines[list[1]]['myOROlevel']){
              if(OroLevelForLine.contains(i)){
                OroLevelForLine.remove(i);
              }
            }
          }else if(list[2] != ''){
            var list1 = [];
            for(var i = 0;i< int.parse(list[2]);i++){
              list1.add(irrigationLines[list[1]]['myOROlevel'][0]);
              irrigationLines[list[1]]['myOROlevel'].remove(irrigationLines[list[1]]['myOROlevel'][0]);
            }
            for(var i in irrigationLines[list[1]]['myOROlevel']){
              OroLevelForLine.add(i);
            }
            irrigationLines[list[1]]['myOROlevel'] = list1;
            OroLevelForLine.sort();
          }else{
            OroLevelForLine += irrigationLines[list[1]]['myOROlevel'];
            irrigationLines[list[1]]['myOROlevel'] = [];
            OroLevelForLine.sort();
          }
          ///////////////////////////////////////////////////////////////////////////////////
          if(irrigationLines[list[1]]['ORO_level'] == ''){
            if(irrigationLines[list[1]]['myRTU_list'].contains('ORO Level')){
              irrigationLines[list[1]]['myRTU_list'].remove('ORO Level');
            }
          }else{
            if(!irrigationLines[list[1]]['myRTU_list'].contains('ORO Level')){
              irrigationLines[list[1]]['myRTU_list'].add('ORO Level');
            }
          }
        }
        updateIfRefNoEmpty(list[1],'ORO Level',irrigationLines[list[1]]['myOROlevel']);
        break;
      }
      case ('editLocalDosing'): {
        irrigationLines[list[1]]['Local_dosing_site'] = list[2];
        if(list[2] == true){
          localDosingFunctionality(['addLocalDosing',irrigationLines[list[1]]['sNo'],list[4],list[5],list[6]]);
        }else{
          localDosingFunctionality(['deleteLocalDosingFromLine',irrigationLines[list[1]]['sNo']]);
        }
        break;
      }
      case ('editLocalFiltration'): {
        irrigationLines[list[1]]['local_filtration_site'] = list[2];
        if(list[2] == true){
          localFiltrationFunctionality(['addFiltrationDosing',irrigationLines[list[1]]['sNo']]);
        }else{
          localFiltrationFunctionality(['deleteLocalFiltrationFromLine',irrigationLines[list[1]]['sNo']]);
        }
        break;
      }
      case ('editPressureSensorInConnection'): {
        if(total_p_sensor > 0){
          if(list[2] == true){
            irrigationLines[list[1]]['pressureIn'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            total_p_sensor = total_p_sensor - 1;
          }else{
            irrigationLines[list[1]]['pressureIn'] = {};
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            irrigationLines[list[1]]['pressureIn'] = {};
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('editPressureSensorOutConnection'): {
        if(total_p_sensor > 0){
          if(list[2] == true){
            irrigationLines[list[1]]['pressureOut'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            total_p_sensor = total_p_sensor - 1;
          }else{
            irrigationLines[list[1]]['pressureOut'] = {};
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            irrigationLines[list[1]]['pressureOut'] = {};
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
          if(list[2] == true){
            irrigationLines[list[1]]['water_meter'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalWaterMeter = totalWaterMeter - 1;
          }else{
            irrigationLines[list[1]]['water_meter'] = {};
            totalWaterMeter = totalWaterMeter + 1;
          }

        }
        if(totalWaterMeter == 0){
          if(list[2] == false){
            irrigationLines[list[1]]['water_meter'] = {};
            totalWaterMeter = totalWaterMeter + 1;
          }
        }

        break;
      }
    }
    notifyListeners();
  }
  //TODO: setLine
  int setLine(int autoIncrement){
    int value = 0;
    for(var i in irrigationLines){
      if(i['sNo'] == autoIncrement){
        value = irrigationLines.indexOf(i);
      }
    }
    return value;
  }
  //TODO: localDosingFunctionality
  void localDosingFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addLocalDosing'):{
        if(totalInjector > 0){
          localDosingUpdated.add({
            'line' : setLine(list[1]) + 1,
            'sNo' : list[1],
            'selection' : 'unselect',
            'injector' : addBatchInjector(list[2]),
            'boosterPump' : '',
            'boosterConnection' : [],
            'ec' : '',
            'ecConnection' : [],
            'ph' : '',
            'phConnection' : [],
            'pressureSwitch' : {},
          });
        }
        localDosingUpdated.sort((a, b) => a['line'].compareTo(b['line']));
        break;
      }
      case ('edit_l_DosingSelection'):{
        l_dosingSelection = list[1];
        break;
      }
      case ('edit_l_DosingSelectAll'):{
        l_dosingSelectAll = list[1];
        for(var i in localDosingUpdated){
          i['selection'] = list[1] == true ? 'select' : 'unselect';
        }
        break;
      }
      case ('editDosingMeter') : {
        if(totalDosingMeter > 0){
          if(list[3] == true){
            localDosingUpdated[list[1]]['injector'][list[2]]['dosingMeter'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalDosingMeter = totalDosingMeter - 1;
          }else{
            localDosingUpdated[list[1]]['injector'][list[2]]['dosingMeter'] = {};
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        if(totalDosingMeter == 0){
          if(list[3] == false){
            localDosingUpdated[list[1]]['injector'][list[2]]['dosingMeter'] = {};
            totalDosingMeter = totalDosingMeter + 1;
          }
        }
        break;
      }
      case ('editLevelSensor') : {
        if(totalLevelSensor > 0){
          if(list[3] == true){
            localDosingUpdated[list[1]]['injector'][list[2]]['levelSensor'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalLevelSensor = totalLevelSensor - 1;
          }else{
            localDosingUpdated[list[1]]['injector'][list[2]]['levelSensor'] = {};
            totalLevelSensor = totalLevelSensor + 1;
          }
        }
        if(totalLevelSensor == 0){
          if(list[3] == false){
            localDosingUpdated[list[1]]['injector'][list[2]]['levelSensor'] = {};
            totalLevelSensor = totalLevelSensor + 1;
          }
        }
        break;
      }
      case ('editInjectorType') : {
        localDosingUpdated[list[1]]['injector'][list[2]]['injectorType'] = list[3];
        break;
      }
      case ('editPressureSwitch') : {
        if(totalPressureSwitch > 0){
          if(list[2] == true){
            localDosingUpdated[list[1]]['pressureSwitch'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalPressureSwitch = totalPressureSwitch - 1;
          }else{
            localDosingUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        if(totalPressureSwitch == 0){
          if(list[2] == false){
            localDosingUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        break;
      }
      case ('selectLocalDosing') : {
        if(localDosingUpdated[list[1]]['selection'] == 'unselect'){
          localDosingUpdated[list[1]]['selection'] = 'select';
          selection += 1;
        }else{
          localDosingUpdated[list[1]]['selection'] = 'unselect';
          selection -= 1;
        }
        break;
      }
      case ('deleteLocalDosing') : {
        List<Map<String, dynamic>> selectedSite = [];
        for (var i = localDosingUpdated.length - 1; i >= 0; i--) {
          if (localDosingUpdated[i]['selection'] == 'select') {
            selectedSite.add(localDosingUpdated[i]);
          }
        }
        for (var i in selectedSite) {
          totalInjector = totalInjector + i['injector'].length as int;
          totalBooster = totalBooster + i['boosterConnection'].length as int;
          totalEcSensor = totalEcSensor + i['ecConnection'].length as int;
          totalPhSensor = totalPhSensor + i['phConnection'].length as int;
          if(i['pressureSwitch'].isNotEmpty){
            totalPressureSwitch = totalPressureSwitch + 1;
          }
          for(var inj in i['injector']){
            if(inj['dosingMeter'].isNotEmpty){
              totalDosingMeter = totalDosingMeter + 1;
            }
          }
          for(var irr in irrigationLines){
            if(irr['sNo'] == i['sNo']){
              irr['Local_dosing_site'] = false;
            }
          }
          localDosingUpdated.remove(i);
        }
        break;
      }
      case ('editBoosterPumpSelection'):{
        if(localDosingUpdated[list[1]]['boosterPump'] == ''){
          localDosingUpdated[list[1]]['boosterConnection'] = [];
          for(var inj = 0;inj < localDosingUpdated[list[1]]['injector'].length;inj++){
            localDosingUpdated[list[1]]['injector'][inj]['Which_Booster_Pump'] = '-';
          }
        }else{
          if(int.parse(localDosingUpdated[list[1]]['boosterPump']) > localDosingUpdated[list[1]]['boosterConnection'].length){
            int count = (int.parse(localDosingUpdated[list[1]]['boosterPump'])- localDosingUpdated[list[1]]['boosterConnection'].length) as int;
            for(var i = 0; i < count;i++){
              localDosingUpdated[list[1]]['boosterConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              });
            }
          }else{
            int count = (localDosingUpdated[list[1]]['boosterConnection'].length - int.parse(localDosingUpdated[list[1]]['boosterPump']));
            for(var i = 0; i < count;i++){
              for(var inj = 0;inj < localDosingUpdated[list[1]]['injector'].length;inj++){
                if(localDosingUpdated[list[1]]['injector'][inj]['Which_Booster_Pump'].contains('${localDosingUpdated[list[1]]['boosterConnection'].length}')){
                  localDosingUpdated[list[1]]['injector'][inj]['Which_Booster_Pump'] = '-';
                }
              }
              localDosingUpdated[list[1]]['boosterConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editEcSelection'):{
        if(localDosingUpdated[list[1]]['ec'] == ''){
          localDosingUpdated[list[1]]['ecConnection'] = [];
        }else{
          if(int.parse(localDosingUpdated[list[1]]['ec']) > localDosingUpdated[list[1]]['ecConnection'].length){
            int count = (int.parse(localDosingUpdated[list[1]]['ec'])- localDosingUpdated[list[1]]['ecConnection'].length) as int;
            for(var i = 0; i < count;i++){
              localDosingUpdated[list[1]]['ecConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'input' : '-',
                'input_type' : '-',
              });
            }
          }else{
            int count = (localDosingUpdated[list[1]]['ecConnection'].length - int.parse(localDosingUpdated[list[1]]['ec']));
            for(var i = 0; i < count;i++){
              localDosingUpdated[list[1]]['ecConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editPhSelection'):{
        if(localDosingUpdated[list[1]]['ph'] == ''){
          localDosingUpdated[list[1]]['phConnection'] = [];
        }else{
          if(int.parse(localDosingUpdated[list[1]]['ph']) > localDosingUpdated[list[1]]['phConnection'].length){
            int count = (int.parse(localDosingUpdated[list[1]]['ph'])- localDosingUpdated[list[1]]['phConnection'].length) as int;
            for(var i = 0; i < count;i++){
              localDosingUpdated[list[1]]['phConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'input' : '-',
                'input_type' : '-',
              });
            }
          }else{
            int count = (localDosingUpdated[list[1]]['phConnection'].length - int.parse(localDosingUpdated[list[1]]['ph']));
            for(var i = 0; i < count;i++){
              localDosingUpdated[list[1]]['phConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editBoosterPump'): {
        if(totalBooster > -1){
          if(localDosingUpdated[list[1]]['boosterPump'] != ''){
            totalBooster = totalBooster + int.parse(localDosingUpdated[list[1]]['boosterPump']);
            if(list[2] == ''){
              totalBooster = totalBooster - 0;
            }else{
              if(list[2] == '0'){
                totalBooster = totalBooster - 1;
              }else{
                totalBooster = totalBooster - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalBooster = totalBooster - 1;
            }else{
              totalBooster = totalBooster - int.parse(list[2]);
            }
          }
          localDosingUpdated[list[1]]['boosterPump'] = list[2];
        }
        break;
      }
      case ('boosterSelectionForInjector'): {
        localDosingUpdated[list[1]]['injector'][list[2]]['Which_Booster_Pump'] = list[3];
        break;
      }
      case ('editEcSensor'): {
        if(totalEcSensor > -1){
          if(localDosingUpdated[list[1]]['ec'] != ''){
            totalEcSensor = totalEcSensor + int.parse(localDosingUpdated[list[1]]['ec']);
            if(list[2] == ''){
              totalEcSensor = totalEcSensor - 0;
            }else{
              if(list[2] == '0'){
                totalEcSensor = totalEcSensor - 1;
              }else{
                totalEcSensor = totalEcSensor - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalEcSensor = totalEcSensor - 1;
            }else{
              totalEcSensor = totalEcSensor - int.parse(list[2]);
            }
          }
          localDosingUpdated[list[1]]['ec'] = list[2];
        }
        break;
      }
      case ('editPhSensor'): {
        if(totalPhSensor > -1){
          if(localDosingUpdated[list[1]]['ph'] != ''){
            totalPhSensor = totalPhSensor + int.parse(localDosingUpdated[list[1]]['ph']);
            if(list[2] == ''){
              totalPhSensor = totalPhSensor - 0;
            }else{
              if(list[2] == '0'){
                totalPhSensor = totalPhSensor - 1;
              }else{
                totalPhSensor = totalPhSensor - int.parse(list[2]);
              }

            }
          }else{
            if(list[2] == '0'){
              totalPhSensor = totalPhSensor - 1;
            }else{
              totalPhSensor = totalPhSensor - int.parse(list[2]);
            }
          }
          localDosingUpdated[list[1]]['ph'] = list[2];
        }
        break;
      }
      case ('deleteLocalDosingFromLine') : {
        List<Map<String,dynamic>> Deletelist = [];
        for(var i = 0;i < localDosingUpdated.length;i++){
          if(localDosingUpdated[i]['sNo'] == list[1]){
            Deletelist.add(localDosingUpdated[i]);
          }
        }
        for(var i in Deletelist){
          if(localDosingUpdated.contains(i)){
            totalInjector = totalInjector + i['injector'].length as int;
            totalBooster = totalBooster + i['boosterConnection'].length as int;
            totalEcSensor = totalEcSensor + i['ecConnection'].length as int;
            totalPhSensor = totalPhSensor + i['phConnection'].length as int;
            if(i['pressureSwitch'].isNotEmpty){
              totalPressureSwitch = totalPressureSwitch + 1;
            }
            for(var i in i['injector']){
              if(i['dosingMeter'].isNotEmpty){
                totalDosingMeter = totalDosingMeter + 1;
              }
            }
            localDosingUpdated.remove(i);
          }
        }
        for(var i in localDosingUpdated){
          i['line'] = setLine(i['sNo']) + 1;
        }
        break;
      }
      default :{
        break;
      }
    }
    notifyListeners();
  }
  //TODO: localFiltrationFunctionality
  void localFiltrationFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('addFiltrationDosing'):{
        totalFilter -= 1;
        localFiltrationUpdated.add(
            {
              'line' : setLine(list[1]) + 1,
              'sNo' : list[1],
              'selection' : 'unselect',
              'filter' : '1',
              'filterConnection' : [{
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              }],
              'dv' : {},
              'pressureIn' : {},
              'pressureOut' : {},
              'pressureSwitch' : {},
              'diffPressureSensor' : {},
            }
        );
        localFiltrationUpdated.sort((a, b) => a['line'].compareTo(b['line']));

        break;
      }
      case ('editPressureSwitch') : {
        if(totalPressureSwitch > 0){
          if(list[2] == true){
            localFiltrationUpdated[list[1]]['pressureSwitch'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalPressureSwitch = totalPressureSwitch - 1;
          }else{
            localFiltrationUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }
        if(totalPressureSwitch == 0){
          if(list[2] == false){
            localFiltrationUpdated[list[1]]['pressureSwitch'] = {};
            totalPressureSwitch = totalPressureSwitch + 1;
          }
        }

        break;
      }
      case ('editDiffPressureSensor') : {
        if(totalDiffPressureSensor > 0){
          if(list[2] == true){
            localFiltrationUpdated[list[1]]['diffPressureSensor'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            totalDiffPressureSensor = totalDiffPressureSensor - 1;
          }else{
            localFiltrationUpdated[list[1]]['diffPressureSensor'] = {};
            totalDiffPressureSensor = totalDiffPressureSensor + 1;
          }
        }
        if(totalDiffPressureSensor == 0){
          if(list[2] == false){
            localFiltrationUpdated[list[1]]['diffPressureSensor'] = {};
            totalDiffPressureSensor = totalDiffPressureSensor + 1;
          }
        }
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
          if(localFiltrationUpdated[list[1]]['filter'] != ''){
            totalFilter = totalFilter + int.parse(localFiltrationUpdated[list[1]]['filter']);
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
          localFiltrationUpdated[list[1]]['filter'] = list[2];
        }
        break;
      }
      case ('editFilterSelection'):{
        if(localFiltrationUpdated[list[1]]['filter'] == ''){
          localFiltrationUpdated[list[1]]['filterConnection'] = [];
        }else{
          if(int.parse(localFiltrationUpdated[list[1]]['filter']) > localFiltrationUpdated[list[1]]['filterConnection'].length){
            int count = (int.parse(localFiltrationUpdated[list[1]]['filter'])- localFiltrationUpdated[list[1]]['filterConnection'].length) as int;
            for(var i = 0; i < count;i++){
              localFiltrationUpdated[list[1]]['filterConnection'].add({
                'sNo' : returnI_O_AutoIncrement(),
                'rtu' : '-',
                'rfNo' : '-',
                'output' : '-',
                'output_type' : '1',
              });
            }
          }else{
            int count = (localFiltrationUpdated[list[1]]['filterConnection'].length - int.parse(localFiltrationUpdated[list[1]]['filter']));
            for(var i = 0; i < count;i++){
              localFiltrationUpdated[list[1]]['filterConnection'].removeLast();
            }
          }
        }
        break;
      }
      case ('editDownStreamValve') : {
        if(total_D_s_valve > 0){
          if(list[2] == true){
            localFiltrationUpdated[list[1]]['dv'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'output' : '-',
              'output_type' : '1',
            };
            total_D_s_valve = total_D_s_valve - 1;
          }else{
            localFiltrationUpdated[list[1]]['dv'] = {};
            total_D_s_valve = total_D_s_valve + 1;
          }

        }
        if(total_D_s_valve == 0){
          if(list[2] == false){
            localFiltrationUpdated[list[1]]['dv'] = {};
            total_D_s_valve = total_D_s_valve + 1;
          }
        }
        break;
      }
      case ('editPressureSensor') : {
        if(total_p_sensor > 0){
          if(list[2] == true){
            localFiltrationUpdated[list[1]]['pressureIn'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            total_p_sensor = total_p_sensor - 1;
          }else{
            localFiltrationUpdated[list[1]]['pressureIn'] = {};
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            localFiltrationUpdated[list[1]]['pressureIn'] = {};
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('editPressureSensor_out') : {
        if(total_p_sensor > 0){
          if(list[2] == true){
            localFiltrationUpdated[list[1]]['pressureOut'] = {
              'sNo' : returnI_O_AutoIncrement(),
              'rtu' : '-',
              'rfNo' : '-',
              'input' : '-',
              'input_type' : '-',
            };
            total_p_sensor = total_p_sensor - 1;
          }else{
            localFiltrationUpdated[list[1]]['pressureOut'] = {};
            total_p_sensor = total_p_sensor + 1;
          }

        }
        if(total_p_sensor == 0){
          if(list[2] == false){
            localFiltrationUpdated[list[1]]['pressureOut'] = {};
            total_p_sensor = total_p_sensor + 1;
          }
        }
        break;
      }
      case ('selectLocalFiltration') : {
        if(localFiltrationUpdated[list[1]]['selection'] == 'select'){
          localFiltrationUpdated[list[1]]['selection'] = 'unselect';
        }else{
          localFiltrationUpdated[list[1]]['selection'] = 'select';
        }
        break;
      }
      case ('deleteLocalFiltrationFromLine') : {
        List<Map<String,dynamic>> selectedSite = [];
        for(var i in localFiltrationUpdated){
          if(i['sNo'] == list[1]){
            selectedSite.add(i);
          }
        }
        for(var i in selectedSite){
          if(localFiltrationUpdated.contains(i)){
            totalFilter += i['filterConnection'].length as int;
            if(i['dv'].isNotEmpty){
              total_D_s_valve += 1;
            }
            if(i['pressureIn'].isNotEmpty){
              total_p_sensor += 1;
            }
            if(i['pressureOut'].isNotEmpty){
              total_p_sensor += 1;
            }
            if(i['pressureSwitch'].isNotEmpty){
              totalPressureSwitch += 1;
            }
            if(i['diffPressureSensor'].isNotEmpty){
              totalDiffPressureSensor += 1;
            }
            localFiltrationUpdated.remove(i);
          }
        }
        for(var i in localFiltrationUpdated){
          i['line'] = setLine(i['sNo']) + 1;
        }
        break;
      }
      case ('deleteLocalFiltration') : {
        List<Map<String, dynamic>> selectedSite = [];
        for (var i = localFiltrationUpdated.length - 1; i >= 0; i--) {
          if (localFiltrationUpdated[i]['selection'] == 'select') {
            selectedSite.add(localFiltrationUpdated[i]);
          }
        }
        for (var cfSite in selectedSite) {
          if(cfSite['dv'].isNotEmpty){
            total_D_s_valve = total_D_s_valve + 1;
          }
          if(cfSite['pressureIn'].isNotEmpty){
            total_p_sensor = total_p_sensor + 1;
          }
          if(cfSite['pressureOut'].isNotEmpty){
            total_p_sensor = total_p_sensor + 1;
          }
          if(cfSite['pressureSwitch'].isNotEmpty){
            totalPressureSwitch = totalPressureSwitch + 1;
          }
          if(cfSite['diffPressureSensor'].isNotEmpty){
            totalDiffPressureSensor += 1;
          }
          if(cfSite['filter'] != ''){
            totalFilter = totalFilter + int.parse(cfSite['filter']);
          }
          for(var irr in irrigationLines){
            if(irr['sNo'] == cfSite['sNo']){
              irr['local_filtration_site'] = false;
            }
          }
          localFiltrationUpdated.remove(cfSite);
        }

        l_filtrationSelectALL = false;
        l_filtrationSelection = false;

        break;
      }
      default :{
        break;
      }
    }
    notifyListeners();
  }
  //TODO: mappingOfOutputsFunctionality
  void mappingOfOutputsFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('m_o_line'):{
        if(list[4] == 'rtu'){
          if(irrigationLines[list[1]][list[2]][list[3]][list[4]] != list[5]){
            irrigationLines[list[1]][list[2]][list[3]]['rfNo'] = '-';
            irrigationLines[list[1]][list[2]][list[3]]['output'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(irrigationLines[list[1]][list[2]][list[3]][list[4]] != list[5]){
            irrigationLines[list[1]][list[2]][list[3]]['output'] = '-';
          }
        }
        irrigationLines[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_localDosing'):{
        if(list[4] == 'rtu'){
          if(localDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
            localDosingUpdated[list[1]][list[2]][list[3]]['rfNo'] = '-';
            localDosingUpdated[list[1]][list[2]][list[3]]['output'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(localDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
            localDosingUpdated[list[1]][list[2]][list[3]]['output'] = '-';
          }
        }else if(list[4] == 'output'){
        }
        localDosingUpdated[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_centralDosing'):{
        if(list[4] == 'rtu'){
          if(centralDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
            centralDosingUpdated[list[1]][list[2]][list[3]]['rfNo'] = '-';
            centralDosingUpdated[list[1]][list[2]][list[3]]['output'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(centralDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
            centralDosingUpdated[list[1]][list[2]][list[3]]['output'] = '-';
          }
        }else if(list[4] == 'output'){
        }
        centralDosingUpdated[list[1]][list[2]][list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_localFiltration'):{
        if(list[4] == 'rtu'){
          if(list[3] == -1){
            if(localFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              localFiltrationUpdated[list[1]][list[2]]['rfNo'] = '-';
              localFiltrationUpdated[list[1]][list[2]]['output'] = '-';
            }
          }else{
            if(localFiltrationUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              localFiltrationUpdated[list[1]][list[2]][list[3]]['rfNo'] = '-';
              localFiltrationUpdated[list[1]][list[2]][list[3]]['output'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[3] == -1){
            if(localFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              localFiltrationUpdated[list[1]][list[2]]['output'] = '-';
            }
          }else{
            if(localFiltrationUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              localFiltrationUpdated[list[1]][list[2]][list[3]]['output'] = '-';
            }
          }
        }
        if(list[3] == -1){
          localFiltrationUpdated[list[1]][list[2]][list[4]] = list[5];
        }else{
          localFiltrationUpdated[list[1]][list[2]][list[3]][list[4]] = list[5];
        }
        break;
      }
      case ('m_o_centralFiltration'):{
        if(list[4] == 'rtu'){
          if(list[3] == -1){
            if(centralFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              centralFiltrationUpdated[list[1]][list[2]]['rfNo'] = '-';
              centralFiltrationUpdated[list[1]][list[2]]['output'] = '-';
            }
          }else{
            if(centralFiltrationUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              centralFiltrationUpdated[list[1]][list[2]][list[3]]['rfNo'] = '-';
              centralFiltrationUpdated[list[1]][list[2]][list[3]]['output'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[3] == -1){
            if(centralFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              centralFiltrationUpdated[list[1]][list[2]]['output'] = '-';
            }
          }else{
            if(centralFiltrationUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              centralFiltrationUpdated[list[1]][list[2]][list[3]]['output'] = '-';
            }
          }
        }
        if(list[3] == -1){
          centralFiltrationUpdated[list[1]][list[2]][list[4]] = list[5];
        }else{
          centralFiltrationUpdated[list[1]][list[2]][list[3]][list[4]] = list[5];
        }
        break;
      }
      case ('m_o_sourcePump'):{
        if(list[4] == 'rtu'){
          if(sourcePumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            sourcePumpUpdated[list[1]][list[2]]['rfNo'] = '-';
            sourcePumpUpdated[list[1]][list[2]]['output'] = '-';
            sourcePumpUpdated[list[1]][list[2]]['current_selection'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(sourcePumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            if(sourcePumpUpdated[list[1]]['off'] != null){
              sourcePumpUpdated[list[1]]['off']['rfNo'] = list[5];
              sourcePumpUpdated[list[1]]['off']['output'] = '-';
            }
            if(sourcePumpUpdated[list[1]]['scr'] != null){
              sourcePumpUpdated[list[1]]['scr']['rfNo'] = list[5];
              sourcePumpUpdated[list[1]]['scr']['output'] = '-';
            }
            if(sourcePumpUpdated[list[1]]['ecr'] != null){
              sourcePumpUpdated[list[1]]['ecr']['rfNo'] = list[5];
              sourcePumpUpdated[list[1]]['ecr']['output'] = '-';
            }
            if(sourcePumpUpdated[list[1]]['on'] != null){
              sourcePumpUpdated[list[1]]['on']['rfNo'] = list[5];
              sourcePumpUpdated[list[1]]['on']['output'] = '-';
            }
            if(sourcePumpUpdated[list[1]]['c1'] != null){
              if(sourcePumpUpdated[list[1]]['c1'].isNotEmpty){
                sourcePumpUpdated[list[1]]['c1']['rfNo'] = list[5];
                sourcePumpUpdated[list[1]]['c1']['input'] = '-';
              }
            }
            if(sourcePumpUpdated[list[1]]['c2'] != null){
              if(sourcePumpUpdated[list[1]]['c2'].isNotEmpty){
                sourcePumpUpdated[list[1]]['c2']['rfNo'] = list[5];
                sourcePumpUpdated[list[1]]['c2']['input'] = '-';
              }
            }
            if(sourcePumpUpdated[list[1]]['c3'] != null){
              if(sourcePumpUpdated[list[1]]['c3'].isNotEmpty){
                sourcePumpUpdated[list[1]]['c3']['rfNo'] = list[5];
                sourcePumpUpdated[list[1]]['c3']['input'] = '-';
              }
            }
            sourcePumpUpdated[list[1]][list[2]]['output'] = '-';
          }
        }
        sourcePumpUpdated[list[1]][list[2]][list[4]] = list[5];
        break;
      }
      case ('m_o_irrigationPump'):{
        if(list[4] == 'rtu'){
          if(irrigationPumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            irrigationPumpUpdated[list[1]][list[2]]['rfNo'] = '-';
            irrigationPumpUpdated[list[1]][list[2]]['output'] = '-';
            irrigationPumpUpdated[list[1]][list[2]]['current_selection'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(irrigationPumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            if(irrigationPumpUpdated[list[1]]['off'] != null){
              irrigationPumpUpdated[list[1]]['off']['rfNo'] = list[5];
              irrigationPumpUpdated[list[1]]['off']['output'] = '-';
            }
            if(irrigationPumpUpdated[list[1]]['scr'] != null){
              irrigationPumpUpdated[list[1]]['scr']['rfNo'] = list[5];
              irrigationPumpUpdated[list[1]]['scr']['output'] = '-';
            }
            if(irrigationPumpUpdated[list[1]]['ecr'] != null){
              irrigationPumpUpdated[list[1]]['ecr']['rfNo'] = list[5];
              irrigationPumpUpdated[list[1]]['ecr']['output'] = '-';
            }
            if(irrigationPumpUpdated[list[1]]['on'] != null){
              irrigationPumpUpdated[list[1]]['on']['rfNo'] = list[5];
              irrigationPumpUpdated[list[1]]['on']['output'] = '-';
            }
            if(irrigationPumpUpdated[list[1]]['c1'] != null){
              if(irrigationPumpUpdated[list[1]]['c1'].isNotEmpty){
                irrigationPumpUpdated[list[1]]['c1']['rfNo'] = list[5];
                irrigationPumpUpdated[list[1]]['c1']['input'] = '-';
              }
            }
            if(irrigationPumpUpdated[list[1]]['c2'] != null){
              if(irrigationPumpUpdated[list[1]]['c2'].isNotEmpty){
                irrigationPumpUpdated[list[1]]['c2']['rfNo'] = list[5];
                irrigationPumpUpdated[list[1]]['c2']['input'] = '-';
              }
            }
            if(irrigationPumpUpdated[list[1]]['c3'] != null){
              if(irrigationPumpUpdated[list[1]]['c3'].isNotEmpty){
                irrigationPumpUpdated[list[1]]['c3']['rfNo'] = list[5];
                irrigationPumpUpdated[list[1]]['c3']['input'] = '-';
              }
            }
            irrigationPumpUpdated[list[1]][list[2]]['output'] = '-';
          }
        }
        irrigationPumpUpdated[list[1]][list[2]][list[4]] = list[5];
        break;
      }
      case ('m_o_agitator'):{
        if(list[4] == 'rtu'){
          if(totalAgitator[list[3]][list[4]] != list[5]){
            totalAgitator[list[3]]['rfNo'] = '-';
            totalAgitator[list[3]]['output'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(totalAgitator[list[3]][list[4]] != list[5]){
            totalAgitator[list[3]]['output'] = '-';
          }
        }
        totalAgitator[list[3]][list[4]] = list[5];
        break;
      }
      case ('m_o_selector'):{
        if(list[4] == 'rtu'){
          if(totalSelector[list[3]][list[4]] != list[5]){
            totalSelector[list[3]]['rfNo'] = '-';
            totalSelector[list[3]]['output'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(totalSelector[list[3]][list[4]] != list[5]){
            totalSelector[list[3]]['output'] = '-';
          }
        }
        totalSelector[list[3]][list[4]] = list[5];
        break;
      }
    }
    notifyListeners();
  }
  //TODO: mappingOfInputsFunctionality
  void mappingOfInputsFunctionality(List<dynamic> list){
    switch (list[0]){
      case ('m_i_line'):{
        if(list[4] == 'rtu'){
          if(list[3] == -1){
            if(irrigationLines[list[1]][list[2]][list[4]] != list[5]){
              irrigationLines[list[1]][list[2]]['rfNo'] = '-';
              irrigationLines[list[1]][list[2]]['input'] = '-';
            }
          }else{
            if(irrigationLines[list[1]][list[2]][list[3]][list[4]] != list[5]){
              irrigationLines[list[1]][list[2]][list[3]]['rfNo'] = '-';
              irrigationLines[list[1]][list[2]][list[3]]['input'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[3] == -1){
            if(irrigationLines[list[1]][list[2]][list[4]] != list[5]){
              irrigationLines[list[1]][list[2]]['input'] = '-';
            }
          }else{
            if(irrigationLines[list[1]][list[2]][list[3]][list[4]] != list[5]){
              irrigationLines[list[1]][list[2]][list[3]]['input'] = '-';
            }
          }
        }
        if(list[3] == -1){
          irrigationLines[list[1]][list[2]][list[4]] = list[5];
        }else{
          irrigationLines[list[1]][list[2]][list[3]][list[4]] = list[5];
        }
        break;
      }
      case ('m_i_centralDosing'):{
        if(list[4] == 'rtu'){
          if(list[2].contains('-')){
            if(centralDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]][list[4]] != list[5]){
              centralDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]]['rfNo'] = '-';
              centralDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]]['input'] = '-';
            }
          }else if(list[2] == 'pressureSwitch'){
            if(centralDosingUpdated[list[1]][list[2]][list[4]] != list[5]){
              centralDosingUpdated[list[1]][list[2]]['rfNo'] = '-';
              centralDosingUpdated[list[1]][list[2]]['input'] = '-';
            }
          }else{
            if(centralDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              centralDosingUpdated[list[1]][list[2]][list[3]]['rfNo'] = '-';
              centralDosingUpdated[list[1]][list[2]][list[3]]['input'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[2].contains('-')){
            if(centralDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]][list[4]] != list[5]){
              centralDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]]['input'] = '-';
            }
          }else if(list[2] == 'pressureSwitch'){
            if(centralDosingUpdated[list[1]][list[2]][list[4]] != list[5]){
              centralDosingUpdated[list[1]][list[2]]['input'] = '-';
            }
          }else{
            if(centralDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              centralDosingUpdated[list[1]][list[2]][list[3]]['input'] = '-';
            }
          }

        }
        if(list[2].contains('-')){
          centralDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]][list[4]] = list[5];
        }else if(list[2] == 'pressureSwitch'){
          centralDosingUpdated[list[1]][list[2]][list[4]] = list[5];
        }else{
          centralDosingUpdated[list[1]][list[2]][list[3]][list[4]] = list[5];
        }
        break;
      }
      case ('m_i_localDosing'):{
        if(list[4] == 'rtu'){
          if(list[2].contains('-')){
            if(localDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]][list[4]] != list[5]){
              localDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]]['rfNo'] = '-';
              localDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]]['input'] = '-';
            }
          }else if(list[2] == 'pressureSwitch'){
            if(localDosingUpdated[list[1]][list[2]][list[4]] != list[5]){
              localDosingUpdated[list[1]][list[2]]['rfNo'] = '-';
              localDosingUpdated[list[1]][list[2]]['input'] = '-';
            }
          }else{
            if(localDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              localDosingUpdated[list[1]][list[2]][list[3]]['rfNo'] = '-';
              localDosingUpdated[list[1]][list[2]][list[3]]['input'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[2].contains('-')){
            if(localDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]][list[4]] != list[5]){
              localDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]]['input'] = '-';
            }
          }else if(list[2] == 'pressureSwitch'){
            if(localDosingUpdated[list[1]][list[2]][list[4]] != list[5]){
              localDosingUpdated[list[1]][list[2]]['input'] = '-';
            }
          }else{
            if(localDosingUpdated[list[1]][list[2]][list[3]][list[4]] != list[5]){
              localDosingUpdated[list[1]][list[2]][list[3]]['input'] = '-';
            }
          }

        }
        if(list[2].contains('-')){
          localDosingUpdated[list[1]][list[2].split('-')[0]][list[3]][list[2].split('-')[1]][list[4]] = list[5];
        }else if(list[2] == 'pressureSwitch'){
          localDosingUpdated[list[1]][list[2]][list[4]] = list[5];
        }else{
          localDosingUpdated[list[1]][list[2]][list[3]][list[4]] = list[5];
        }
        break;
      }
      case ('m_i_sourcePump'):{
        if(list[4] == 'rtu'){
          if(sourcePumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            sourcePumpUpdated[list[1]][list[2]]['rfNo'] = '-';
            sourcePumpUpdated[list[1]][list[2]]['input'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(sourcePumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            sourcePumpUpdated[list[1]][list[2]]['input'] = '-';
          }
        }
        sourcePumpUpdated[list[1]][list[2]][list[4]] = list[5];
        break;
      }
      case ('m_i_irrigationPump'):{
        if(list[4] == 'rtu'){
          if(irrigationPumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            irrigationPumpUpdated[list[1]][list[2]]['rfNo'] = '-';
            irrigationPumpUpdated[list[1]][list[2]]['input'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(irrigationPumpUpdated[list[1]][list[2]][list[4]] != list[5]){
            irrigationPumpUpdated[list[1]][list[2]]['input'] = '-';
          }
        }
        irrigationPumpUpdated[list[1]][list[2]][list[4]] = list[5];
        break;
      }
      case ('m_i_localFiltration'):{
        if(list[4] == 'rtu'){
          if(list[3] == -1){
            if(localFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              localFiltrationUpdated[list[1]][list[2]]['rfNo'] = '-';
              localFiltrationUpdated[list[1]][list[2]]['input'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[3] == -1){
            if(localFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              localFiltrationUpdated[list[1]][list[2]]['input'] = '-';
            }
          }
        }
        if(list[3] == -1){
          localFiltrationUpdated[list[1]][list[2]][list[4]] = list[5];
        }
        break;
      }
      case ('m_i_centralFiltration'):{
        if(list[4] == 'rtu'){
          if(list[3] == -1){
            if(centralFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              centralFiltrationUpdated[list[1]][list[2]]['rfNo'] = '-';
              centralFiltrationUpdated[list[1]][list[2]]['input'] = '-';
            }
          }
        }else if(list[4] == 'rfNo'){
          if(list[3] == -1){
            if(centralFiltrationUpdated[list[1]][list[2]][list[4]] != list[5]){
              centralFiltrationUpdated[list[1]][list[2]]['input'] = '-';
            }
          }
        }
        if(list[3] == -1){
          centralFiltrationUpdated[list[1]][list[2]][list[4]] = list[5];
        }
        break;
      }
      case ('m_i_analogSensor'):{
        if(list[4] == 'rtu'){
          if(totalAnalogSensor[list[3]][list[4]] != list[5]){
            totalAnalogSensor[list[3]]['rfNo'] = '-';
            totalAnalogSensor[list[3]]['input'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(totalAnalogSensor[list[3]][list[4]] != list[5]){
            totalAnalogSensor[list[3]]['input'] = '-';
          }
        }
        totalAnalogSensor[list[3]][list[4]] = list[5];
        break;
      }
      case ('m_i_temperature'):{
        editSensor(list,connTempSensor);
        break;
      }
      case ('m_i_soilTemperature'):{
        editSensor(list,connSoilTempSensor);
        break;
      }
      case ('m_i_rainGauge'):{
        editSensor(list,connRainGauge);
        break;
      }
      case ('m_i_leafWetness'):{
        editSensor(list,connLeafWetness);
        break;
      }
      case ('m_i_windSpeed'):{
        editSensor(list,connWindSpeed);
        break;
      }
      case ('m_i_windDirection'):{
        editSensor(list,connWindDirection);
        break;
      }
      case ('m_i_co2'):{
        editSensor(list,connCo2);
        break;
      }
      case ('m_i_lux'):{
        editSensor(list,connLux);
        break;
      }
      case ('m_i_ldr'):{
        editSensor(list,connLdr);
        break;
      }
      case ('m_i_humidity'):{
        editSensor(list,connHumidity);
        break;
      }
      case ('m_i_contact'):{
        if(list[4] == 'rtu'){
          if(totalContact[list[3]][list[4]] != list[5]){
            totalContact[list[3]]['rfNo'] = '-';
            totalContact[list[3]]['input'] = '-';
          }
        }else if(list[4] == 'rfNo'){
          if(totalContact[list[3]][list[4]] != list[5]){
            totalContact[list[3]]['input'] = '-';
          }
        }
        totalContact[list[3]][list[4]] = list[5];
        break;
      }
    }
    notifyListeners();
  }

  editSensor(list,connection){
    if(list[4] == 'rtu'){
      if(connection[list[3]][list[4]] != list[5]){
        connection[list[3]]['rfNo'] = '-';
        connection[list[3]]['input'] = '-';
      }
    }else if(list[4] == 'rfNo'){
      if(connection[list[3]][list[4]] != list[5]){
        connection[list[3]]['input'] = '-';
      }
    }
    connection[list[3]][list[4]] = list[5];
    notifyListeners();
  }
  //TODO: returnDeviceType
  String returnDeviceType(String title){
    if(title == 'ORO Smart'){
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
  //TODO: fetchAll data from server
  void fetchAll(dynamic data,[bool? newData]){
    serverData = data;
    for(var i in data.entries){
      if(newData == null){
        if(i.key == 'configMaker'){
          oldData = i.value;
          fetchFromServer();
        }
      }
      if(newData == null){
        if(i.key == 'names'){
          if(i.value['SP'] != null){
            for(var sp in i.value['SP']){
              names['${sp['sNo']}'] = sp['name'];
            }
          }
          if(i.value['IP'] != null){
            for(var ip in i.value['IP']){
              names['${ip['sNo']}'] = ip['name'];
            }
          }
          if(i.value['WS'] != null){
            for(var ws in i.value['WS']){
              names['${ws['sNo']}'] = ws['name'];
            }
          }
          if(i.value['IL'] != null){
            for(var il in i.value['IL']){
              names['${il['sNo']}'] = il['name'];
            }
          }
          if(i.value['VL'] != null){
            for(var vl in i.value['VL']){
              names['${vl['sNo']}'] = vl['name'];
            }
          }
          if(i.value['CFESI'] != null){
            for(var cd in i.value['CFESI']){
              names['${cd['sNo']}'] = cd['name'];
            }
          }
          if(i.value['CFI'] != null){
            for(var fl in i.value['CFI']){
              names['${fl['sNo']}'] = fl['name'];
            }
          }
          if(i.value['MVL'] != null){
            for(var mv in i.value['MVL']){
              names['${mv['sNo']}'] = mv['name'];
            }
          }
          if(i.value['LFI'] != null){
            for(var lfl in i.value['LFI']){
              names['${lfl['sNo']}'] = lfl['name'];
            }
          }
          if(i.value['MS'] != null){
            for(var ms in i.value['MS']){
              names['${ms['sNo']}'] = ms['name'];
            }
          }
          if(i.value['LS'] != null){
            for(var ls in i.value['LS']){
              names['${ls['sNo']}'] = ls['name'];
            }
          }
          if(i.value['PS'] != null){
            for(var ps in i.value['PS']){
              names['${ps['sNo']}'] = ps['name'];
            }
          }
          if(i.value['ECS'] != null){
            for(var ecs in i.value['ECS']){
              names['${ecs['sNo']}'] = ecs['name'];
            }
          }
          if(i.value['PHS'] != null){
            for(var phs in i.value['PHS']){
              names['${phs['sNo']}'] = phs['name'];
            }
          }
          if(i.value['WM'] != null){
            for(var wm in i.value['WM']){
              names['${wm['sNo']}'] = wm['name'];
            }
          }
          if(i.value['FAN'] != null){
            for(var fn in i.value['FAN']){
              names['${fn['sNo']}'] = fn['name'];
            }
          }
          if(i.value['CFEI'] != null){
            for(var cdInj in i.value['CFEI']){
              names['${cdInj['sNo']}'] = cdInj['name'];
            }
          }
          if(i.value['CFEM'] != null){
            for(var cdDm in i.value['CFEM']){
              names['${cdDm['sNo']}'] = cdDm['name'];
            }
          }
          if(i.value['LFEI'] != null){
            for(var ldDm in i.value['LFEI']){
              names['${ldDm['sNo']}'] = ldDm['name'];
            }
          }
          if(i.value['FOG'] != null){
            for(var fg in i.value['FOG']){
              names['${fg['sNo']}'] = fg['name'];
            }
          }
          if(i.value['AS'] != null){
            for(var as in i.value['AS']){
              names['${as['sNo']}'] = as['name'];
            }
          }
        }
      }
      if(newData == true){
        if(i.key == 'referenceNo'){
          for(var rf in i.value.entries){
            if(rf.key == '6'){
              OroLevelForLine = rf.value;
              totalOroLevel = rf.value.length;
              for(var i in rf.value){
                oLevel.add('$i');
              }
            }else if(rf.key == '12'){
              OroSmartRtuForLine = rf.value;
              totalOroSmartRTU = rf.value.length;
              for(var i in rf.value){
                oSrtu.add('$i');
              }
            }else if(rf.key == '9'){
              switchForLine = rf.value;
              totalOroSwitch = rf.value.length;
              for(var i in rf.value){
                oSwitch.add('$i');
              }
            }else if(rf.key == '13'){
              rtuForLine = rf.value;
              totalRTU = rf.value.length;
              for(var i in rf.value){
                oRtu.add('$i');
              }
            }else if(rf.key == '10'){
              OroSenseForLine = rf.value;
              totalOroSense = rf.value.length;
              for(var i in rf.value){
                oSense.add('$i');
              }
            }else if(rf.key == '3'){
              totalOroPump= rf.value.length;
              for(var i in rf.value){
                oPump.add('$i');
              }
            }else if(rf.key == '11'){
              OroExtendForLine = rf.value;
              totalOroExtend= rf.value.length;
              for(var i in rf.value){
                oExtend.add('$i');
              }
            }else if(rf.key == '5'){
              oRoWeatherForStation = rf.value;
              for(var i in rf.value){
                oWeather.add('$i');
              }
            }else if(rf.key == '7'){
              OroSmartRtuPlusForLine = rf.value;
              totalOroSmartRtuPlus = rf.value.length;
              for(var i in rf.value){
                oSrtuPlus.add('$i');
              }
            }else if(rf.key == '8'){
              rtuPlusForLine = rf.value;
              totalRtuPlus = rf.value.length;
              for(var i in rf.value){
                oRtuPlus.add('$i');
              }
            }else if(rf.key == '4'){
              for(var i in rf.value){
                oPumpPlus.add('$i');
              }
            }
          }
        }
        if (i.key == 'productLimit') {
          for (var j in i.value) {
            switch (j['productTypeId']) {
              case 1:
                totalSourcePump = j['quantity'];
                break;
              case 2:
                totalIrrigationPump = j['quantity'];
                break;
              case 3:
                totalBooster = j['quantity'];
                break;
              case 4:
                totalInjector = j['quantity'];
                break;
              case 5:
                totalFilter = j['quantity'];
                break;
              case 6:
                totalValve = j['quantity'];
                break;
              case 7:
                totalMainValve = j['quantity'];
                break;
              case 8:
                total_D_s_valve = j['quantity'];
              case 9:
                totalFan = j['quantity'];
                break;
              case 10:
                totalFogger = j['quantity'];
                break;
              case 11:
                for (var k = 0; k < j['quantity']; k++) {
                  totalAgitator.add({
                    'sNo': returnI_O_AutoIncrement(),
                    'rtu': '-',
                    'rfNo': '-',
                    'output': '-',
                    'output_type': '-',
                  });
                }
                break;
              case 12:
                print('totalSelector1 : $totalSelector');

                for (var k = 0; k < j['quantity']; k++) {
                  print(k);
                  totalSelector.add({
                    'sNo': returnI_O_AutoIncrement(),
                    'rtu': '-',
                    'rfNo': '-',
                    'output': '-',
                    'output_type': '-',
                  });
                }
                print('totalSelector : $totalSelector');
                break;
              case 13:
                totalWaterMeter = j['quantity'];
                break;
              case 14:
                totalDosingMeter = j['quantity'];
                break;
              case 15:
                totalPressureSwitch = j['quantity'];
                break;
              case 16:
                total_p_sensor = j['quantity'];
                break;
              case 17:
                totalDiffPressureSensor = j['quantity'];
                break;
              case 18:
                totalMoistureSensor = j['quantity'];
                break;
              case 19:
                totalLevelSensor = j['quantity'];
                break;
              case 20:
                for (var k = 0; k < j['quantity']; k++) {
                  totalAnalogSensor.add({
                    'sNo': returnI_O_AutoIncrement(),
                    'rtu': '-',
                    'rfNo': '-',
                    'input': '-',
                    'input_type': '-',
                  });
                }
                break;
              case 21:
                totalEcSensor = j['quantity'];
                break;
              case 22:
                totalPhSensor = j['quantity'];
                break;
              case 23:
                totalTempSensor = j['quantity'];
                for(var i = 0;i < j['quantity'];i++){
                  connTempSensor.add({
                    'sNo': returnI_O_AutoIncrement(),
                    'rtu': '-',
                    'rfNo': '-',
                    'input': '-',
                    'input_type': '-',
                  });
                }
                break;
              case 24:
                totalSoilTempSensor = j['quantity'];
                for(var i = 0;i < j['quantity'];i++){
                  connSoilTempSensor.add({
                    'sNo': returnI_O_AutoIncrement(),
                    'rtu': '-',
                    'rfNo': '-',
                    'input': '-',
                    'input_type': '-',
                  });
                }
                break;
              case 25:
                totalWindDirection = j['quantity'];
                connWindDirection.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 26:
                totalWindSpeed = j['quantity'];
                connWindSpeed.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 27:
                totalCo2 = j['quantity'];
                connCo2.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 28:
                totalLux = j['quantity'];
                connLux.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 29:
                totalLdr = j['quantity'];
                connLdr.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 30:
                totalHumidity = j['quantity'];
                connHumidity.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 31:
                totalLeafWetness = j['quantity'];
                connLeafWetness.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 32:
                totalRainGauge = j['quantity'];
                connRainGauge.add({
                  'sNo': returnI_O_AutoIncrement(),
                  'rtu': '-',
                  'rfNo': '-',
                  'input': '-',
                  'input_type': '-',
                });
                break;
              case 33:
                for (var k = 0; k < j['quantity']; k++) {
                  totalContact.add({
                    'sNo': returnI_O_AutoIncrement(),
                    'rtu': '-',
                    'rfNo': '-',
                    'input': '-',
                    'input_type': '-',
                  });
                }
                break;
              case 34:
                totalIrrigationLine = j['quantity'];
                break;
              case 35:
                totalCentralDosing = j['quantity'];
                break;
              case 36:
                totalCentralFiltration = j['quantity'];
                break;
              case 45:
                var src = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'];
                waterSource = [];
                waterSource.add('-');
                for(var i = 0;i < j['quantity'];i++){
                  totalWaterSource.add({
                    'sNo' : returnI_O_AutoIncrement(),
                    'id' : 'WS${i+1}',
                    'name' : 'Water Source ${src[i]}',
                    'location' : ''
                  });
                  waterSource.add(src[i]);
                }
                break;
            }
          }
        }

      }
    }
    notifyListeners();
  }
  //TODO: returnDeviceType_HW
  String returnDeviceType_HW(String title){
    if(title == 'ORO Smart'){
      return '12';
    }else if(title == 'O-Smart-Plus'){
      return '7';
    }else if(title == 'ORO RTU'){
      return '13';
    }else if(title == 'O-RTU-Plus'){
      return '8';
    }else if(title == 'ORO Switch'){
      return '9';
    }else if(title == 'ORO Sense'){
      return '10';
    }else if(title == 'ORO Pump'){
      return '3';
    }else if(title == 'O-Pump-Plus'){
      return '4';
    }else{
      return '0';
    }
  }
  String convertStringForOutput(dynamic data){
    String myData = '';
    if(data != null){
      if(data.isNotEmpty){
        myData = '${data['sNo']},${returnDeviceType_HW(data['rtu'])},${data['rfNo']},${data['output']},1';
      }
    }
    return myData;
  }
  String convertStringForOutputHW(String title,dynamic data){
    String myData = '';
    if(data != null){
      if(data.isNotEmpty){
        myData = '${data['sNo']},${title},${returnDeviceType_HW(data['rtu'])},${refOutCheck(data['rfNo'])},${refOutCheck(data['output'])},1';
      }
    }
    return myData;
  }
  String convertStringForInput(dynamic data){
    String myData = '';
    if(data != null){
      if(data.isNotEmpty){
        myData = '${data['sNo']},${returnDeviceType_HW(data['rtu'])},${data['rfNo']},${data['input']},${data['input_type']}';
      }
    }
    return myData;
  }
  String refOutCheck(String rfandOutput){
    if(rfandOutput == '-'){
      return '0';
    }else{
      return rfandOutput;
    }
  }
  String checkInputType(String input){
    switch (input){
      case ('A-I'):{
        return '2';
      }
      case ('D-I'):{
        return '3';
      }
      case ('P-I'):{
        return '4';
      }
      case ('RS485'):{
        return '5';
      }
      case ('I2C'):{
        return '6';
      }
      default :{
        return '0';
      }
    }
  }
  String convertStringForInputHW(String title,dynamic data){
    String myData = '';
    if(data != null){
      if(data.isNotEmpty){
        myData = '${data['sNo']},${title},${returnDeviceType_HW(data['rtu'])},${refOutCheck(data['rfNo'])},${refOutCheck(data['input'])},${checkInputType(data['input_type'])}';
      }
    }
    return myData;
  }
  String insertHardwareData(String title,dynamic data,String io){
    String myData = '';
    if(data == null || data.isEmpty){
      myData = '';
    }else{
      if(io == 'output'){
        myData = '${convertStringForOutputHW(title,data)}';
      }else{
        myData = '${convertStringForInputHW(title,data)}';
      }
    }
    return myData;
  }
  String putEnd(String data){
    if(data == ''){
      return '';
    }else{
      if(data[data.length - 1] != ';'){
        return ';';
      }else{
        return '';
      }
    }
  }
  //TODO: sendData for hardware
  dynamic sendData(){
    Map<String,dynamic> configData = {
      '200' : [
        {'201' : ''},
        {'202' : ''},
        {'203' : ''},
        {'204' : ''},
        {'205' : ''},
        {'206' : ''},
      ],
    };
    if(sourcePumpUpdated.isNotEmpty){
      for(var i = 0;i < sourcePumpUpdated.length;i++){
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SP.${i+1}',sourcePumpUpdated[i]['pumpConnection'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SP.${i+1}.1',sourcePumpUpdated[i]['on'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SP.${i+1}.2',sourcePumpUpdated[i]['off'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SP.${i+1}.3',sourcePumpUpdated[i]['scr'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SP.${i+1}.4',sourcePumpUpdated[i]['ecr'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SW.${i+1}',sourcePumpUpdated[i]['waterMeter'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LS.${i+1}',sourcePumpUpdated[i]['levelSensor'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SF.${i+1}.1',sourcePumpUpdated[i]['TopTankLow'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SF.${i+1}.2',sourcePumpUpdated[i]['TopTankHigh'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SF.${i+1}.3',sourcePumpUpdated[i]['SumpTankLow'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SF.${i+1}.4',sourcePumpUpdated[i]['SumpTankHigh'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SC.${i+1}.1',sourcePumpUpdated[i]['c1'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SC.${i+1}.2',sourcePumpUpdated[i]['c2'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SC.${i+1}.3',sourcePumpUpdated[i]['c3'],'input')}' ;

      }
    }
    if(irrigationPumpUpdated.isNotEmpty){
      for(var i = 0;i < irrigationPumpUpdated.length;i++){
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IP.${i+1}',irrigationPumpUpdated[i]['pumpConnection'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IP.${i+1}.1',irrigationPumpUpdated[i]['on'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IP.${i+1}.2',irrigationPumpUpdated[i]['off'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IP.${i+1}.3',irrigationPumpUpdated[i]['scr'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IP.${i+1}.4',irrigationPumpUpdated[i]['ecr'],'output')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IW.${i+1}',irrigationPumpUpdated[i]['waterMeter'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LS.${i+1}',irrigationPumpUpdated[i]['levelSensor'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IF.${i+1}.1',irrigationPumpUpdated[i]['TopTankLow'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IF.${i+1}.2',irrigationPumpUpdated[i]['TopTankHigh'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IF.${i+1}.3',irrigationPumpUpdated[i]['SumpTankLow'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IF.${i+1}.4',irrigationPumpUpdated[i]['SumpTankHigh'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IC.${i+1}.1',irrigationPumpUpdated[i]['c1'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IC.${i+1}.2',irrigationPumpUpdated[i]['c2'],'input')}' ;
        configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('IC.${i+1}.3',irrigationPumpUpdated[i]['c3'],'input')}' ;
      }
    }
    if(centralDosingUpdated.isNotEmpty){
      for(var i = 0;i < centralDosingUpdated.length;i++){

        for(var bp = 0;bp < centralDosingUpdated[i]['boosterConnection'].length;bp++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FB.1.${i+1}.${bp + 1}',centralDosingUpdated[i]['boosterConnection'][bp],'output')}' ;
        }
        for(var inj = 0;inj < centralDosingUpdated[i]['injector'].length;inj++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FC.1.${i+1}.${inj + 1}',centralDosingUpdated[i]['injector'][inj],'output')}' ;
          if(centralDosingUpdated[i]['injector'][inj]['dosingMeter'].isNotEmpty){
            configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FM.1.${i+1}.${inj + 1}',centralDosingUpdated[i]['injector'][inj]['dosingMeter'],'input')}' ;
          }
          if(centralDosingUpdated[i]['injector'][inj]['levelSensor'].isNotEmpty){
            configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LS.1.${i+1}.${inj + 1}',centralDosingUpdated[i]['injector'][inj]['levelSensor'],'input')}' ;
          }
        }
        if(centralDosingUpdated[i]['pressureSwitch'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('PSW.1.${i+1}',centralDosingUpdated[i]['pressureSwitch'],'input')}' ;
        }
        for(var bp = 0;bp < centralDosingUpdated[i]['ecConnection'].length;bp++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('EC.1.${i+1}.${bp + 1}',centralDosingUpdated[i]['ecConnection'][bp],'input')}' ;

        }
        for(var bp = 0;bp < centralDosingUpdated[i]['phConnection'].length;bp++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('PH.1.${i+1}.${bp + 1}',centralDosingUpdated[i]['phConnection'][bp],'input')}' ;
        }
      }
    }
    if(centralFiltrationUpdated.isNotEmpty){
      for(var i = 0;i < centralFiltrationUpdated.length;i++){
        for(var fl = 0;fl < centralFiltrationUpdated[i]['filterConnection'].length;fl++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FL.1.${i+1}.${fl + 1}',centralFiltrationUpdated[i]['filterConnection'][fl],'output')}' ;
        }
        if(centralFiltrationUpdated[i]['pressureSwitch'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('PSW.1.${i+1}',centralFiltrationUpdated[i]['pressureSwitch'],'input')}' ;
        }
        if(centralFiltrationUpdated[i]['diffPressureSensor'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('DPS.1.${i+1}',centralFiltrationUpdated[i]['diffPressureSensor'],'input')}' ;
        }
        if(centralFiltrationUpdated[i]['dv'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('DV.1.${i+1}',centralFiltrationUpdated[i]['dv'],'output')}' ;

        }
        if(centralFiltrationUpdated[i]['pressureIn'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FI.1.${i+1}',centralFiltrationUpdated[i]['pressureIn'],'input')}' ;
        }
        if(centralFiltrationUpdated[i]['pressureOut'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FO.1.${i+1}',centralFiltrationUpdated[i]['pressureOut'],'input')}' ;
        }
      }
    }
    if(irrigationLines.isNotEmpty){
      for(var i = 0;i < irrigationLines.length;i++){
        for(var il = 0;il < irrigationLines[i]['valveConnection'].length;il++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('VL.${i+1}.${il + 1}',irrigationLines[i]['valveConnection'][il],'output')}' ;
        }
        for(var il = 0;il < irrigationLines[i]['main_valveConnection'].length;il++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('MV.${i+1}.${il + 1}',irrigationLines[i]['main_valveConnection'][il],'output')}' ;
        }
        for(var il = 0;il < irrigationLines[i]['moistureSensorConnection'].length;il++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('SM.${i+1}.${il + 1}',irrigationLines[i]['moistureSensorConnection'][il],'input')}' ;
        }
        for(var il = 0;il < irrigationLines[i]['levelSensorConnection'].length;il++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LV.${i+1}.${il + 1}',irrigationLines[i]['levelSensorConnection'][il],'input')}' ;
        }
        for(var il = 0;il < irrigationLines[i]['foggerConnection'].length;il++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FG.${i+1}.${il + 1}',irrigationLines[i]['foggerConnection'][il],'output')}' ;
        }
        for(var il = 0;il < irrigationLines[i]['fanConnection'].length;il++){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FN.${i+1}.${il + 1}',irrigationLines[i]['fanConnection'][il],'output')}' ;
        }
        if(irrigationLines[i]['pressureIn'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LI.${i+1}',irrigationLines[i]['pressureIn'],'input')}' ;
        }
        if(irrigationLines[i]['pressureOut'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LO.${i+1}',irrigationLines[i]['pressureOut'],'input')}' ;
        }
        if(irrigationLines[i]['water_meter'].isNotEmpty){
          configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LW.${i+1}',irrigationLines[i]['water_meter'],'input')}' ;
        }
        if(irrigationLines[i]['Local_dosing_site'] == true){
          for(var ld = 0; ld < localDosingUpdated.length;ld++){
            if(localDosingUpdated[ld]['sNo'] == irrigationLines[i]['sNo']){
              for(var bp = 0;bp < localDosingUpdated[ld]['boosterConnection'].length;bp++){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FB.2.${i+1}.${bp + 1}',localDosingUpdated[ld]['boosterConnection'][bp],'output')}' ;
              }
              for(var inj = 0;inj < localDosingUpdated[ld]['injector'].length;inj++){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FC.2.${i+1}.${inj + 1}',localDosingUpdated[ld]['injector'][inj],'output')}' ;
                if(localDosingUpdated[ld]['injector'][inj]['dosingMeter'].isNotEmpty){
                  configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FM.2.${i+1}.${inj + 1}',localDosingUpdated[ld]['injector'][inj]['dosingMeter'],'input')}' ;
                }
                if(localDosingUpdated[i]['injector'][inj]['levelSensor'].isNotEmpty){
                  configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('LS.2.${i+1}.${inj + 1}',localDosingUpdated[i]['injector'][inj]['levelSensor'],'input')}' ;
                }
              }
              if(localDosingUpdated[i]['pressureSwitch'].isNotEmpty){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('PSW.2.${i+1}',localDosingUpdated[i]['pressureSwitch'],'input')}' ;
              }
              for(var bp = 0;bp < localDosingUpdated[ld]['ecConnection'].length;bp++){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('EC.2.${i+1}.${bp + 1}',localDosingUpdated[ld]['ecConnection'][bp],'input')}' ;

              }
              for(var bp = 0;bp < localDosingUpdated[ld]['phConnection'].length;bp++){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('PH.2.${i+1}.${bp + 1}',localDosingUpdated[ld]['phConnection'][bp],'input')}' ;
              }
            }
          }
        }
        if(irrigationLines[i]['local_filtration_site'] == true){
          for(var lf = 0; lf < localFiltrationUpdated.length;lf++){
            if(localFiltrationUpdated[lf]['sNo'] == irrigationLines[i]['sNo']){
              for(var fl = 0;fl < localFiltrationUpdated[lf]['filterConnection'].length;fl++){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FL.2.${i+1}.${fl + 1}',localFiltrationUpdated[lf]['filterConnection'][fl],'output')}' ;
              }
              if(localFiltrationUpdated[i]['pressureSwitch'].isNotEmpty){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('PSW.2.${i+1}',localFiltrationUpdated[i]['pressureSwitch'],'input')}' ;
              }
              if(localFiltrationUpdated[i]['diffPressureSensor'].isNotEmpty){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('DPS.2.${i+1}',localFiltrationUpdated[i]['diffPressureSensor'],'input')}' ;
              }
              if(localFiltrationUpdated[lf]['dv'].isNotEmpty){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('DV.2.${i+1}',localFiltrationUpdated[lf]['dv'],'output')}' ;

              }
              if(localFiltrationUpdated[lf]['pressureIn'].isNotEmpty){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FI.2.${i+1}',localFiltrationUpdated[lf]['pressureIn'],'input')}' ;
              }
              if(localFiltrationUpdated[lf]['pressureOut'].isNotEmpty){
                configData['200'][5]['206'] += '${putEnd(configData['200'][5]['206'])}${insertHardwareData('FO.2.${i+1}',localFiltrationUpdated[lf]['pressureOut'],'input')}' ;
              }
            }
          }
        }
      }
    }

    return configData;
  }

  dynamic changeOutputPayload(String data){
    var split = data.split(',');
    return {
      'sNo' : int.parse(split[0]),
      'rtu' : split[1],
      'rfNo' : split[2],
      'output' : split[3],
    };
  }
  dynamic changeInputPayload(String data){
    var split = data.split(',');
    return {
      'sNo' : int.parse(split[0]),
      'rtu' : split[1],
      'rfNo' : split[2],
      'input' : split[3],
      'input_type' : split[4],
    };
  }
  //TODO: sendData for hardware
  void fetchFromServer(){
    isNew = false;
    oWeather = oldData['productLimit']['oWeather'];
    oRoWeatherForStation = oldData['productLimit']['oRoWeatherForStation'];
    totalTempSensor = oldData['productLimit']['totalTempSensor'];
    connTempSensor = oldData['productLimit']['connTempSensor'];
    totalSoilTempSensor = oldData['productLimit']['totalSoilTempSensor'];
    connSoilTempSensor = oldData['productLimit']['connSoilTempSensor'];
    totalHumidity = oldData['productLimit']['totalHumidity'];
    connHumidity = oldData['productLimit']['connHumidity'];
    totalCo2 = oldData['productLimit']['totalCo2'];
    connCo2 = oldData['productLimit']['connCo2'];
    totalLux = oldData['productLimit']['totalLux'];
    connLux = oldData['productLimit']['connLux'];
    totalLdr = oldData['productLimit']['totalLdr'];
    connLdr = oldData['productLimit']['connLdr'];
    totalWindSpeed = oldData['productLimit']['totalWindSpeed'];
    connWindSpeed = oldData['productLimit']['connWindSpeed'];
    totalWindDirection = oldData['productLimit']['totalWindDirection'];
    connWindDirection = oldData['productLimit']['connWindDirection'];
    totalRainGauge = oldData['productLimit']['totalRainGauge'];
    connRainGauge = oldData['productLimit']['connRainGauge'];
    totalLeafWetness = oldData['productLimit']['totalLeafWetness'];
    connLeafWetness = oldData['productLimit']['connLeafWetness'];
    totalPressureSwitch = oldData['productLimit']['totalPressureSwitch'];
    totalDiffPressureSensor = oldData['productLimit']['totalDiffPressureSensor'];
    totalWaterSource = oldData['productLimit']['totalWaterSource'];
    totalWaterMeter = oldData['productLimit']['totalWaterMeter'];
    totalSourcePump = oldData['productLimit']['totalSourcePump'];
    totalIrrigationPump = oldData['productLimit']['totalIrrigationPump'];
    totalInjector = oldData['productLimit']['totalIrrigationPump'];
    totalDosingMeter = oldData['productLimit']['totalDosingMeter'];
    totalBooster = oldData['productLimit']['totalBooster'];
    totalCentralDosing = oldData['productLimit']['totalCentralDosing'];
    totalFilter = oldData['productLimit']['totalFilter'];
    total_D_s_valve = oldData['productLimit']['total_D_s_valve'];
    total_p_sensor = oldData['productLimit']['total_p_sensor'];
    totalCentralFiltration = oldData['productLimit']['totalCentralFiltration'];
    totalValve = oldData['productLimit']['totalValve'];
    totalMainValve = oldData['productLimit']['totalMainValve'];
    totalIrrigationLine = oldData['productLimit']['totalIrrigationLine'];
    totalLocalFiltration = oldData['productLimit']['totalLocalFiltration'];
    totalLocalDosing = oldData['productLimit']['totalLocalDosing'];
    totalRTU = oldData['productLimit']['totalRTU'];
    totalRtuPlus = oldData['productLimit']['totalRtuPlus'];
    totalOroSwitch = oldData['productLimit']['totalOroSwitch'];
    totalOroSense = oldData['productLimit']['totalOroSense'];
    totalOroSmartRTU = oldData['productLimit']['totalOroSmartRTU'];
    totalOroSmartRtuPlus = oldData['productLimit']['totalOroSmartRtuPlus'];
    totalOroLevel = oldData['productLimit']['totalOroLevel'];
    totalOroPump = oldData['productLimit']['totalOroPump'];
    totalOroExtend = oldData['productLimit']['totalOroExtend'];
    i_o_types = oldData['productLimit']['i_o_types'];
    totalAnalogSensor = oldData['productLimit']['totalAnalogSensor'];
    totalContact = oldData['productLimit']['totalContact'];
    totalAgitator = oldData['productLimit']['totalAgitator'];
    totalSelector = oldData['productLimit']['totalSelector'];
    totalPhSensor = oldData['productLimit']['totalPhSensor'];
    totalEcSensor = oldData['productLimit']['totalEcSensor'];
    totalMoistureSensor = oldData['productLimit']['totalMoistureSensor'];
    totalLevelSensor = oldData['productLimit']['totalLevelSensor'];
    totalFan = oldData['productLimit']['totalFan'];
    totalFogger = oldData['productLimit']['totalFogger'];
    oRtu = oldData['productLimit']['oRtu'];
    oRtuPlus = oldData['productLimit']['oRtuPlus'];
    oSrtu = oldData['productLimit']['oSrtu'];
    oSrtuPlus = oldData['productLimit']['oSrtuPlus'];
    oSwitch = oldData['productLimit']['oSwitch'];
    oSense = oldData['productLimit']['oSense'];
    oLevel = oldData['productLimit']['oLevel'];
    oPump = oldData['productLimit']['oPump'];
    oPumpPlus = oldData['productLimit']['oPumpPlus'];
    oExtend = oldData['productLimit']['oExtend'];
    rtuForLine = oldData['productLimit']['rtuForLine'];
    rtuPlusForLine = oldData['productLimit']['rtuPlusForLine'];
    OroExtendForLine = oldData['productLimit']['OroExtendForLine'];
    switchForLine = oldData['productLimit']['switchForLine'];
    OroSmartRtuForLine = oldData['productLimit']['OroSmartRtuForLine'];
    OroSmartRtuPlusForLine = oldData['productLimit']['OroSmartRtuPlusForLine'];
    OroSenseForLine = oldData['productLimit']['OroSenseForLine'];
    OroLevelForLine = oldData['productLimit']['OroLevelForLine'];
    waterSource = oldData['productLimit']['waterSource'];
    weatherStation = oldData['productLimit']['weatherStation'];
    central_dosing_site_list = oldData['productLimit']['central_dosing_site_list'];
    central_filtration_site_list = oldData['productLimit']['central_filtration_site_list'];
    irrigation_pump_list = oldData['productLimit']['irrigation_pump_list'];
    water_source_list = oldData['productLimit']['water_source_list'];
    I_O_autoIncrement = oldData['productLimit']['I_O_autoIncrement'];
    sourcePumpUpdated = oldData['sourcePump'];
    irrigationPumpUpdated = oldData['irrigationPump'];
    centralDosingUpdated = oldData['centralFertilizer'];
    centralFiltrationUpdated = oldData['centralFilter'];
    irrigationLines = oldData['irrigationLine'];
    localDosingUpdated = oldData['localFertilizer'];
    localFiltrationUpdated = oldData['localFilter'];
    notifyListeners();
  }
  String spName = 'Source Pump';
  String spId = 'SP';
  String spwmName = 'Water Meter SP';
  String spwmId = 'WMSP';
  String ipName = 'Irrigation Pump';
  String ipId = 'IP';
  String ipwmName = 'Water Meter IP';
  String ipwmId = 'WMIP';
  String cdName = 'Central Fertilizer Site';
  String cdId = 'CFESI';
  String cdInjName = 'Central Fertilizer Injector';
  String cdInjId = 'CFEI';
  String cdDmName = 'Central Fertilizer Meter';
  String cdDmId = 'CFEFM';
  String cdEcName = 'EC Sensor CFESI';
  String cdEcId = 'ECSCFESI';
  String cdPhName = 'PH Sensor CFESI';
  String cdPhId = 'PHSCFESI';
  String cfName = 'Central Filtration Site';
  String cfId = 'CFISI';
  String cflName = 'Central Filter';
  String cflId = 'CFI';
  String cfPiName = 'Pressure Sensor In CFISI';
  String cfPiId = 'PSICFISI';
  String cfPoName = 'Pressure Sensor Out CFISI';
  String cfPoId = 'PSOCFISI';
  String ilName = 'Irrigation Line';
  String ilId = 'IL';
  String ilvName = 'Valve';
  String ilvId = 'VL';
  String ilMvName = 'Main Valve';
  String ilMvId = 'MVL';
  String ilMsName = 'Moisture Sensor';
  String ilMsId = 'MS';
  String ilLsName = 'Level Sensor';
  String ilLsId = 'LS';
  String ilFgName = 'Fogger';
  String ilFgId = 'FG';
  String ilFnName = 'Fan';
  String ilFnId = 'FAN';
  String ilPiName = 'Pressure Sensor In IL';
  String ilPiId = 'PSIIL';
  String ilPoName = 'Pressure Sensor Out IL';
  String ilPoId = 'PSOIL';
  String ilwmName = 'Water Meter IL';
  String ilwmId = 'WMIL';
  String ldInjName = 'Local Fertilizer Injector';
  String ldInjId = 'LFEI';
  String ldDmName = 'Local Fertilizer Meter';
  String ldDmId = 'LFEM';
  String ldEcName = 'EC Sensor IL';
  String ldEcId = 'ECSIL';
  String ldPhName = 'PH Sensor IL';
  String ldPhId = 'PHSIL';
  String lflName = 'Local Filter';
  String lflId = 'LFI';
  String lfPiName = 'Pressure Sensor In LFI';
  String lfPiId = 'PSILFI';
  String lfPoName = 'Pressure Sensor Out LFI';
  String lfPoId = 'PSOLFI';
  String asId = 'AS';
  String asName = 'Analog Sensor';
  String ctId = 'CONT';
  String ctName = 'Contact';
  String agId = 'AG';
  String agName = 'Agitator';
  String wsId = 'WS';
  String wsName = 'Water Source';
  //TODO: generating names
  dynamic configFinish(){
    Map<String,dynamic> name = {
      'SP' : [],
      'IP' : [],
      'WM' : [],
      'CFESI' : [],
      'CFEI' : [],
      'LFEI' : [],
      'CFEM' : [],
      'LFEM' : [],
      'ECS' : [],
      'PHS' : [],
      'CFISI' : [],
      'CFI' : [],
      'LFI' : [],
      'PS' : [],
      'IL' : [],
      'VL' : [],
      'MVL' : [],
      'MS' : [],
      'LS' : [],
      'FOG' : [],
      'FAN' : [],
      'OROSEN' : [],
      'OROLVL' : [],
      'AS' : [],
      'CONT' : [],
      'AG' : [],
      'WS' : [],
    };
    name['WS'] = totalWaterSource;
    for(var as = 0;as < totalAnalogSensor.length;as++){
      name['AS'].add({
        'sNo' : totalAnalogSensor[as]['sNo'],
        'id' : '$asId${as+1}',
        'name' : isNew == true ? '$asName ${as+1}' : names['${totalAnalogSensor[as]['sNo']}'] ?? '$asName ${as+1}',
        'location' : '',
      });
    }
    for(var ag = 0;ag < totalAgitator.length;ag++){
      name['AG'].add({
        'sNo' : totalAgitator[ag]['sNo'],
        'id' : '$agId${ag+1}',
        'name' : isNew == true ? '$agName ${ag+1}' : names['${totalAgitator[ag]['sNo']}'] ?? '$agName ${ag+1}',
        'location' : '',
      });
    }
    for(var cnt = 0;cnt < totalContact.length;cnt++){
      name['CONT'].add({
        'sNo' : totalContact[cnt]['sNo'],
        'id' : '$ctId${cnt+1}',
        'name' : isNew == true ? '$ctName ${cnt+1}' : names['${totalContact[cnt]['sNo']}'] ?? '$ctName ${cnt+1}',
        'location' : '',
      });
    }
    for(var i = 0 ;i < sourcePumpUpdated.length;i++){
      name['SP'].add({
        'sNo' : sourcePumpUpdated[i]['sNo'],
        'id' : '$spId${i+1}',
        'name' : isNew == true ? '$spName ${i+1}' : names['${sourcePumpUpdated[i]['sNo']}'] ?? '$spName ${i+1}',
        'location' : '',
      });
      if(sourcePumpUpdated[i]['waterMeter'].isNotEmpty){
        name['WM'].add({
          'sNo' : sourcePumpUpdated[i]['waterMeter']['sNo'],
          'id' : '$spwmId${i+1}',
          'name' : isNew == true ? '$spwmName${i+1}' : names['${sourcePumpUpdated[i]['waterMeter']['sNo']}'] ?? '$spwmName${i+1}',
          'location' : '${spId}${i+1}',
        });
      }
    }
    for(var i = 0 ;i < irrigationPumpUpdated.length;i++){
      var location = '';
      for(var irr = 0;irr < irrigationLines.length;irr++){
        if(irrigationLines[irr]['irrigationPump'] == '${i+1}'){
          location += '${location.length != 0 ? '&' : ''}IL${irr+1}';

        }
      }
      name['IP'].add({
        'sNo' : irrigationPumpUpdated[i]['sNo'],
        'id' : '$ipId${i+1}',
        'name' : isNew == true ? '$ipName ${i+1}' : names['${irrigationPumpUpdated[i]['sNo']}'] ?? '$ipName ${i+1}',
        'location' : location,
      });
      if(irrigationPumpUpdated[i]['waterMeter'].isNotEmpty){
        name['WM'].add({
          'sNo' : irrigationPumpUpdated[i]['waterMeter']['sNo'],
          'id' : '$ipwmId${i+1}',
          'name' : isNew == true ? '$ipwmName${i+1}' : names['${irrigationPumpUpdated[i]['waterMeter']['sNo']}'] ?? '$ipwmName${i+1}',
          'location' : '$ipId${i+1}',
        });
      }
    }
    for(var i = 0; i < centralDosingUpdated.length;i++){
      var location = '';
      for(var irr = 0;irr < irrigationLines.length;irr++){
        if(irrigationLines[irr]['Central_dosing_site'] == '${i+1}'){
          location += '${location.isNotEmpty ? '&' : ''}IL${irr+1}';
        }
      }
      name['CFESI'].add({
        'sNo' : centralDosingUpdated[i]['sNo'],
        'id' : '${cdId}${i+1}',
        'name' : isNew == true ? '$cdName ${i+1}' : names['${centralDosingUpdated[i]['sNo']}'] ?? '$cdName ${i+1}',
        'location' : location,
      });
      for(var j = 0;j < centralDosingUpdated[i]['injector'].length;j++){
        name['CFEI'].add({
          'sNo' : centralDosingUpdated[i]['injector'][j]['sNo'],
          'id' : '$cdInjId${i+1}.${j+1}',
          'name' : isNew == true ? '$cdInjName ${i+1}.${j+1}' : names['${centralDosingUpdated[i]['injector'][j]['sNo']}'] ?? '$cdInjName ${i+1}.${j+1}',
          'location' : '$cdId${i+1}',
        });
        if(centralDosingUpdated[i]['injector'][j]['dosingMeter'].isNotEmpty){
          name['CFEM'].add({
            'sNo' : centralDosingUpdated[i]['injector'][j]['dosingMeter']['sNo'],
            'id' : '$cdDmId${i+1}.${j+1}',
            'name' : isNew == true ? '$cdDmName ${i+1}.${j+1}' : names['${centralDosingUpdated[i]['injector'][j]['dosingMeter']['sNo']}'] ?? '$cdDmName ${i+1}.${j+1}',
            'location' : '$cdInjId${i+1}.${j+1}',
          });
        }
      }
      for(var j = 0;j < centralDosingUpdated[i]['ecConnection'].length;j++){
        if(centralDosingUpdated[i]['ecConnection'][j].isNotEmpty){
          name['ECS'].add({
            'sNo' : centralDosingUpdated[i]['ecConnection'][j]['sNo'],
            'id' : '$cdEcId${i+1}.${j+1}',
            'name' : isNew == true ? '$cdEcName ${i+1}.${j+1}' : names['${centralDosingUpdated[i]['ecConnection'][j]['sNo']}'] ?? '$cdEcName ${i+1}.${j+1}',
            'location' : '$cdId${i+1}',
          });
        }
      }
      for(var j = 0;j < centralDosingUpdated[i]['phConnection'].length;j++){
        if(centralDosingUpdated[i]['phConnection'][j].isNotEmpty){
          name['PHS'].add({
            'sNo' : centralDosingUpdated[i]['phConnection'][j]['sNo'],
            'id' : '$cdPhId${i+1}.${j+1}',
            'name' : isNew == true ? '$cdPhName ${i+1}.${j+1}' : names['${centralDosingUpdated[i]['phConnection'][j]['sNo']}'] ?? '$cdPhName ${i+1}.${j+1}',
            'location' : '$cdId${i+1}',
          });

        }
      }
    }
    for(var i = 0; i < centralFiltrationUpdated.length;i++){
      centralFiltrationUpdated[i]['id'] = '${cfId}${i+1}';
      centralFiltrationUpdated[i]['name'] = '${cfName}${i+1}';
      var location = '';
      for(var irr = 0;irr < irrigationLines.length;irr++){
        if(irrigationLines[irr]['Central_filtration_site'] == '${i+1}'){
          location += '${location.length != 0 ? '&' : ''}IL${irr + 1}';
        }
      }
      name['CFISI'].add({
        'sNo' : centralFiltrationUpdated[i]['sNo'],
        'id' : '$cfId${i+1}',
        'name' : isNew == true ? '$cfName ${i+1}' : names['${centralFiltrationUpdated[i]['sNo']}'] ?? '$cfName ${i+1}',
        'location' : location,
      });
      for(var j = 0;j < centralFiltrationUpdated[i]['filterConnection'].length;j++){
        name['CFI'].add({
          'sNo' : centralFiltrationUpdated[i]['filterConnection'][j]['sNo'],
          'id' : '$cflId${i+1}.${j+1}',
          'name' : isNew == true ? '$cflName ${i+1}.${j+1}' : names['${centralFiltrationUpdated[i]['filterConnection'][j]['sNo']}'] ?? '$cflName ${i+1}.${j+1}',
          'location' : '$cfId${i+1}',
        });
      }
      if(centralFiltrationUpdated[i]['pressureIn'].isNotEmpty){
        name['PS'].add({
          'sNo' : centralFiltrationUpdated[i]['pressureIn']['sNo'],
          'id' : '${cfPiId}${i+1}.1',
          'name' : isNew == true ? '$cfPiName ${i+1}.1' : names['${centralFiltrationUpdated[i]['pressureIn']['sNo']}'] ?? '$cfPiName ${i+1}.1',
          'location' : '$cfId${i+1}',
        });
      }
      if(centralFiltrationUpdated[i]['pressureOut'].isNotEmpty){
        name['PS'].add({
          'sNo' : centralFiltrationUpdated[i]['pressureOut']['sNo'],
          'id' : '${cfPoId}${i+1}.1',
          'name' : isNew == true ? '$cfPoName ${i+1}.1' : names['${centralFiltrationUpdated[i]['pressureOut']['sNo']}'] ?? '$cfPoName ${i+1}.1',
          'location' : '$cfId${i+1}',
        });
      }
    }
    for(var i = 0;i < irrigationLines.length;i++){
      name['IL'].add({
        'sNo' : irrigationLines[i]['sNo'],
        'id' : '$ilId${i+1}',
        'name' : isNew == true ? '$ilName ${i+1}' : names['${irrigationLines[i]['sNo']}'] ?? '$ilName ${i+1}',
        'location' : '',
      });
      for(var j = 0;j < irrigationLines[i]['valveConnection'].length;j++){
        name['VL'].add({
          'sNo' : irrigationLines[i]['valveConnection'][j]['sNo'],
          'id' : '$ilvId${i+1}.${j+1}',
          'name' : isNew == true ? '$ilvName ${i+1}.${j+1}' : names['${irrigationLines[i]['valveConnection'][j]['sNo']}'] ?? '$ilvName ${i+1}.${j+1}',
          'location' : '${ilId}${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['main_valveConnection'].length;j++){
        name['MVL'].add({
          'sNo' : irrigationLines[i]['main_valveConnection'][j]['sNo'],
          'id' : '$ilMvId${i+1}.${j+1}',
          'name' : isNew == true ? '$ilMvName ${i+1}.${j+1}' : names['${irrigationLines[i]['main_valveConnection'][j]['sNo']}'] ?? '$ilMvName ${i+1}.${j+1}',
          'location' : '$ilId${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['moistureSensorConnection'].length;j++){
        name['MS'].add({
          'sNo' : irrigationLines[i]['moistureSensorConnection'][j]['sNo'],
          'id' : '$ilMsId${i+1}.${j+1}',
          'name' : isNew == true ? '$ilMsName ${i+1}.${j+1}' : names['${irrigationLines[i]['moistureSensorConnection'][j]['sNo']}'] ?? '$ilMsName ${i+1}.${j+1}',
          'location' : '$ilId${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['levelSensorConnection'].length;j++){
        name['LS'].add({
          'sNo' : irrigationLines[i]['levelSensorConnection'][j]['sNo'],
          'id' : '$ilLsId${i+1}.${j+1}',
          'name' : isNew == true ? '$ilLsName ${i+1}.${j+1}' : names['${irrigationLines[i]['levelSensorConnection'][j]['sNo']}'] ?? '$ilLsName ${i+1}.${j+1}',
          'location' : '$ilId${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['foggerConnection'].length;j++){
        name['FOG'].add({
          'sNo' : irrigationLines[i]['foggerConnection'][j]['sNo'],
          'id' : '$ilFgId${i+1}.${j+1}',
          'name' : isNew == true ? '$ilFgName ${i+1}.${j+1}' : names['${irrigationLines[i]['foggerConnection'][j]['sNo']}'] ?? '$ilFgName ${i+1}.${j+1}',
          'location' : '$ilId${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['fanConnection'].length;j++){
        name['FAN'].add({
          'sNo' : irrigationLines[i]['fanConnection'][j]['sNo'],
          'id' : '$ilFnId${i+1}.${j+1}',
          'name' : isNew == true ? '$ilFnName ${i+1}.${j+1}' : names['${irrigationLines[i]['fanConnection'][j]['sNo']}'] ?? '$ilFnName ${i+1}.${j+1}',
          'location' : '${ilId}${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['myOROsense'].length;j++){
        var sNo = returnI_O_AutoIncrement();
        name['OROSEN'].add({
          'sNo' : sNo,
          'id' : 'MSIL${i+1}.${j+1}',
          'name' : isNew == true ? 'Moisture ${i+1}.${j+1}' : names['${sNo}'] ?? 'Moisture ${i+1}.${j+1}',
          'location' : '$ilId${i+1}',
        });
      }
      for(var j = 0;j < irrigationLines[i]['myOROlevel'].length;j++){
        var sNo = returnI_O_AutoIncrement();
        name['OROLVL'].add({
          'sNo' : sNo,
          'id' : 'LSIL${i+1}.${j+1}',
          'name' : isNew == true ? 'Level ${i+1}.${j+1}' : names['$sNo'] ?? 'Level ${i+1}.${j+1}',
          'location' : '$ilId${i+1}',
        });
      }
      if(irrigationLines[i]['pressureIn'].isNotEmpty){
        name['PS'].add({
          'sNo' : irrigationLines[i]['pressureIn']['sNo'],
          'id' : '$ilPiId${i+1}.1',
          'name' : isNew == true ? '$ilPiName ${i+1}.1' : names['${irrigationLines[i]['pressureIn']['sNo']}'] ?? '$ilPiName ${i+1}.1',
          'location' : '$ilId${i+1}',
        });
      }
      if(irrigationLines[i]['pressureOut'].isNotEmpty){
        name['PS'].add({
          'sNo' : irrigationLines[i]['pressureOut']['sNo'],
          'id' : '$ilPoId${i+1}.1',
          'name' : isNew == true ? '$ilPoName ${i+1}.1' : names['${irrigationLines[i]['pressureOut']['sNo']}'] ?? '$ilPoName ${i+1}.1',
          'location' : '$ilId${i+1}',
        });
      }
      if(irrigationLines[i]['water_meter'].isNotEmpty){
        name['WM'].add({
          'sNo' : irrigationLines[i]['water_meter']['sNo'],
          'id' : '$ilwmId${i+1}.1',
          'name' : isNew == true ? '$ilwmName ${i+1}.1' : names['${irrigationLines[i]['water_meter']['sNo']}'] ?? '$ilwmName ${i+1}.1',
          'location' : '$ilId${i+1}',
        });
      }
      if(irrigationLines[i]['Local_dosing_site'] == true){
        for(var ld in localDosingUpdated){
          if(ld['sNo'] == irrigationLines[i]['sNo']){
            for(var j = 0;j < ld['injector'].length;j++){
              name['LFEI'].add({
                'sNo' : ld['injector'][j]['sNo'],
                'id' : '$ldInjId${i+1}.${j+1}',
                'name' : isNew == true ? '$ldInjName ${i+1}.${j+1}' : names['${ld['injector'][j]['sNo']}'] ?? '$ldInjName ${i+1}.${j+1}',
                'location' : '$ilId${i+1}',
              });
              if(ld['injector'][j]['dosingMeter'].isNotEmpty){
                name['LFEM'].add({
                  'sNo' : ld['injector'][j]['dosingMeter']['sNo'],
                  'id' : '$ldDmId${i+1}.${j+1}',
                  'name' : isNew == true ? '$ldDmName ${i+1}.${j+1}' : names['${ld['injector'][j]['dosingMeter']['sNo']}'] ?? '$ldDmName ${i+1}.${j+1}',
                  'location' : '$ldInjId${i+1}.${j+1}',
                });
              }
            }
            for(var j = 0;j < ld['ecConnection'].length;j++){
              if(ld['ecConnection'][j].isNotEmpty){
                name['ECS'].add({
                  'sNo' : ld['ecConnection'][j]['sNo'],
                  'id' : '$ldEcId${i+1}.${j+1}',
                  'name' : isNew == true ? '$ldEcName ${i+1}.${j+1}' : names['${ld['ecConnection'][j]['sNo']}'] ?? '$ldEcName ${i+1}.${j+1}',
                  'location' : '$ilId${i+1}',
                });
              }
            }
            for(var j = 0;j < ld['phConnection'].length;j++){
              if(ld['phConnection'][j].isNotEmpty){
                name['PHS'].add({
                  'sNo' : ld['phConnection'][j]['sNo'],
                  'id' : '$ldPhId${i+1}.${j+1}',
                  'name' : isNew == true ? '$ldPhName ${i+1}.${j+1}' : names['${ld['phConnection'][j]['sNo']}'] ?? '$ldPhName ${i+1}.${j+1}',
                  'location' : '$ilId${i+1}',
                });

              }
            }
          }
        }
      }
      if(irrigationLines[i]['local_filtration_site'] == true){
        for(var lf in localFiltrationUpdated){
          if(lf['sNo'] == irrigationLines[i]['sNo']){
            for(var j = 0;j < lf['filterConnection'].length;j++){
              name['LFI'].add({
                'sNo' : lf['filterConnection'][j]['sNo'],
                'id' : '$lflId${i+1}.${j+1}',
                'name' : isNew == true ? '$lflName ${i+1}.${j+1}' : names['${lf['filterConnection'][j]['sNo']}'] ?? '$lflName ${i+1}.${j+1}',
                'location' : '$ilId${i+1}',
              });
            }
            if(lf['pressureIn'].isNotEmpty){
              name['PS'].add({
                'sNo' : lf['pressureIn']['sNo'],
                'id' : '$lfPiId${i+1}.1',
                'name' : isNew == true ? '$lfPiName ${i+1}.1' : names['${lf['pressureIn']['sNo']}'] ?? '$lfPiName ${i+1}.1',
                'location' : '$ilId${i+1}',
              });
            }
            if(lf['pressureOut'].isNotEmpty){
              name['PS'].add({
                'sNo' : lf['pressureOut']['sNo'],
                'id' : '$lfPoId${i+1}.1',
                'name' : isNew == true ? '$lfPoName ${i+1}.1' : names['${lf['pressureOut']['sNo']}'] ?? '$lfPoName ${i+1}.1',
                'location' : '$ilId${i+1}',
              });
            }
          }
        }
      }
    }
    notifyListeners();

    print('namesuu : ${jsonEncode(name)}');
    return name;
  }
}