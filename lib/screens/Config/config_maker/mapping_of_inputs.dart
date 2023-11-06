import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../constants/theme.dart';
import '../../../widgets/drop_down_button.dart';



class MappingOfInputsTable extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const MappingOfInputsTable({super.key,required this.configPvd});

  @override
  State<MappingOfInputsTable> createState() => _MappingOfInputsTableState();
}

class _MappingOfInputsTableState extends State<MappingOfInputsTable> {
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
        configPvd.refreshMapOfInputs();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (context,constrainst){
      var width = constrainst.maxWidth;
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Obj',style: TextStyle(color: Colors.white),),
                        // Text('(${configPvd.totalCentralFiltration})',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  ),
                ),
                if(width < 400)
                  Container(
                    width: 150,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('RTU',style: TextStyle(color: Colors.white),),
                        // Text('(${configPvd.totalFilter})',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  )
                else
                  Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('RTU',style: TextStyle(color: Colors.white),),
                        // Text('(${configPvd.totalFilter})',style: TextStyle(color: Colors.white),),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('R.no',style: TextStyle(color: Colors.white),),
                        // Text('Valve(${configPvd.total_D_s_valve})',style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('I/P',style: TextStyle(color: Colors.white),),
                        // Text('Sensor(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  ),
                ),
                if(width < 400)
                  Container(
                    height: 60,
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('I-Tps',style: TextStyle(color: Colors.white),),
                        // Text('Sensor(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('I-Tps',style: TextStyle(color: Colors.white),),
                          // Text('Sensor(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
                      ),
                    ),
                  )

              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10,right: 10),
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for(var i = 0; i < configPvd.mappingOfInputs.length;i++)
                      for(var j in configPvd.mappingOfInputs[i].entries)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Visibility(
                                visible: lineShow(configPvd,i),
                                child: Container(
                                  width: double.infinity,
                                  height: 30  ,
                                  color: Colors.blue,
                                  child: Center(child: Text('Irrigation line${i + 1}',style: TextStyle(color: Colors.white),),),
                                ),
                              ),
                              j.value['pressure_sensor'].length == 0 ? Container() : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorsFind(j.value,j.value['pressure_sensor'][0]),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('PS')),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['pressure_sensor'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['pressure_sensor'][1])['list'], pvdName: 'm_i_pressure_sensor/${i}/${j.key}/pressure_sensor/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['pressure_sensor'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['pressure_sensor'][1])['list'], pvdName: 'm_i_pressure_sensor/${i}/${j.key}/pressure_sensor/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['pressure_sensor'][1],j.value['pressure_sensor'][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['pressure_sensor'][1],j.value['pressure_sensor'][2]])['list'], pvdName: 'm_i_pressure_sensor/${i}/${j.key}/pressure_sensor/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['pressure_sensor'][j.value['pressure_sensor'].length - 1], j.value['pressure_sensor'][1],j.value['pressure_sensor'][2],j.value['pressure_sensor'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['pressure_sensor'][j.value['pressure_sensor'].length - 1], j.value['pressure_sensor'][1], j.value['pressure_sensor'][2], j.value['pressure_sensor'][3] ])['list'], pvdName: 'm_i_pressure_sensor/${i}/${j.key}/pressure_sensor/3', index: -1,),
                                    ),
                                    if(width < 400)
                                      Container(
                                          width: 60,
                                          child: MyDropDown(initialValue: j.value['pressure_sensor'][4], itemList: configPvd.i_o_types, pvdName:  'm_i_pressure_sensor/${i}/${j.key}/pressure_sensor/4', index: -1)
                                      )
                                    else
                                      Expanded(
                                          child: MyDropDown(initialValue: j.value['pressure_sensor'][4], itemList: configPvd.i_o_types, pvdName:  'm_i_pressure_sensor/${i}/${j.key}/pressure_sensor/4', index: -1)
                                      )

                                  ],
                                ),
                              ),
                              j.value['water_meter'].length == 0 ? Container() : Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorsFind(j.value,j.value['water_meter'][0]),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('WM')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['water_meter'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['water_meter'][1])['list'], pvdName: 'm_i_water_meter/${i}/${j.key}/water_meter/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['water_meter'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['water_meter'][1])['list'], pvdName: 'm_i_water_meter/${i}/${j.key}/water_meter/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['water_meter'][1],j.value['water_meter'][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['water_meter'][1],j.value['water_meter'][2]])['list'], pvdName: 'm_i_water_meter/${i}/${j.key}/water_meter/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['water_meter'][j.value['water_meter'].length - 1], j.value['water_meter'][1],j.value['water_meter'][2],j.value['water_meter'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [ j.value['water_meter'][j.value['water_meter'].length - 1], j.value['water_meter'][1], j.value['water_meter'][2], j.value['water_meter'][3] ])['list'], pvdName: 'm_i_water_meter/${i}/${j.key}/water_meter/3', index: -1,),
                                      ),
                                      if(width < 400)
                                        Container(
                                            width: 60,
                                            child: MyDropDown(initialValue: j.value['water_meter'][4], itemList: configPvd.i_o_types, pvdName:  'm_i_water_meter/${i}/${j.key}/water_meter/4', index: -1)
                                        )
                                      else
                                        Expanded(
                                            child: MyDropDown(initialValue: j.value['water_meter'][4], itemList: configPvd.i_o_types, pvdName:  'm_i_water_meter/${i}/${j.key}/water_meter/4', index: -1)
                                        )
                                    ],
                                  ),
                                ),
                              for(var k = 0;k < j.value['ORO_sense'].length;k++)
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorsFind(j.value,j.value['ORO_sense'][k][0]),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('OSense ${k+1}')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['ORO_sense'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['ORO_sense'][k][1])['list'], pvdName: 'm_i_ORO_sense/${i}/${j.key}/ORO_sense/${k}/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['ORO_sense'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['ORO_sense'][k][1])['list'], pvdName: 'm_i_ORO_sense/${i}/${j.key}/ORO_sense/${k}/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['ORO_sense'][k][1],j.value['ORO_sense'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['ORO_sense'][k][1],j.value['ORO_sense'][k][2]])['list'], pvdName: 'm_i_ORO_sense/${i}/${j.key}/ORO_sense/${k}/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[ j.value['ORO_sense'][k][j.value['ORO_sense'][k].length - 1], j.value['ORO_sense'][k][1],j.value['ORO_sense'][k][2],j.value['ORO_sense'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [ j.value['ORO_sense'][k][j.value['ORO_sense'][k].length - 1], j.value['ORO_sense'][k][1], j.value['ORO_sense'][k][2], j.value['ORO_sense'][k][3] ])['list'], pvdName: 'm_i_ORO_sense/${i}/${j.key}/ORO_sense/${k}/3', index: -1,),
                                      ),
                                      if(width < 400)
                                        Container(
                                            width: 60,
                                            child: MyDropDown(initialValue: j.value['ORO_sense'][k][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ORO_sense/${i}/${j.key}/ORO_sense/${k}/4', index: -1)
                                        )
                                      else
                                        Expanded(
                                            child: MyDropDown(initialValue: j.value['ORO_sense'][k][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ORO_sense/${i}/${j.key}/ORO_sense/${k}/4', index: -1)
                                        )
                                    ],
                                  ),
                                ),
                              for(var k = 0;k < j.value['dosing_meter'].length;k++)
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorsFind(j.value,j.value['dosing_meter'][k][0]),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('DM ${j.value['dosing_meter'][k][0].split(':')[1].split('dosing_meter')[1]}')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['dosing_meter'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['dosing_meter'][k][1])['list'], pvdName: 'm_i_dosing_meter/${i}/${j.key}/dosing_meter/${k}/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['dosing_meter'][k][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['dosing_meter'][k][1])['list'], pvdName: 'm_i_dosing_meter/${i}/${j.key}/dosing_meter/${k}/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['dosing_meter'][k][1],j.value['dosing_meter'][k][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['dosing_meter'][k][1],j.value['dosing_meter'][k][2]])['list'], pvdName: 'm_i_dosing_meter/${i}/${j.key}/dosing_meter/${k}/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['dosing_meter'][k][j.value['dosing_meter'][k].length - 1], j.value['dosing_meter'][k][1],j.value['dosing_meter'][k][2],j.value['dosing_meter'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['dosing_meter'][k][j.value['dosing_meter'][k].length - 1], j.value['dosing_meter'][k][1], j.value['dosing_meter'][k][2], j.value['dosing_meter'][k][3] ])['list'], pvdName: 'm_i_dosing_meter/${i}/${j.key}/dosing_meter/${k}/3', index: -1,),
                                      ),
                                      if(width < 400)
                                        Container(
                                            width: 60,
                                            child: MyDropDown(initialValue:j.value['dosing_meter'][k][4], itemList: configPvd.i_o_types, pvdName: 'm_i_dosing_meter/${i}/${j.key}/dosing_meter/${k}/4', index: -1)
                                        )
                                      else
                                        Expanded(
                                            child: MyDropDown(initialValue:j.value['dosing_meter'][k][4], itemList: configPvd.i_o_types, pvdName: 'm_i_dosing_meter/${i}/${j.key}/dosing_meter/${k}/4', index: -1)
                                        )
                                    ],
                                  ),
                                ),
                              j.value['D_pressure_sensor'].length == 0 ? Container() : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorsFind(j.value,j.value['D_pressure_sensor'][0]),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('DPS_in')),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor'][1])['list'], pvdName: 'm_i_D_pressure_sensor/${i}/${j.key}/D_pressure_sensor/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor'][1])['list'], pvdName: 'm_i_D_pressure_sensor/${i}/${j.key}/D_pressure_sensor/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['D_pressure_sensor'][1],j.value['D_pressure_sensor'][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['D_pressure_sensor'][1],j.value['D_pressure_sensor'][2]])['list'], pvdName: 'm_i_D_pressure_sensor/${i}/${j.key}/D_pressure_sensor/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['D_pressure_sensor'][j.value['D_pressure_sensor'].length - 1], j.value['D_pressure_sensor'][1],j.value['D_pressure_sensor'][2],j.value['D_pressure_sensor'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['D_pressure_sensor'][j.value['D_pressure_sensor'].length - 1], j.value['D_pressure_sensor'][1], j.value['D_pressure_sensor'][2], j.value['D_pressure_sensor'][3] ])['list'], pvdName: 'm_i_D_pressure_sensor/${i}/${j.key}/D_pressure_sensor/3', index: -1,),
                                    ),
                                    if(width < 400)
                                      Container(
                                          width: 60,
                                          child: MyDropDown(initialValue:j.value['D_pressure_sensor'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_D_pressure_sensor/${i}/${j.key}/D_pressure_sensor/4', index: -1)
                                      )
                                    else
                                      Expanded(
                                          child: MyDropDown(initialValue:j.value['D_pressure_sensor'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_D_pressure_sensor/${i}/${j.key}/D_pressure_sensor/4', index: -1)
                                      )
                                  ],
                                ),
                              ),
                              j.value['D_pressure_sensor_out'].length == 0 ? Container() : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorsFind(j.value,j.value['D_pressure_sensor_out'][0]),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('DPS_out')),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor_out'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor_out'][1])['list'], pvdName: 'm_i_D_pressure_sensor_out/${i}/${j.key}/D_pressure_sensor_out/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor_out'][1])['initialValue'], itemList: returnigListForRtu(j.key,configPvd,j.value['D_pressure_sensor_out'][1])['list'], pvdName: 'm_i_D_pressure_sensor_out/${i}/${j.key}/D_pressure_sensor_out/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForRfNo(j.key,configPvd,[j.value['D_pressure_sensor_out'][1],j.value['D_pressure_sensor_out'][2]])['initialValue'], itemList: returnigListForRfNo(j.key,configPvd,[j.value['D_pressure_sensor_out'][1],j.value['D_pressure_sensor_out'][2]])['list'], pvdName: 'm_i_D_pressure_sensor_out/${i}/${j.key}/D_pressure_sensor_out/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['D_pressure_sensor_out'][j.value['D_pressure_sensor_out'].length - 1], j.value['D_pressure_sensor_out'][1],j.value['D_pressure_sensor_out'][2],j.value['D_pressure_sensor_out'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd, [j.value['D_pressure_sensor_out'][j.value['D_pressure_sensor_out'].length - 1], j.value['D_pressure_sensor_out'][1], j.value['D_pressure_sensor_out'][2], j.value['D_pressure_sensor_out'][3] ])['list'], pvdName: 'm_i_D_pressure_sensor_out/${i}/${j.key}/D_pressure_sensor_out/3', index: -1,),
                                    ),
                                    if(width < 400)
                                      Container(
                                          width: 60,
                                          child: MyDropDown(initialValue:j.value['D_pressure_sensor_out'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_D_pressure_sensor_out/${i}/${j.key}/D_pressure_sensor_out/4', index: -1)
                                      )
                                    else
                                      Expanded(
                                          child: MyDropDown(initialValue:j.value['D_pressure_sensor_out'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_D_pressure_sensor_out/${i}/${j.key}/D_pressure_sensor_out/4', index: -1)
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    for(var i = 0;i < configPvd.CD_for_MO.length;i++)
                      for(var j in configPvd.CD_for_MO[i].entries)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Visibility(
                                visible: CDShow(configPvd,i),
                                child: Container(
                                  width: double.infinity,
                                  height: 30  ,
                                  color: Colors.blue,
                                  child: Center(child: Text('Central Dosing Site ${i + 1}',style: TextStyle(color: Colors.white),),),
                                ),
                              ),
                              for(var k = 0;k < j.value['dosing_meter'].length;k++)
                                if(j.value['dosing_meter'][k][0] == true)
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorsFindForCD(j.value,'dm${k}'),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Center(child: Text('DM ${k+1}')),
                                          ),
                                        ),
                                        if(width < 400)
                                          Container(
                                            width: 150,
                                            child: MyDropDown(initialValue: j.value['dosing_meter'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_i_CD_dosing_meter/${i}/${j.key}/dosing_meter/${k}/1', index: -1,),
                                          )
                                        else
                                          Expanded(
                                            child: MyDropDown(initialValue: j.value['dosing_meter'][k][1], itemList: getRTUs(configPvd), pvdName: 'm_i_CD_dosing_meter/${i}/${j.key}/dosing_meter/${k}/1', index: -1,),
                                          ),
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['dosing_meter'][k][2], itemList: getRFnos(configPvd,j.value['dosing_meter'][k][1]), pvdName: 'm_i_CD_dosing_meter/${i}/${j.key}/dosing_meter/${k}/2', index: -1,),
                                        ),
                                        Expanded(
                                          child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['dosing_meter'][k][j.value['dosing_meter'][k].length - 1], j.value['dosing_meter'][k][1],j.value['dosing_meter'][k][2],j.value['dosing_meter'][k][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[j.value['dosing_meter'][k][j.value['dosing_meter'][k].length - 1], j.value['dosing_meter'][k][1],j.value['dosing_meter'][k][2],j.value['dosing_meter'][k][3] ])['list'], pvdName: 'm_i_CD_dosing_meter/${i}/${j.key}/dosing_meter/${k}/3', index: -1,),
                                        ),
                                        if(width < 400)
                                          Container(
                                              width: 60,
                                              child: MyDropDown(initialValue: j.value['dosing_meter'][k][4], itemList: configPvd.i_o_types, pvdName: 'm_i_CD_dosing_meter/${i}/${j.key}/dosing_meter/${k}/4', index: -1)
                                          )
                                        else
                                          Expanded(
                                              child: MyDropDown(initialValue: j.value['dosing_meter'][k][4], itemList: configPvd.i_o_types, pvdName: 'm_i_CD_dosing_meter/${i}/${j.key}/dosing_meter/${k}/4', index: -1)
                                          )
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        ),
                    for(var i = 0;i < configPvd.CF_for_MO.length;i++)
                      for(var j in configPvd.CF_for_MO[i].entries)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Visibility(
                                visible: CFShow(configPvd,i),
                                child: Container(
                                  width: double.infinity,
                                  height: 30  ,
                                  color: Colors.blue,
                                  child: Center(child: Text('Central Filtration Site ${i + 1}',style: TextStyle(color: Colors.white),),),
                                ),
                              ),
                                if(j.value['P_sensor'][0] == true)
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('PS_in')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: j.value['P_sensor'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_CF_P_sensor/${i}/${j.key}/P_sensor/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['P_sensor'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_CF_P_sensor/${i}/${j.key}/P_sensor/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['P_sensor'][2], itemList: getRFnos(configPvd,j.value['P_sensor'][1]), pvdName: 'm_i_CF_P_sensor/${i}/${j.key}/P_sensor/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['P_sensor'][j.value['P_sensor'].length - 1], j.value['P_sensor'][1],j.value['P_sensor'][2],j.value['P_sensor'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[j.value['P_sensor'][j.value['P_sensor'].length - 1], j.value['P_sensor'][1],j.value['P_sensor'][2],j.value['P_sensor'][3] ])['list'], pvdName: 'm_i_CF_P_sensor/${i}/${j.key}/P_sensor/3', index: -1,),
                                      ),
                                      if(width < 400)
                                        Container(
                                            width: 60,
                                            child: MyDropDown(initialValue: j.value['P_sensor'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_CF_P_sensor/${i}/${j.key}/P_sensor/4', index: -1)
                                        )
                                      else
                                        Expanded(
                                            child: MyDropDown(initialValue: j.value['P_sensor'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_CF_P_sensor/${i}/${j.key}/P_sensor/4', index: -1)
                                        )
                                    ],
                                  ),
                                ),
                              if(j.value['P_sensor_out'][0] == true)
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          child: Center(child: Text('PS_out')),
                                        ),
                                      ),
                                      if(width < 400)
                                        Container(
                                          width: 150,
                                          child: MyDropDown(initialValue: j.value['P_sensor_out'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_CF_P_sensor_out/${i}/${j.key}/P_sensor_out/1', index: -1,),
                                        )
                                      else
                                        Expanded(
                                          child: MyDropDown(initialValue: j.value['P_sensor_out'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_CF_P_sensor_out/${i}/${j.key}/P_sensor_out/1', index: -1,),
                                        ),
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['P_sensor_out'][2], itemList: getRFnos(configPvd,j.value['P_sensor_out'][1]), pvdName: 'm_i_CF_P_sensor_out/${i}/${j.key}/P_sensor_out/2', index: -1,),
                                      ),
                                      Expanded(
                                        child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['P_sensor_out'][j.value['P_sensor_out'].length - 1], j.value['P_sensor_out'][1],j.value['P_sensor_out'][2],j.value['P_sensor_out'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[j.value['P_sensor_out'][j.value['P_sensor_out'].length - 1], j.value['P_sensor_out'][1],j.value['P_sensor_out'][2],j.value['P_sensor_out'][3] ])['list'], pvdName: 'm_i_CF_P_sensor_out/${i}/${j.key}/P_sensor_out/3', index: -1,),
                                      ),
                                      if(width < 400)
                                        Container(
                                            width: 60,
                                            child: MyDropDown(initialValue: j.value['P_sensor_out'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_CF_P_sensor_out/${i}/${j.key}/P_sensor_out/4', index: -1)
                                        )
                                      else
                                        Expanded(
                                            child: MyDropDown(initialValue: j.value['P_sensor_out'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_CF_P_sensor_out/${i}/${j.key}/P_sensor_out/4', index: -1)
                                        )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    Visibility(
                      visible: SPShow(configPvd),
                      child: Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Source Pumps',style: TextStyle(color: Colors.white),),),
                      ),
                    ),
                    for(var i = 0;i < configPvd.SP_MO.length;i++)
                      for(var j in configPvd.SP_MO[i].entries)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              j.value['water_meter'].length == 0 || j.value['water_meter'][0] == false ? Container() : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorsFindForSP(configPvd,'wm${i}'),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('WM ${i+1}',style: TextStyle(fontWeight: FontWeight.normal))),
                                      ),
                                    ),
                                    if(width < 400)
                                      Container(
                                        width: 150,
                                        child: MyDropDown(initialValue: j.value['water_meter'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_sp_wm/${i}/${j.key}/water_meter/1', index: -1,),
                                      )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['water_meter'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_sp_wm/${i}/${j.key}/water_meter/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: j.value['water_meter'][2], itemList: getRFnos(configPvd,j.value['water_meter'][1]), pvdName: 'm_i_sp_wm/${i}/${j.key}/water_meter/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['water_meter'][j.value['water_meter'].length - 1], j.value['water_meter'][1],j.value['water_meter'][2],j.value['water_meter'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[j.value['water_meter'][j.value['water_meter'].length - 1], j.value['water_meter'][1],j.value['water_meter'][2],j.value['water_meter'][3] ])['list'], pvdName: 'm_i_sp_wm/${i}/${j.key}/water_meter/3', index: -1,),
                                    ),
                                    if(width < 400)
                                      Container(
                                          width: 60,
                                          child: MyDropDown(initialValue: j.value['water_meter'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_sp_wm/${i}/${j.key}/water_meter/4', index: -1)
                                      )
                                    else
                                      Expanded(
                                          child: MyDropDown(initialValue: j.value['water_meter'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_sp_wm/${i}/${j.key}/water_meter/4', index: -1)
                                      )

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    Visibility(
                      visible: IPShow(configPvd),
                      child: Container(
                        width: double.infinity,
                        height: 30  ,
                        color: Colors.blue,
                        child: Center(child: Text('Irrigation pumps',style: TextStyle(color: Colors.white),),),
                      ),
                    ),
                    for(var i = 0;i < configPvd.IP_MO.length;i++)
                      for(var j in configPvd.IP_MO[i].entries)
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              j.value['water_meter'].length == 0 || j.value['water_meter'][0] == false ? Container() : Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorsFindForIP(configPvd,'wm${i}'),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('WM ${i+1}',style: TextStyle(fontWeight: FontWeight.normal),)),
                                      ),
                                    ),
                                    if(width < 400)
                                    Container(
                                      width: 150,
                                      child: MyDropDown(initialValue: j.value['water_meter'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_ip_wm/${i}/${j.key}/water_meter/1', index: -1,),
                                    )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: j.value['water_meter'][1], itemList: getRTUs(configPvd), pvdName: 'm_i_ip_wm/${i}/${j.key}/water_meter/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: j.value['water_meter'][2], itemList: getRFnos(configPvd,j.value['water_meter'][1]), pvdName: 'm_i_ip_wm/${i}/${j.key}/water_meter/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput(j.key,configPvd,[j.value['water_meter'][j.value['water_meter'].length - 1], j.value['water_meter'][1],j.value['water_meter'][2],j.value['water_meter'][3] ])['initialValue'], itemList: returnigListForOutput(j.key,configPvd,[j.value['water_meter'][j.value['water_meter'].length - 1], j.value['water_meter'][1],j.value['water_meter'][2],j.value['water_meter'][3] ])['list'], pvdName: 'm_i_ip_wm/${i}/${j.key}/water_meter/3', index: -1,),
                                    ),
                                    if(width < 400)
                                      Container(
                                          width: 60,
                                          child: MyDropDown(initialValue: j.value['water_meter'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ip_wm/${i}/${j.key}/water_meter/4', index: -1)
                                      )
                                    else
                                      Expanded(
                                          child: MyDropDown(initialValue: j.value['water_meter'][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ip_wm/${i}/${j.key}/water_meter/4', index: -1)
                                      )

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    configPvd.totalAnalogSensor.length == 0 ? Container() : Container(
                      width: double.infinity,
                      height: 30  ,
                      color: Colors.blue,
                      child: Center(child: Text('Analog Sensor',style: TextStyle(color: Colors.white),),),
                    ),
                    for(var i = 0;i < configPvd.totalAnalogSensor.length;i++)
                      Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        child: Center(child: Text('AS ${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                      ),
                                    ),
                                    if(width < 400)
                                    Container(
                                      width: 150,
                                      child: MyDropDown(initialValue: configPvd.totalAnalogSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_analog_sensor/${i}/1', index: -1,),
                                    )
                                    else
                                      Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalAnalogSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_analog_sensor/${i}/1', index: -1,),
                                      ),
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalAnalogSensor[i][2], itemList: getRFnos(configPvd,configPvd.totalAnalogSensor[i][1]), pvdName: 'm_i_analog_sensor/${i}/2', index: -1,),
                                    ),
                                    Expanded(
                                      child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalAnalogSensor[i][configPvd.totalAnalogSensor[i].length - 1], configPvd.totalAnalogSensor[i][1], configPvd.totalAnalogSensor[i][2], configPvd.totalAnalogSensor[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalAnalogSensor[i][configPvd.totalAnalogSensor[i].length - 1], configPvd.totalAnalogSensor[i][1],configPvd.totalAnalogSensor[i][2],configPvd.totalAnalogSensor[i][3]])['list'], pvdName: 'm_i_analog_sensor/${i}/3', index: -1,),
                                    ),
                                    if(width < 400)
                                      Container(
                                          width: 60,
                                          child: MyDropDown(initialValue: configPvd.totalAnalogSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_analog_sensor/${i}/4', index: -1)
                                      )
                                    else
                                      Expanded(
                                          child: MyDropDown(initialValue: configPvd.totalAnalogSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_analog_sensor/${i}/4', index: -1)
                                      )

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    configPvd.totalContact.length == 0 ? Container() : Container(
                      width: double.infinity,
                      height: 30  ,
                      color: Colors.blue,
                      child: Center(child: Text('Contacts',style: TextStyle(color: Colors.white),),),
                    ),
                    for(var i = 0;i < configPvd.totalContact.length;i++)
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(child: Text('CONT${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                    ),
                                  ),
                                  if(width < 400)
                                    Container(
                                      width: 150,
                                      child: MyDropDown(initialValue: configPvd.totalContact[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_contacts/${i}/1', index: -1,),
                                    )
                                  else
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalContact[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_contacts/${i}/1', index: -1,),
                                    ),
                                  Expanded(
                                    child: MyDropDown(initialValue: configPvd.totalContact[i][2], itemList: getRFnos(configPvd,configPvd.totalContact[i][1]), pvdName: 'm_i_contacts/${i}/2', index: -1,),
                                  ),
                                  Expanded(
                                    child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalContact[i][configPvd.totalContact[i].length - 1], configPvd.totalContact[i][1], configPvd.totalContact[i][2], configPvd.totalContact[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalContact[i][configPvd.totalContact[i].length - 1], configPvd.totalContact[i][1],configPvd.totalContact[i][2],configPvd.totalContact[i][3]])['list'], pvdName: 'm_i_contacts/${i}/3', index: -1,),
                                  ),
                                  if(width < 400)
                                    Container(
                                      width: 60,
                                      child: MyDropDown(initialValue: configPvd.totalContact[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_contacts/${i}/4', index: -1)
                                    )
                                  else
                                    Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalContact[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_contacts/${i}/4', index: -1)
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    configPvd.totalPhSensor.length == 0 ? Container() : Container(
                      width: double.infinity,
                      height: 30  ,
                      color: Colors.blue,
                      child: Center(child: Text('Ph sensor',style: TextStyle(color: Colors.white),),),
                    ),
                    for(var i = 0;i < configPvd.totalPhSensor.length;i++)
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(child: Text('PH sensor ${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                    ),
                                  ),
                                  if(width < 400)
                                    Container(
                                      width: 150,
                                      child: MyDropDown(initialValue: configPvd.totalPhSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_ph_sensor/${i}/1', index: -1,),
                                    )
                                  else
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalPhSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_ph_sensor/${i}/1', index: -1,),
                                    ),
                                  Expanded(
                                    child: MyDropDown(initialValue: configPvd.totalPhSensor[i][2], itemList: getRFnos(configPvd,configPvd.totalPhSensor[i][1]), pvdName: 'm_i_ph_sensor/${i}/2', index: -1,),
                                  ),
                                  Expanded(
                                    child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalPhSensor[i][configPvd.totalPhSensor[i].length - 1], configPvd.totalPhSensor[i][1], configPvd.totalPhSensor[i][2], configPvd.totalPhSensor[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalPhSensor[i][configPvd.totalPhSensor[i].length - 1], configPvd.totalPhSensor[i][1],configPvd.totalPhSensor[i][2],configPvd.totalPhSensor[i][3]])['list'], pvdName: 'm_i_ph_sensor/${i}/3', index: -1,),
                                  ),
                                  if(width < 400)
                                    Container(
                                        width: 60,
                                        child: MyDropDown(initialValue: configPvd.totalPhSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ph_sensor/${i}/4', index: -1)
                                    )
                                  else
                                    Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalPhSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ph_sensor/${i}/4', index: -1)
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    configPvd.totalEcSensor.length == 0 ? Container() : Container(
                      width: double.infinity,
                      height: 30  ,
                      color: Colors.blue,
                      child: Center(child: Text('EC sensor',style: TextStyle(color: Colors.white),),),
                    ),
                    for(var i = 0;i < configPvd.totalEcSensor.length;i++)
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(child: Text('EC sensor ${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                    ),
                                  ),
                                  if(width < 400)
                                    Container(
                                      width: 150,
                                      child: MyDropDown(initialValue: configPvd.totalEcSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_ec_sensor/${i}/1', index: -1,),
                                    )
                                  else
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalEcSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_ec_sensor/${i}/1', index: -1,),
                                    ),
                                  Expanded(
                                    child: MyDropDown(initialValue: configPvd.totalEcSensor[i][2], itemList: getRFnos(configPvd,configPvd.totalEcSensor[i][1]), pvdName: 'm_i_ec_sensor/${i}/2', index: -1,),
                                  ),
                                  Expanded(
                                    child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalEcSensor[i][configPvd.totalEcSensor[i].length - 1], configPvd.totalEcSensor[i][1], configPvd.totalEcSensor[i][2], configPvd.totalEcSensor[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalEcSensor[i][configPvd.totalEcSensor[i].length - 1], configPvd.totalEcSensor[i][1],configPvd.totalEcSensor[i][2],configPvd.totalEcSensor[i][3]])['list'], pvdName: 'm_i_ec_sensor/${i}/3', index: -1,),
                                  ),
                                  if(width < 400)
                                    Container(
                                        width: 60,
                                        child: MyDropDown(initialValue: configPvd.totalEcSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ec_sensor/${i}/4', index: -1)
                                    )
                                  else
                                    Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalEcSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_ec_sensor/${i}/4', index: -1)
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    configPvd.totalMoistureSensor.length == 0 ? Container() : Container(
                      width: double.infinity,
                      height: 30  ,
                      color: Colors.blue,
                      child: Center(child: Text('Moisture sensor',style: TextStyle(color: Colors.white),),),
                    ),
                    for(var i = 0;i < configPvd.totalMoistureSensor.length;i++)
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: i % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: Center(child: Text('MS${i+1}',style: width < 400 ? TextStyle(fontWeight: FontWeight.normal) : null,)),
                                    ),
                                  ),
                                  if(width < 400)
                                    Container(
                                      width: 150,
                                      child: MyDropDown(initialValue: configPvd.totalMoistureSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_moisture_sensor/${i}/1', index: -1,),
                                    )
                                  else
                                    Expanded(
                                      child: MyDropDown(initialValue: configPvd.totalMoistureSensor[i][1], itemList: getRTUs(configPvd), pvdName: 'm_i_moisture_sensor/${i}/1', index: -1,),
                                    ),
                                  Expanded(
                                    child: MyDropDown(initialValue: configPvd.totalMoistureSensor[i][2], itemList: getRFnos(configPvd,configPvd.totalMoistureSensor[i][1]), pvdName: 'm_i_moisture_sensor/${i}/2', index: -1,),
                                  ),
                                  Expanded(
                                    child: MyDropDown(initialValue: returnigListForOutput('',configPvd,[configPvd.totalMoistureSensor[i][configPvd.totalMoistureSensor[i].length - 1], configPvd.totalMoistureSensor[i][1], configPvd.totalMoistureSensor[i][2], configPvd.totalMoistureSensor[i][3]])['initialValue'], itemList: returnigListForOutput('1',configPvd,[configPvd.totalMoistureSensor[i][configPvd.totalMoistureSensor[i].length - 1], configPvd.totalMoistureSensor[i][1],configPvd.totalMoistureSensor[i][2],configPvd.totalMoistureSensor[i][3]])['list'], pvdName: 'm_i_moisture_sensor/${i}/3', index: -1,),
                                  ),
                                  if(width < 400)
                                    Container(
                                        width: 60,
                                        child: MyDropDown(initialValue: configPvd.totalMoistureSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_moisture_sensor/${i}/4', index: -1)
                                    )
                                  else
                                    Expanded(
                                        child: MyDropDown(initialValue: configPvd.totalMoistureSensor[i][4], itemList: configPvd.i_o_types, pvdName: 'm_i_moisture_sensor/${i}/4', index: -1)
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                  ],
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  Map<String,dynamic> returnigListForRtu(String autoIncrement,ConfigMakerProvider configPvd,String value){
    List<String> list = [];
    String myValue = '';
    for(var i in configPvd.irrigationLines){
      if(i['autoIncrement'].toString() == autoIncrement){
        list = i['myRTU_list'];
      }
      if(!list.contains(value)){
        myValue = '-';
      }else{
        myValue = value;
      }
    }
    return {'initialValue' : myValue,'list' : list};
  }
  List<String> getRTUs(ConfigMakerProvider configPvd){
    List<String> list = ['-'];
    if(configPvd.rtuForLine_others.length != 0){
      list.add('ORO RTU');
    }
    if(configPvd.switchForLine_others.length != 0){
      list.add('ORO Switch');
    }
    if(configPvd.OroSmartRtuForLine_others.length != 0){
      list.add('ORO Smart RTU');
    }
    if(configPvd.OroSenseForLine_others != 0){
      list.add('ORO Sense');
    }
    return list;
  }
  List<String> getRFnos(ConfigMakerProvider configPvd,String title){
    List<String> list = ['-'];
    if(title == 'ORO RTU'){
      for(var i in configPvd.rtuForLine_others){
        list.add('${i}');
      }
    }else if(title == 'ORO Switch'){
      for(var i in configPvd.switchForLine_others){
        list.add('${i}');
      }
    }else if(title == 'ORO Smart RTU'){
      for(var i in configPvd.OroSmartRtuForLine_others){
        list.add('${i}');
      }
    }else if(title == 'ORO Sense'){
      for(var i in configPvd.OroSenseForLine_others){
        list.add('${i}');
      }
    }
    return list;
  }
  Map<String,dynamic> returnigListForRfNo(String autoIncrement,ConfigMakerProvider configPvd,List<String> valueList){
    List<String> list = ['-'];
    String myValue = '';
    for(var i in configPvd.irrigationLines){
      if(i['autoIncrement'].toString() == autoIncrement){
        if(valueList[0] == 'ORO RTU'){
          for(var i in i['myRTU']){
            list.add(i.toString());
          }
        }else if(valueList[0] == 'ORO Switch'){
          for(var i in i['myOROswitch']){
            list.add(i.toString());
          }
        }else if(valueList[0] == 'ORO Smart RTU'){
          for(var i in i['myOroSmartRtu']){
            list.add(i.toString());
          }
        }else if(valueList[0] == 'ORO Sense'){
          for(var i in i['myOROsense']){
            list.add(i.toString());
          }
        }
      }
      if(!list.contains(valueList[1])){
        myValue = '-';
      }else{
        myValue = valueList[1];
      }
    }
    return {'initialValue' : myValue,'list' : list};
  }
  Map<String,dynamic> returnigListForOutput(String autoIncrement,ConfigMakerProvider configPvd,List<String> valueList){
    List<String> list = ['-'];
    List<dynamic> overall = [];
    List<dynamic> overall_for_others = [];
    List<dynamic> overall_for_sensors_contacts = [];
    String myValue = '-';
    if(valueList[1] == 'ORO Smart RTU'){
      if(valueList[2] != '-'){
        for(var i = 0;i < 16;i++){
          list.add('${i + 1}');
        }
      }
    }else if(valueList[1] == 'ORO RTU'){
      for(var i = 0;i < 8;i++){
        list.add('${i + 1}');
      }
    }else if(valueList[1] == 'ORO Switch'){
      for(var i = 0;i < 4;i++){
        list.add('${i + 1}');
      }
    }else if(valueList[1] == 'ORO Sense'){
      for(var i = 0;i < 4;i++){
        list.add('${i + 1}');
      }
    }
    for(var i in configPvd.totalAnalogSensor){
      overall_for_sensors_contacts.add(i);
    }
    for(var i in configPvd.totalEcSensor){
      overall_for_sensors_contacts.add(i);
    }
    for(var i in configPvd.totalPhSensor){
      overall_for_sensors_contacts.add(i);
    }
    for(var i in configPvd.totalMoistureSensor){
      overall_for_sensors_contacts.add(i);
    }
    for(var i in configPvd.totalContact){
      overall_for_sensors_contacts.add(i);
    }
    for(var i in configPvd.CD_for_MO){
      for(var j in i.entries){
        for(var k in j.value['dosing_meter']){
          overall_for_others.add(k);
        }
      }
    }
    for(var i in configPvd.CF_for_MO){
      for(var j in i.entries){
        if(j.value['P_sensor'].length != 0){
          overall_for_others.add(j.value['P_sensor']);
        }
      }
    }
    for(var i in configPvd.SP_MO){
      for(var j in i.entries){
        if(j.value['water_meter'].length != 0){
          overall_for_others.add(j.value['water_meter']);
        }
      }
    }
    for(var i in configPvd.IP_MO){
      for(var j in i.entries){
        if(j.value['water_meter'].length != 0){
          overall_for_others.add(j.value['water_meter']);
        }
      }
    }

    for(var i in configPvd.previousDataOfM_I){
      for(var j in i.entries){
        for(var k in j.value['ORO_sense']){
          overall.add(k);
        }
        if(j.value['pressure_sensor'].length != 0){
          overall.add(j.value['pressure_sensor']);
        }
        if(j.value['water_meter'].length != 0){
          overall.add(j.value['water_meter']);
        }
        for(var k in j.value['dosing_meter']){
          overall.add(k);
        }
        if(j.value['D_pressure_sensor'].length != 0){
          overall.add(j.value['D_pressure_sensor']);
        }
        if(j.value['D_pressure_sensor_out'].length != 0){
          overall.add(j.value['D_pressure_sensor_out']);
        }
      }
    }
    for(var i in overall){
      if(i[i.length - 1] != valueList[0] && i[1] != '-' && i[1] == valueList[1] && i[2] == valueList[2] && i[2] != '-' && i[3] != '-' ){
        list.remove('${i[3]}');

      }
    }
    for(var i in overall_for_others){
      if(i[i.length - 1] != valueList[0] && i[1] != '-' && i[1] == valueList[1] && i[2] == valueList[2] && i[2] != '-' && i[3] != '-' ){
        list.remove('${i[3]}');
      }
    }
    for(var i in overall_for_sensors_contacts){
      if(i[i.length - 1] != valueList[0] && i[1] != '-' && i[1] == valueList[1] && i[2] == valueList[2] && i[2] != '-' && i[3] != '-' ){
        list.remove('${i[3]}');
      }
    }
    myValue = valueList[3];
    return {'initialValue' : myValue,'list' : list};
  }

  bool lineShow(ConfigMakerProvider configPvd,int index){
    bool show = false;
    for(var i = 0; i < configPvd.mappingOfInputs.length;i++){
      for(var j in configPvd.mappingOfInputs[i].entries){
        if(j.value['pressure_sensor'].length != 0 || j.value['water_meter'].length != 0 || j.value['ORO_sense'].length != 0 || j.value['dosing_meter'].length != 0 || j.value['D_pressure_sensor'].length != 0 || j.value['D_pressure_sensor_out'].length != 0){
          if(index == i){
            show = true;
          }
          break;
        }
      }
    }
    return show;
  }
  bool CDShow(ConfigMakerProvider configPvd,int index){
    bool show = false;
    for(var i = 0; i < configPvd.CD_for_MO.length;i++){
      if(i == index){
        for(var j in configPvd.CD_for_MO[i].entries){
          for(var k = 0;k < j.value['dosing_meter'].length;k++){
            if(j.value['dosing_meter'][k][0] == true){
              show = true;
            }
          }
        }
      }
    }
    return show;
  }
  bool CFShow(ConfigMakerProvider configPvd,int index){
    bool show = false;
    for(var i = 0; i < configPvd.CF_for_MO.length;i++){
      if(i == index){
        for(var j in configPvd.CF_for_MO[i].entries){
          if(j.value['P_sensor'][0] == true){
            show = true;
          }
          if(j.value['P_sensor_out'][0] == true){
            show = true;
          }
        }
      }
    }
    return show;
  }
  bool SPShow(ConfigMakerProvider configPvd){
    bool show = false;
    for(var i = 0; i < configPvd.SP_MO.length;i++){
      for(var j in configPvd.SP_MO[i].entries){
        if(j.value['water_meter'][0] == true){
          show = true;
        }
      }
    }
    return show;
  }
  bool IPShow(ConfigMakerProvider configPvd){
    bool show = false;
    for(var i = 0; i < configPvd.IP_MO.length;i++){
      for(var j in configPvd.IP_MO[i].entries){
        if(j.value['water_meter'][0] == true){
          show = true;
        }
      }
    }
    return show;
  }
  Color colorsFind(Map<String,dynamic> object,String title){
    var myList = [];
    for(var i in object.entries){
      if(i.key == 'ORO_sense'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }
      }
      if(i.key == 'dosing_meter'){
        if(i.value.length!= 0){
          myList.addAll(i.value);
        }
      }
      if(i.key == 'D_pressure_sensor'){
        if(i.value.length!= 0){
          myList.add(i.value);
        }
      }
      if(i.key == 'D_pressure_sensor_out'){
        if(i.value.length!= 0){
          myList.add(i.value);
        }
      }
      if(i.key == 'water_meter'){
        if(i.value.length!= 0){
          myList.add(i.value);
        }
      }
      if(i.key == 'pressure_sensor'){
        if(i.value.length!= 0){
          myList.add(i.value);
        }
      }

    }
    for(var i = 0;i < myList.length;i++){
      if(myList[i][0] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }
  Color colorsFindForCD(Map<String,dynamic> object,String title){
    var myList = [];
    for(var k = 0;k < object['dosing_meter'].length;k++){
      if(object['dosing_meter'][k][0] == true){
        myList.add('dm${k}');
      }
    }
    for(var i = 0;i < myList.length;i++){
      if(myList[i] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }
  Color colorsFindForSP(ConfigMakerProvider configPvd,String title){
    var myList = [];

    for(var i = 0;i < configPvd.SP_MO.length;i++){
      for(var j in configPvd.SP_MO[i].entries){
        if(j.value['water_meter'][0] == true){
          myList.add('wm${i}');
        }
      }
    }


    for(var i = 0;i < myList.length;i++){
      if(myList[i] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }
  Color colorsFindForIP(ConfigMakerProvider configPvd,String title){
    var myList = [];

    for(var i = 0;i < configPvd.IP_MO.length;i++){
      for(var j in configPvd.IP_MO[i].entries){
        if(j.value['water_meter'][0] == true){
          myList.add('wm${i}');
        }
      }
    }


    for(var i = 0;i < myList.length;i++){
      if(myList[i] == title){
        if(i % 2 == 0){
          return Colors.blue.shade50;
        }else{
          return Colors.blue.shade100;
        }
      }
    }
    return Colors.white;
  }

}
