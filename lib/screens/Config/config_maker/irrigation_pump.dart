import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
                  configPvd.irrigationPumpFunctionality(['addIrrigationPump']);
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 500), // Adjust the duration as needed
                    curve: Curves.easeInOut, // Adjust the curve as needed
                  );
                },
                deleteButtonFunction: (){
                  configPvd.irrigationPumpFunctionality(['deleteIrrigationPump']);
                  configPvd.cancelSelection();
                },
                addBatchButtonFunction: () {  },
                selectionCount: configPvd.selection,
                singleSelection: configPvd.irrigationPumpSelection,
                multipleSelection: configPvd.irrigationPumpSelectAll
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
                          Text('Irrigation',style: TextStyle(color: Colors.white),),
                          Text('Pump (${configPvd.totalIrrigationPump})',style: TextStyle(color: Colors.white)),
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
                          Text('Water',style: TextStyle(color: Colors.white),),
                          Text('Meter (${configPvd.totalWaterMeter})',style: TextStyle(color: Colors.white)),
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
                          Text('ORO',style: TextStyle(color: Colors.white),),
                          Text('pump',style: TextStyle(color: Colors.white)),
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
                          Text('Relay',style: TextStyle(color: Colors.white),),
                          Text('count',style: TextStyle(color: Colors.white)),
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
                          Text('Top',style: TextStyle(color: Colors.white),),
                          Text('tank(high)',style: TextStyle(color: Colors.white)),
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
                          Text('Top',style: TextStyle(color: Colors.white),),
                          Text('tank(low)',style: TextStyle(color: Colors.white)),
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
                          Text('Sump',style: TextStyle(color: Colors.white),),
                          Text('tank(high)',style: TextStyle(color: Colors.white)),
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
                          Text('Sump',style: TextStyle(color: Colors.white),),
                          Text('tank(low)',style: TextStyle(color: Colors.white)),
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
                  itemCount: configPvd.irrigationPumpUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
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
                              height: 60,
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
                                height: 60,
                                child: (configPvd.totalWaterMeter == 0 && configPvd.irrigationPumpUpdated[index]['waterMeter'].isEmpty) ?
                                    Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
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
                              height: 60,
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
                                height: 60,
                                child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == false) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                MyDropDown(initialValue: configPvd.irrigationPumpUpdated[index]['relayCount'], itemList: ['1','2','3','4'], pvdName: 'editRelayCount_ip', index: index)
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1))
                              ),
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
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
                              height: 60,
                              child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
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
                              height: 60,
                              child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
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
                              height: 60,
                              child: (configPvd.irrigationPumpUpdated[index]['oro_pump'] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.irrigationPumpUpdated[index]['SumpTankLow'].isEmpty ? false : true,
                                  onChanged: (value){
                                    configPvd.irrigationPumpFunctionality(['editSumpTankLow',index,value]);
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
