import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../../constants/theme.dart';
import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/text_form_field_for_config_flexible.dart';


class CentralDosingTable extends StatefulWidget {
  const CentralDosingTable({super.key});

  @override
  State<CentralDosingTable> createState() => _CentralDosingTableState();
}

class _CentralDosingTableState extends State<CentralDosingTable> {

  bool selectButton = false;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var configPvd = Provider.of<ConfigMakerProvider>(context,listen: false);
        configPvd.sourcePumpFunctionality(['editsourcePumpSelection',false]);
        configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelection',false]);
        configPvd.centralDosingFunctionality(['c_dosingSelectAll',false]);
        configPvd.centralDosingFunctionality(['c_dosingSelection',false]);
        configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',false]);
        configPvd.centralFiltrationFunctionality(['centralFiltrationSelectAll',false]);
        configPvd.irrigationLinesFunctionality(['editIrrigationSelection',false]);
        configPvd.irrigationLinesFunctionality(['editIrrigationSelectAll',false]);
        configPvd.localDosingFunctionality(['edit_l_DosingSelectAll',false]);
        configPvd.localDosingFunctionality(['edit_l_DosingSelection',false]);
        configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',false]);
        configPvd.localFiltrationFunctionality(['edit_l_filtrationSelectALL',false]);
        configPvd.cancelSelection();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        color: Color(0xFFF3F3F3),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            configButtons(
              selectFunction: (value){
                setState(() {
                  configPvd.centralDosingFunctionality(['c_dosingSelection',value]);
                });
              },
              selectAllFunction: (value){
                setState(() {
                  configPvd.centralDosingFunctionality(['c_dosingSelectAll',value]);
                });
              },
              cancelButtonFunction: (){
                configPvd.centralDosingFunctionality(['c_dosingSelectAll',false]);
                configPvd.centralDosingFunctionality(['c_dosingSelection',false]);
                configPvd.cancelSelection();
              },
              addBatchButtonFunction: (){
                showDialog(context: context, builder: (BuildContext context){
                  return Consumer<ConfigMakerProvider>(builder: (context,configPvd,child){
                    if(configPvd.totalCentralDosing == 0){
                      return showingMessage('Oops!', 'The dosing site limit is achieved!..', context);
                    }else if(configPvd.totalInjector == 0){
                      return showingMessage('Oops!', 'The injector limit is achieved!..', context);
                    }else{
                      return AlertDialog(
                        backgroundColor: myTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0))
                        ),
                        title: Text('Add Batch of Dosing Sites',style: TextStyle(color: Colors.white,fontSize: 14),),
                        content: SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text('No of Dosing sites',style: TextStyle(color: Colors.indigo.shade50,fontSize: 14),),
                                  trailing: DropdownButton(
                                      value: configPvd.cdSite,
                                      icon: Icon(Icons.arrow_drop_down,color: Colors.white,),
                                      dropdownColor: Colors.black87,
                                      // focusColor: Colors.white,
                                      underline: Container(),
                                      items: dropDownList(configPvd.totalCentralDosing).map((String items) {
                                        return DropdownMenuItem(
                                          onTap: (){
                                          },
                                          value: items,
                                          child: Container(
                                              child: Text(items,style: TextStyle(fontSize: 11,color: Colors.white),)
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value){
                                        configPvd.editTotalSite(value!);
                                        configPvd.editInjector('1');
                                      }),
                                ),
                                ListTile(
                                  title: Text('no of injector per site',style: TextStyle(color: Colors.indigo.shade50,fontSize: 14),),
                                  trailing: int.parse(configPvd.cdSite) > configPvd.totalInjector ?  Text('N/A',style: TextStyle(color: Colors.white),) : DropdownButton(
                                      value: configPvd.injector,
                                      icon: Icon(Icons.arrow_drop_down,color: Colors.white,),
                                      dropdownColor: Colors.black87,
                                      // focusColor: Colors.white,
                                      underline: Container(),
                                      items: dropDownList(configPvd.totalInjector ~/ int.parse(configPvd.cdSite)).map((String items) {
                                        return DropdownMenuItem(
                                          onTap: (){
                                          },
                                          value: items,
                                          child: Container(
                                              child: Text(items,style: TextStyle(fontSize: 11,color: Colors.white),)
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value){
                                        configPvd.editInjector(value!);
                                      }),
                                ),
                              ],
                            )
                        ),
                        actions: [
                          InkWell(
                              onTap: (){
                                configPvd.editTotalSite('1');
                                configPvd.editInjector('1');
                                Navigator.pop(context);
                              },
                              child: Container(
                                child: Center(
                                  child: Text('cancel',style: TextStyle(color: Colors.indigo.shade50,fontSize: 16),
                                  ),
                                ),
                                width : 80,
                                height: 30,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.5,color: Colors.indigo.shade50),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                              )
                          ),
                          InkWell(
                            onTap: (){
                              configPvd.centralDosingFunctionality(['addBatch_CD',int.parse(configPvd.cdSite),configPvd.totalInjector == 0 ? 0 : int.parse(configPvd.injector)]);
                              configPvd.editTotalSite('1');
                              configPvd.editInjector('1');
                              Navigator.pop(context);
                            },
                            child: Container(
                              child: Center(
                                child: Text('ok',style: TextStyle(color: Colors.black,fontSize: 16),
                                ),
                              ),
                              width: 80,
                              height: 30,
                              color: Colors.indigo.shade50,
                            ),
                          )
                        ],
                      );
                    }

                  });

                });
              },
              reOrderFunction: (){
                List<int> list1 = [];
                for(var i = 0;i < configPvd.centralDosingUpdated.length;i++){
                  list1.add(i+1);
                }
                showDialog(context: context, builder: (BuildContext context){
                  return ReOrderInCdSite(list: list1);
                });
              },
              addButtonFunction: (){
                if(configPvd.totalCentralDosing == 0){
                  showDialog(
                      context: context,
                      builder: (context){
                        return showingMessage('Oops!', 'The dosing site limit is achieved!..', context);
                      }
                  );
                }else if(configPvd.totalInjector == 0){
                  showDialog(
                      context: context,
                      builder: (context){
                        return showingMessage('Oops!', 'The injector limit is achieved!..', context);
                      }
                  );
                }else{
                  configPvd.centralDosingFunctionality(['addCentralDosing']);
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 500), // Adjust the duration as needed
                    curve: Curves.easeInOut, // Adjust the curve as needed
                  );
                }
              },
              deleteButtonFunction: (){
                configPvd.centralDosingFunctionality(['c_dosingSelection',false]);
                configPvd.centralDosingFunctionality(['deleteCentralDosing']);
                configPvd.cancelSelection();
              },
              selectionCount: configPvd.selection,
              singleSelection: configPvd.c_dosingSelection,
              multipleSelection: configPvd.c_dosingSelectAll,
            ),
            Container(
              child: Row(
                children: [
                  topBtmLftRgt('Site', '(${configPvd.totalCentralDosing})'),
                  topBtmRgt('Booster','(${configPvd.totalBooster})'),
                  topBtmRgt('Ec','(${configPvd.totalEcSensor})'),
                  topBtmRgt('Ph','(${configPvd.totalPhSensor})'),
                  topBtmRgt('Pressure','Switch(${configPvd.totalPressureSwitch})'),
                  topBtmRgt('Injector','(${configPvd.totalInjector})'),
                  topBtmRgt('Dosing','Meter(${configPvd.totalDosingMeter})'),
                  topBtmRgt('Level','Sensor(${configPvd.totalLevelSensor})'),
                  topBtmRgt('Injector','type'),
                  topBtmRgt('Select','Bp'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: configPvd.centralDosingUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Visibility(
                      visible: configPvd.centralDosingUpdated[index]['deleted'] == true ? false : true,
                      child: Container(
                        decoration: BoxDecoration(
                            color: index % 2 == 0 ? Colors.white : Color(0XFFF3F3F3),
                            border: Border(bottom: BorderSide(width: 1))
                        ),
                        margin: index == configPvd.centralDosingUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1)),
                                ),
                                height: (configPvd.centralDosingUpdated[index]['injector'].length) * 50,
                                width: double.infinity,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if(configPvd.c_dosingSelection == true || configPvd.c_dosingSelectAll == true)
                                        Checkbox(
                                            value: configPvd.centralDosingUpdated[index]['selection'] == 'select' ? true : false,
                                            onChanged: (value){
                                              configPvd.centralDosingFunctionality(['selectCentralDosing',index]);
                                            }),
                                      Text('${index + 1}',style: TextStyle(color: Colors.black),),
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
                                  height: (configPvd.centralDosingUpdated[index]['injector'].length) * 50,
                                  width: double.infinity,
                                  child : configPvd.totalBooster == 0 && configPvd.centralDosingUpdated[index]['boosterPump'] == '' ?
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 50,
                                      child: notAvailable
                                  ) : Center(
                                    child: TextFieldForFlexibleConfig(index: index, initialValue: '${configPvd.centralDosingUpdated[index]['boosterPump']}', config: configPvd, purpose: 'centralDosingFunctionality/editBoosterPump',),
                                  )
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1)),
                                  ),
                                  height: (configPvd.centralDosingUpdated[index]['injector'].length) * 50,
                                  width: double.infinity,
                                  child : configPvd.totalEcSensor == 0 && configPvd.centralDosingUpdated[index]['ec'] == '' ?
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 50,
                                      child: notAvailable
                                  ) : Center(
                                      child: TextFieldForFlexibleConfig(index: index, initialValue: '${configPvd.centralDosingUpdated[index]['ec']}', config: configPvd, purpose: 'centralDosingFunctionality/editEcSensor',)
                                  )
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1)),
                                  ),
                                  height: (configPvd.centralDosingUpdated[index]['injector'].length) * 50,
                                  width: double.infinity,
                                  child : configPvd.totalPhSensor == 0 && configPvd.centralDosingUpdated[index]['ph'] == '' ?
                                  Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      height: 50,
                                      child: notAvailable
                                  ) : Center(
                                      child: TextFieldForFlexibleConfig(index: index, initialValue: '${configPvd.centralDosingUpdated[index]['ph']}', config: configPvd, purpose: 'centralDosingFunctionality/editPhSensor',)
                                  )
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1)),
                                ),
                                width: double.infinity,
                                height: (configPvd.centralDosingUpdated[index]['injector'].length) * 50 ,
                                child: (configPvd.totalPressureSwitch == 0 && configPvd.centralDosingUpdated[index]['pressureSwitch'].isEmpty) ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.centralDosingUpdated[index]['pressureSwitch'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.centralDosingFunctionality(['editPressureSwitch',index,value]);
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
                                      for(var i = 0; i< configPvd.centralDosingUpdated[index]['injector'].length;i ++)
                                        Container(
                                          child: Center(child: Text('${i+1}')),
                                          height: 50,
                                          decoration:  BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(width: i == configPvd.centralDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
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
                                      for(var i = 0; i< configPvd.centralDosingUpdated[index]['injector'].length;i ++)
                                        Container(
                                          width: double.infinity,
                                          decoration:  BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(width: i == configPvd.centralDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                              )
                                          ),
                                          height: 50,
                                          child: (configPvd.totalDosingMeter == 0 && configPvd.centralDosingUpdated[index]['injector'][i]['dosingMeter'].isEmpty) ?
                                          notAvailable :
                                          Checkbox(
                                              value: configPvd.centralDosingUpdated[index]['injector'][i]['dosingMeter'].isEmpty ? false : true,
                                              onChanged: (value){
                                                configPvd.centralDosingFunctionality(['editDosingMeter',index,i,value]);
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
                                      for(var i = 0; i< configPvd.centralDosingUpdated[index]['injector'].length;i ++)
                                        Container(
                                          width: double.infinity,
                                          decoration:  BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(width: i == configPvd.centralDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                              )
                                          ),
                                          height: 50,
                                          child: (configPvd.totalLevelSensor == 0 && configPvd.centralDosingUpdated[index]['injector'][i]['levelSensor'].isEmpty) ?
                                          notAvailable :
                                          Checkbox(
                                              value: configPvd.centralDosingUpdated[index]['injector'][i]['levelSensor'].isEmpty ? false : true,
                                              onChanged: (value){
                                                configPvd.centralDosingFunctionality(['editLevelSensor',index,i,value]);
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
                                      for(var i = 0; i< configPvd.centralDosingUpdated[index]['injector'].length;i ++)
                                        Container(
                                          width: double.infinity,
                                          decoration:  BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(width: i == configPvd.centralDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                              )
                                          ),
                                          height: 50,
                                          child: Center(
                                            child: DropdownButton(
                                                focusColor: Colors.transparent,
                                                value: configPvd.centralDosingUpdated[index]['injector'][i]['injectorType'],
                                                underline: Container(),
                                                items: ['Venturi','Electrical'].map((String items) {
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
                                                  configPvd.centralDosingFunctionality(['editInjectorType',index,i,newValue]);
                                                }
                                            ),
                                          ),
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
                                      for(var i = 0; i< configPvd.centralDosingUpdated[index]['injector'].length;i ++)
                                        Container(
                                          width: double.infinity,
                                          decoration:  BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(width: i == configPvd.centralDosingUpdated[index]['injector'].length - 1 ? 0 : 1)
                                              )
                                          ),
                                          height: 50,
                                          child: configPvd.centralDosingUpdated[index]['injector'][i]['injectorType'] == 'Electrical' ? Center(
                                            child: DropdownButton(
                                                focusColor: Colors.transparent,
                                                //style: ioText,
                                                value: configPvd.centralDosingUpdated[index]['injector'][i]['Which_Booster_Pump'],
                                                underline: Container(),
                                                items: giveBoosterSelection(configPvd.centralDosingUpdated[index]['boosterConnection'].length,configPvd).map((String items) {
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
                                                  configPvd.centralDosingFunctionality(['boosterSelectionForInjector',index,i,newValue]);
                                                }
                                            ),
                                          ) : notAvailable,
                                        ),
                                    ],
                                  )
                              ),
                            ),
                          ],
                        ),
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

class ReOrderInCdSite extends StatefulWidget {
  final List<int> list;
  const ReOrderInCdSite({super.key, required this.list});

  @override
  State<ReOrderInCdSite> createState() => _ReOrderInCdSiteState();
}

class _ReOrderInCdSiteState extends State<ReOrderInCdSite> {

  late int oldIndex;
  late int newIndex;
  List<int> cdData = [];

  @override
  Widget buildItem(String text) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(5)
      ),
      width: 50,
      height: 50 ,
      key: ValueKey('CD${text}'),
      child: Center(child: Text('CD${text}')),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cdData = widget.list;
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return AlertDialog(
      title: Text('Re-Order Central Dosing Site',style: TextStyle(color: Colors.black),),
      content: Container(
        width: 250,
        height: 250,
        child: Center(
          child: ReorderableGridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: cdData.map((e) => buildItem("${e}")).toList(),
            onReorder: (oldIND, newIND) {
              setState(() {
                oldIndex = oldIND;
                newIndex = newIND;
                var removeData = cdData[oldIND];
                cdData.removeAt(oldIND);
                cdData.insert(newIND, removeData);
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
              configPvd.centralDosingFunctionality(['reOrderCdSite',oldIndex,newIndex]);
              Navigator.pop(context);
            },
            child: Text('Change')
        )
      ],
    );
  }
}

