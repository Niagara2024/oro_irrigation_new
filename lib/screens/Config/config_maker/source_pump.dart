import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/drop_down_button.dart';

class SourcePumpTable extends StatefulWidget {
  const SourcePumpTable({super.key});

  @override
  State<SourcePumpTable> createState() => _SourcePumpTableState();
}

class _SourcePumpTableState extends State<SourcePumpTable> {
  ScrollController scrollController = ScrollController();
  bool selectButton = false;
  var val = '1';


  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        color: Color(0xFFF3F3F3),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(left: 5,right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5,),
            configButtons(
                selectFunction: (value){
                  configPvd.sourcePumpFunctionality(['editsourcePumpSelection',value]);

                },
                selectAllFunction: (value){
                  configPvd.sourcePumpFunctionality(['editsourcePumpSelectAll',value]);

                },
                cancelButtonFunction: (){
                  configPvd.sourcePumpFunctionality(['editsourcePumpSelection',false]);
                  configPvd.cancelSelection();
                },
                addButtonFunction: (){
                  if(configPvd.totalSourcePump == 0){
                    showDialog(
                        context: context,
                        builder: (context){
                          return showingMessage('Oops!', 'The source pump limit is achieved!..', context);
                        }
                    );
                  }else{
                    configPvd.sourcePumpFunctionality(['addSourcePump']);
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 500), // Adjust the duration as needed
                      curve: Curves.easeInOut, // Adjust the curve as needed
                    );
                  }
                },
                reOrderFunction: (){
                  List<int> list1 = [];
                  for(var i = 0;i < configPvd.sourcePumpUpdated.length;i++){
                    list1.add(i+1);
                  }
                  showDialog(context: context, builder: (BuildContext context){
                    return ReOrderInSourcePump(list: list1,);
                  });
                },
                deleteButtonFunction: (){
                  configPvd.sourcePumpFunctionality(['deleteSourcePump']);
                  configPvd.cancelSelection();
                },
                selectionCount: configPvd.selection,
                singleSelection: configPvd.sourcePumpSelection,
                multipleSelection: configPvd.sourcePumpSelectAll,
                addBatchButtonFunction: () {
                  showDialog(context: context, builder: (context){
                    return Consumer<ConfigMakerProvider>(builder: (context,configPvd,child){
                      if(configPvd.totalSourcePump == 0){
                        return showingMessage('Oops!', 'The source pump limit is achieved!..', context);
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
                                        items: dropDownList(configPvd.totalSourcePump).map((String items) {
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
                                configPvd.sourcePumpFunctionality(['addBatch',configPvd.val,configPvd.wmYesOrNo]);
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
                }
            ),
            Container(
              child: Row(
                children: [
                  topBtmLftRgt('Source', 'Pump(${configPvd.totalSourcePump})'),
                  topBtmRgt('Water','Source(${configPvd.totalWaterSource.length})'),
                  topBtmRgt('Water','Meter(${configPvd.totalWaterMeter})'),
                  topBtmRgt('ORO','pump'),
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
                  itemCount: configPvd.sourcePumpUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Visibility(
                      visible: configPvd.sourcePumpUpdated[index]['deleted'] == true ? false : true,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1)),
                          color: Colors.white70,
                        ),
                        margin: index == configPvd.sourcePumpUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                        // color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
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
                                      if(configPvd.sourcePumpSelection == true || configPvd.sourcePumpSelectAll == true)
                                        Checkbox(
                                            value: configPvd.sourcePumpUpdated[index]['selection'] == 'select' ? true : false,
                                            onChanged: (value){
                                              configPvd.sourcePumpFunctionality(['selectSourcePump',index,value]);
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
                                  child: MyDropDown(initialValue: configPvd.sourcePumpUpdated[index]['waterSource'], itemList: configPvd.waterSource, pvdName: 'editWaterSource_sp', index: index)
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.totalWaterMeter == 0 && configPvd.sourcePumpUpdated[index]['waterMeter'].isEmpty) ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.sourcePumpUpdated[index]['waterMeter'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.sourcePumpFunctionality(['editWaterMeter',index,value]);
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
                                    value: configPvd.sourcePumpUpdated[index]['oro_pump'],
                                    onChanged: (value){
                                      configPvd.sourcePumpFunctionality(['editOroPump',index,value]);
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
                                  child: (configPvd.sourcePumpUpdated[index]['oro_pump'] == false) ?
                                  notAvailable :
                                  MyDropDown(initialValue: configPvd.sourcePumpUpdated[index]['relayCount'], itemList: ['1','2','3','4'], pvdName: 'editRelayCount_sp', index: index)
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(right: BorderSide(width: 1))
                                  ),
                                  width: double.infinity,
                                  height: 50,
                                  child: MyDropDown(initialValue: configPvd.sourcePumpUpdated[index]['levelType'], itemList: ['-','ADC level','RS485 level','float level'], pvdName: 'editLevelType_sp', index: index)
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 50,
                                child: (configPvd.sourcePumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.sourcePumpUpdated[index]['TopTankHigh'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.sourcePumpFunctionality(['editTopTankHigh',index,value]);
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
                                child: (configPvd.sourcePumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.sourcePumpUpdated[index]['TopTankLow'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.sourcePumpFunctionality(['editTopTankLow',index,value]);
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
                                child: (configPvd.sourcePumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.sourcePumpUpdated[index]['SumpTankHigh'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.sourcePumpFunctionality(['editSumpTankHigh',index,value]);
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
                                child: (configPvd.sourcePumpUpdated[index]['levelType'] != 'float level') ?
                                notAvailable :
                                Checkbox(
                                    value: configPvd.sourcePumpUpdated[index]['SumpTankLow'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.sourcePumpFunctionality(['editSumpTankLow',index,value]);
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

class ReOrderInSourcePump extends StatefulWidget {
  final List<int> list;
  const ReOrderInSourcePump({super.key, required this.list});

  @override
  State<ReOrderInSourcePump> createState() => _ReOrderInSourcePumpState();
}

class _ReOrderInSourcePumpState extends State<ReOrderInSourcePump> {

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
              configPvd.sourcePumpFunctionality(['reOrderPump',oldIndex,newIndex]);
              Navigator.pop(context);
            },
            child: Text('Change')
        )
      ],
    );
  }
}


Widget configButtons(
    {
      required Function(bool?) selectFunction,
      required Function(bool?) selectAllFunction,
      required VoidCallback cancelButtonFunction,
      required VoidCallback addButtonFunction,
      required VoidCallback deleteButtonFunction,
      VoidCallback? addBatchButtonFunction,
      VoidCallback? reOrderFunction,
      required int selectionCount,
      required bool singleSelection,
      required bool multipleSelection,
      List<dynamic>? myList,
      bool? local
    }){
  return Container(
    height: 50,
    color: Colors.white,
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if(singleSelection == false)
            Row(
              children: [
                Checkbox(
                  value: singleSelection,
                  onChanged: selectFunction,
                ),
                Text('Select')
              ],
            )
          else
            Row(
              children: [
                IconButton(
                    onPressed: cancelButtonFunction, icon: Icon(Icons.cancel_outlined)),
                Text('${selectionCount}')
              ],
            ),
          if(singleSelection == false)
            if(reOrderFunction != null)
              Row(
                children: [
                  IconButton(
                      onPressed: reOrderFunction,
                      icon: Icon(Icons.reorder)
                  ),
                  Text('Reorder')
                ],
              ),
          if(local == null)
            if(singleSelection == false)
              IconButton(
                color: Colors.black,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)
                ),
                highlightColor: myTheme.primaryColor,
                onPressed: addButtonFunction,
                icon: Icon(Icons.add,color: Colors.white,),
              ),
          if(local == null)
            if(singleSelection == false)
              if(addBatchButtonFunction != null)
                IconButton(
                  splashColor: Colors.grey,
                  color: Colors.black,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blueGrey)
                  ),
                  highlightColor: myTheme.primaryColor,
                  onPressed: addBatchButtonFunction,
                  icon: Icon(Icons.batch_prediction,color: Colors.white,),
                ),

          if(singleSelection == true)
            IconButton(
              color: Colors.black,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)
              ),
              highlightColor: myTheme.primaryColor,
              onPressed: deleteButtonFunction,
              icon: Icon(Icons.delete_forever,color: Colors.white,),
            ),
          if(singleSelection == true)
            Row(
              children: [
                Checkbox(
                    value: multipleSelection,
                    onChanged: selectAllFunction
                ),
                Text('All')
              ],
            ),

        ],
      ),
    ),
  );
}

Widget notAvailable = Center(child: Text('N/A',style: TextStyle(fontSize: 12,color: Colors.black54),));

TextStyle HeadingFont = TextStyle(color: Colors.black);
Widget topBtmRgt(first,second){
  return  Expanded(
    child: Container(
      decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          border: const Border(
            top: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
            right: BorderSide(width: 1),

          )
      ),
      width: double.infinity,
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(first,style: const TextStyle(color: Colors.black),),
          Text(second,style: const TextStyle(color: Colors.black)),
        ],
      ),
    ),
  );
}
Widget topBtmLftRgt(first,second){
  return  Expanded(
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          border: const Border(
            top: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
            right: BorderSide(width: 1),
            left: BorderSide(width: 1),
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(first,style: const TextStyle(color: Colors.black),),
          Text(second,style: const TextStyle(color: Colors.black)),
        ],
      ),
    ),
  );
}

Widget fixTopBtmRgt(first,second){
  return Container(
    decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border(
          top: BorderSide(width: 1),
          bottom: BorderSide(width: 1),
          right: BorderSide(width: 1),
        )
    ),
    padding: EdgeInsets.only(top: 8),
    width: 80,
    height: 50,
    child: Column(
      children: [
        Text(first,style: HeadingFont,),
        Text(second,style: HeadingFont,),
      ],
    ),
  );
}
List<String> dropDownList(int count){
  print("the count is $count");
  List<String> list = [];
  for(var i = 0;i < count;i++){
    list.add('${i+1}');
  }
  print(list);
  return list;
}

Widget showingMessage(title,message,BuildContext context){
  return AlertDialog(
    title: Text('$title',style: TextStyle(color: Colors.red)),
    content: Text(message,style: TextStyle(color: Colors.black87,fontSize: 14),),
    actions: [
      InkWell(
        onTap: (){
          Navigator.pop(context);
        },
        child: Container(
          child: Center(
            child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
            ),
          ),
          width: 80,
          height: 30,
          color: myTheme.primaryColor,
        ),
      )
    ],
  );

}