import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../state_management/config_maker_provider.dart';
import '../../../constants/theme.dart';



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
        margin: (MediaQuery.of(context).orientation == Orientation.portrait ||  kIsWeb ) ? null : EdgeInsets.only(right: 70),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(configPvd.irrigationPumpSelection == false)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.irrigationPumpSelection,
                          onChanged: (value){
                            setState(() {
                              configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelection',value]);
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
                            configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelection',false]);
                            configPvd.cancelSelection();
                          }, icon: Icon(Icons.cancel_outlined)),
                      Text('${configPvd.selection}')
                    ],
                  ),
                if(configPvd.irrigationPumpSelection == false)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.amber)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.irrigationPumpFunctionality(['addIrrigationPump']);
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500), // Adjust the duration as needed
                        curve: Curves.easeInOut, // Adjust the curve as needed
                      );
                    },
                    icon: Icon(Icons.add),
                  ),
                if(configPvd.irrigationPumpSelection == false)
                  IconButton(
                    splashColor: Colors.grey,
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.amber)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){

                    },
                    icon: Icon(Icons.batch_prediction),
                  ),

                if(configPvd.irrigationPumpSelection == true)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.amber)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.irrigationPumpFunctionality(['deleteIrrigationPump']);
                      configPvd.cancelSelection();
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
                if(configPvd.irrigationPumpSelection == true)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.irrigationPumpSelectAll,
                          onChanged: (value){
                            setState(() {
                              configPvd.irrigationPumpFunctionality(['editIrrigationPumpSelectAll',value]);
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
                          Text('Irrigation',style: TextStyle(color: Colors.white),),
                          Text('Pump (${configPvd.totalIrrigationPump})',style: TextStyle(color: Colors.white)),
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
                          Text('Meter (${configPvd.totalWaterMeter})',style: TextStyle(color: Colors.white)),
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
                  itemCount: configPvd.irrigationPump.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: index == configPvd.irrigationPump.length - 1 ? EdgeInsets.only(bottom: 60) : null,
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
                                    if(configPvd.irrigationPumpSelection == true || configPvd.irrigationPumpSelectAll == true)
                                      Checkbox(
                                          value: configPvd.irrigationPump[index][1][0] == 'select' ? true : false,
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
                                width: double.infinity,
                                height: 60,
                                child: (configPvd.totalWaterMeter == 0 && configPvd.irrigationPump[index][0] == false) ?
                                    Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                    Checkbox(
                                    value: configPvd.irrigationPump[index][0],
                                    onChanged: (value){
                                      configPvd.irrigationPumpFunctionality(['editWaterMeter',index,value]);
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
