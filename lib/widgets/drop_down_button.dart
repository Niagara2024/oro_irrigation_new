import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_management/config_maker_provider.dart';
import '../state_management/constant_provider.dart';



class MyDropDown extends StatefulWidget {
  int index;
  String initialValue;
  String pvdName;
  List<String> itemList;

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
  @override


  @override
  Widget build(BuildContext context) {
    //var deviceListPvd = Provider.of<DeviceListProvider>(context, listen: true);
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Container(
      width: double.infinity,
      child: Center(
        child: DropdownButton(
          focusColor: Colors.transparent,
        style: TextStyle(fontWeight: FontWeight.normal),
          value: widget.initialValue,
          underline: Container(),
          items: widget.itemList.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Container(
                  child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
              ),
            );
          }).toList(),
          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (String? newValue) {
             if(widget.pvdName == 'editWaterSource_sp'){
              configPvd.sourcePumpFunctionality(['editWaterSource_sp',widget.index,newValue!]);
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
            }else if(widget.pvdName == 'editDropDownValue'){
              print('venky');
              constantPvd.editDropDownValue(newValue!);
            }
             else{
              var forWhat = widget.pvdName.split('/');
              if(forWhat[0] == 'm_o_valve'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_main_valve'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_injector'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_Booster'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_filter'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_D_valve'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_o_CD_injector'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_CD_booster'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_CD_agitator'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_CF_filter'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_o_CF_D_valve'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_o_SP'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_o_IP'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_o_fan'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_o_fogger'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_o_agitator'){
                configPvd.mappingOfOutputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_i_pressure_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_water_meter'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_ORO_sense'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_i_dosing_meter'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_i_D_pressure_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_D_pressure_sensor_out'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_CD_dosing_meter'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]), int.parse(forWhat[5]),newValue]);
              }else if(forWhat[0] == 'm_i_CF_P_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_CF_P_sensor_out'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_sp_wm'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_ip_wm'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), forWhat[2], forWhat[3], int.parse(forWhat[4]),newValue]);
              }else if(forWhat[0] == 'm_i_analog_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_i_contacts'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_i_ph_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_i_ec_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'm_i_moisture_sensor'){
                configPvd.mappingOfInputsFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]), newValue]);
              }else if(forWhat[0] == 'fertilizer_injector_mode'){
                //constantPvd.fertilizerFunctionality([forWhat[0], int.parse(forWhat[1]), int.parse(forWhat[2]),int.parse(forWhat[3]), newValue]);
              }
            }
          },
        ),
      ),
    );
  }
}
