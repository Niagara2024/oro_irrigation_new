import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../../widgets/FontSizeUtils.dart';

class VirtualMeterScreen extends StatefulWidget {
  const VirtualMeterScreen({
    super.key,
    required this.userId,
    required this.controllerId,
  });
  final userId, controllerId;

  @override
  State<VirtualMeterScreen> createState() => _VirtualMeterScreenState();
}

class _VirtualMeterScreenState extends State<VirtualMeterScreen>
    with SingleTickerProviderStateMixin {
  var jsondata;
  String formulastr = '';
  List<String> conditionhdrlist = [
    'Name',
    'Function',
    'Formula',
    'Protection Limit',
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
  List<String> formulastrList = [];

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
        formulastrList = jsondata['plan'][Selectindexrow]['formula'].split(' ');
      });
    }
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response = await HttpService()
        .postRequest("getUserPlanningVirtualWaterMeter", body);
    if (response.statusCode == 200) {
      setState(() {
        final jsondata1 = jsonDecode(response.body);
        jsondata = jsondata1['data'];
        formulajson = jsondata1['data']['plan'];
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  Widget build(BuildContext context) {
    if (jsondata == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (jsondata['plan'].isEmpty || virtualMeterjson.isEmpty || formulajson.isEmpty) {
      return const Center(child: Text('Currently No Virtual Meter Available'));
    } else {
      return Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildDataTableWidget(),
            MediaQuery.of(context).size.width >= 600
                ? buildFormulaEditorWidget()
                : Container()
            // buildFormulaEditorWidget(),
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
  }

  Widget buildDataTableWidget() {
    return Flexible(
      flex: 3,
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
            child: DataTable2(
                headingRowColor: MaterialStateProperty.all<Color>(
                    primaryColorDark.withOpacity(0.2)),
                fixedCornerColor: myTheme.primaryColor,
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                border: TableBorder.all(width: 0.5),
                fixedColumnsColor: Colors.amber,
                columns: [
                  for (int i = 0; i < conditionhdrlist.length; i++)
                    DataColumn2(
                      label: Center(
                          child: Text(
                            conditionhdrlist[i].toString(),
                            style:  TextStyle(
                              fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                              fontWeight: FontWeight.bold,),
                            softWrap: true,
                          )),
                    ),
                ],
                rows: List<DataRow>.generate(
                    formulajson.length,
                        (index) => DataRow(
                      color: MaterialStateColor.resolveWith((states) {
                        if (index == Selectindexrow) {
                          return Colors.blue
                              .withOpacity(0.5); // Selected row color
                        }
                        return Colors.white;
                      }),
                      cells: [
                        for (int i = 0; i < conditionhdrlist.length; i++)
                          if ((conditionhdrlist[i] == 'Function'))
                            DataCell(
                              onTap: () {
                                setState(() {
                                  Selectindexrow = index;
                                });
                              },
                              DropdownButton(
                                // focusColor: Colors.transparent,
                                items:
                                functiondropdown.map((String? items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Container(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: Text(
                                          items!,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: _fontSize(),
                                          ),
                                        )),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    formulajson[index]['function'] =
                                        value.toString();
                                    Selectindexrow = index;
                                  });
                                },
                                value: formulajson[index]['function'] == ''
                                    ? functiondropdown[0]
                                    : formulajson[index]['function'],
                              ),
                            )
                          else if ((conditionhdrlist[i] == 'Action'))
                            DataCell(
                              onTap: () {
                                setState(() {
                                  Selectindexrow = index;
                                });
                              },
                              DropdownButton(
                                items:
                                functiondropdown.map((String? items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Center(
                                      child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 10),
                                          child: Text(items!,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: _fontSize(),
                                              ))),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    formulajson[index]['action'] =
                                        value.toString();
                                    Selectindexrow = index;
                                    // checklistdropdown();
                                    //   print(jsonEncode(_conditionModel.data!.dropdown));
                                  });
                                },
                                value: formulajson[index]['action'] == ''
                                    ? functiondropdown[0]
                                    : formulajson[index]['action'],
                              ),
                            )
                          else if (conditionhdrlist[i] == 'Protection Limit')
                              DataCell(onTap: () {
                                setState(() {
                                  Selectindexrow = index;
                                });
                              },
                                  Center(
                                      child: InkWell(
                                        child: SizedBox(
                                            width: 50,
                                            child: Center(
                                              child: TextFormField(
                                                textAlign: TextAlign.center,
                                                decoration: const InputDecoration(
                                                    hintText: '0'),
                                                onChanged: (text) {
                                                  setState(() {
                                                    Selectindexrow = index;
                                                    formulajson[index]
                                                    ['protectionLimit'] =
                                                        text;
                                                  });
                                                },
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                initialValue:
                                                '${formulajson[index]['protectionLimit']}' ??
                                                    '0',
                                              ),
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
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        )))
                              else if (conditionhdrlist[i] == 'Object')
                                  DataCell(onTap: () {
                                    setState(() {
                                      Selectindexrow = index;
                                    });
                                  },
                                      Center(
                                          child: InkWell(
                                            child: Text(
                                              formulajson[index]['object'],
                                              style: const TextStyle(fontSize: 20),
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
                                                style: const TextStyle(fontSize: 20),
                                              ),
                                            )))
                                  else if (conditionhdrlist[i] == 'Formula')
                                      DataCell(onTap: () {
                                        setState(() {
                                          Selectindexrow = index;
                                          if (MediaQuery.of(context).size.width < 600)
                                            _showFormulaBottomSheet();
                                        });
                                      },
                                          Center(
                                              child: InkWell(
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: Container(
                                                    child: Text(
                                                      '${formulajson[index]['formula']}',
                                                      style:
                                                      const TextStyle(fontSize: 12),
                                                    ),
                                                  ),
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
                                                child: (conditionhdrlist[i] != 'ID')
                                                    ? Text(
                                                  '${conditionhdrlist[i]}',
                                                  style:
                                                  const TextStyle(fontSize: 16),
                                                )
                                                    : Text('${index + 1}'),
                                              )))
                      ],
                      //                          onSelectChanged: (isSelected) {
                      //    print('Row $index selected: $isSelected');
                      // },
                    )))),
      ),
    );
  }

  double _fontSize() {
    // return MediaQuery.of(context).size.width < 600 ? 2 : 9;
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = (screenWidth / 100) + 1;
    return fontSize;
  }

  Widget buildFormulaEditorWidget() {
    formulastrList = jsondata['plan'][Selectindexrow]['formula'].split(' ');
    // formulastrList = [];

    return Flexible(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.9,
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
                formulastr.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
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
                        child: Text(formulastrList.join(' ')),
                      )),
                )
                    : Container(),
                if (Selectindexrow != null)
                  Flexible(
                    flex: 3,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                            height: double.infinity,
                            width: 300,
                            child: DataTable2(
                                headingRowColor:
                                MaterialStateProperty.all<Color>(
                                    primaryColorDark.withOpacity(0.2)),
                                showBottomBorder: true,
                                columnSpacing: 12,
                                horizontalMargin: 12,
                                minWidth: 80,
                                border: TableBorder.all(
                                    width: 1,
                                    color: primaryColorDark.withOpacity(0.2)),
                                columns: [
                                  for (int i = 0;
                                  i < formulaEditlist.length;
                                  i++)
                                    DataColumn2(
                                      label: Center(
                                          child: Text(
                                            formulaEditlist[i].toString(),
                                            style:  TextStyle(
                                                fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                                                fontWeight: FontWeight.bold),
                                            softWrap: true,
                                          )),
                                    ),
                                ],
                                rows: List<DataRow>.generate(
                                  virtualMeterjson.length,
                                      (index) => DataRow(
                                    color: MaterialStateColor.resolveWith(
                                            (states) {
                                          return Color.fromARGB(0, 176, 35, 35);
                                        }),
                                    cells: [
                                      for (int i = 0;
                                      i < formulaEditlist.length;
                                      i++)
                                        if (formulaEditlist[i] == '+')
                                          DataCell(
                                            Center(
                                              child: Checkbox(
                                                value: checkboxvalassign(
                                                    formulajson[Selectindexrow]
                                                    ['formula'],
                                                    virtualMeterjson[index]
                                                    ['id'],
                                                    true),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      if (formulastrList.contains(
                                                          '-${virtualMeterjson[index]['id']}')) {
                                                        formulastrList.remove(
                                                            '-${virtualMeterjson[index]['id']}');
                                                        formulastrList.add(
                                                            '+${virtualMeterjson[index]['id']}');
                                                      } else if (!formulastrList
                                                          .contains(
                                                          '+${virtualMeterjson[index]['id']}')) {
                                                        formulastrList.add(
                                                            '+${virtualMeterjson[index]['id']}');
                                                      } else {
                                                        formulastrList.remove(
                                                            '+${virtualMeterjson[index]['id']}');
                                                      }
                                                    } else {
                                                      formulastrList.remove(
                                                          '+${virtualMeterjson[index]['id']}');
                                                    }
                                                    String formulaString =
                                                    formulajson[Selectindexrow]
                                                    ['formula'] =
                                                        formulastrList
                                                            .join(' ');
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                        else if (formulaEditlist[i] == '-')
                                          DataCell(
                                            Center(
                                              child: Checkbox(
                                                value: checkboxvalassign(
                                                    formulajson[Selectindexrow]
                                                    ['formula'],
                                                    virtualMeterjson[index]
                                                    ['id'],
                                                    false),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      if (formulastrList.contains(
                                                          '+${virtualMeterjson[index]['id']}')) {
                                                        formulastrList.remove(
                                                            '+${virtualMeterjson[index]['id']}');
                                                        formulastrList.add(
                                                            '-${virtualMeterjson[index]['id']}');
                                                      } else if (!formulastrList
                                                          .contains(
                                                          '-${virtualMeterjson[index]['id']}')) {
                                                        formulastrList.add(
                                                            '-${virtualMeterjson[index]['id']}');
                                                      } else {
                                                        formulastrList.remove(
                                                            '-${virtualMeterjson[index]['id']}');
                                                      }
                                                    } else {
                                                      formulastrList.remove(
                                                          '-${virtualMeterjson[index]['id']}');
                                                    }
                                                    String formulaString =
                                                    formulajson[Selectindexrow]
                                                    ['formula'] =
                                                        formulastrList
                                                            .join(' ');
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                        else
                                          DataCell(
                                            Center(
                                              child: InkWell(
                                                child: (formulaEditlist[i] !=
                                                    'ID')
                                                    ? Text(
                                                  '${virtualMeterjson[index]['sNo']}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                )
                                                    : Text(
                                                    '${virtualMeterjson[index]['id']}'),
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ))),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        String formulaString = formulastrList.join(' ');
                        formulajson[Selectindexrow]['formula'] = formulaString;
                      });
                    },
                    child: const Text('Apply Changes'))
              ],
            ),
          ),
        ));
  }

  void _showFormulaBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return buildFormulaEditorWidget();
      },
    );
  }

  bool checkboxvalassign(String formulastr, String srno, bool minplus) {
    if (formulastr != '') {
      List<String> positiveParts = formulastr.replaceAll(' ', '').split('+');
      List<String> plusValues = [];
      List<String> minusValues = [];
      for (var part in positiveParts) {
        List<String> values = part.split('-');
        if (values.length > 1) {
          for (int i = 1; i < values.length; i++) {
            minusValues.add(values[i]);
          }
        }
        plusValues.add(values[0]);
      }
      plusValues.removeWhere((value) => value.isEmpty);
      if (minplus == true) {
        if (plusValues.contains(srno)) {
          return true;
        } else {
          return false;
        }
      } else {
        if (minusValues.contains(srno)) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  String generateFormulaString(List<dynamic> items) {
    List<String> plusList = [];
    List<String> minusList = [];

    for (var item in items) {
      if (item['plus']) {
        plusList.add(item['id']);
      }
      if (item['minus']) {
        minusList.add(item['id']);
      }
    }

    String plusString = '';
    if (plusList.isNotEmpty) {
      plusString = plusList.sublist(1).map((e) => '+ $e').join(' ');
    }

    String minusString =
    minusList.isNotEmpty ? minusList.map((e) => '- $e').join(' ') : '';

    String mergedString = plusString + ' ' + minusString;

    // if (mergedString.startsWith('+ ')) {
    //   mergedString = mergedString.replaceFirst('+ ', '');
    // } else if (mergedString.startsWith('- ')) {
    //   mergedString = mergedString.replaceFirst('- ', '');
    // }

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
      final response = await HttpService()
          .postRequest("createUserPlanningVirtualWaterMeter", body);
      final jsonDataresponse = json.decode(response.body);
      GlobalSnackBar.show(
          context, jsonDataresponse['message'], response.statusCode);
      if (jsonDataresponse['code'] == 200) {
        initializeData();
      }
    } else {
      print('else $jsondata');
    }
  }

  double? _fontSizeheading() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = (screenWidth / 100) + 5;
    return fontSize <= 9 ? 11 : fontSize;
  }

  double? _fontSizelabel() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = (screenWidth / 100) + 3;
    return fontSize <= 9
        ? 10
        : fontSize > 14
        ? 14
        : fontSize;
  }
}