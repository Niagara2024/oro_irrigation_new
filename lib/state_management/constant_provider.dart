import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConstantProvider extends ChangeNotifier{
  List<String> myTabs = ['General','Lines','Main valve','Valve','Water meter','Fertilizers','Filters','Analog sensor'];
  List<List<dynamic>> general = [['Reset time','00:00',Icon(Icons.restart_alt),'time'],['Fertilizer leakage limit','20',Icon(Icons.production_quantity_limits),'numbers'],['Run list limit','10',Icon(Icons.list)],['Current irrigation day','1',Icon(Icons.today),'numbers'],['No pressure delay','00:00',Icon(Icons.timelapse_outlined),'time'],['Water pulse before dosing','Yes',Icon(Icons.navigate_before),'yes/no'],['Common dosing coefficient','100%',Icon(Icons.percent),'percentage']];
  int selected = -1;
  dynamic APIdata = {};
  dynamic APIpump = ['IP1','IP2','IP3','IP4','IP5'];
  List<dynamic>  irrigationLines = [
    ['Line 1','1','IP1','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 2','2','IP2','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 3','3','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 4','4','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 5','5','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 6','6','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 7','7','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 8','8','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 9','9','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 10','10','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 11','11','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
    ['Line 12','12','IP3','00:00:00','00:00:00','IGNORE','IGNORE','10'],
  ];
  
  List<dynamic>  mainValve = [
    ['Main Valve 1','1','1','NO DELAY','00:00'],
    ['Main Valve 2','2','1','NO DELAY','00:00'],
    ['Main Valve 3','3','1','NO DELAY','00:00'],
    ['Main Valve 4','4','1','NO DELAY','00:00'],
    ['Main Valve 5','5','2','NO DELAY','00:00'],
    ['Main Valve 6','6','2','NO DELAY','00:00'],
    ['Main Valve 7','7','2','NO DELAY','00:00'],
    ['Main Valve 8','8','3','NO DELAY','00:00'],
    ['Main Valve 9','9','3','NO DELAY','00:00'],
    ['Main Valve 10','10','3','NO DELAY','00:00'],
    ['Main Valve 11','11','3','NO DELAY','00:00'],
    ['Main Valve 12','12','3','NO DELAY','00:00'],
    ['Main Valve 12','12','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
    ['Main Valve 13','13','3','NO DELAY','00:00'],
  ];
  List<dynamic> valve = [
    {
      '1' : [
        ['1','1','valve 1','00:00:00','100','75','125','15','1.00','100'],
        ['2','2','valve 2','00:00:00','100','75','125','15','1.00','100'],
        ['3','3','valve 3','00:00:00','100','75','125','15','1.00','100'],
        ['4','4','valve 4','00:00:00','100','75','125','15','1.00','100'],
        ['5','5','valve 5','00:00:00','100','75','125','15','1.00','100'],
        ['6','6','valve 6','00:00:00','100','75','125','15','1.00','100'],
        ['7','7','valve 7','00:00:00','100','75','125','15','1.00','100'],
        ['8','8','valve 8','00:00:00','100','75','125','15','1.00','100'],
      ]
    },
    {
      '2' : [
        ['1','1','valve 1','00:00:00','100','75','125','15','1.00','100'],
        ['2','2','valve 2','00:00:00','100','75','125','15','1.00','100'],
        ['3','3','valve 3','00:00:00','100','75','125','15','1.00','100'],
        ['4','4','valve 4','00:00:00','100','75','125','15','1.00','100'],
        ['5','5','valve 5','00:00:00','100','75','125','15','1.00','100'],
        ['6','6','valve 6','00:00:00','100','75','125','15','1.00','100'],
        ['7','7','valve 7','00:00:00','100','75','125','15','1.00','100'],
        ['8','8','valve 8','00:00:00','100','75','125','15','1.00','100'],
      ]
    },
  ];


  List<dynamic>  waterMeter = [
    ['1','Line 1','water meter 1','100','1000'],
    ['2','Line 2','water meter 2','100','1000'],
    ['3','Line 3','water meter 3','100','1000'],
    ['4','Line 4','water meter 4','100','1000'],
    ['5','Line 5','water meter 5','100','1000'],
    ['6','IP 1','water meter 6','100','1000'],
    ['7','IP 2','water meter 7','100','1000'],
    ['8','IP 3','water meter 8','100','1000'],
    ['9','SP 1','water meter 9','100','1000'],
    ['10','SP 2','water meter 10','100','1000'],
  ];

  List<dynamic> fertilizer = [
    ['central fertilizer 1','1,2,3','STOP FAULTY FERTILIZER',[['fert 1','CF1 fert1','yes','100','20','400','REGULAR'],['fert 2','CF1 fert2','yes','100','20','400','REGULAR'],['fert 3','CF1 fert3','yes','100','20','400','REGULAR']]],
    ['central fertilizer 2','1,2,3','INFORM ONLY',[['fert 1','CF2 fert1','yes','100','20','400','REGULAR'],['fert 2','CF2 fert2','yes','100','20','400','REGULAR'],['fert 3','CF2 fert3','yes','100','20','400','REGULAR']]]
  ];
  String dropDownValue = 'Stop Irrigation';
  void editDropDownValue(String val){
    dropDownValue = val;
    notifyListeners();
  }

  List<dynamic>  filter = [
    ['CF 1','Central filtration 1','1,2,3','30','99','NO FERTILIZATION'],
    ['CF 2','Central filtration 2','1,2,3','30','99','NO FERTILIZATION'],
    ['CF 3','Central filtration 3','1,2,3','30','99','NO FERTILIZATION'],
    ['CF 4','Central filtration 4','1,2,3','30','99','NO FERTILIZATION'],
    ['LF 1','Local filtration 1','1','30','99','NO FERTILIZATION'],
    ['LF 2','Local filtration 2','2','30','99','NO FERTILIZATION'],
    ['LF 3','Local filtration 3','3','30','99','NO FERTILIZATION'],
    ['LF 4','Local filtration 4','4','30','99','NO FERTILIZATION'],
  ];

  List<dynamic>  analogSensor = [
    ['1','Analog Sensor 1','VWC','bar','current','10','10'],
    ['2','Analog Sensor 2','VWC','bar','current','10','10'],
    ['3','Analog Sensor 3','VWC','bar','current','10','10'],
    ['4','Analog Sensor 4','VWC','bar','current','10','10'],
    ['5','Analog Sensor 5','VWC','bar','current','10','10'],
    ['6','Analog Sensor 6','VWC','bar','current','10','10'],
    ['7','Analog Sensor 7','VWC','bar','current','10','10'],
    ['8','Analog Sensor 8','VWC','bar','current','10','10'],
  ];

  String lineBehavior(String value){
    switch(value){
      case ('IGNORE'):{
        return '1';
      }
      case ('DO NEXT'):{
        return '2';
      }
      default :{
        return '3';
      }
    }
  }
  String mvMode(String value){
    switch(value){
      case ('NO DELAY'):{
        return '1';
      }
      case ('OPEN BEFORE'):{
        return '2';
      }
      default :{
        return '3';
      }
    }
  }
  String AStype(String value){
    switch(value){
      case ('Pressure IN'):{
        return '1';
      }
      case ('Pressure OUT'):{
        return '2';
      }
      case ('EC'):{
        return '3';
      }
      case ('PH'):{
        return '4';
      }
      case ('Level'):{
        return '5';
      }
      case ('Valve Pressure'):{
        return '6';
      }
      case ('Soil Moisture'):{
        return '7';
      }
      default :{
        return '8';
      }
    }
  }
  String AStUnit(String value){
    switch(value){
      case ('Bar'):{
        return '1';
      }
      case ('dS/m'):{
        return '2';
      }

      default :{
        return '3';
      }
    }
  }
  String ASDS(String value){
    switch(value){
      case ('Built- in Cloud'):{
        return '1';
      }
      default :{
        return '2';
      }
    }
  }
  String ASbase(String value){
    switch(value){
      case ('current'):{
        return '1';
      }
      default :{
        return '2';
      }
    }
  }

  void fetchAll(dynamic data){
    for(var i in data.entries){
      if(i.key == 'constant'){
        APIdata = i.value;
      }
      if(i.key == 'default'){
        for(var j in i.value.entries){
          if(j.key == 'line'){
            print('');
            print('working line : ${APIdata['line']}');
            print('');
            var checkList = [];
            for(var line in j.value){
              var add = true;
              oldline : for(var oldLine in APIdata['line']){
                if('${line['sNo']}' == '${oldLine[0]}'){
                  add = false;
                  checkList.add('${line['sNo']}');
                  break oldline;
                }else{
                  print('no line');
                }
              }
              if(add == true){
                checkList.add('${line['sNo']}');
                APIdata['line'].add(['${line['sNo']}','${line['name']}','${line['irrigationPump'].length == 0 ? APIpump[0] : line['irrigationPump'][0]}','00:00:00','00:00:00','Ignore','Ignore','10']);
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            var duplicate = APIdata['line'];
            for (var oldLine = APIdata['line'].length - 1;oldLine >= 0;oldLine--) {
              if (!checkList.contains('${APIdata['line'][oldLine][0]}')) {
                print('no : ${oldLine}');
                APIdata['line'].remove(APIdata['line'][oldLine]);
              }
            }
            irrigationLines = APIdata['line'];
            irrigationLines.sort((a, b) => a[1].compareTo(b[1]));
            print('irrigationLines : ${irrigationLines}');
          }else if(j.key == 'valve'){
            var list = [];
            for(var valve in j.value){
              list.add(valve['location']);
            }
            var filterList = list.toSet().toList();
            for(var flitem in filterList){
              var dataAdd = true;
              for(var vData in APIdata['valve']){
                for(var keyLine in vData.entries){
                  if(keyLine.key == '${flitem}'){
                    dataAdd = false;
                  }
                }

              }
              if(dataAdd == true){
                APIdata['valve'].add({flitem : []});
              }
            }
            var checkList = [];
            for(var valve in j.value){
              for(var apiValve in APIdata['valve']){
                for(var valitem in apiValve.entries){
                  if(valitem.key == valve['location']){
                    var add = true;
                    oldValve : for(var oldValve in valitem.value){
                      if('${valve['sNo']}' == '${oldValve[0]}'){
                        add = false;
                        checkList.add('${valve['sNo']}');
                        break oldValve;
                      }
                    }
                    if(add == true){
                      checkList.add('${valve['sNo']}');
                      valitem.value.add(['${valve['sNo']}','${valve['id']}','${valve['name']}','00:00:00','100','50','75','125','10','1.00','100']);
                    }
                  }
                }
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            for(var valve in APIdata['valve']){
              for(var dupValve in valve.entries){
                for(var item in dupValve.value){
                  if(!checkList.contains('${item[0]}')){
                    itemsToRemove.add(item);
                  }
                }
              }
            }
            for (var item in itemsToRemove) {
              for(var valve in APIdata['valve']){
                for(var dupValve in valve.entries){
                  dupValve.value.remove(item);
                }
              }
            }
            valve = APIdata['valve'];
          }
          else if(j.key == 'fertilization'){
            var checkList = [];
            for(var fertilizer in j.value){
              var add = true;
              oldFertilizer : for(var oldFertilizer in APIdata['fertilization']){
                for(var noOfFert in fertilizer['fertlizer']){
                  for(var eachFert in oldFertilizer[3]){
                    if('${noOfFert['sNo']}' == '${eachFert[eachFert.length - 1]}'){
                      add = false;
                      checkList.add('${noOfFert['sNo']}');
                      break oldFertilizer;
                    }
                  }

                }
              }
              if(add == true){
                var myList = [];
                for(var fert in fertilizer['fertlizer']){
                  checkList.add('${fert['sNo']}');
                  myList.add(['${fert['id']}','${fert['name']}','${fert['fertilizerMeter'].length == 0 ? 'no' : 'yes'}','100','20','100','Regular','${fert['sNo']}']);
                }
                APIdata['fertilization'].add(['${fertilizer['name']}','${fertilizer['location']}','Inform Only',myList]);
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            for (var oldFertilizer in APIdata['fertilization']) {
              for(var eachFert in oldFertilizer[3]){
                if (!checkList.contains('${eachFert[eachFert.length - 1]}')) {
                  itemsToRemove.add(oldFertilizer);
                }
              }
            }
            for (var item in itemsToRemove) {
              for (var oldFertilizer in APIdata['fertilization']) {
                for(var eachFert in oldFertilizer[3]){
                  if('${item}' == eachFert[eachFert.length - 1]){
                    oldFertilizer[3].remove(eachFert);
                  }
                }
              }
            }
            fertilizer = APIdata['fertilization'];
          }
          else if(j.key == 'mainValve'){
            var checkList = [];
            for(var mainValve in j.value){
              var add = true;
              oldMainValve : for(var oldMainValve in APIdata['mainValve']){
                if('${mainValve['sNo'] }'== '${oldMainValve[0]}'){
                  add = false;
                  checkList.add('${mainValve['sNo']}');
                  break oldMainValve;
                }
              }
              if(add == true){
                checkList.add('${mainValve['sNo']}');
                APIdata['mainValve'].add(['${mainValve['sNo']}','${mainValve['name']}','${mainValve['location']}','No delay','00:00']);
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            for (var oldMainValve in APIdata['mainValve']) {
              if (!checkList.contains('${oldMainValve[0]}')) {
                itemsToRemove.add(oldMainValve);
              }
            }
            for (var item in itemsToRemove) {
              APIdata['mainValve'].remove(item);
            }
            mainValve = APIdata['mainValve'];
            mainValve.sort((a, b) => a[1].compareTo(b[1]));
          }else if(j.key == 'filtration'){
            var checkList = [];
            for(var filter in j.value){
              for(var filt in filter['filter']){
                var add = true;
                oldFilter : for(var oldFilter in APIdata['filtration']){
                  if('${filt['sNo'] }'== '${oldFilter[oldFilter.length - 1]}'){
                    add = false;
                    checkList.add('${filt['sNo']}');
                    break oldFilter;
                  }
                }
                if(add == true){
                  checkList.add('${filt['sNo']}');
                  APIdata['filtration'].add(['${filter['id']}','${filt['name']}','${filt['location']}','30','99','Stop Irrigation','${filt['sNo']}']);
                }
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            for (var oldFilter in APIdata['filtration']) {
              if (!checkList.contains('${oldFilter[oldFilter.length - 1]}')) {
                itemsToRemove.add(oldFilter);
              }
            }
            for (var item in itemsToRemove) {
              for (var oldFilter in APIdata['filtration']) {
                if(oldFilter[oldFilter.length - 1] == item[item.length]){
                  APIdata['filtration'].remove(item);
                }
              }
            }
            filter = APIdata['filtration'];

          }else if(j.key == 'waterMeter'){
            var checkList = [];
            for(var wm in j.value){
              var add = true;
              print(APIdata['waterMeter']);
              oldWaterMeter : for(var oldWaterMeter in APIdata['waterMeter']){
                if('${wm['sNo']}' == '${oldWaterMeter[0]}'){
                  checkList.add('${wm['sNo']}');
                  add = false;
                  break oldWaterMeter;
                }
              }
              if(add == true){
                checkList.add('${wm['sNo']}');
                APIdata['waterMeter'].add(['${wm['sNo']}','${wm['name']}','${wm['location']}','100','1000']);
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            for (var oldWaterMeter in APIdata['waterMeter']) {
              if (!checkList.contains('${oldWaterMeter[0]}')) {
                itemsToRemove.add(oldWaterMeter);
              }
            }
            for (var item in itemsToRemove) {
              APIdata['waterMeter'].remove(item);
            }
            waterMeter = APIdata['waterMeter'];
          }else if(j.key == 'analogSensor'){
            var checkList = [];
            print('full sensor : ${j.value}');
            print("APIdata['analogSensor'] : ${APIdata['analogSensor']}");
            for(var AS in j.value){
              var add = true;
              oldAnalogSensor : for(var oldAnalogSensor in APIdata['analogSensor']){
                print('oldAnalogSensor : ${oldAnalogSensor}');
                if(AS['sNo'] == oldAnalogSensor[0]){
                  checkList.add('${AS['sNo']}');
                  add = false;
                  break oldAnalogSensor;
                }
              }
              if(add == true){
                checkList.add('${AS['sNo']}');
                APIdata['analogSensor'].add(['${AS['sNo']}','${AS['name']}','EC','Bar','Cloud','Current','10','10']);
              }
            }
            List<List<dynamic>> itemsToRemove = [];
            for (var oldAnalogSensor in APIdata['analogSensor']) {
              if (!checkList.contains('${oldAnalogSensor[0]}')) {
                itemsToRemove.add(oldAnalogSensor);
              }
            }
            for (var item in itemsToRemove) {
              APIdata['analogSensor'].remove(item);
            }
            analogSensor = APIdata['analogSensor'];
            print(analogSensor);
          }
        }
      }
    }
    notifyListeners();
  }

  void generalSelected(int index){
    selected = index;
    notifyListeners();
  }

  void generalFunctionality(int index,String value){
   general[index][1] = value;
   notifyListeners();
  }
  void irrigationLineFunctionality(dynamic list){
    switch(list[0]){
      case ('line/irrigationPump'):{
        irrigationLines[list[1]][2] = list[2];
        break;
      }
      case ('line/lowFlowDelay'):{
        irrigationLines[list[1]][3] = list[2];
        break;
      }
      case ('line/highFlowDelay'):{
        irrigationLines[list[1]][4] = list[2];
        break;
      }
      case ('line/lowFlowBehavior'):{
        irrigationLines[list[1]][5] = list[2];
        break;
      }
      case ('line/highFlowBehavior'):{
        irrigationLines[list[1]][6] = list[2];
        break;
      }
      case ('line/leakageLimit'):{
        irrigationLines[list[1]][7] = list[2];
        break;
      }
    }
    notifyListeners();
  }

  void mainValveFunctionality(dynamic list){
    switch (list[0]){
      case ('mainvalve/mode'):{
        mainValve[list[1]][3] = list[2];
        break;
      }
      case ('mainvalve/delay'):{
        mainValve[list[1]][4] = list[2];
        break;
      }
    }
    notifyListeners();
  }

  void valveFunctionality(dynamic list){
    switch (list[0]){
      case ('valve_defaultDosage'):{
        valve[list[1]][list[2]]?[list[3]][3] = list[4];
        break;
      }
      case ('valve_nominal_flow'):{
        valve[list[1]][list[2]]?[list[3]][4] = list[4];
        break;
      }
      case ('valve_minimum_flow'):{
        valve[list[1]][list[2]]?[list[3]][5] = list[4];
        break;
      }
      case ('valve_maximum_flow'):{
        valve[list[1]][list[2]]?[list[3]][6] = list[4];
        break;
      }
      case ('valve_fillUpDelay'):{
        valve[list[1]][list[2]]?[list[3]][7] = list[4];
        break;
      }
      case ('valve_area'):{
        valve[list[1]][list[2]]?[list[3]][8] = list[4];
        break;
      }
      case ('valve_crop_factor'):{
        valve[list[1]][list[2]]?[list[3]][9] = list[4];
        break;
      }
    }
    notifyListeners();
  }

  void waterMeterFunctionality(dynamic list){
    switch (list[0]){
      case ('wm_ratio'):{
        waterMeter[list[1]][3] = list[2];
        break;
      }
      case ('maximum_flow'):{
        waterMeter[list[1]][4] = list[2];
        break;
      }
    }
    notifyListeners();
  }

  void fertilizerFunctionality(dynamic list){
    switch (list[0]){
      case ('fertilizer/noFlowBehavior'):{
        fertilizer[list[1]][2] = list[2];
        break;
      }
      case ('fertilizer_ratio'):{
        fertilizer[list[1]][list[2]][list[3]][3] = list[4];
        break;
      }
      case ('fertilizer_shortestPulse'):{
        fertilizer[list[1]][list[2]][list[3]][4] = list[4];
        break;
      }
      case ('fertilizer_nominal_flow'):{
        fertilizer[list[1]][list[2]][list[3]][5] = list[4];
        break;
      }
      case ('fertilizer_injector_mode'):{
        fertilizer[list[1]][list[2]][list[3]][6] = list[4];
        break;
      }

    }
    notifyListeners();
  }

  void filterFunctionality(dynamic list){
    switch (list[0]){
      case ('filter_dp_delay'):{
        filter[list[1]][3] = list[2];
        break;
      }
      case ('filter_looping_limit'):{
        filter[list[1]][4] = list[2];
        break;
      }
      case ('filter/flushing'):{
        filter[list[1]][5] = list[2];
        break;
      }

    }
    notifyListeners();
  }

  void analogSensorFunctionality(dynamic list){
    switch (list[0]){
      case ('analogSensor/type'):{
        analogSensor[list[1]][2] = list[2];
        break;
      }
      case ('analogSensor/units'):{
        analogSensor[list[1]][3] = list[2];
        break;
      }
      case ('analogSensor/base'):{
        analogSensor[list[1]][5] = list[2];
        break;
      }
      case ('analogSensor_minimum_v'):{
        analogSensor[list[1]][list[2]] = list[3];
        break;
      }
      case ('analogSensor_maximum_v'):{
        analogSensor[list[1]][list[2]] = list[3];
        break;
      }

    }
    notifyListeners();
  }
  bool valveContentShow = false;
  void editValveContentShow(bool value){
    valveContentShow = value;
    notifyListeners();
  }
}