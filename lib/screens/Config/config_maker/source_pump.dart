import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        //color: Color(0xFFF3F3F3),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(height: 5,),
            configButtons(
                selectFunction: (value){
                  setState(() {
                    configPvd.sourcePumpFunctionality(['editsourcePumpSelection',value]);
                  });
                },
                selectAllFunction: (value){
                  setState(() {
                    configPvd.sourcePumpFunctionality(['editsourcePumpSelectAll',value]);
                  });
                },
                cancelButtonFunction: (){
                  configPvd.sourcePumpFunctionality(['editsourcePumpSelection',false]);
                  configPvd.cancelSelection();
                },
                addButtonFunction: (){
                  configPvd.sourcePumpFunctionality(['addSourcePump']);
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 500), // Adjust the duration as needed
                    curve: Curves.easeInOut, // Adjust the curve as needed
                  );
                },
                deleteButtonFunction: (){
                  configPvd.sourcePumpFunctionality(['deleteSourcePump']);
                  configPvd.cancelSelection();
                },
                selectionCount: configPvd.selection,
                singleSelection: configPvd.sourcePumpSelection,
                multipleSelection: configPvd.sourcePumpSelectAll,
                addBatchButtonFunction: () {  }
            ),
            Expanded(
              child: Padding(
                padding:  const EdgeInsets.only(right: 5, left: 5, top: 5),
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 1100,
                  dataRowHeight: 40.0,
                  headingRowHeight: 50,
                  headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                  border: TableBorder.all(color: Colors.grey),
                  columns: [
                    DataColumn2(
                        label: Text('Source pump(${configPvd.totalSourcePump})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                        size: ColumnSize.M
                    ),
                    const DataColumn2(
                        label: Text('Water Source(6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                        size: ColumnSize.M
                    ),
                    DataColumn2(
                      label: Text('Water Meter(${configPvd.totalWaterMeter})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                      size: ColumnSize.M,
                    ),
                    const DataColumn2(
                      label: Center(child: Text('ORO Pump', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M,
                    ),
                    const DataColumn2(
                      label: Center(child: Text('Relay Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M,
                    ),
                    const DataColumn2(
                      label: Center(child: Text('Top tank(high)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M,
                    ),
                    const DataColumn2(
                      label: Center(child: Text('Top tank(low)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M,
                    ),
                    const DataColumn2(
                      label: Center(child: Text('Sump tank(high)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M,
                    ),
                    const DataColumn2(
                      label: Center(child: Text('Sump tank(low)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),)),
                      size: ColumnSize.M,
                    ),
                  ],
                  rows: List<DataRow>.generate(configPvd.sourcePumpUpdated.length, (index) => DataRow(cells: [
                    DataCell(Center(child: Text('${index + 1}'))),
                    DataCell(Center(child: MyDropDown(initialValue: configPvd.sourcePumpUpdated[index]['waterSource'], itemList: configPvd.waterSource, pvdName: 'editWaterSource_sp', index: index))),
                    DataCell((configPvd.totalWaterMeter == 0 && configPvd.sourcePumpUpdated[index]['waterMeter'].isEmpty) ?
                    const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                    Center(
                      child: Checkbox(
                          value: configPvd.sourcePumpUpdated[index]['waterMeter'].isEmpty ? false : true,
                          onChanged: (value){
                            configPvd.sourcePumpFunctionality(['editWaterMeter',index,value]);
                          }),
                    )),
                    DataCell(Center(
                      child: Checkbox(
                          value: configPvd.sourcePumpUpdated[index]['oro_pump'],
                          onChanged: (value){
                            configPvd.sourcePumpFunctionality(['editOroPump',index,value]);
                          }),
                    )),
                    DataCell(Center(child: (configPvd.sourcePumpUpdated[index]['oro_pump'] == false) ?
                    const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                    Center(child: MyDropDown(initialValue: configPvd.sourcePumpUpdated[index]['relayCount'], itemList: ['1','2','3','4'], pvdName: 'editRelayCount_sp', index: index)))),
                    DataCell(Center(child: (configPvd.sourcePumpUpdated[index]['oro_pump'] == false) ?
                    const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                    Center(
                      child: Checkbox(
                          value: configPvd.sourcePumpUpdated[index]['TopTankHigh'].isEmpty ? false : true,
                          onChanged: (value){
                            configPvd.sourcePumpFunctionality(['editTopTankHigh',index,value]);
                          }),
                    ))),
                    DataCell(Center(child: (configPvd.sourcePumpUpdated[index]['oro_pump'] == false) ?
                    const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                    Center(
                      child: Checkbox(
                          value: configPvd.sourcePumpUpdated[index]['TopTankLow'].isEmpty ? false : true,
                          onChanged: (value){
                            configPvd.sourcePumpFunctionality(['editTopTankLow',index,value]);
                          }),
                    ))),
                    DataCell(Center(child: (configPvd.sourcePumpUpdated[index]['oro_pump'] == false) ?
                    const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                    Center(
                      child: Checkbox(
                          value: configPvd.sourcePumpUpdated[index]['SumpTankHigh'].isEmpty ? false : true,
                          onChanged: (value){
                            configPvd.sourcePumpFunctionality(['editSumpTankHigh',index,value]);
                          }),
                    ))),
                    DataCell(Center(child: (configPvd.sourcePumpUpdated[index]['oro_pump'] == false) ?
                    const Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                    Center(
                      child: Checkbox(
                          value: configPvd.sourcePumpUpdated[index]['SumpTankLow'].isEmpty ? false : true,
                          onChanged: (value){
                            configPvd.sourcePumpFunctionality(['editSumpTankLow',index,value]);
                          }),
                    ))),
                  ])),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

Widget configButtons({
      required Function(bool?) selectFunction,
      required Function(bool?) selectAllFunction,
      required VoidCallback cancelButtonFunction,
      required VoidCallback addButtonFunction,
      required VoidCallback deleteButtonFunction,
      required VoidCallback addBatchButtonFunction,
      required int selectionCount,
      required bool singleSelection,
      required bool multipleSelection,
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
