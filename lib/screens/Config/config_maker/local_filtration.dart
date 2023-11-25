import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Config/config_maker/source_pump.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/text_form_field_config.dart';


class LocalFiltrationTable extends StatefulWidget {
  const LocalFiltrationTable({super.key});

  @override
  State<LocalFiltrationTable> createState() => LocalFiltrationTableState();
}

class LocalFiltrationTableState extends State<LocalFiltrationTable> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

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
                  configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',value]);
                });
              },
              selectAllFunction: (value){
                setState(() {
                  configPvd.localFiltrationFunctionality(['localFiltrationSelectAll',value]);
                });
              },
              cancelButtonFunction: (){
                configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',false]);
                configPvd.localFiltrationFunctionality(['edit_l_filtrationSelectALL',false]);
                configPvd.cancelSelection();
              },
              addBatchButtonFunction: (){

              },
              addButtonFunction: (){
              },
              deleteButtonFunction: (){
                configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',false]);
                configPvd.localFiltrationFunctionality(['deleteLocalFiltration']);
                configPvd.cancelSelection();
              },
              selectionCount: configPvd.selection,
              singleSelection: configPvd.l_filtrationSelection,
              multipleSelection: configPvd.l_filtrationSelectALL,
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
                        Text('Line',style: TextStyle(color: Colors.white),),
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

                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: configPvd.localFiltrationUpdated.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 1)),
                        color: Colors.white70,
                      ),
                      margin: index == configPvd.localFiltrationUpdated.length - 1 ? EdgeInsets.only(bottom: 60) : null,
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
                                  if(configPvd.l_filtrationSelection == true || configPvd.l_filtrationSelectALL == true)
                                    Checkbox(
                                        value: configPvd.localFiltrationUpdated[index]['selection'] == 'select' ? true : false,
                                        onChanged: (value){
                                          configPvd.localFiltrationFunctionality(['selectLocalFiltration',index,value]);
                                        }),
                                  Text('${configPvd.localFiltrationUpdated[index]['line']}'),
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
                                  child: TextFieldForConfig(index: index, initialValue: configPvd.localFiltrationUpdated[index]['filter'], config: configPvd, purpose: 'localFiltrationFunctionality',),
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
                              child: (configPvd.total_D_s_valve == 0 && configPvd.localFiltrationUpdated[index]['dv'].isEmpty) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.localFiltrationUpdated[index]['dv'].isEmpty ? false : true,
                                  onChanged: (value){
                                    configPvd.localFiltrationFunctionality(['editDownStreamValve',index,value]);
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
                              child: (configPvd.total_p_sensor == 0 && configPvd.localFiltrationUpdated[index]['pressureIn'].isEmpty) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.localFiltrationUpdated[index]['pressureIn'].isEmpty ? false : true,
                                  onChanged: (value){
                                    configPvd.localFiltrationFunctionality(['editPressureSensor',index,value]);
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
                              child: (configPvd.total_p_sensor == 0 && configPvd.localFiltrationUpdated[index]['pressureOut'].isEmpty) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.localFiltrationUpdated[index]['pressureOut'].isEmpty ? false : true,
                                  onChanged: (value){
                                    configPvd.localFiltrationFunctionality(['editPressureSensor_out',index,value]);
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
