// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:oro_2024/utils/widgets/form%20needs/drop_down_button.dart';
// import 'package:oro_2024/utils/widgets/table_needs.dart';
// import 'package:provider/provider.dart';
//
// import '../../state_management/constant_provider.dart';
// import '../../state_management/overall_use.dart';
// import '../../theme/Theme.dart';
// import '../../utils/widgets/text_form_field_constant.dart';
// import '../../utils/widgets/time_picker.dart';
// import 'fertilizer_in_constant.dart';
//
// class AnalogSensorConstant extends StatefulWidget {
//   const AnalogSensorConstant({super.key});
//
//   @override
//   State<AnalogSensorConstant> createState() => _AnalogSensorConstantState();
// }
//
// class _AnalogSensorConstantState extends State<AnalogSensorConstant> {
//   @override
//   Widget build(BuildContext context) {
//     var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
//     var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
//     return myTable(
//         [expandedTableCell_Text('ID',''),
//           expandedTableCell_Text('Name',''),
//           expandedTableCell_Text('TYPE',''),
//           expandedTableCell_Text('UNITS',''),
//           expandedTableCell_Text('DATA','SOURCE'),
//           expandedTableCell_Text('MINIMUM',''),
//           expandedTableCell_Text('MAXIMUM',''),
//         ],
//         Expanded(
//           child: ListView.builder(
//               itemCount: constantPvd.filter.length,
//               itemBuilder: (BuildContext context,int index){
//                 return Container(
//                   margin: index == constantPvd.filter.length - 1 ? EdgeInsets.only(bottom: 60) : null,
//                   color: index % 2 == 0 ? Colors.blue.shade50 : Colors.blue.shade100,
//                   child: Row(
//                     children: [
//                       expandedCustomCell(Text('${constantPvd.analogSensor[index][0]}'),),
//                       expandedCustomCell(Text('${constantPvd.analogSensor[index][1]}'),),
//                       expandedCustomCell(MyDropDown(initialValue: constantPvd.analogSensor[index][2], itemList: ['ATM Pressure','CO2','Daily rain','Dendrometer','Dew point'], pvdName: 'analogSensor/type', index: index),),
//
//                     ],
//                   ),
//                 );
//               }),
//         )
//     );
//   }
// }
//
