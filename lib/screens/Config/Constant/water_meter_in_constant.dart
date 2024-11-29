import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:provider/provider.dart';

import '../../../state_management/constant_provider.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/table_needs.dart';
import '../../../widgets/text_form_field_constant.dart';



class WaterMeterConstant extends StatefulWidget {
  const WaterMeterConstant({super.key});

  @override
  State<WaterMeterConstant> createState() => _WaterMeterConstantState();
}

class _WaterMeterConstantState extends State<WaterMeterConstant> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return LayoutBuilder(builder: (context,constraints){
      if(constraints.maxWidth < 800){
        return WaterMeterConstantForMobile();
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
              label: Text('Location'),
            ),
            DataColumn(
              label: Text('Ratio'),
            ),
            DataColumn(
              label: Text('Maximum flow'),
            ),
          ],
          rows: [
            for(var i = 0;i < constantPvd.waterMeterUpdated.length;i++)
              DataRow(cells: [
                DataCell(Text('${constantPvd.waterMeterUpdated[i]['name']}')),
                DataCell(Text('${constantPvd.waterMeterUpdated[i]['id']}')),
                DataCell(Text('${constantPvd.waterMeterUpdated[i]['location']}')),
                DataCell(
                    TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeterUpdated[i]['ratio'], constantPvd: constantPvd, purpose: 'wm_ratio/$i', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)
                ),
                DataCell(TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeterUpdated[i]['maximumFlow'], constantPvd: constantPvd, purpose: 'maximum_flow/${i}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)),

              ])
          ],
        ),
      );
    });

  }
}

class WaterMeterConstantForMobile extends StatefulWidget {
  const WaterMeterConstantForMobile({super.key});

  @override
  State<WaterMeterConstantForMobile> createState() => _WaterMeterConstantForMobileState();
}

class _WaterMeterConstantForMobileState extends State<WaterMeterConstantForMobile> {
  int selectedWaterMeter = 0;
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
                  child: Image.asset('assets/images/water_meter.png'),
                ),
                trailing:  PopupMenuButton<int>(
                  child: Text('${selectedWaterMeter + 1}',style: TextStyle(fontSize: 20),),
                  itemBuilder: (context) => [
                    for(var i = 0;i < constantPvd.waterMeterUpdated.length;i++)
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
                    setState(() {
                      selectedWaterMeter = value;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 5,),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: MediaQuery.sizeOf(context).width/210,

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
                          Text('Ratio',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeterUpdated[selectedWaterMeter]['ratio'], constantPvd: constantPvd, purpose: 'wm_ratio/$selectedWaterMeter', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)
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
                          Text('Maximum flow',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: TextFieldForConstant(index: -1, initialValue: constantPvd.waterMeterUpdated[selectedWaterMeter]['maximumFlow'], constantPvd: constantPvd, purpose: 'maximum_flow/${selectedWaterMeter}', inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],)
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
                          child: Center(child: Text('${constantPvd.waterMeterUpdated[selectedWaterMeter]['name']}'))
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
                        child: Center(child: Text('${constantPvd.waterMeterUpdated[selectedWaterMeter]['name']}')),
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
                          Icon(Icons.location_pin,color: myTheme.primaryColor,),
                          Text('Location',style: TextStyle(color: myTheme.primaryColor),),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Center(child: Text('${constantPvd.waterMeterUpdated[selectedWaterMeter]['location']}')),
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
