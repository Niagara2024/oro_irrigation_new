import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../../state_management/constant_provider.dart';
import '../constants/theme.dart';
import '../state_management/overall_use.dart';

class MyTimePicker extends StatefulWidget {
  final bool displayHours;
  final bool displayMins;
  final bool displaySecs;
  final bool displayCustom;
  final bool displayAM_PM;
  final String CustomString;
  final List<int> CustomList;
  const MyTimePicker({super.key, required this.displayHours, required this.displayMins, required this.displaySecs, required this.displayCustom, required this.CustomString, required this.CustomList, required this.displayAM_PM});
  @override
  State<MyTimePicker> createState() => _MyTimePickerState();
}

class _MyTimePickerState extends State<MyTimePicker> {
  int _currentSegment = 0; // Store the currently selected segment index
  // Create a list of options for the segmented control
  final Map<int, Widget> segmentedOptions = {
    0: Padding(padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
    child : Text('AM',style: TextStyle(color: Colors.black),)),
    1: Padding(padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
        child : Text('PM',style: TextStyle(color: Colors.black),)),
  };
  @override
  Widget build(BuildContext context) {
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: myTheme.primaryColor
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.displayAM_PM,
            child: CupertinoSegmentedControl(
              unselectedColor: Colors.blueGrey,
              borderColor: Colors.white,
              selectedColor: Colors.white,
              children: segmentedOptions,
              groupValue: _currentSegment,
              onValueChanged: (value) {
                setState(() {
                  _currentSegment = value;
                });
                overAllPvd.edit_am_pm(value == 0 ? 'AM' : 'PM');
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: widget.displayHours,
                child: NumberPicker(
                  itemHeight: 80,
                    textStyle: TextStyle(color: Colors.white70,fontSize: 12),
                    selectedTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: 1,color: Colors.white),bottom: BorderSide(width: 1,color: Colors.white))
                    ),
                    infiniteLoop: true,
                    minValue: 0,
                    maxValue: widget.displayAM_PM == true ? 12 : 24,
                    value: overAllPvd.hrs,
                    onChanged: (value){
                      overAllPvd.editTime('hrs', value);
                    },
                  forWhat: 'hrs',
                ),
              ),
              Visibility(
                visible: widget.displayMins,
                child: NumberPicker(
                  itemHeight: 80,
                    textStyle: TextStyle(color: Colors.white70,fontSize: 12),
                    selectedTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: 1,color: Colors.white),bottom: BorderSide(width: 1,color: Colors.white))
                    ),
                    infiniteLoop: true,
                    minValue: 0,
                    maxValue: 60,
                    value: overAllPvd.min,
                    onChanged: (value){
                      overAllPvd.editTime('min', value);
                    },
                  forWhat: 'min',
                ),
              ),
              Visibility(
                visible: widget.displaySecs,
                child: NumberPicker(
                  itemHeight: 80,
                    textStyle: TextStyle(color: Colors.white70,fontSize: 12),
                    selectedTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(width: 1,color: Colors.white),bottom: BorderSide(width: 1,color: Colors.white))
                    ),
                    infiniteLoop: true,
                    minValue: 0,
                    maxValue: 60,
                    value: overAllPvd.sec,
                    onChanged: (value){
                      overAllPvd.editTime('sec', value);
                    },
                  forWhat: 'sec',
                ),
              ),
              Visibility(
                visible: widget.displayCustom,
                child: NumberPicker(
                  itemHeight: 80,
                  textStyle: TextStyle(color: Colors.white70,fontSize: 12),
                  selectedTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 1,color: Colors.white),bottom: BorderSide(width: 1,color: Colors.white))
                  ),
                  infiniteLoop: true,
                  minValue: widget.CustomList[0],
                  maxValue: widget.CustomList[1],
                  value: overAllPvd.other,
                  onChanged: (value){
                    overAllPvd.editTime('other', value);
                  },
                  forWhat: '${widget.CustomString}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



