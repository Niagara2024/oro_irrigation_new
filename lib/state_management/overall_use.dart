import 'package:flutter/cupertino.dart';

class OverAllUse extends ChangeNotifier{

  int hrs = 0;
  int min = 0;
  int sec = 0;
  int other = 1;
  String am_pm = '';
  int userId = 21;
  int createUser = 21;
  int controllerId = 10;

  void editTimeAll(){
    hrs = 0;
    min = 0;
    sec = 0;
    other = 1;
    am_pm = '';
    notifyListeners();
  }
  void edit_am_pm(String value){
    am_pm = value;
    notifyListeners();
  }
  void editTime(String title, int value){
    switch (title){
      case ('hrs') :{
        hrs = value;
        break;
      }
      case ('min') :{
        min = value;
        break;
      }
      case ('sec') :{
        sec = value;
        break;
      }
      case ('other') :{
        print(other);
        other = value;
        break;
      }
    }
    notifyListeners();
  }

}