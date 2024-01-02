import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../../constants/theme.dart';
import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/drop_down_button.dart';



class IrrigationPumpTable extends StatefulWidget {
  const IrrigationPumpTable({super.key});

  @override
  State<IrrigationPumpTable> createState() => _IrrigationPumpTableState();
}

class _IrrigationPumpTableState extends State<IrrigationPumpTable> {
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
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5,),
            configButtons(
                selectFunction: (value){
                  setState(() {
                    configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelection',value]);
                  });
                },
                selectAllFunction: (value){
                  setState(() {
                    configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelectAll',value]);
                  });
                },
                cancelButtonFunction: (){
                  configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelection',false]);
                  configPvd.cancelSelection();
                },
                addButtonFunction: (){
                  if(configPvd.totalIrrigationPump == 0){
                    showDialog(
                        context: context,
                        builder: (context){
                          return showingMessage('Oops!', 'The irrigation pump limit is achieved!..', context);
                        }
                    );
                  }else{
                    configPvd.irrigationPumpFunctionality(['addIrrigationPump']);
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 500), // Adjust the duration as needed
                      curve: Curves.easeInOut, // Adjust the curve as needed
                    );
                  }
                },
                reOrderFunction: (){
                  List<int> list1 = [];
                  for(var i = 0;i < configPvd.irrigationPumpUpdated.length;i++){
                    list1.add(i+1);
                  }
                  showDialog(context: context, builder: (BuildContext context){
                    return ReOrderInIrrigationPump(list: list1);
                  });
                },
                deleteButtonFunction: (){
                  configPvd.irrigationPumpFunctionality(['deleteIrrigationPump']);
                  configPvd.cancelSelection();
                },
                addBatchButtonFunction: () {
                  showDialog(context: context, builder: (context){

                    return Consumer<ConfigMakerProvider>(builder: (context,configPvd,child){
                      if(configPvd.totalIrrigationPump == 0){
                        return showingMessage('Oops!', 'The irrigation pump limit is achieved!..', context);
                      }else{
                        return AlertDialog(
                          backgroundColor: myTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(0))
                          ),
                          title: Text('Add Batch of Pumps with Same Properties',style: TextStyle(color: Colors.white,fontSize: 14),),
                          content: SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text('No of pumps',style: TextStyle(color: Colors.indigo.shade50,fontSize: 14),),
                                    trailing: DropdownButton(
                                        value: configPvd.val,
                                        icon: Icon(Icons.arrow_drop_down,color: Colors.white,),
                                        dropdownColor: Colors.black87,
                                        // focusColor: Colors.white,
                                        underline: Container(),
                                        items: dropDownList(configPvd.totalIrrigationPump).map((String items) {
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
                                          configPvd.editVal(value!);
                                        }),
                                  ),
                                  ListTile(
                                    title: Text('Water meter per pumps',style: TextStyle(color: Colors.indigo.shade50,fontSize: 14),),
                                    trailing: int.parse(configPvd.val) > configPvd.totalWaterMeter ?  Text('N/A',style: TextStyle(color: Colors.white),) : Checkbox(
                                        checkColor: Colors.black,
                                        value: configPvd.wmYesOrNo,
                                        fillColor: MaterialStateProperty.all(Colors.amberAccent),
                                        onChanged: (value){
                                          configPvd.editWmYesOrNo(value);
                                        }
                                    ),
                                  ),
                                ],
                              )
                          ),
                          actions: [
                            InkWell(
                                onTap: (){
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
                                configPvd.irrigationPumpFunctionality(['addBatch',configPvd.val,configPvd.wmYesOrNo]);
                                configPvd.editVal('1');
                                configPvd.editWmYesOrNo(false);
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
                selectionCount: configPvd.selection,
                singleSelection: configPvd.irrigationPumpSelection,
                multipleSelection: configPvd.irrigationPumpSelectAll
            ),
            Container(
              child: Row(
                children: [
                  topBtmLftRgt('Irrigation', 'Pump(${configPvd.totalIrrigationPump})'),
                  topBtmRgt('Water','Meter(${configPvd.totalWaterMeter})'),
                  topBtmRgt('ORO','pump'),
                  topBtmRgt('ORO Pump','Plus'),
                  topBtmRgt('Relay','count'),
                  topBtmRgt('Level','Type'),
                  topBtmRgt('Top','tank(high)'),
                  topBtmRgt('Top','tank(low)'),
                  topBtmRgt('Sump','tank(high)'),
                  topBtmRgt('Sump','tank(low)'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: configPvd.irrigationPumpUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Visibility(
                      visible: configPvd.irrigationPumpUpdated[index]['deleted'] == true ? false : true,
                      child: Container(
                        margin: index == configPvd.irrigationPumpUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1)),
                          color: Colors.white70,

                        ),
                        width: width-20,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if(configPvd.irrigationPumpSelection == true || configPvd.irrigationPumpSelectAll == true)
                                        Checkbox(
                                            value: configPvd.irrigationPumpUpdated[index]['selection'] == 'select' ? true : false,
                                            onChanged: (value){
                                              configPvd.irrigationPumpFunctionality(['selectIrrigationPump',index]);
                                            }),
                                      Text('${index + 1}'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == true || (configPvd.totalWaterMeter == 0 && configPvd.irrigationPumpUpdated[index]['waterMeter'].isEmpty)) ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['waterMeter'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editWaterMeter',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['oro_pump'],
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editOroPump',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['oro_pump_plus'],
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editOroPumpPlus',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(right: BorderSide(width: 1))
                                  ),
                                  width: double.infinity,
                                  height: 50,
                                  child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == true || configPvd.irrigationPumpUpdated[index]['oro_pump_plus'] == true) ?
                                  MyDropDown(initialValue: configPvd.irrigationPumpUpdated[index]['relayCount'], itemList: ['1','2','3','4'], pvdName: 'editRelayCount_ip', index: index) : notAvailable
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(right: BorderSide(width: 1))
                                  ),
                                  width: double.infinity,
                                  height: 50,
                                  child: configPvd.irrigationPumpUpdated[index]['oro_pump_plus'] == true ? MyDropDown(initialValue: configPvd.irrigationPumpUpdated[index]['levelType'], itemList: ['-','ADC level','RS485 level','float level'], pvdName: 'editLevelType_ip', index: index) : notAvailable
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.irrigationPumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['TopTankHigh'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editTopTankHigh',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.irrigationPumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['TopTankLow'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editTopTankLow',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.irrigationPumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['SumpTankHigh'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editSumpTankHigh',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.irrigationPumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.irrigationPumpUpdated[index]['SumpTankLow'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editSumpTankLow',index,value]);
                                    }),
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
}
class ReOrderInIrrigationPump extends StatefulWidget {
  final List<int> list;
  const ReOrderInIrrigationPump({super.key, required this.list});

  @override
  State<ReOrderInIrrigationPump> createState() => _ReOrderInIrrigationPumpState();
}

class _ReOrderInIrrigationPumpState extends State<ReOrderInIrrigationPump> {

  late int oldIndex;
  late int newIndex;
  List<int> pumpData = [];
  @override
  Widget buildItem(String text) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(5)
      ),
      width: 50,
      height: 50 ,
      key: ValueKey('P${text}'),
      child: Center(child: Text('P${text}')),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pumpData = widget.list;
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return AlertDialog(
      title: Text('Re-Order Pump',style: TextStyle(color: Colors.black),),
      content: Container(
        width: 250,
        height: 250,
        child: Center(
          child: ReorderableGridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: pumpData.map((e) => buildItem("${e}")).toList(),
            primary: true,
            onReorder: (oldIND, newIND) {
              setState(() {
                oldIndex = oldIND;
                newIndex = newIND;
                var removeData = pumpData[oldIND];
                pumpData.removeAt(oldIND);
                pumpData.insert(newIND, removeData);
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
              configPvd.irrigationPumpFunctionality(['reOrderPump',oldIndex,newIndex]);
              Navigator.pop(context);
            },
            child: Text('Change')
        )
      ],
    );
  }
}
