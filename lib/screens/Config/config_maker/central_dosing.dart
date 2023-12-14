import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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
                  return AlertDialog(
                    title: Text('Add batch',style: TextStyle(color: Colors.black),),
                    content: AddBatchCD(),
                  );
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
                configPvd.centralDosingFunctionality(['addCentralDosing']);
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500), // Adjust the duration as needed
                  curve: Curves.easeInOut, // Adjust the curve as needed
                );
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
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('#',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalCentralDosing})',style: TextStyle(color: Colors.white),),
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
                                height: (configPvd.centralDosingUpdated[index]['injector'].length) * 60,
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
                                  height: (configPvd.centralDosingUpdated[index]['injector'].length) * 60,
                                  width: double.infinity,
                                  child : configPvd.totalBooster == 0 && configPvd.centralDosingUpdated[index]['boosterPump'] == '' ?
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    width: 80,
                                    height: 60,
                                    child: Center(
                                      child: Text('N/A',style: TextStyle(fontSize: 12)),
                                    ),
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
                                  height: (configPvd.centralDosingUpdated[index]['injector'].length) * 60,
                                  width: double.infinity,
                                  child : configPvd.totalEcSensor == 0 && configPvd.centralDosingUpdated[index]['ec'] == '' ?
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    width: 80,
                                    height: 60,
                                    child: Center(
                                      child: Text('N/A',style: TextStyle(fontSize: 12)),
                                    ),
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
                                  height: (configPvd.centralDosingUpdated[index]['injector'].length) * 60,
                                  width: double.infinity,
                                  child : configPvd.totalPhSensor == 0 && configPvd.centralDosingUpdated[index]['ph'] == '' ?
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    width: 80,
                                    height: 60,
                                    child: Center(
                                      child: Text('N/A',style: TextStyle(fontSize: 12)),
                                    ),
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
                                height: (configPvd.centralDosingUpdated[index]['injector'].length) * 60 ,
                                child: (configPvd.totalPressureSwitch == 0 && configPvd.centralDosingUpdated[index]['pressureSwitch'].isEmpty) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
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
                                          height: 60,
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
                                          height: 60,
                                          child: (configPvd.totalDosingMeter == 0 && configPvd.centralDosingUpdated[index]['injector'][i]['dosingMeter'].isEmpty) ?
                                          Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
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
                                          height: 60,
                                          child: Center(
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
                                          ),
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

class AddBatchCD extends StatefulWidget {
  const AddBatchCD({super.key});

  @override
  State<AddBatchCD> createState() => _AddBatchCDState();
}

class _AddBatchCDState extends State<AddBatchCD> {
  int totalSite = 0;
  String injector = '-';
  bool d_meter = false;
  bool d_meter_value = false;
  bool booster = false;
  bool booster_value = false;
  FocusNode myFocus = FocusNode();
  late TextEditingController myController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myController = TextEditingController();
    if(myFocus.hasFocus == false){
      if(myController.text == ''){
        totalSite = 0;
      }
    }

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
              Text('No of dosing sites : ',style: TextStyle(color: Colors.black,fontSize: 14)),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 40,
                    child: TextFormField(
                      focusNode: myFocus,
                      controller: myController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      onFieldSubmitted: (value){
                        if(value == ''){
                          myController.text = '1';
                        }
                      },
                      maxLength: 2,
                      onChanged: (value){
                        setState(() {
                          injector = '-';
                          booster_value = false;
                          d_meter_value = false;
                        });
                        if(value == '0' ){
                          myController.text = '1';
                        }
                        var total = configPvd.totalCentralDosing - int.parse(myController.text == '' ? '0' : myController.text);
                        int value1 = 0;
                        if(total < 0){
                          value1 = int.parse(myController.text) + total;
                          myController.text = value1.toString();
                        }
                        setState(() {
                          totalSite = int.parse(myController.text == '' ? '0' : myController.text);
                        });
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
                  ),
                  Text('(${configPvd.totalCentralDosing})')
                ],
              ),

            ],
          ),
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
                      totalSite = 0;
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
                      configPvd.centralDosingFunctionality(['addBatch_CD',totalSite,int.parse(injector),d_meter_value,booster_value]);
                    }
                    setState(() {
                      totalSite = 0;
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
    if(totalSite != 0){
      for(var i = 0;i < 6;i++){
        if(totalSite * (i+1) <= configPvd.totalInjector){
          myList.add('${i+1}');
        }
      }
    }
    return myList;
  }
  bool give_D_meter(ConfigMakerProvider configPvd){
    if(injector != '-'){
      if(configPvd.totalDosingMeter - (totalSite * int.parse(injector))  < 0){
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
      if(configPvd.totalBooster - (totalSite * int.parse(injector))  < 0){
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

