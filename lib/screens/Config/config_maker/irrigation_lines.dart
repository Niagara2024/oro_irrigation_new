import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/drop_down_button.dart';
import '../../../widgets/text_form_field_config.dart';
import '../../../widgets/text_form_field_for_config_flexible.dart';


class IrrigationLineTable extends StatefulWidget {
  const IrrigationLineTable({super.key});

  @override
  State<IrrigationLineTable> createState() => _IrrigationLineTableState();
}

class _IrrigationLineTableState extends State<IrrigationLineTable> {
  bool listReady = false;
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  bool selectButton = false;
  bool delete = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Container(
      //color: Color(0xFFF3F3F3),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 5,right: 5,top: 5),
            child: configButtons(
              selectFunction: (value){
                setState(() {
                  configPvd.irrigationLinesFunctionality(['editIrrigationSelection',value]);
                });
              },
              selectAllFunction: (value){
                configPvd.irrigationLinesFunctionality(['editIrrigationSelectAll',value]);
              },
              cancelButtonFunction: (){
                configPvd.irrigationLinesFunctionality(['editIrrigationSelection',false]);
                configPvd.irrigationLinesFunctionality(['editIrrigationSelectAll',false]);
                configPvd.cancelSelection();
              },
              addBatchButtonFunction: (){

              },
              addButtonFunction: (){
                configPvd.irrigationLinesFunctionality(['addIrrigationLine']);
                _verticalScroll1.animateTo(
                  _verticalScroll1.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500), // Adjust the duration as needed
                  curve: Curves.easeInOut, // Adjust the curve as needed
                );
                _verticalScroll2.animateTo(
                  _verticalScroll2.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500), // Adjust the duration as needed
                  curve: Curves.easeInOut, // Adjust the curve as needed
                );
              },
              deleteButtonFunction: (){
                configPvd.irrigationLinesFunctionality(['editIrrigationSelection',false]);
                configPvd.irrigationLinesFunctionality(['deleteIrrigationLine']);
                configPvd.cancelSelection();
                setState(() {
                  delete = true;
                });
              },
              selectionCount: configPvd.selection,
              singleSelection: configPvd.irrigationSelection,
              multipleSelection: configPvd.irrigationSelectAll,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 5,right: 5),
              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                var width = constraints.maxWidth;
                return Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                border: Border(
                                  bottom: BorderSide(width: 1),
                                  right: BorderSide(width: 1),
                                  left: BorderSide(width: 1),
                                  top: BorderSide(width: 1),
                                )
                            ),
                            padding: EdgeInsets.only(top: 8),
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Text('Line',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                                Text('(${configPvd.totalIrrigationLine})',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white),),
                              ],
                            )
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _verticalScroll1,
                            child: Container(
                              child: Column(
                                children: [
                                  for(var i = 0;i < configPvd.irrigationLines.length; i++)
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.blueGrey,
                                          border: Border(
                                            bottom: BorderSide(width: 1),
                                            left: BorderSide(width: 1),
                                            right: BorderSide(width: 1),
                                          )
                                      ),
                                      width: 60,
                                      height: 61,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if(configPvd.irrigationSelection == true || configPvd.irrigationSelectAll == true)
                                            Checkbox(
                                                fillColor: MaterialStateProperty.all(Colors.white),
                                                checkColor: myTheme.primaryColor,
                                                value: configPvd.irrigationLines[i]['isSelected'] == 'select' ? true : false,
                                                onChanged: (value){
                                                  configPvd.irrigationLinesFunctionality(['selectIrrigationLine',i,value]);
                                                }),
                                          Center(child: Text('${i + 1}',style: TextStyle(fontSize: 12,color: Colors.white))),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: width-60,
                          child: SingleChildScrollView(
                            controller: _horizontalScroll1,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Valve',style: TextStyle(fontSize: 14,color: Colors.white),),
                                      Text('(${configPvd.totalValve})',style: TextStyle(fontSize: 14,color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Main',style: TextStyle(fontSize: 14,color: Colors.white),),
                                      Text('Valve(${configPvd.totalMainValve})',style: TextStyle(fontSize: 14,color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Moisture',style: TextStyle(fontSize: 14,color: Colors.white),),
                                      Text('Sensor(${configPvd.totalMoistureSensor})',style: TextStyle(fontSize: 14,color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Level',style: TextStyle(fontSize: 14,color: Colors.white),),
                                      Text('Sensor(${configPvd.totalLevelSensor})',style: TextStyle(fontSize: 14,color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Fogger',style: TextStyle(fontSize: 14,color: Colors.white),),
                                      Text('(${configPvd.totalFogger})',style: TextStyle(fontSize: 14,color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Fan',style: TextStyle(fontSize: 14,color: Colors.white),),
                                      Text('(${configPvd.totalFan})',style: TextStyle(fontSize: 14,color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Central',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Dosing',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Central',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Filtration',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Local',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Dosing',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Local',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Filtration',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Press.Sen',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('In(${configPvd.total_p_sensor})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Press.Sens',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Out(${configPvd.total_p_sensor})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Irr.',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Pump',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('Water',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Meter(${configPvd.totalWaterMeter})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('O_S_RTU',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('(${configPvd.totalOroSmartRTU})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 80,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('RTU',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('(${configPvd.totalRTU})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 90,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('ORO',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Switch(${configPvd.totalOroSwitch})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      border: Border(
                                        top: BorderSide(width: 1),
                                        bottom: BorderSide(width: 1),
                                        right: BorderSide(width: 1),
                                      )
                                  ),
                                  padding: EdgeInsets.only(top: 8),
                                  width: 90,
                                  height: 60,
                                  child: Column(
                                    children: [
                                      Text('ORO',style: TextStyle(fontSize: 14, color: Colors.white),),
                                      Text('Sense(${configPvd.totalOroSense})',style: TextStyle(fontSize: 14, color: Colors.white),),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: width-60 ,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _horizontalScroll2,
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  controller: _verticalScroll2,
                                  child: Column(
                                    children: [
                                      for(var i = 0;i < configPvd.irrigationLines.length; i++)
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(width: 1)),
                                            color: i % 2 == 0 ? Colors.white : Color(0XFFF3F3F3),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 60,
                                                child: TextFieldForConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['valve']}', config: configPvd, purpose: 'irrigationLinesFunctionality/valve',),
                                              ),
                                              configPvd.totalMainValve == 0 && configPvd.irrigationLines[i]['main_valve'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 60,
                                                child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['main_valve']}', config: configPvd, purpose: 'irrigationLinesFunctionality/mainValve',),
                                              ),
                                              configPvd.totalMoistureSensor == 0 && configPvd.irrigationLines[i]['moistureSensor'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['moistureSensor']}', config: configPvd, purpose: 'irrigationLinesFunctionality/moistureSensor',),
                                              ),
                                              configPvd.totalLevelSensor == 0 && configPvd.irrigationLines[i]['levelSensor'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['levelSensor']}', config: configPvd, purpose: 'irrigationLinesFunctionality/levelSensor',),
                                              ),
                                              configPvd.totalFogger == 0 && configPvd.irrigationLines[i]['fogger'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['fogger']}', config: configPvd, purpose: 'irrigationLinesFunctionality/fogger',),
                                              ),
                                              configPvd.totalFan == 0 && configPvd.irrigationLines[i]['fan'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['fan']}', config: configPvd, purpose: 'irrigationLinesFunctionality/fan',),
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 80,
                                                  height: 60,
                                                  child: MyDropDown(initialValue: configPvd.irrigationLines[i]['Central_dosing_site'], itemList: configPvd.central_dosing_site_list , pvdName: 'editCentralDosing', index: i)
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 80,
                                                  height: 60,
                                                  child: MyDropDown(initialValue: configPvd.irrigationLines[i]['Central_filtration_site'], itemList: configPvd.central_filtration_site_list , pvdName: 'editCentralFiltration', index: i)
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                width: 80,
                                                height: 60,
                                                child: (configPvd.totalInjector == 0 &&  configPvd.irrigationLines[i]['Local_dosing_site'] == false) ?
                                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                                Checkbox(
                                                    value:  configPvd.irrigationLines[i]['Local_dosing_site'],
                                                    onChanged: (value){
                                                      if(value == true){
                                                        showDialog(context: context, builder: (BuildContext context){
                                                          return AlertDialog(
                                                            title: Text('Add batch',style: TextStyle(color: Colors.black),),
                                                            content: ldBatch(index: i, value: value!,),
                                                          );
                                                        });
                                                      }else{
                                                        configPvd.irrigationLinesFunctionality(['editLocalDosing',i,value!]);
                                                      }
                                                    }),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                width: 80,
                                                height: 60,
                                                child: (configPvd.totalFilter == 0 &&  configPvd.irrigationLines[i]['local_filtration_site'] == false) ?
                                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                                Checkbox(
                                                    value:  configPvd.irrigationLines[i]['local_filtration_site'],
                                                    onChanged: (value){
                                                      configPvd.irrigationLinesFunctionality(['editLocalFiltration',i,value]);
                                                    }),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                width: 80,
                                                height: 60,
                                                child: (configPvd.total_p_sensor == 0 && configPvd.irrigationLines[i]['pressureIn'].isEmpty) ?
                                                const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                                Checkbox(
                                                    value: configPvd.irrigationLines[i]['pressureIn'].isEmpty ? false : true,
                                                    onChanged: (value){
                                                      configPvd.irrigationLinesFunctionality(['editPressureSensorInConnection',i,value]);
                                                    }),
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                width: 80,
                                                height: 60,
                                                child: (configPvd.total_p_sensor == 0 && configPvd.irrigationLines[i]['pressureOut'].isEmpty) ?
                                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                                Checkbox(
                                                    value: configPvd.irrigationLines[i]['pressureOut'].isEmpty ? false : true,
                                                    onChanged: (value){
                                                      configPvd.irrigationLinesFunctionality(['editPressureSensorOutConnection',i,value]);
                                                    }),
                                              ),
                                              Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 80,
                                                  height: 60,
                                                  child: MyDropDown(initialValue: configPvd.irrigationLines[i]['irrigationPump'], itemList: getIpList(configPvd) , pvdName: 'editIrrigationPump', index: i)
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                width: 80,
                                                height: 60,
                                                child: (configPvd.totalWaterMeter == 0 && configPvd.irrigationLines[i]['water_meter'].isEmpty) ?
                                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                                Checkbox(
                                                    value: configPvd.irrigationLines[i]['water_meter'].isEmpty ? false : true,
                                                    onChanged: (value){
                                                      configPvd.irrigationLinesFunctionality(['editWaterMeter',i,value]);
                                                    }),
                                              ),
                                              configPvd.totalOroSmartRTU == 0 && configPvd.irrigationLines[i]['ORO_Smart_RTU'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 5),
                                                width: 80,
                                                height: 60,
                                                child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_Smart_RTU']}', config: configPvd, purpose: 'irrigationLinesFunctionality/OroSmartRtu',)),
                                              ),
                                              configPvd.totalRTU == 0 && configPvd.irrigationLines[i]['RTU'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                  height: 60,
                                                child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['RTU']}', config: configPvd, purpose: 'irrigationLinesFunctionality/RTU',)),
                                              ),
                                              configPvd.totalOroSwitch == 0 && configPvd.irrigationLines[i]['ORO_switch'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 90,
                                                  height: 60,
                                                child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_switch']}', config: configPvd, purpose: 'irrigationLinesFunctionality/0roSwitch',)),
                                              ),
                                              configPvd.totalOroSense == 0 && configPvd.irrigationLines[i]['ORO_sense'] == '' ?
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                padding: EdgeInsets.all(5),
                                                width: 80,
                                                height: 60,
                                                child: Center(
                                                  child: Text('N/A',style: TextStyle(fontSize: 12)),
                                                ),
                                              ) : Container(
                                                decoration: BoxDecoration(
                                                  border: Border(right: BorderSide(width: 1)),
                                                ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 90,
                                                  height: 60,
                                                child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_sense']}', config: configPvd, purpose: 'irrigationLinesFunctionality/0roSense',)),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },),
            ),
          ),
        ],
      ),
    );
  }
  List<String> getIpList(ConfigMakerProvider configPvd){
    var list = ['-'];
    for(var i = 0;i < configPvd.irrigationPumpUpdated.length;i++){
      list.add('${i+1}');
    }
    return list;
  }
}
class ldBatch extends StatefulWidget {
  final int index;
  final bool value;
  const ldBatch({super.key, required this.index, required this.value});

  @override
  State<ldBatch> createState() => _ldBatchState();
}

class _ldBatchState extends State<ldBatch> {
  int line = 1;
  String injector = '-';
  bool d_meter = false;
  bool d_meter_value = false;
  bool booster = false;
  bool booster_value = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Container(
      width: double.infinity,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('No of injector per site : ',style: TextStyle(color: Colors.black,fontSize: 14)),
              DropdownButton(
                value: injector,
                underline: Container(),
                items: getList(configPvd).map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Container(
                        child: Text(items,style: TextStyle(fontSize: 12),)
                    ),
                  );
                }).toList(),
                // After selecting the desired option,it will
                // change button value to selected value
                onChanged: (String? newValue) {
                  setState(() {
                    injector = newValue!;
                  });
                },
              )

            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Dosing meter per injector : ',style: TextStyle(color: Colors.black,fontSize: 14)),
          //     give_D_meter(configPvd) == false ?
          //     Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
          //     Checkbox(
          //         value: d_meter_value,
          //         onChanged: (value){
          //           setState(() {
          //             d_meter_value = value!;
          //           });
          //         }),
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Booster per injector : ',style: TextStyle(color: Colors.black,fontSize: 14)),
          //     give_booster(configPvd) == false ?
          //     Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
          //     Checkbox(
          //         value: booster_value,
          //         onChanged: (value){
          //           setState(() {
          //             booster_value = value!;
          //           });
          //         }),
          //
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                  onPressed: (){
                    Navigator.pop(context);
                    setState(() {
                      line = 0;
                      injector = '-';
                      d_meter = false;
                      d_meter_value = false;
                      booster = false;
                      booster_value = false;
                    });
                  },
                  child: Text('Cancel',style: TextStyle(color: Colors.white),)
              ),
              ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                  onPressed: (){
                    if(injector != '-'){
                      configPvd.irrigationLinesFunctionality(['editLocalDosing',widget.index,widget.value,line,int.parse(injector),d_meter_value,booster_value]);
                    }
                    setState(() {
                      line = 0;
                      injector = '-';
                      d_meter = false;
                      d_meter_value = false;
                      booster = false;
                      booster_value = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Add',style: TextStyle(color: Colors.white))
              ),
            ],
          )
        ],
      ),
    );
  }
  List<String> getList(ConfigMakerProvider configPvd) {
    List<String> myList = ['-'];
    if(line != 0){
      for(var i = 0;i < 6;i++){
        if(line * (i+1) <= configPvd.totalInjector){
          myList.add('${i+1}');
        }
      }
    }
    return myList;
  }
  bool give_D_meter(ConfigMakerProvider configPvd){
    if(injector != '-'){
      if(configPvd.totalDosingMeter - (line * int.parse(injector))  < 0){
        setState(() {
          d_meter = false;
        });
      }else{
        setState(() {
          d_meter = true;
        });
      }
    }

    return d_meter;
  }
  bool give_booster(ConfigMakerProvider configPvd){
    if(injector != '-'){
      if(configPvd.totalBooster - (line * int.parse(injector))  < 0){
        setState(() {
          booster = false;
        });
      }else{
        setState(() {
          booster = true;
        });
      }
    }
    return booster;
  }
}
