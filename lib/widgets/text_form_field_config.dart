import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state_management/config_maker_provider.dart';

class TextFieldForConfig extends StatefulWidget {
  final String initialValue;
  final int index;
  final ConfigMakerProvider config;
  final String purpose;
  const TextFieldForConfig({super.key,required this.index,required this.initialValue, required this.config, required this.purpose});

  @override
  State<TextFieldForConfig> createState() => _TextFieldForConfigState();
}

class _TextFieldForConfigState extends State<TextFieldForConfig> {
  FocusNode myFocus = FocusNode();
  late TextEditingController myController;
  bool focus = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myController = TextEditingController();
    myController.text = widget.initialValue;
    myFocus.addListener(() {
      if(myFocus.hasFocus == false){
        setState(() {
          focus = false;
        });
        if(myController.text == ''){
          switch (widget.purpose){
            case ('centralFiltrationFunctionality') : {
              widget.config.centralFiltrationFunctionality(['editFilters',widget.index,'1']);
              break;
            }
            case ('irrigationLinesFunctionality/valve') : {
              widget.config.irrigationLinesFunctionality(['editValve',widget.index,'1']);
              break;
            }
            case ('localFiltration/filter') : {
              widget.config.irrigationLinesFunctionality(['editValve',widget.index,'1']);
              widget.config.localFiltrationFunctionality(['editFilter',widget.index,'1']);
              break;
            }
          }

          myController.text = '1';
        }
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
        onFieldSubmitted: (value){
          if(value == ''){
            myController.text = '1';
            switch (widget.purpose){
              case ('centralFiltrationFunctionality') : {
                configPvd.centralFiltrationFunctionality(['editFilters',widget.index,'1']);
                break;
              }
              case ('irrigationLinesFunctionality/valve') : {
                configPvd.irrigationLinesFunctionality(['editValve',widget.index,'1']);
                break;
              }
            }

          }
        },
        maxLength: 2,
        onChanged: (value){
          if(value == '0'){
            myController.text = '1';
          }
          switch (widget.purpose){
            case ('centralFiltrationFunctionality') : {
              var total = configPvd.totalFilter + int.parse(configPvd.centralFiltration[widget.index][0] == '' ? '0' : configPvd.centralFiltration[widget.index][0]);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.centralFiltrationFunctionality(['editFilters',widget.index,myController.text]);
              break;
            }
            case ('irrigationLinesFunctionality/valve') : {
              var total = configPvd.totalValve + int.parse(configPvd.irrigationLines[widget.index]['valve'] == '' ? '0' : configPvd.irrigationLines[widget.index]['valve']);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.irrigationLinesFunctionality(['editValve',widget.index,myController.text]);
              print(myController.text);
              break;
            }
            case ('localFiltration/filter') : {
              var total = configPvd.totalFilter + int.parse(configPvd.localFiltration[widget.index][1] == '' ? '0' : configPvd.localFiltration[widget.index][1]);
              total = total - int.parse(myController.text == '' ? '0' : myController.text);
              if(total < 0){
                setState(() {
                  myController.text = (int.parse(myController.text) + total).toString();
                });
              }
              configPvd.localFiltrationFunctionality(['editFilter',widget.index,myController.text]);
              print(myController.text);
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
