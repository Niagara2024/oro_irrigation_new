import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/text_form_field_for_config_flexible.dart';



class LocalDosingTable extends StatefulWidget {
  const LocalDosingTable({super.key});

  @override
  State<LocalDosingTable> createState() => _LocalDosingTableState();
}

class _LocalDosingTableState extends State<LocalDosingTable> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        //color: Color(0xFFF3F3F3),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            configButtons(
              local: true,
              selectFunction: (value){
                setState(() {
                  configPvd.localDosingFunctionality(['edit_l_DosingSelection',value]);
                });
              },
              selectAllFunction: (value){
                setState(() {
                  configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',value]);
                });
              },
              cancelButtonFunction: (){
                configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',false]);
                configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
                configPvd.cancelSelection();
              },
              addBatchButtonFunction: (){

              },
              addButtonFunction: (){
              },
              deleteButtonFunction: (){
                configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
                configPvd.localDosingFunctionality(['deleteLocalDosing']);
                configPvd.cancelSelection();
              },
              selectionCount: configPvd.selection,
              singleSelection: configPvd.l_dosingSelection,
              multipleSelection: configPvd.l_dosingSelectAll,
            ),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('#',style: TextStyle(color: Colors.white),),
                          // Text('(${configPvd.totalCentralDosing})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                            left: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Booster',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalBooster})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ec',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalEcSensor})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Ph',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalPhSensor})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Pressure',style: TextStyle(color: Colors.white),),
                          Text('Switch(${configPvd.totalPressureSwitch})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Injector',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalInjector})',style: TextStyle(color: Colors.white),),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Dosing',style: TextStyle(color: Colors.white),),
                          Text('Meter(${configPvd.totalDosingMeter})',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Which',style: TextStyle(color: Colors.white),),
                          Text('Bp',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),


                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: configPvd.localDosingUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      decoration: BoxDecoration(
                          color: index % 2 == 0 ? Colors.white : Color(0XFFF3F3F3),
                          border: Border(bottom: BorderSide(width: 1))
                      ),
                      margin: index == configPvd.localDosingUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1)),
                              ),
                              height: (configPvd.localDosingUpdated[index]['injector'].length) * 60,
                              width: double.infinity,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(configPvd.l_dosingSelection == true || configPvd.l_dosingSelectAll == true)
                                      Checkbox(
                                          fillColor: MaterialStateProperty.all(Colors.white),
                                          checkColor: myTheme.primaryColor,
                                          value: configPvd.localDosingUpdated[index]['selection'] == 'select' ? true : false,
                                          onChanged: (value){
                                            configPvd.localDosingFunctionality(['selectLocalDosing',index]);
                                          }),
                                    Text('${configPvd.localDosingUpdated[index]['line']}',style: TextStyle(color: Colors.black),),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1)),
                                ),
                                height: (configPvd.localDosingUpdated[index]['injector'].length) * 60,
                                width: double.infinity,
                                child : configPvd.totalBooster == 0 && configPvd.localDosingUpdated[index]['boosterPump'] == '' ?
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: 80,
                                  height: 60,
                                  child: Center(
                                    child: Text('N/A',style: TextStyle(fontSize: 12)),
                                  ),
                                ) : Center(
                                  child: TextFieldForFlexibleConfig(index: index, initialValue: '${configPvd.localDosingUpdated[index]['boosterPump']}', config: configPvd, purpose: 'localDosingFunctionality/editBoosterPump',),
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1)),
                                ),
                                height: (configPvd.localDosingUpdated[index]['injector'].length) * 60,
                                width: double.infinity,
                                child : configPvd.totalEcSensor == 0 && configPvd.localDosingUpdated[index]['ec'] == '' ?
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: 80,
                                  height: 60,
                                  child: Center(
                                    child: Text('N/A',style: TextStyle(fontSize: 12)),
                                  ),
                                ) : Center(
                                    child: TextFieldForFlexibleConfig(index: index, initialValue: '${configPvd.localDosingUpdated[index]['ec']}', config: configPvd, purpose: 'localDosingFunctionality/editEcSensor',)
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1)),
                                ),
                                height: (configPvd.localDosingUpdated[index]['injector'].length) * 60,
                                width: double.infinity,
                                child : configPvd.totalPhSensor == 0 && configPvd.localDosingUpdated[index]['ph'] == '' ?
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: 80,
                                  height: 60,
                                  child: Center(
                                    child: Text('N/A',style: TextStyle(fontSize: 12)),
                                  ),
                                ) : Center(
                                    child: TextFieldForFlexibleConfig(index: index, initialValue: '${configPvd.localDosingUpdated[index]['ph']}', config: configPvd, purpose: 'localDosingFunctionality/editPhSensor',)
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(width: 1)),
                              ),
                              width: double.infinity,
                              height: (configPvd.localDosingUpdated[index]['injector'].length) * 60 ,
                              child: (configPvd.totalPressureSwitch == 0 && configPvd.localDosingUpdated[index]['pressureSwitch'].isEmpty) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.localDosingUpdated[index]['pressureSwitch'].isEmpty ? false : true,
                                  onChanged: (value){
                                    configPvd.localDosingFunctionality(['editPressureSwitch',index,value]);
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    for(var i = 0; i< configPvd.localDosingUpdated[index]['injector'].length;i ++)
                                      Container(
                                        child: Center(child: Text('${i+1}')),
                                        height: 60,
                                        decoration:  BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(width: i == configPvd.localDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                            )
                                        ),
                                      )
                                  ],
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    for(var i = 0; i< configPvd.localDosingUpdated[index]['injector'].length;i ++)
                                      Container(
                                        width: double.infinity,
                                        decoration:  BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(width: i == configPvd.localDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                            )
                                        ),
                                        height: 60,
                                        child: (configPvd.totalDosingMeter == 0 && configPvd.localDosingUpdated[index]['injector'][i]['dosingMeter'].isEmpty) ?
                                        Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                        Checkbox(
                                            value: configPvd.localDosingUpdated[index]['injector'][i]['dosingMeter'].isEmpty ? false : true,
                                            onChanged: (value){
                                              configPvd.localDosingFunctionality(['editDosingMeter',index,i,value]);
                                            }),
                                      ),
                                  ],
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    for(var i = 0; i< configPvd.localDosingUpdated[index]['injector'].length;i ++)
                                      Container(
                                        width: double.infinity,
                                        decoration:  BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(width: i == configPvd.localDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                            )
                                        ),
                                        height: 60,
                                        child: Center(
                                          child: DropdownButton(
                                              focusColor: Colors.transparent,
                                              //style: ioText,
                                              value: configPvd.localDosingUpdated[index]['injector'][i]['Which_Booster_Pump'],
                                              underline: Container(),
                                              items: giveBoosterSelection(configPvd.localDosingUpdated[index]['boosterConnection'].length,configPvd).map((String items) {
                                                return DropdownMenuItem(
                                                  value: items,
                                                  child: Container(
                                                      child: Text(items,style: TextStyle(fontSize: 11,color: Colors.black),)
                                                  ),
                                                );
                                              }).toList(),
                                              // After selecting the desired option,it will
                                              // change button value to selected value
                                              onChanged: (newValue) {
                                                configPvd.localDosingFunctionality(['boosterSelectionForInjector',index,i,newValue]);
                                              }
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                            ),
                          ),
                          // Expanded(
                          //   child: Container(
                          //       decoration: BoxDecoration(
                          //           border: Border(right: BorderSide(width: 1))
                          //       ),
                          //       width: double.infinity,
                          //       child: Column(
                          //         children: [
                          //           for(var i = 0; i< configPvd.centralDosing[index].length - 1;i ++)
                          //             Container(
                          //               width: double.infinity,
                          //               decoration:  BoxDecoration(
                          //                   border: Border(
                          //                       bottom: BorderSide(width: i == configPvd.centralDosing[index].length - 2 ? 0 : 1)
                          //                   )
                          //               ),
                          //               height: 60,
                          //               child: (configPvd.totalBooster == 0 && configPvd.centralDosing[index][i][2] == false) ?
                          //               Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                          //               Checkbox(
                          //                   value: configPvd.centralDosing[index][i][2],
                          //                   onChanged: (value){
                          //                     configPvd.centralDosingFunctionality(['editBooster',index,i,value]);
                          //                   }),
                          //             ),
                          //         ],
                          //       )
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }

  List<String> giveBoosterSelection(int count,ConfigMakerProvider configPvd){
    var list = ['-'];
    for(var i = 0; i< count;i++){
      list.add('BP ${i+1}');
    }
    return list;
  }
}
