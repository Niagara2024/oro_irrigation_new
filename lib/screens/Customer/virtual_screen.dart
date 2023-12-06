import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../Config/dealer_definition_config.dart';


class VirtualMeterScreen extends StatefulWidget {
  const VirtualMeterScreen({super.key , required this.userId, required this.controllerId,});
  final userId, controllerId;

  @override
  State<VirtualMeterScreen> createState() => _VirtualMeterScreenState();
}

class _VirtualMeterScreenState extends State<VirtualMeterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var jsondata;
  String formulastr = '';
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> conditionhdrlist = [
    'Name',
    'Function',
    'Formula',
    'ProtectionLimit',
    'Object',
    'Action',
    'Radio',
  ];
  List<String> functiondropdown = [
    '',
    'Open',
    'Close',
    'Running',
  ];
  List<String> formulaEditlist = [
    'SNo',
    'ID',
    '+',
    '-',
  ];
  List<dynamic> formulajson = [];
  List<dynamic> virtualMeterjson = [];

  String usedprogramdropdownstr = '';
  String hint = 'Enter Flow Values';
  String dropdowntitle = '';
  int Selectindexrow = 0;
  int tabclickindex = 0;

  List<String> conditionList = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (jsondata['plan'] != null && jsondata['plan'].isNotEmpty) {
      setState(() {
        formulajson = jsondata['plan'];
        virtualMeterjson = jsondata['virtualWaterMeter'];
      });
    }
  }


  Future<void> fetchData() async {
    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.controllerId};
    final response = await HttpService()
        .postRequest("getUserPlanningVirtualWaterMeter", body);
    if (response.statusCode == 200) {
      setState(() {
        final jsondata1 = jsonDecode(response.body);
        // print(" jsondata1 : $jsondata1");
        jsondata = jsondata1['data'];
        formulajson = jsondata1['data']['plan'];
        // print("formulajson fetch : $formulajson");
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Water Meter'),
        backgroundColor: myTheme.primaryColor,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                  height: double.infinity,
                  width: 800,
                  child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 580,
                      columns: [
                        for (int i = 0; i < conditionhdrlist.length; i++)
                          DataColumn2(
                            label: Center(
                                child: Text(
                              conditionhdrlist[i].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                              softWrap: true,
                            )),
                          ),
                      ],
                      rows: List<DataRow>.generate(
                          formulajson.length,
                          (index) => DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) {
                                  if (index == Selectindexrow) {
                                    return Colors.blue.withOpacity(
                                        0.5); // Selected row color
                                  }
                                  return Color.fromARGB(0, 176, 35, 35);
                                }),
                                cells: [
                                  for (int i = 0;
                                      i < conditionhdrlist.length;
                                      i++)
                                    if ((conditionhdrlist[i] == 'Function'))
                                      DataCell(
                                        onTap: () {
                                          setState(() {
                                            Selectindexrow = index;
                                          });
                                        },
                                        DropdownButton(
                                          items: functiondropdown
                                              .map((String? items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                    items!,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 8.6),
                                                  )),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              formulajson[index]
                                                      ['function'] =
                                                  value.toString();
                                            });
                                          },
                                          value: formulajson[index]
                                                      ['function'] ==
                                                  ''
                                              ? functiondropdown[0]
                                              : formulajson[index]
                                                  ['function'],
                                        ),
                                      )
                                    else if ((conditionhdrlist[i] ==
                                        'Action'))
                                      DataCell(
                                        onTap: () {
                                          setState(() {
                                            Selectindexrow = index;
                                          });
                                        },
                                        DropdownButton(
                                          items: functiondropdown
                                              .map((String? items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: Text(
                                                    items!,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 8.6),
                                                  )),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              formulajson[index]['action'] =
                                                  value.toString();
                                              // checklistdropdown();
                                              //   print(jsonEncode(_conditionModel.data!.dropdown));
                                            });
                                          },
                                          value: formulajson[index]
                                                      ['action'] ==
                                                  ''
                                              ? functiondropdown[0]
                                              : formulajson[index]
                                                  ['action'],
                                        ),
                                      )
                                    else if (conditionhdrlist[i] ==
                                        'ProtectionLimit')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                            child: SizedBox(
                                                width: 50,
                                                child: CustomTextField(
                                                  onChanged: (text) {
                                                    setState(() {
                                                      formulajson[index][
                                                              'protectionLimit'] =
                                                          text;
                                                    });
                                                  },
                                                  initialValue:
                                                      '${formulajson[index]['protectionLimit']}' ??
                                                          '0',
                                                )),
                                          )))
                                    else if (conditionhdrlist[i] == 'Name')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                            child: Text(
                                              '${formulajson[index]['name']}',
                                              style: const TextStyle(
                                                  fontSize: 12),
                                            ),
                                          )))
                                    else if (conditionhdrlist[i] ==
                                        'Object')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                            child: Text(
                                              formulajson[index]['object'],
                                              style: const TextStyle(
                                                  fontSize: 20),
                                            ),
                                          )))
                                    else if (conditionhdrlist[i] == 'Radio')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                            child: Text(
                                              '${formulajson[index]['radio']}',
                                              style: const TextStyle(
                                                  fontSize: 20),
                                            ),
                                          )))
                                    else if (conditionhdrlist[i] ==
                                        'Formula')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                            child: Text(
                                              '${formulajson[index]['formula']}',
                                              style: const TextStyle(
                                                  fontSize: 12),
                                            ),
                                          )))
                                    else
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                            child: (conditionhdrlist[i] !=
                                                    'ID')
                                                ? Text(
                                                    '${conditionhdrlist[i]}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  )
                                                : Text('${index + 1}'),
                                          )))
                                ],
                                //                          onSelectChanged: (isSelected) {
                                //    print('Row $index selected: $isSelected');
                                // },
                              )))),
            ),
          ),

          //TODO: Formula Edit
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.amber,
                    child: const Center(
                        child: Text(
                      'Formula Editor',
                    )),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: TextFormField(
                  //     // controller:
                  //     //     TextEditingController.fromValue(),
                  //
                  //       initialValue: '$formulastr',
                  //     decoration: InputDecoration(
                  //       border: OutlineInputBorder(),
                  //       // hintText: '$formulastr',
                  //       labelText: 'Formula',
                  //     ),
                  //   ),
                  // ),
                  formulastr.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: Colors.black),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(formulastr),
                              )),
                        )
                      : Container(),
                  if (Selectindexrow != null)
                    Flexible(
                      flex: 3,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                            height: double.infinity,
                            width: 300,
                            child: DataTable2(
                                columnSpacing: 12,
                                horizontalMargin: 12,
                                minWidth: 80,
                                columns: [
                                  for (int i = 0;
                                      i < formulaEditlist.length;
                                      i++)
                                    DataColumn2(
                                      label: Center(
                                          child: Text(
                                        formulaEditlist[i].toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        softWrap: true,
                                      )),
                                    ),
                                ],
                                rows: List<DataRow>.generate(
                                    virtualMeterjson.length,
                                    (index) => DataRow(
                                          color: MaterialStateColor
                                              .resolveWith((states) {
                                            return Color.fromARGB(
                                                0, 176, 35, 35);
                                          }),
                                          cells: [
                                            for (int i = 0;
                                                i < formulaEditlist.length;
                                                i++)
                                              if ((formulaEditlist[i] ==
                                                  '+'))
                                                DataCell(
                                                  Checkbox(
                                                    value: virtualMeterjson[
                                                        index]['plus'],
                                                    onChanged:
                                                        (bool? value) {
                                                      setState(() {
                                                        virtualMeterjson[
                                                                    index]
                                                                ['plus'] =
                                                            value;
                                                        virtualMeterjson[
                                                                    index]
                                                                ['minus'] =
                                                            value;
                                                        formulastr =
                                                            generateFormulaString(
                                                                formulajson);
                                                        print(value);
                                                      });
                                                    },
                                                  ),
                                                )
                                              else if ((formulaEditlist[
                                                      i] ==
                                                  '-'))
                                                DataCell(
                                                  Checkbox(
                                                    value: virtualMeterjson[
                                                        index]['minus'],
                                                    onChanged:
                                                        (bool? value) {
                                                      setState(() {
                                                        virtualMeterjson[
                                                                    index]
                                                                ['minus'] =
                                                            value!;
                                                        virtualMeterjson[
                                                                    index]
                                                                ['plus'] =
                                                            !value;
                                                        formulastr =
                                                            generateFormulaString(
                                                                formulajson);
                                                        print(value);
                                                      });
                                                    },
                                                  ),
                                                )
                                              else
                                                DataCell(Center(
                                                    child: InkWell(
                                                  child: (formulaEditlist[
                                                              i] !=
                                                          'ID')
                                                      ? Text(
                                                          '${virtualMeterjson[index]['sNo']}',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize:
                                                                      16),
                                                        )
                                                      : Text(
                                                          '${virtualMeterjson[index]['id']}'),
                                                )))
                                          ],
                                          //                          onSelectChanged: (isSelected) {
                                          //    print('Row $index selected: $isSelected');
                                          // },
                                        )))),
                      ),
                    ),

                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          formulastr =
                              generateFormulaString(virtualMeterjson);
                          formulajson[Selectindexrow]['formula'] =
                              formulastr;

                          print('virtual_screen : $formulastr');
                        });
                      },
                      child: const Text('Apply Changes'))
                ],
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          updateconditions();
        },
        tooltip: 'Send',
        child: const Icon(Icons.send),
      ),
    );
    }

  String generateFormulaString(List<dynamic> items) {
    List<String> plusList = [];
    List<String> minusList = [];

    for (var item in items) {
      print('plus');
      print(item['plus']);
      print('minus');
      print(item['minus']);
      if (item['plus']) {
        plusList.add(item['id']);
      }
      if (item['minus']) {
        minusList.add(item['id']);
      }
    }
    print(plusList);
    print(minusList);

    String plusString = '';
    if (plusList.isNotEmpty) {
      plusString = plusList.sublist(1).map((e) => '+ $e').join(' ');
    }

    String minusString =
        minusList.isNotEmpty ? minusList.map((e) => '- $e').join(' ') : '';

    String mergedString = plusString + ' ' + minusString;

    if (mergedString.startsWith('+ ')) {
      mergedString = mergedString.replaceFirst('+ ', '');
    } else if (mergedString.startsWith('- ')) {
      mergedString = mergedString.replaceFirst('- ', '');
    }

    return mergedString;
  }

  updateconditions() async {
     if (jsondata['virtualWaterMeter'].length > 0) {
      Map<String, Object> body = {
        "userId": widget.userId,
        "controllerId": widget.controllerId,
        "virtualWaterMeter": jsondata,
        "createUser": widget.userId
      };
      print('body: $body');
      final response = await HttpService()
          .postRequest("createUserPlanningVirtualWaterMeter", body);
      final jsonDataresponse = json.decode(response.body);
      GlobalSnackBar.show(context, jsonDataresponse['message'], response.statusCode);
      if (jsonDataresponse['code'] == 200) {
        initializeData();
      }
    } else {
      print('else $jsondata');
    }
  }
}
