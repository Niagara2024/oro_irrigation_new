import 'dart:convert';

import 'package:flutter/cupertino.dart';

class FertilizerSetProvider extends ChangeNotifier{
  dynamic listOfRecipe = [];
  dynamic listOfSite = [];
  int selectFunction = 0;
  dynamic sample = [];
  int selectedSite = 0;
  int wantToSendData = 0;
  int autoIncrement = 0;
  int editAutoIncrement(){
    autoIncrement += 1;
    notifyListeners();
    return autoIncrement;
  }
  editWantToSendData(value){
    wantToSendData = value;
    notifyListeners();
  }

  void addRecipe(String name){
    listOfRecipe[selectedSite]['recipe'].add({
      'sNo' : editAutoIncrement(),
      'id' : 'CFESE$autoIncrement',
      'name' : name,
      'location' : listOfRecipe[selectedSite]['id'],
      'select' : false,
      'ecActive' : false,
      'Ec' : '0',
      'phActive' : false,
      'Ph' : '0',
      'fertilizer' : editSample(listOfRecipe[selectedSite])
    });
    print(jsonEncode(listOfRecipe));
    notifyListeners();
  }
  void editSite(int value){
    selectedSite = value;
    notifyListeners();
    print(selectedSite);
  }

  void editSelectFunction(int data){
    selectFunction = data;
    notifyListeners();
  }

  void editRecipe(dynamic data){
    autoIncrement = data['data']['fertilizerSet']['autoIncrement'] == null ? 0 : data['data']['fertilizerSet']['autoIncrement'];
    if(data['data']['fertilizerSet']['fertilizerSet'] == null){
      for(var i in data['data']['default']['fertilization']){
        i['recipe'] = [];
        listOfRecipe.add(i);
      }
    }else{
      listOfRecipe = data['data']['fertilizerSet']['fertilizerSet'];
    }
    notifyListeners();
  }

  dynamic editSample(dynamic data){
    var sample = [];
    for(var fert in data['fertilizer']){
      sample.add({
        'sNo' : fert['sNo'],
        'id' : fert['id'],
        'name' : fert['name'],
        'location' : fert['location'],
        'fertilizerMeter' : fert['fertilizerMeter'],
        'active' : false,
        'method' : 'Time',
        'timeValue' : '00:00:00',
        'quantityValue' : '0',
        'dmControl' : false,
      });
    }
    return sample;
  }

  void fertilizerFunctionality(list){
    switch( list[0]){
      case ('selectFertilizer'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['select'] = list[3];
        break;
      }
      case ('selectAllFertilizer'):{
        for(var i in listOfRecipe[selectedSite]['recipe']){
          i['select'] = true;
        }
        selectFunction = 1;
        break;
      }
      case ('deleteFertilizer'):{
        var deleteList = [];
        for(var i in listOfRecipe[selectedSite]['recipe']){
          if(i['select'] == true){
            deleteList.add(i);
          }
        }
        for(var i in deleteList){
          if(listOfRecipe[selectedSite]['recipe'].contains(i)){
            listOfRecipe[selectedSite]['recipe'].remove(i);
          }
        }
        selectFunction = 0;
        break;
      }
      case ('cancelFertilizer'):{
        var deleteList = [];
        for(var i in listOfRecipe[selectedSite]['recipe']){
          if(i['select'] == true){
            i['select'] = false;
          }
        }
        selectFunction = 0;
        break;
      }
    }
    notifyListeners();
  }

  void listOfFertilizerFunctionality(list){
    switch (list[0]){
      case ('editActive'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['active'] = list[4];
        break;
      }
      case ('editDmControl'):{
        if(listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['dmControl'] == true){
          listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['dmControl'] = false;
        }else{
          listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['dmControl'] = true;
        }
        break;
      }
      case ('editMethod'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['method'] = list[4];
        break;
      }
      case ('editTimeOrQuantity'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['quantity/time'] = list[4];
        break;
      }
      case ('editTimeValue'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['timeValue'] = list[4];
        break;
      }
      case ('editQuantityValue'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['fertilizer'][list[3]]['quantityValue'] = list[4];
        break;
      }
      case ('editEc'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['Ec'] = list[3];
        break;
      }
      case ('editEcActive'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['ecActive'] = list[3];
        break;
      }
      case ('editPh'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['Ph'] = list[3];
        break;
      }
      case ('editPhActive'):{
        listOfRecipe[list[1]]['recipe'][list[2]]['phActive'] = list[3];
        break;
      }
    }
    notifyListeners();
    print(sample);
  }

  int fertMethod(String name){
    if(name == 'Time'){
      return 1;
    }else if(name == 'Time Proportional'){
      return 2;
    }else if(name == 'Quantity'){
      return 3;
    }else{
      return 4;
    }
  }

  dynamic hwPayload(){
    var payload = '';
    for(var i = 0;i < listOfRecipe.length;i++){
      for(var j = 0;j < listOfRecipe[i]['recipe'].length;j++){
        for(var fert in listOfRecipe[i]['recipe'][j]['fertilizer']){
          payload += '${payload.isNotEmpty ? ';' : '' }'
              '${fert['sNo']},'
              '${listOfRecipe[i]['recipe'][j]['sNo']},'
              '${listOfRecipe[i]['recipe'][j]['name']},'
              '${listOfRecipe[i]['recipe'][j]['ecActive'] == true ? 1 : 0},'
              '${listOfRecipe[i]['recipe'][j]['Ec']},'
              '${listOfRecipe[i]['recipe'][j]['phActive'] == true ? 1 : 0},'
              '${listOfRecipe[i]['recipe'][j]['Ph']},'
              '${listOfRecipe[i]['id']},'
              '${listOfRecipe[i]['recipe'][j]['fertilizer'].indexOf(fert) + 1},'
              '${fert['active'] == true ? 1 : 0},'
              '${fertMethod(fert['method'])},'
              '${['Time','Time Proportional'].contains(fert['method']) ? fert['timeValue'] : fert['quantityValue']},'
              '${fert['dmControl'] == true ? 1 : 0}' ;
        }
      }
    }
    print(payload);
    return {'2000' : [{'2001' : payload}]};
  }

}