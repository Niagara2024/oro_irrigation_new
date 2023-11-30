import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../state_management/constant_provider.dart';


class MyDropDown extends StatefulWidget {
  int index;
  String initialValue;
  String pvdName;
  List<dynamic> itemList;

  MyDropDown({super.key,
    required this.initialValue,
    required this.itemList,
    required this.pvdName,
    required this.index,
  });

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  bool isEditing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;

    });
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return GestureDetector(
      onTap: toggleEditing,
      child: isEditing
          ? Container(
        width: double.infinity,
        child: Center(
          child: DropdownButton(
            focusColor: Colors.transparent,
            // style: ioText,
            value: widget.initialValue,
            underline: Container(),
            items: widget.itemList.map((dynamic items) {
              return DropdownMenuItem(
                onTap: (){
                  toggleEditing();
                },
                value: items,
                child: Container(
                    child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                ),
              );
            }).toList(),
            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (dynamic newValue) {
             if(widget.pvdName == 'editWaterSource_sp'){
                configPvd.sourcePumpFunctionality(['editWaterSource_sp',widget.index,newValue!]);
              }else if(widget.pvdName == 'editRelayCount_sp'){
                configPvd.sourcePumpFunctionality(['editRelayCount_sp',widget.index,newValue!]);
              }else if(widget.pvdName == 'editRelayCount_ip'){
                configPvd.irrigationPumpFunctionality(['editRelayCount_ip',widget.index,newValue!]);
              }else if(widget.pvdName == 'editCentralDosing'){
                configPvd.irrigationLinesFunctionality(['editCentralDosing',widget.index,newValue!]);
              }else if(widget.pvdName == 'editCentralFiltration'){
                configPvd.irrigationLinesFunctionality(['editCentralFiltration',widget.index,newValue!]);
              }else if(widget.pvdName == 'editIrrigationPump'){
                configPvd.irrigationLinesFunctionality(['editIrrigationPump',widget.index,newValue!]);
              }else if(widget.pvdName == 'constant-general-waterPulse'){
                constantPvd.generalFunctionality(widget.index,newValue!);
              }else if(widget.pvdName == 'line/irrigationPump'){
                constantPvd.irrigationLineFunctionality(['line/irrigationPump',widget.index,newValue!]);
              }else if(widget.pvdName == 'line/lowFlowBehavior'){
                constantPvd.irrigationLineFunctionality(['line/lowFlowBehavior',widget.index,newValue!]);
              }else if(widget.pvdName == 'line/highFlowBehavior'){
                constantPvd.irrigationLineFunctionality(['line/highFlowBehavior',widget.index,newValue!]);
              }else if(widget.pvdName == 'mainvalve/mode'){
                constantPvd.mainValveFunctionality(['mainvalve/mode',widget.index,newValue!]);
              }else if(widget.pvdName == 'fertilizer/noFlowBehavior'){
                constantPvd.fertilizerFunctionality(['fertilizer/noFlowBehavior',widget.index,newValue!]);
              }else if(widget.pvdName == 'filter/flushing'){
                constantPvd.filterFunctionality(['filter/flushing',widget.index,newValue!]);
              }else if(widget.pvdName == 'analogSensor/type'){
                constantPvd.analogSensorFunctionality(['analogSensor/type',widget.index,newValue!]);
              }else if(widget.pvdName == 'analogSensor/units'){
                constantPvd.analogSensorFunctionality(['analogSensor/units',widget.index,newValue!]);
              }else if(widget.pvdName == 'analogSensor/base'){
                constantPvd.analogSensorFunctionality(['analogSensor/base',widget.index,newValue!]);
              }else if(widget.pvdName == 'moistureSensor_high_low'){
                constantPvd.moistureSensorFunctionality(['moistureSensor_high_low',widget.index,newValue!]);
              }else if(widget.pvdName == 'levelSensor_high_low'){
                constantPvd.levelSensorFunctionality(['levelSensor_high_low',widget.index,newValue!]);
              }else if(widget.pvdName == 'editDropDownValue'){
                print('venky');
                constantPvd.editDropDownValue(newValue!);
              }else{
                var forWhat = widget.pvdName.split('/');
                if(forWhat[0] == 'm_o_line'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_line'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_o_localDosing'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_localDosing'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_o_localFiltration'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_localFiltration'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_o_centralDosing'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_centralDosing'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_o_centralFiltration'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_centralFiltration'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_o_sourcePump'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_sourcePump'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_o_irrigationPump'){
                  configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_irrigationPump'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_analogSensor'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'm_i_contact'){
                  configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], int.parse(forWhat[3]), forWhat[4],newValue]);
                }else if(forWhat[0] == 'ecPh_injector_mode'){
                  constantPvd.ecPhFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2],int.parse(forWhat[3]), newValue]);
                }
              }
            },
          ),
        ),
      )
          : Container(
          margin: EdgeInsets.all(2),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          height: double.infinity,
          child: Center(child: Text(widget.initialValue,style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),))
      ),
    );
  }
}
