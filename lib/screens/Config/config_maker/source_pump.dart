import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../state_management/config_maker_provider.dart';
import '../../../constants/theme.dart';
import '../../../widgets/drop_down_button.dart';


class SourcePumpTable extends StatefulWidget {
  const SourcePumpTable({super.key});

  @override
  State<SourcePumpTable> createState() => _SourcePumpTableState();
}

class _SourcePumpTableState extends State<SourcePumpTable> {
  ScrollController scrollController = ScrollController();
  bool selectButton = false;
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        margin: (MediaQuery.of(context).orientation == Orientation.portrait ||  kIsWeb ) ? null : EdgeInsets.only(right: 70),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(left: 10,right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(configPvd.sourcePumpSelection == false)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.sourcePumpSelection,
                          onChanged: (value){
                            setState(() {
                              configPvd.sourcePumpFunctionality(['editsourcePumpSelection',value]);
                            });
                          }
                      ),
                      Text('Select')
                    ],
                  )
                else
                  Row(
                    children: [
                      IconButton(
                          onPressed: (){
                            configPvd.sourcePumpFunctionality(['editsourcePumpSelection',false]);
                            configPvd.cancelSelection();
                      }, icon: Icon(Icons.cancel_outlined)),
                      Text('${configPvd.selection}')
                    ],
                  ),
                if(configPvd.sourcePumpSelection == false)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.sourcePumpFunctionality(['addSourcePump']);
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500), // Adjust the duration as needed
                        curve: Curves.easeInOut, // Adjust the curve as needed
                      );
                    },
                    icon: Icon(Icons.add),
                  ),
                if(configPvd.sourcePumpSelection == false)
                  IconButton(
                    splashColor: Colors.grey,
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                      onPressed: (){

                      },
                      icon: Icon(Icons.batch_prediction),
                  ),

                if(configPvd.sourcePumpSelection == true)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.sourcePumpFunctionality(['deleteSourcePump']);
                      configPvd.cancelSelection();
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
                if(configPvd.sourcePumpSelection == true)
                  Row(
                  children: [
                    Checkbox(
                        value: configPvd.sourcePumpSelectAll,
                        onChanged: (value){
                          setState(() {
                            configPvd.sourcePumpFunctionality(['editsourcePumpSelectAll',value]);
                          });
                        }
                    ),
                    Text('All')
                  ],
                ),

              ],
            ),
            SizedBox(height: 5,),
            Container(
              width: width-20,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Source',style: TextStyle(color: Colors.white),),
                          Text('Pump(${configPvd.totalSourcePump})',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
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
                          Text('Water',style: TextStyle(color: Colors.white),),
                          Text('Source(6)',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
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
                          Text('Water',style: TextStyle(color: Colors.white),),
                          Text('Meter(${configPvd.totalWaterMeter})',style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: myTheme.primaryColor
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: configPvd.sourcePump.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: index == configPvd.sourcePump.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                      color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
                      width: width-20,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(configPvd.sourcePumpSelection == true || configPvd.sourcePumpSelectAll == true)
                                      Checkbox(
                                          value: configPvd.sourcePump[index][2] == 'select' ? true : false,
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
                              width: double.infinity,
                              height: 60,
                              child: MyDropDown(initialValue: configPvd.sourcePump[index][0], itemList: configPvd.waterSource, pvdName: 'editWaterSource_sp', index: index)
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.totalWaterMeter == 0 && configPvd.sourcePump[index][1] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.sourcePump[index][1],
                                  onChanged: (value){
                                    configPvd.sourcePumpFunctionality(['editWaterMeter',index,value]);
                                  }),
                            ),
                          ),

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
}
