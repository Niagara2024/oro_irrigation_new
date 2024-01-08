import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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
      color: Color(0xFFF3F3F3),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 5,right: 5),
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
              reOrderFunction: (){
                List<int> list1 = [];
                for(var i = 0;i < configPvd.irrigationLines.length;i++){
                  list1.add(i+1);
                }
                showDialog(context: context, builder: (BuildContext context){
                  return ReOrderInIL(list: list1);
                });
              },
              addButtonFunction: (){
                if(configPvd.totalIrrigationLine == 0){
                  showDialog(
                      context: context,
                      builder: (context){
                        return showingMessage('Oops!', 'The irrigation line limit is achieved!..', context);
                      }
                  );
                }else if(configPvd.totalValve == 0){
                  showDialog(
                      context: context,
                      builder: (context){
                        return showingMessage('Oops!', 'The valve limit is achieved!..', context);
                      }
                  );
                }else{
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
                }
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
                                color: Colors.indigo.shade50,
                                border: Border(
                                  bottom: BorderSide(width: 1),
                                  right: BorderSide(width: 1),
                                  left: BorderSide(width: 1),
                                  top: BorderSide(width: 1),
                                )
                            ),
                            padding: EdgeInsets.only(top: 8),
                            width: 60,
                            height: 50,
                            child: Column(
                              children: [
                                Text('Line',style: HeadingFont,),
                                Text('(${configPvd.totalIrrigationLine})',style: HeadingFont,),
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
                                    Visibility(
                                      visible : configPvd.irrigationLines[i]['deleted'] == true ? false : true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            border: Border(
                                              bottom: BorderSide(width: 1),
                                              left: BorderSide(width: 1),
                                              right: BorderSide(width: 1),
                                            )
                                        ),
                                        width: 60,
                                        height: 51,
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
                                            Center(child: Text('${i + 1}',style: TextStyle(fontSize: 12,color: Colors.black))),
                                          ],
                                        ),
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
                                fixTopBtmRgt('Valve','(${configPvd.totalValve})'),
                                fixTopBtmRgt('Main','Valve(${configPvd.totalMainValve})'),
                                fixTopBtmRgt('Moisture','Sensor(${configPvd.totalMoistureSensor})'),
                                fixTopBtmRgt('Level','Sensor(${configPvd.totalLevelSensor})'),
                                fixTopBtmRgt('Fogger','(${configPvd.totalFogger})'),
                                fixTopBtmRgt('Fan','(${configPvd.totalFan})'),
                                fixTopBtmRgt('Central','Dosing'),
                                fixTopBtmRgt('Central','Filtration'),
                                fixTopBtmRgt('Local','Dosing'),
                                fixTopBtmRgt('Local','Filtration'),
                                fixTopBtmRgt('P.Sensor','In(${configPvd.total_p_sensor})'),
                                fixTopBtmRgt('P.Sensor','Out(${configPvd.total_p_sensor})'),
                                fixTopBtmRgt('Irr.','Pump'),
                                fixTopBtmRgt('Water','Meter(${configPvd.totalWaterMeter})'),
                                // fixTopBtmRgt('ORO Smart','(${configPvd.totalOroSmartRTU})'),
                                // fixTopBtmRgt('ORO Smart','Plus(${configPvd.totalOroSmartRtuPlus})'),
                                // fixTopBtmRgt('RTU','(${configPvd.totalRTU})'),
                                // fixTopBtmRgt('RTU_Plus','(${configPvd.totalRtuPlus})'),
                                // fixTopBtmRgt('ORO','Switch(${configPvd.totalOroSwitch})'),
                                // fixTopBtmRgt('ORO','Sense(${configPvd.totalOroSense})'),
                                // fixTopBtmRgt('ORO','Level(${configPvd.totalOroLevel})'),
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
                                        Visibility(
                                          visible : configPvd.irrigationLines[i]['deleted'] == true ? false : true,
                                          child: Container(
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
                                                  height: 50,
                                                  child: TextFieldForConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['valve']}', config: configPvd, purpose: 'irrigationLinesFunctionality/valve',),
                                                ),
                                                configPvd.totalMainValve == 0 && configPvd.irrigationLines[i]['main_valve'] == '' ?
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: notAvailable,
                                                ) : Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['main_valve']}', config: configPvd, purpose: 'irrigationLinesFunctionality/mainValve',),
                                                ),
                                                configPvd.totalMoistureSensor == 0 && configPvd.irrigationLines[i]['moistureSensor'] == '' ?
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: notAvailable,
                                                ) : Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['moistureSensor']}', config: configPvd, purpose: 'irrigationLinesFunctionality/moistureSensor',),
                                                ),
                                                configPvd.totalLevelSensor == 0 && configPvd.irrigationLines[i]['levelSensor'] == '' ?
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: notAvailable,
                                                ) : Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['levelSensor']}', config: configPvd, purpose: 'irrigationLinesFunctionality/levelSensor',),
                                                ),
                                                configPvd.totalFogger == 0 && configPvd.irrigationLines[i]['fogger'] == '' ?
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: notAvailable,
                                                ) : Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['fogger']}', config: configPvd, purpose: 'irrigationLinesFunctionality/fogger',),
                                                ),
                                                configPvd.totalFan == 0 && configPvd.irrigationLines[i]['fan'] == '' ?
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: notAvailable,
                                                ) : Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                  width: 80,
                                                  height: 50,
                                                  child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['fan']}', config: configPvd, purpose: 'irrigationLinesFunctionality/fan',),
                                                ),
                                                Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(right: BorderSide(width: 1)),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                                    width: 80,
                                                    height: 50,
                                                    child: MyDropDown(initialValue: configPvd.irrigationLines[i]['Central_dosing_site'], itemList: configPvd.central_dosing_site_list , pvdName: 'editCentralDosing', index: i)
                                                ),
                                                Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(right: BorderSide(width: 1)),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                                    width: 80,
                                                    height: 50,
                                                    child: MyDropDown(initialValue: configPvd.irrigationLines[i]['Central_filtration_site'], itemList: configPvd.central_filtration_site_list , pvdName: 'editCentralFiltration', index: i)
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 80,
                                                  height: 50,
                                                  child: (configPvd.totalInjector == 0 &&  configPvd.irrigationLines[i]['Local_dosing_site'] == false) ?
                                                  notAvailable :
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
                                                  height: 50,
                                                  child: (configPvd.totalFilter == 0 &&  configPvd.irrigationLines[i]['local_filtration_site'] == false) ?
                                                  notAvailable :
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
                                                  height: 50,
                                                  child: (configPvd.total_p_sensor == 0 && configPvd.irrigationLines[i]['pressureIn'].isEmpty) ?
                                                  notAvailable :
                                                  Checkbox(
                                                      value: configPvd.irrigationLines[i]['pressureIn'].isEmpty ? false : true,
                                                      onChanged: (value){
                                                        configPvd.irrigationLinesFunctionality(['editPressureSensorInConnection',i,value]);
                                                      }),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 80,
                                                  height: 50,
                                                  child: (configPvd.total_p_sensor == 0 && configPvd.irrigationLines[i]['pressureOut'].isEmpty) ?
                                                  notAvailable :
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
                                                    height: 50,
                                                    child: MyDropDown(initialValue: configPvd.irrigationLines[i]['irrigationPump'], itemList: getIpList(configPvd) , pvdName: 'editIrrigationPump', index: i)
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border(right: BorderSide(width: 1)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                                  width: 80,
                                                  height: 50,
                                                  child: (configPvd.totalWaterMeter == 0 && configPvd.irrigationLines[i]['water_meter'].isEmpty) ?
                                                  notAvailable :
                                                  Checkbox(
                                                      value: configPvd.irrigationLines[i]['water_meter'].isEmpty ? false : true,
                                                      onChanged: (value){
                                                        configPvd.irrigationLinesFunctionality(['editWaterMeter',i,value]);
                                                      }),
                                                ),
                                                // configPvd.totalOroSmartRTU == 0 && configPvd.irrigationLines[i]['ORO_Smart_RTU'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.symmetric(horizontal: 5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_Smart_RTU']}', config: configPvd, purpose: 'irrigationLinesFunctionality/OroSmartRtu',)),
                                                // ),
                                                // configPvd.totalOroSmartRtuPlus == 0 && configPvd.irrigationLines[i]['ORO_Smart_RTU_Plus'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.symmetric(horizontal: 5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_Smart_RTU_Plus']}', config: configPvd, purpose: 'irrigationLinesFunctionality/OroSmartRtuPlus',)),
                                                // ),
                                                // configPvd.totalRTU == 0 && configPvd.irrigationLines[i]['RTU'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['RTU']}', config: configPvd, purpose: 'irrigationLinesFunctionality/RTU',)),
                                                // ),
                                                // configPvd.totalRtuPlus == 0 && configPvd.irrigationLines[i]['RTU_Plus'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['RTU_Plus']}', config: configPvd, purpose: 'irrigationLinesFunctionality/RTU_Plus',)),
                                                // ),
                                                // configPvd.totalOroSwitch == 0 && configPvd.irrigationLines[i]['ORO_switch'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_switch']}', config: configPvd, purpose: 'irrigationLinesFunctionality/0roSwitch',)),
                                                // ),
                                                // configPvd.totalOroSense == 0 && configPvd.irrigationLines[i]['ORO_sense'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.symmetric(horizontal: 5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_sense']}', config: configPvd, purpose: 'irrigationLinesFunctionality/0roSense',)),
                                                // ),
                                                // configPvd.totalOroLevel == 0 && configPvd.irrigationLines[i]['ORO_level'] == '' ?
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.all(5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: notAvailable,
                                                // ) : Container(
                                                //   decoration: BoxDecoration(
                                                //     border: Border(right: BorderSide(width: 1)),
                                                //   ),
                                                //   padding: EdgeInsets.symmetric(horizontal: 5),
                                                //   width: 80,
                                                //   height: 50,
                                                //   child: Center(child: TextFieldForFlexibleConfig(index: i, initialValue: '${configPvd.irrigationLines[i]['ORO_level']}', config: configPvd, purpose: 'irrigationLinesFunctionality/0roLevel',)),
                                                // ),
                                              ],
                                            ),
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
class ReOrderInIL extends StatefulWidget {
  final List<int> list;
  const ReOrderInIL({super.key, required this.list});

  @override
  State<ReOrderInIL> createState() => _ReOrderInILState();
}

class _ReOrderInILState extends State<ReOrderInIL> {

  late int oldIndex;
  late int newIndex;
  List<int> ilData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ilData = widget.list;
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return AlertDialog(
      title: Text('Re-Order Irrigation Line',style: TextStyle(color: Colors.black),),
      content: Container(
        width: 250,
        height: 250,
        child: Center(
          child: ReorderableGridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            primary: true,
            children: [
              for(var i = 0;i < ilData.length;i++)
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  width: 50,
                  height: 50 ,
                  key: ValueKey('IL${ilData[i]}'),
                  child: GestureDetector(child: Center(child: Text('IL${ilData[i]}'))),
                )
            ],
            onReorder: (oldIND, newIND) {
              setState(() {
                oldIndex = oldIND;
                newIndex = newIND;
                var removeData = ilData[oldIND];
                ilData.removeAt(oldIND);
                ilData.insert(newIND, removeData);
              });
            },
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('Cancel')
        ),
        TextButton(
            onPressed: (){
              configPvd.irrigationLinesFunctionality(['reOrderIl',oldIndex,newIndex]);
              Navigator.pop(context);
            },
            child: Text('Change')
        )
      ],
    );
  }
}
