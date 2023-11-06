import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state_management/config_maker_provider.dart';

class TextFieldForFlexibleConfig extends StatefulWidget {
  String initialValue;
  final int index;
  final ConfigMakerProvider config;
  final String purpose;
  TextFieldForFlexibleConfig({super.key, required this.purpose, required this.initialValue, required this.index, required this.config});

  @override
  State<TextFieldForFlexibleConfig> createState() => _TextFieldForFlexibleConfigState();
}

class _TextFieldForFlexibleConfigState extends State<TextFieldForFlexibleConfig> {
  late TextEditingController myController;
  FocusNode myFocus = FocusNode();
  bool focus = false;
  @override
  void initState() {
    // TODO: implement initState
    myController = TextEditingController();
    myController.text = widget.initialValue;
    myFocus.addListener(() {
      if(myFocus.hasFocus == false){
        setState(() {
          focus = false;
        });
      }
      if(myFocus.hasFocus == true){
        setState(() {
          focus = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    if(focus == false){
      myController.text = widget.initialValue;
    }
    return Container(
      width: 60,
      child: TextFormField(
        focusNode: myFocus,
        controller: myController,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        maxLength: 2,
        onChanged: (value){
          if(value == '0'){
            myController.text = '1';
          }
          switch(widget.purpose){
            case ('irrigationLinesFunctionality/mainValve'):{
              var total = configPvd.totalMainValve + int.parse(configPvd.irrigationLines[widget.index]['main_valve'] == '' ? '0' : configPvd.irrigationLines[widget.index]['main_valve']);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.irrigationLinesFunctionality(['editMainValve',widget.index,myController.text]);
              break;
            }
            case ('irrigationLinesFunctionality/RTU'):{
              var total = configPvd.totalRTU + int.parse(configPvd.irrigationLines[widget.index]['RTU'] == '' ? '0' : configPvd.irrigationLines[widget.index]['RTU']);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.irrigationLinesFunctionality(['editRTU',widget.index,myController.text]);
              break;
            }
            case ('irrigationLinesFunctionality/0roSwitch'):{
              var total = configPvd.totalOroSwitch + int.parse(configPvd.irrigationLines[widget.index]['ORO_switch'] == '' ? '0' : configPvd.irrigationLines[widget.index]['ORO_switch']);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.irrigationLinesFunctionality(['editOroSwitch',widget.index,myController.text]);
              break;
            }
            case ('irrigationLinesFunctionality/0roSense'):{
              var total = configPvd.totalOroSense + int.parse(configPvd.irrigationLines[widget.index]['ORO_sense'] == '' ? '0' : configPvd.irrigationLines[widget.index]['ORO_sense']);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.irrigationLinesFunctionality(['editOroSense',widget.index,myController.text]);
              break;
            }
            case ('irrigationLinesFunctionality/OroSmartRtu'):{
              var total = configPvd.totalOroSmartRTU + int.parse(configPvd.irrigationLines[widget.index]['ORO_Smart_RTU'] == '' ? '0' : configPvd.irrigationLines[widget.index]['ORO_Smart_RTU']);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.irrigationLinesFunctionality(['editOroSmartRtu',widget.index,myController.text]);
              break;
            }
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
                borderSide: BorderSide.none
            )
        ),
      ),
    );
  }
}
