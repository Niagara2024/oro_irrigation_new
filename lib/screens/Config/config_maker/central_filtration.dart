import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/text_form_field_config.dart';


class CentralFiltrationTable extends StatefulWidget {
  const CentralFiltrationTable({super.key});

  @override
  State<CentralFiltrationTable> createState() => _CentralFiltrationTableState();
}

class _CentralFiltrationTableState extends State<CentralFiltrationTable> {
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
                  configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',value]);
                });
              },
              selectAllFunction: (value){
                setState(() {
                  configPvd.centralFiltrationFunctionality(['centralFiltrationSelectAll',value]);
                });
              },
              cancelButtonFunction: (){
                configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',false]);
                configPvd.centralFiltrationFunctionality(['centralFiltrationSelectAll',false]);
                configPvd.cancelSelection();
              },
              addBatchButtonFunction: (){

              },
              reOrderFunction: (){
                List<int> list1 = [];
                for(var i = 0;i < configPvd.centralFiltrationUpdated.length;i++){
                  list1.add(i+1);
                }
                showDialog(context: context, builder: (BuildContext context){
                  return ReOrderInCfSite(list: list1);
                });
              },
              addButtonFunction: (){
                configPvd.centralFiltrationFunctionality(['addCentralFiltration']);
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500), // Adjust the duration as needed
                  curve: Curves.easeInOut, // Adjust the curve as needed
                );
              },
              deleteButtonFunction: (){
                configPvd.centralFiltrationFunctionality(['centralFiltrationSelection',false]);
                configPvd.centralFiltrationFunctionality(['deleteCentralFiltration']);
                configPvd.cancelSelection();
              },
              selectionCount: configPvd.selection,
              singleSelection: configPvd.centralFiltrationSelection,
              multipleSelection: configPvd.centralFiltrationSelectAll,
            ),
            Container(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('#',style: TextStyle(color: Colors.white),),
                        Text('(${configPvd.totalCentralFiltration})',style: TextStyle(color: Colors.white),),
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
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Filters',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalFilter})',style: TextStyle(color: Colors.white),),
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
                          Text('D.stream',style: TextStyle(color: Colors.white),),
                          Text('Valve(${configPvd.total_D_s_valve})',style: TextStyle(color: Colors.white)),
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
                          Text('P_Sense',style: TextStyle(color: Colors.white),),
                          Text('in(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
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
                          Text('P_Sense',style: TextStyle(color: Colors.white),),
                          Text('out(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white)),
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
                          Text('Diff.Press',style: TextStyle(color: Colors.white),),
                          Text('Sensor(${configPvd.totalDiffPressureSensor})',style: TextStyle(color: Colors.white),),
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
                  itemCount: configPvd.centralFiltrationUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Visibility(
                      visible: configPvd.centralFiltrationUpdated[index]['deleted'] == true ? false : true,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1)),
                          color: Colors.white70,
                        ),
                        margin: index == configPvd.centralFiltrationUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                        width: width-20,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1))
                              ),
                              width: 60,
                              height: 60,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(configPvd.centralFiltrationSelection == true || configPvd.centralFiltrationSelectAll == true)
                                      Checkbox(
                                          value: configPvd.centralFiltrationUpdated[index]['selection'] == 'select' ? true : false,
                                          onChanged: (value){
                                            configPvd.centralFiltrationFunctionality(['selectCentralFiltration',index,value]);
                                          }),
                                    Text('${index + 1}'),
                                  ],
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
                                  child: Center(
                                    child: TextFieldForConfig(index: index, initialValue: configPvd.centralFiltrationUpdated[index]['filter'], config: configPvd, purpose: 'centralFiltrationFunctionality',),
                                  )
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border(right: BorderSide(width: 1))
                                ),
                                width: double.infinity,
                                height: 60,
                                child: (configPvd.total_D_s_valve == 0 && configPvd.centralFiltrationUpdated[index]['dv'].isEmpty) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                Checkbox(
                                    value: configPvd.centralFiltrationUpdated[index]['dv'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.centralFiltrationFunctionality(['editDownStreamValve',index,value]);
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
                                child: (configPvd.total_p_sensor == 0 && configPvd.centralFiltrationUpdated[index]['pressureIn'].isEmpty) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                Checkbox(
                                    value: configPvd.centralFiltrationUpdated[index]['pressureIn'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.centralFiltrationFunctionality(['editPressureSensor',index,value]);
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
                                child: (configPvd.total_p_sensor == 0 && configPvd.centralFiltrationUpdated[index]['pressureOut'].isEmpty) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                Checkbox(
                                    value: configPvd.centralFiltrationUpdated[index]['pressureOut'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.centralFiltrationFunctionality(['editPressureSensor_out',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1)),
                                ),
                                width: double.infinity,
                                height: 60 ,
                                child: (configPvd.totalPressureSwitch == 0 && configPvd.centralFiltrationUpdated[index]['pressureSwitch'].isEmpty) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                Checkbox(
                                    value: configPvd.centralFiltrationUpdated[index]['pressureSwitch'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.centralFiltrationFunctionality(['editPressureSwitch',index,value]);
                                    }),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1)),
                                ),
                                width: double.infinity,
                                height: 60 ,
                                child: (configPvd.totalDiffPressureSensor == 0 && configPvd.centralFiltrationUpdated[index]['diffPressureSensor'].isEmpty) ?
                                Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                                Checkbox(
                                    value: configPvd.centralFiltrationUpdated[index]['diffPressureSensor'].isEmpty ? false : true,
                                    onChanged: (value){
                                      configPvd.centralFiltrationFunctionality(['editDiffPressureSensor',index,value]);
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

class ReOrderInCfSite extends StatefulWidget {
  final List<int> list;
  const ReOrderInCfSite({super.key, required this.list});

  @override
  State<ReOrderInCfSite> createState() => _ReOrderInCfSiteState();
}

class _ReOrderInCfSiteState extends State<ReOrderInCfSite> {

  late int oldIndex;
  late int newIndex;
  List<int> cfData = [];
  @override
  Widget buildItem(String text) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(5)
      ),
      width: 50,
      height: 50 ,
      key: ValueKey('CF${text}'),
      child: Center(child: Text('CF${text}')),
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cfData = widget.list;
  }
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return AlertDialog(
      title: Text('Re-Order Central Filtration Site',style: TextStyle(color: Colors.black),),
      content: Container(
        width: 250,
        height: 250,
        child: Center(
          child: ReorderableGridView.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: cfData.map((e) => buildItem("${e}")).toList(),
            onReorder: (oldIND, newIND) {
              setState(() {
                oldIndex = oldIND;
                newIndex = newIND;
                var removeData = cfData[oldIND];
                cfData.removeAt(oldIND);
                cfData.insert(newIND, removeData);
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
              configPvd.centralFiltrationFunctionality(['reOrderCfSite',oldIndex,newIndex]);
              Navigator.pop(context);
            },
            child: Text('Change')
        )
      ],
    );
  }
}
