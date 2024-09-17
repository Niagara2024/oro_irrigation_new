import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';
import 'analog_sensor_in_constant.dart';

class PumpInConstant extends StatefulWidget {
  const PumpInConstant({super.key});

  @override
  State<PumpInConstant> createState() => _PumpInConstantState();
}

class _PumpInConstantState extends State<PumpInConstant> {
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 900){
        return PumpInConstant_M();
      }
      return  Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          dataRowHeight: 40.0,
          headingRowHeight: 40,
          headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
          border: TableBorder.all(color: Colors.grey),
          columns: [
            DataColumn2(
              label: Text('Name'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Id'),
            ),
            DataColumn(
              label: Text('Range'),
            ),
            DataColumn(
              label: Text('Pump Station'),
            ),
          ],
          rows: [
            for(var i = 0;i < constantPvd.pumpUpdated.length;i++)
              DataRow(cells: [
                DataCell(Text('${constantPvd.pumpUpdated[i]['name']}')),
                DataCell(Text('${constantPvd.pumpUpdated[i]['id']}')),
                DataCell(TextFieldForConstant(index: -1, initialValue: constantPvd.pumpUpdated[i]['range'], constantPvd: constantPvd, purpose: 'pumpRange/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),
                DataCell(Checkbox(value: constantPvd.pumpUpdated[i]['pumpStation'],
                    onChanged: (value){
                      constantPvd.pumpFunctionality(['pumpStation',i,value]);
                    })),
              ])
          ],
        ),
      );
    });
  }
}

class PumpInConstant_M extends StatefulWidget {
  const PumpInConstant_M({super.key});

  @override
  State<PumpInConstant_M> createState() => _PumpInConstant_MState();
}

class _PumpInConstant_MState extends State<PumpInConstant_M> {
  int selectedPump = 0;
  TextEditingController range = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var constantPvd = Provider.of<ConstantProvider>(context,listen: false);
    range.text = constantPvd.pumpUpdated[selectedPump]['range'];
  }

  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Container(
      padding: EdgeInsets.all(10),
      color: Color(0xfff3f3f3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white
            ),
            width: double.infinity,
            height: 60,
            child: Center(
              child: ListTile(
                title: Text('Pump'),
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/images/irrigation_pump.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedPump + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.pumpUpdated.length;i++)
                      PopupMenuItem(
                        value: i,
                        child: Text('${i+1}')
                      ),
                  ],
                  offset: Offset(0, 50),
                  color: Colors.white,
                  elevation: 2,
                  // on selected we show the dialog box
                  onSelected: (value) {
                    print('selected value  : $value');
                    setState(() {
                      selectedPump = value;
                      range.text = constantPvd.pumpUpdated[selectedPump]['range'];
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 5,),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.production_quantity_limits,color: myTheme.primaryColor,),
                          Text('Range',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: TextFormField(
                          controller: range,
                          decoration: InputDecoration(
                            border: OutlineInputBorder()
                          ),
                          onChanged: (value){
                            constantPvd.pumpFunctionality(['pumpRange',selectedPump,value]);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.ev_station,color: myTheme.primaryColor,),
                          Text('Pump Station',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Checkbox(value: constantPvd.pumpUpdated[selectedPump]['pumpStation'],
                            onChanged: (value){
                              constantPvd.pumpFunctionality(['pumpStation',selectedPump,value]);
                            }),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade50,
                            Colors.white,
                          ]
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.perm_identity,color: myTheme.primaryColor,),
                          Text('Name',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Center(child: Text('${constantPvd.pumpUpdated[selectedPump]['name']}'))
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade50,
                            Colors.white,
                          ]
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.local_activity_outlined,color: myTheme.primaryColor,),
                          Text('Id',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Center(child: Text('${constantPvd.pumpUpdated[selectedPump]['id']}')),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

