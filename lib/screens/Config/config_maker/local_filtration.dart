import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';
import '../../../widgets/text_form_field_config.dart';


class LocalFiltrationTable extends StatefulWidget {
  const LocalFiltrationTable({super.key});

  @override
  State<LocalFiltrationTable> createState() => LocalFiltrationTableState();
}

class LocalFiltrationTableState extends State<LocalFiltrationTable> {
  bool selectButton = false;
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
        margin: MediaQuery.of(context).orientation == Orientation.portrait ? null : EdgeInsets.only(right: 70),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if(configPvd.l_filtrationSelection == false)
                  Row(
                    children: [
                      Checkbox(
                          value: configPvd.l_filtrationSelection,
                          onChanged: (value){
                            setState(() {
                              configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',value]);
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
                            configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',false]);
                            configPvd.localFiltrationFunctionality(['edit_l_filtrationSelectALL',false]);
                            configPvd.cancelSelection();
                          }, icon: Icon(Icons.cancel_outlined)),
                      Text('${configPvd.selection}')
                    ],
                  ),
                if(configPvd.l_filtrationSelection == true)
                  IconButton(
                    color: Colors.black,
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.yellow)
                    ),
                    highlightColor: myTheme.primaryColor,
                    onPressed: (){
                      configPvd.localFiltrationFunctionality(['edit_l_filtrationSelection',false]);
                      configPvd.localFiltrationFunctionality(['deleteLocalFiltration']);
                      configPvd.cancelSelection();
                    },
                    icon: Icon(Icons.delete_forever),
                  ),
              ],
            ),
            Container(
              width: width-20,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 60,
                    child: Center(
                      child: Text('Line',style: TextStyle(color: Colors.white),),
                    ),
                    decoration: BoxDecoration(
                        color: myTheme.primaryColor
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Column(
                        children: [
                          Text('Filter',style: TextStyle(color: Colors.white),),
                          Text('(${configPvd.totalFilter})',style: TextStyle(color: Colors.white),),
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
                          Text('D.stream',style: TextStyle(color: Colors.white),),
                          Text('Valve(${configPvd.total_D_s_valve})',style: TextStyle(color: Colors.white),),
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
                          Text('P_Sensor',style: TextStyle(color: Colors.white),),
                          Text('in(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white),),
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
                          Text('P_Sensor',style: TextStyle(color: Colors.white),),
                          Text('out(${configPvd.total_p_sensor})',style: TextStyle(color: Colors.white),),
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
                  itemCount: configPvd.localFiltration.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: index == configPvd.localFiltration.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                      color: index % 2 != 0 ? Colors.blue.shade100 : Colors.blue.shade50,
                      width: width-20,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 60,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(configPvd.l_filtrationSelection == true || configPvd.l_filtrationSelectALL == true)
                                    Checkbox(
                                        value: configPvd.localFiltration[index][configPvd.localFiltration[index].length - 1] == 'select' ? true : false,
                                        onChanged: (value){
                                          configPvd.localFiltrationFunctionality(['selectLocalFiltration',index,value]);
                                        }),
                                  Text('${configPvd.localFiltration[index][0]}'),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                width: double.infinity,
                                height: 60,
                                child: Center(
                                  child: Container(
                                    width: 70,
                                    child: TextFieldForConfig(index: index, initialValue: '${configPvd.localFiltration[index][1]}', config: configPvd, purpose: 'localFiltration/filter',),
                                  ),
                                )
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.total_D_s_valve == 0 && configPvd.localFiltration[index][2] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value:  configPvd.localFiltration[index][2],
                                  onChanged: (value){
                                    configPvd.localFiltrationFunctionality(['editDownStreamValve',index,value]);
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.total_p_sensor == 0 && configPvd.localFiltration[index][3] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.localFiltration[index][3],
                                  onChanged: (value){
                                    configPvd.localFiltrationFunctionality(['editDiffPressureSensor',index,value]);
                                  }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              child: (configPvd.total_p_sensor == 0 && configPvd.localFiltration[index][4] == false) ?
                              Center(child: Text('N/A',style: TextStyle(fontSize: 12),)) :
                              Checkbox(
                                  value: configPvd.localFiltration[index][4],
                                  onChanged: (value){
                                    configPvd.localFiltrationFunctionality(['editDiffPressureSensor_out',index,value]);
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
