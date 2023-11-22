import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../Models/condition_model.dart';
import '../../constants/http_service.dart';
import '../../constants/mqtt_web_client.dart';
import '../Config/dealer_definition_config.dart';

class ConditionwebUI extends StatefulWidget {
  const ConditionwebUI({Key? key, required this.userId, required this.controllerId, required this.imeiNo});
  final userId, controllerId;
  final String imeiNo;

  @override
  State<ConditionwebUI> createState() => _ConditionwebUIState();
}

class _ConditionwebUIState extends State<ConditionwebUI>
    with TickerProviderStateMixin {
  dynamic jsondata;
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> conditionhdrlist = [
    'sNo',
    'ID',
    'Name',
    'Enable',
    'State',
    'Duration',
    'condition IsTrueWhen',
    'From Hour',
    'Unit Hour',
    'Notification',
    'Used Program',
  ];
  String usedprogramdropdownstr = '';
  List<UserNames>? usedprogramdropdownlist = [];
  String usedprogramdropdownstr2 = '';
  String dropdownvalues = '';
  ConditionModel _conditionModel = ConditionModel();
  String hint = 'Enter Flow Values';
  String dropdowntitle = '';
  String valueforwhentrue = '';
  int Selectindexrow = 0;
  String programstr = '';
  String zonestr = '';
  List<String> operatorList = ['&&', '||', '^'];
  String selectedOperator = '';
  String selectedValue = '';
  String selectedCondition = '';
  List<String> conditionList = [];

  @override
  void initState() {
    super.initState();
    MqttWebClient().init();
    initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (_conditionModel.data != null &&
        _conditionModel.data!.conditionLibrary != null &&
        _conditionModel.data!.conditionLibrary!.isNotEmpty) {
      setState(() {
        for (var i = 0;
            i < _conditionModel.data!.conditionLibrary!.length;
            i++) {
          conditionList.add(_conditionModel.data!.conditionLibrary![i].name!);
        }
      });
    }
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.controllerId};
    final response = await HttpService()
        .postRequest("getUserPlanningConditionLibrary", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _conditionModel = ConditionModel.fromJson(jsondata1);
        _conditionModel.data!.dropdown!.insert(0, '');
        // changeval();
        MqttWebClient().onSubscribed('tweet/');
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  String conditionselection(String name, String id, String value) {
    programstr = '';
    zonestr = '';
    String conditionselectionstr = '';
    if (usedprogramdropdownstr.contains('Program')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]}';
      programstr = id;
    }
    if (usedprogramdropdownstr.contains('Sensor')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr =
          '$id is ${usedprogramdropdownstrarr[1]} value $value ';
    }
    if (usedprogramdropdownstr.contains('Contact')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]}';
    }
    if (usedprogramdropdownstr.contains('Water')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '$id is ${usedprogramdropdownstrarr[1]} $value';
    }
    if (usedprogramdropdownstr.contains('Conbined')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
    }
    if (usedprogramdropdownstr.contains('Zone')) {
      var usedprogramdropdownstrarr = usedprogramdropdownstr.split('is');
      conditionselectionstr = '${usedprogramdropdownstrarr[0]} $value';
      zonestr = name;
    }
    return conditionselectionstr;
  }

  @override
  void checklistdropdown() async {
    usedprogramdropdownlist = [];
    dropdowntitle = '';
    hint = '';

    if (usedprogramdropdownstr.contains('Program')) {
      usedprogramdropdownlist = _conditionModel.data!.program;
      dropdowntitle = 'Program';
      hint = 'Programs';
    }
    if (usedprogramdropdownstr.contains('Contact')) {
      usedprogramdropdownlist = _conditionModel.data!.contact;
      dropdowntitle = 'Contact';
      hint = 'Contacts';
    }
    if (usedprogramdropdownstr.contains('Sensor')) {
      usedprogramdropdownlist = _conditionModel.data!.analogSensor;
      dropdowntitle = 'Sensor';
      hint = 'Values';
    }
    if (usedprogramdropdownstr.contains('Water')) {
      usedprogramdropdownlist = _conditionModel.data!.waterMeter;
      dropdowntitle = 'Water Meter';
      hint = 'Flow';
    }
    if (usedprogramdropdownstr.contains('Conbined')) {
      usedprogramdropdownlist = _conditionModel.data!.waterMeter;
      dropdowntitle = 'Expression';
      hint = 'Expression';
    }
    if (usedprogramdropdownlist!.isNotEmpty) {
      usedprogramdropdownstr2 = usedprogramdropdownstr2 == ''
          ? '${usedprogramdropdownlist?[0].name}'
          : usedprogramdropdownstr2;
    }
  }

  Future<String> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      _selectedTime = picked;
    }
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget build(BuildContext context) {
    if (_conditionModel.data == null) {
      return Center(
        child: CircularProgressIndicator(),
      ); // Or handle the null case in a way that makes sense for your application
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Conditions Library'),
            backgroundColor: const Color.fromARGB(255, 31, 164, 231),
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
                      width: 1100,
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
                              _conditionModel.data!.conditionLibrary!.length,
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
                                        if (conditionhdrlist[i] == 'Enable')
                                          DataCell(
                                            onTap: () {
                                              setState(() {
                                                Selectindexrow = index;
                                              });
                                            },
                                            MySwitch(
                                              value: _conditionModel
                                                      .data!
                                                      .conditionLibrary![index]
                                                      .enable ??
                                                  false,
                                              onChanged: ((value) {
                                                setState(() {
                                                  Selectindexrow = index;
                                                  _conditionModel
                                                      .data!
                                                      .conditionLibrary![index]
                                                      .enable = value;
                                                });
                                              }),
                                            ),
                                          )
                                        else if (conditionhdrlist[i] ==
                                            'Notification')
                                          DataCell(
                                            onTap: () {
                                              setState(() {
                                                Selectindexrow = index;
                                              });
                                            },
                                            MySwitch(
                                              value: _conditionModel
                                                      .data!
                                                      .conditionLibrary![index]
                                                      .notification ??
                                                  false,
                                              onChanged: ((value) {
                                                setState(() {
                                                  Selectindexrow = index;
                                                  _conditionModel
                                                      .data!
                                                      .conditionLibrary![index]
                                                      .notification = value;
                                                });
                                              }),
                                            ),
                                          )
                                        else if (conditionhdrlist[i] ==
                                            'Duration')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: InkWell(
                                                child: Text(
                                                  '${_conditionModel.data!.conditionLibrary![index].duration}',
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                onTap: () async {
                                                  String time =
                                                      await _selectTime(
                                                          context);
                                                  setState(() {
                                                    Selectindexrow = index;
                                                    _conditionModel
                                                        .data!
                                                        .conditionLibrary![
                                                            index]
                                                        .duration = time;
                                                  });
                                                },
                                              )))
                                        else if (conditionhdrlist[i] ==
                                            'Unit Hour')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: InkWell(
                                                child: Text(
                                                  '${_conditionModel.data!.conditionLibrary![index].untilTime}',
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                onTap: () async {
                                                  String time =
                                                      await _selectTime(
                                                          context);
                                                  setState(() {
                                                    Selectindexrow = index;
                                                    _conditionModel
                                                        .data!
                                                        .conditionLibrary![
                                                            index]
                                                        .untilTime = time;
                                                  });
                                                },
                                              )))
                                        else if (conditionhdrlist[i] ==
                                            'From Hour')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: InkWell(
                                                child: Text(
                                                  '${_conditionModel.data!.conditionLibrary![index].fromTime}',
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                onTap: () async {
                                                  String time =
                                                      await _selectTime(
                                                          context);
                                                  setState(() {
                                                    Selectindexrow = index;
                                                    _conditionModel
                                                        .data!
                                                        .conditionLibrary![
                                                            index]
                                                        .fromTime = time;
                                                  });
                                                },
                                              )))
                                        else if (conditionhdrlist[i] == 'sNo')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                '${_conditionModel.data!.conditionLibrary![index].sNo}',
                                              )))
                                        else if (conditionhdrlist[i] == 'ID')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                '${_conditionModel.data!.conditionLibrary![index].id}',
                                              )))
                                        else if (conditionhdrlist[i] == 'Name')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                '${_conditionModel.data!.conditionLibrary![index].name}',
                                              )))
                                        else if (conditionhdrlist[i] ==
                                            'condition IsTrueWhen')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Container(
                                                child: Text(
                                                  '${_conditionModel.data!.conditionLibrary![index].conditionIsTrueWhen}',
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                              )))
                                        else if (conditionhdrlist[i] == 'State')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                '${_conditionModel.data!.conditionLibrary![index].state}',
                                              )))
                                        else if (conditionhdrlist[i] ==
                                            'Used Program')
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                '${_conditionModel.data!.conditionLibrary![index].usedByProgram}',
                                              )))
                                        // else if (conditionhdrlist[i] == 'Zone')
                                        //   DataCell(onTap: () { setState(() {
                                        //     Selectindexrow = index;
                                        //   }); },Center(
                                        //       child: Text( '${_conditionModel.data!.conditionLibrary![index].zone}',  )))
                                        // else if (conditionhdrlist[i] == 'Program')
                                        //   DataCell(onTap: () { setState(() {
                                        //     Selectindexrow = index;
                                        //   }); },Center(
                                        //       child: Text( '${_conditionModel.data!.conditionLibrary![index].program}',  )))
                                        else
                                          DataCell(onTap: () {
                                            setState(() {
                                              Selectindexrow = index;
                                            });
                                          },
                                              Center(
                                                  child: Text(
                                                'data',
                                              )))
                                    ],
                                   
                                  )))),
                ),
              ),
              Flexible(
                  child: buildconditionselection(
                _conditionModel.data!.conditionLibrary![Selectindexrow].id,
                Selectindexrow,
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
        ),
      );
    }
  }

  Widget buildconditionselection(String? title, int index) {
    changeval();
    String conditiontrue =
        _conditionModel.data!.conditionLibrary![index].conditionIsTrueWhen!;

    bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropdownvalues);
    bool containsOnlyOperators = RegExp(r'^[&|^]+$').hasMatch(dropdownvalues);

    if ((usedprogramdropdownstr.contains('Combined') == true)) {
      if (conditionList.contains(usedprogramdropdownstr2)) {
        usedprogramdropdownstr2 =
            _conditionModel.data!.conditionLibrary![index].dropdown2!;
      } else {
        usedprogramdropdownstr2 = "";
      }
    } else {
      List<String> names = usedprogramdropdownlist!
          .map((contact) => contact.name as String)
          .toList();
      if (names.contains(usedprogramdropdownstr2)) {
     
        usedprogramdropdownstr2 = usedprogramdropdownstr2;
      } else {
       
        if (usedprogramdropdownlist!.length > 0) {
          usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
        }
      }
    }
    if (usedprogramdropdownstr2.isEmpty &&
        usedprogramdropdownlist!.isNotEmpty) {
      usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
    }
    

    if (conditiontrue.contains("&&")) {
      selectedOperator = "&&";
    } else if (conditiontrue.contains("||")) {
      selectedOperator = "||";
    } else if (conditiontrue.contains("^")) {
      selectedOperator = "^";
    } else {
      selectedOperator = "";
    }

    return Padding(
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
              child: Center(
                  child: Text(
                '$title',
              )),
            ),
            const Text('When in Used'),
            if (Selectindexrow != null)
              //First Dropdown values
              DropdownButton(
                items: _conditionModel.data!.dropdown?.map((String? items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(items!)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    usedprogramdropdownstr = value.toString();
                    _conditionModel.data!.conditionLibrary![Selectindexrow]
                        .dropdown1 = value!;
                    checklistdropdown();
                  });
                },
                value: usedprogramdropdownstr == ''
                    ? _conditionModel.data!.conditionLibrary![Selectindexrow]
                            .dropdown1!.isEmpty
                        ? (_conditionModel.data!.dropdown![0])
                        : _conditionModel
                            .data!.conditionLibrary![Selectindexrow].dropdown1!
                            .toString()
                    : usedprogramdropdownstr,
              ),
            if (usedprogramdropdownlist?.length != 0) Text(dropdowntitle),
            if (usedprogramdropdownstr.contains('Combined') == false &&
                usedprogramdropdownlist?.length != 0)
              DropdownButton(
                hint: Text('--/--'),
                items: usedprogramdropdownlist?.map((UserNames items) {
                  return DropdownMenuItem(
                    value: '${items.name}',
                    child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text('${items.name}')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                  
                    usedprogramdropdownstr2 = value.toString();
                    _conditionModel.data!.conditionLibrary![Selectindexrow]
                        .dropdown2 = value.toString();
                    
                  });
                },
                value: usedprogramdropdownstr2,
              ),
            if (usedprogramdropdownstr.contains('Sensor') ||
                usedprogramdropdownstr.contains('Contact') ||
                usedprogramdropdownstr.contains('Water'))
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    initialValue: containsOnlyNumbers ? dropdownvalues : null,
                    showCursor: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    decoration: InputDecoration(
                        hintText: hint, border: OutlineInputBorder()),
                    onChanged: (value) {
                      setState(() {
                        dropdownvalues = value;
                        _conditionModel.data!.conditionLibrary![Selectindexrow]
                            .dropdownValue = dropdownvalues;
                      });
                    },
                  ),
                ),
              ),
            if (usedprogramdropdownstr.contains('Combined'))
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  //Dropdown for operator  values
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: containsOnlyOperators ? dropdownvalues : null,
                        hint: Text('Select Operator'),
                        onChanged: (value) {
                          setState(() {
                            dropdownvalues = value!;
                            _conditionModel
                                .data!
                                .conditionLibrary![Selectindexrow]
                                .dropdownValue = value!;
                          });
                        },
                        items: operatorList.map((operator) {
                          return DropdownMenuItem(
                            value: operator,
                            child: Text(operator),
                          );
                        }).toList(),
                      ),
                      SizedBox(width: 16),
                      //Dropdown for Condition 2 values
                      DropdownButton<String>(
                        value: usedprogramdropdownstr2.isEmpty
                            ? null
                            : usedprogramdropdownstr2,
                        hint: Text('$usedprogramdropdownstr2'),
                        onChanged: (value) {
                          setState(() {
                            usedprogramdropdownstr2 = value!;
                            _conditionModel
                                .data!
                                .conditionLibrary![Selectindexrow]
                                .dropdown2 = value!;
                          });
                        },
                        items: filterlist(
                                conditionList, conditionList[Selectindexrow])
                            .map((condition) {
                          return DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          );
                        }).toList(),
                      ),
                    ],
                  )),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                  
                    if (usedprogramdropdownstr.contains('Program')) {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                              .conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, '');
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .usedByProgram = programstr;

                      List<UserNames>? program = _conditionModel.data!.program!;
                      if (program != null) {
                        String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          _conditionModel
                              .data!
                              .conditionLibrary![Selectindexrow]
                              .program = '$sNo';
                        } else {
                          _conditionModel.data!
                              .conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Contact')) {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                              .conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, '');
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = dropdownvalues;
                      List<UserNames>? program = _conditionModel.data!.contact!;
                      if (program != null) {
                        String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          _conditionModel
                              .data!
                              .conditionLibrary![Selectindexrow]
                              .program = '$sNo';
                        } else {
                          _conditionModel.data!
                              .conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Sensor')) {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                              .conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = dropdownvalues;
                      List<UserNames>? program =
                          _conditionModel.data!.analogSensor!;
                      if (program != null) {
                        String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          _conditionModel
                              .data!
                              .conditionLibrary![Selectindexrow]
                              .program = '$sNo';
                        } else {
                          _conditionModel.data!
                              .conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Water')) {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .conditionIsTrueWhen = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = dropdownvalues;
                      List<UserNames>? program =
                          _conditionModel.data!.waterMeter!;
                      if (program != null) {
                        String? sNo =
                            getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          _conditionModel
                              .data!
                              .conditionLibrary![Selectindexrow]
                              .program = '$sNo';
                        } else {
                          _conditionModel.data!
                              .conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('condition')) {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                              .conditionIsTrueWhen =
                          '$usedprogramdropdownstr ${conditionList[Selectindexrow]} $dropdownvalues $usedprogramdropdownstr2';
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = dropdownvalues;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow].program = dropdownvalues;

                      List<ConditionLibrary>? program =
                          _conditionModel.data!.conditionLibrary;
                      if (program != null) {
                        String? sNo = getSNoByNamecondition(
                            program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          _conditionModel
                              .data!
                              .conditionLibrary![Selectindexrow]
                              .program = '$sNo';
                        } else {
                          _conditionModel.data!
                              .conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Zone')) {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .conditionIsTrueWhen = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = '';
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .program = '0';
                    } else {
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .conditionIsTrueWhen = '';
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = '';
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = '';
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .program = '0';
                    }
                  });
                },
                child: const Text('Apply Changes'))
          ],
        ),
      ),
    );
  }

  changeval() {
    usedprogramdropdownstr =
        _conditionModel.data!.conditionLibrary![Selectindexrow].dropdown1!;
    usedprogramdropdownstr2 =
        _conditionModel.data!.conditionLibrary![Selectindexrow].dropdown2!;
    // valueforwhentrue =
    //     _conditionModel.data!.conditionLibrary![Selectindexrow].dropdownValue!;
    dropdownvalues =
        _conditionModel.data!.conditionLibrary![Selectindexrow].dropdownValue!;
    checklistdropdown();
  }

  List<String> filterlist(List<String> conditionlist, String removevalue) {
    conditionlist =
        conditionlist.where((item) => item != '$removevalue').toList();
    return conditionlist;
  }

  updateconditions() async {
     List<Map<String, dynamic>> conditionJson = _conditionModel
        .data!.conditionLibrary!
        .map((condition) => condition.toJson())
        .toList();

    String Mqttsenddata = toMqttformat(_conditionModel.data!.conditionLibrary);
     Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "condition": conditionJson,
      "createUser": "1"
    };

     final response = await HttpService()
        .postRequest("createUserPlanningConditionLibrary", body);
    final jsonDataresponse = json.decode(response.body);
    //AlertDialogHelper.showAlert(context, '', jsonDataresponse['message']);
 
    String payLoadFinal = jsonEncode({
      "700": [
        {"708": Mqttsenddata},
      ]
    });
    MqttWebClient().publishMessage('AppToFirmware/${widget.imeiNo}', payLoadFinal);
  }

  String? getSNoByName(List<UserNames> data, String name) {
    UserNames? user = data.firstWhere((element) => element.name == name,
        orElse: () => UserNames());
    return user.sNo.toString();
  }

  String? getSNoByNamecondition(List<ConditionLibrary>? data, String name) {
    ConditionLibrary user = data!.firstWhere((element) => element.name == name,
        orElse: () => ConditionLibrary());
    return user.sNo;
  }

  String toMqttformat(
    List<ConditionLibrary>? data,
  ) {
    String Mqttdata = '';
    for (var i = 0; i < data!.length; i++) {
      String enablevalue = data[i].enable! ? '1' : '0';
      String Notifigation = data[i].notification! ? '1' : '0';
      String conditionIsTrueWhenvalue = '0,0,0,0';
      String Combine = '';
 
      if (data[i].conditionIsTrueWhen!.contains('Program')) {
        if (data[i].conditionIsTrueWhen!.contains('running')) {
          conditionIsTrueWhenvalue = "1,1,${data[i].program},0";
        } else if (data[i].conditionIsTrueWhen!.contains('running')) {
          conditionIsTrueWhenvalue = "1,2,${data[i].program},0";
        } else if (data[i].conditionIsTrueWhen!.contains('starting')) {
          conditionIsTrueWhenvalue = "1,3,${data[i].program},0";
        } else if (data[i].conditionIsTrueWhen!.contains('ending')) {
          conditionIsTrueWhenvalue = "1,4,${data[i].program},0";
        } else {
          conditionIsTrueWhenvalue = "1,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Contact')) {
        if (data[i].conditionIsTrueWhen!.contains('opened')) {
          conditionIsTrueWhenvalue =
              "2,5,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('closed')) {
          conditionIsTrueWhenvalue =
              "2,6,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('opening')) {
          conditionIsTrueWhenvalue =
              "2,7,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('closing')) {
          conditionIsTrueWhenvalue =
              "2,8,${data[i].program},${data[i].dropdownValue}";
        } else {
          conditionIsTrueWhenvalue = "2,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Zone')) {
        if (data[i].conditionIsTrueWhen!.contains('low flow than')) {
          conditionIsTrueWhenvalue = "6,9,0,0";
        } else if (data[i].conditionIsTrueWhen!.contains('high flow than')) {
          conditionIsTrueWhenvalue = "6,10,0,0";
        } else if (data[i].conditionIsTrueWhen!.contains('no flow than')) {
          conditionIsTrueWhenvalue = "6,11,0,0";
        } else {
          conditionIsTrueWhenvalue = "6,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Water')) {
        if (data[i].conditionIsTrueWhen!.contains('higher than')) {
          conditionIsTrueWhenvalue =
              "4,12,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('lower than')) {
          conditionIsTrueWhenvalue =
              "4,13,${data[i].program},${data[i].dropdownValue}";
        } else {
          conditionIsTrueWhenvalue = "4,0,0,0";
        }
      } else if (data[i].conditionIsTrueWhen!.contains('Sensor')) {
        if (data[i].conditionIsTrueWhen!.contains('higher than')) {
          conditionIsTrueWhenvalue =
              "3,14,${data[i].program},${data[i].dropdownValue}";
        } else if (data[i].conditionIsTrueWhen!.contains('lower than')) {
          conditionIsTrueWhenvalue =
              "3,15,${data[i].program},${data[i].dropdownValue}";
        } else {
          conditionIsTrueWhenvalue = "3,0,0,0";
        }
      }
      //  Combine =
      else if (data[i].conditionIsTrueWhen!.contains('condition')) {
        String operator = data[i].dropdownValue!;
        if (operator == "&&") {
          operator = "1";
        } else if (operator == "||") {
          operator = "2";
        } else if (operator == "^") {
          operator = "3";
        } else {
          operator = "0";
        }
        if (data[i]
            .conditionIsTrueWhen!
            .contains('Combined condition is true')) {
          conditionIsTrueWhenvalue =
              "5,16,${data[i].sNo},$operator,${data[i].program}";
        } else if (data[i]
            .conditionIsTrueWhen!
            .contains('Combined condition is false')) {
          conditionIsTrueWhenvalue =
              "5,17,${data[i].sNo},$operator,${data[i].program}";
        } else {
          conditionIsTrueWhenvalue = "5,0,0,0";
        }
      } else {
        conditionIsTrueWhenvalue = "0,0,0,0";
      }
      Mqttdata +=
          '${data[i].sNo},${data[i].name},$enablevalue,${data[i].duration}:00,${data[i].fromTime}:00,${data[i].untilTime}:00,$Notifigation,$conditionIsTrueWhenvalue;';
    }
    return Mqttdata;
  }
}
