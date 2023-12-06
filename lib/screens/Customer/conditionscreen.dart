import 'dart:convert';

import 'package:flutter/material.dart';

import '../../Models/condition_model.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../Config/dealer_definition_config.dart';
import 'conditionwebui.dart';

class ConditionScreen extends StatefulWidget {
  const ConditionScreen(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.imeiNo});
  final userId, controllerId;
  final String imeiNo;

  @override
  State<ConditionScreen> createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 600) {
          // Render mobile content
          return ConditionUI(
            userId: widget.userId,
            controllerId: widget.controllerId,
            imeiNo: widget.imeiNo,
          );;
        } else {
          // Render web content
          return ConditionwebUI(
            userId: widget.userId,
            controllerId: widget.controllerId,
            imeiNo: widget.imeiNo,
          );
        }
      },
    );
  }
}

class ConditionUI extends StatefulWidget {
  const ConditionUI({Key? key, required this.userId,
    required this.controllerId,
    required this.imeiNo});

  final userId, controllerId;
  final String imeiNo;

  @override
  State<ConditionUI> createState() => _ConditionUIState();
}

class _ConditionUIState extends State<ConditionUI>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
  int tabclickindex = 0;
  String programstr = '';
  String zonestr = '';
  String selectedOperator = '';

  List<String> operatorList = ['&&', '||', '^'];
  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];

  @override
  void initState() {
    super.initState();
    fetchData();

    // initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (_conditionModel.data != null &&
        _conditionModel.data!.conditionLibrary != null &&
        _conditionModel.data!.conditionLibrary!.isNotEmpty) {
      setState(() {
        _tabController = TabController(
            length: _conditionModel.data!.conditionLibrary!.length,
            vsync: this);
        _tabController.addListener(_handleTabSelection);
        for (var i = 0;
        i < _conditionModel.data!.conditionLibrary!.length;
        i++) {
          conditionList.add(_conditionModel.data!.conditionLibrary![i].name!);
        }
      });
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      int selectedTabIndex = _tabController.index;
      print("Selected Tab Index: $selectedTabIndex");
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
        if (_conditionModel.data != null &&
            _conditionModel.data!.conditionLibrary != null &&
            _conditionModel.data!.conditionLibrary!.isNotEmpty) {
          setState(() {
            _tabController = TabController(
                length: _conditionModel.data!.conditionLibrary!.length,
                vsync: this);
            _tabController.addListener(_handleTabSelection);
            for (var i = 0;
            i < _conditionModel.data!.conditionLibrary!.length;
            i++) {
              conditionList
                  .add(_conditionModel.data!.conditionLibrary![i].name!);
            }
          });
        }
      });
    } else {
      //_showSnackBar(response.body);
    }
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

  Future<String?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      _selectedTime = picked;
      final hour = _selectedTime.hour.toString().padLeft(2, '0');
      final minute = _selectedTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return null;
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
      conditionselectionstr = '$name value is $value ';
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
    print('conditionselectionstr:  $conditionselectionstr');
    return conditionselectionstr;
  }

  @override
  Widget build(BuildContext context) {
    if (_conditionModel.data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_conditionModel.data!.conditionLibrary!.length <= 0) {
      return Container(
        child: const Center(
            child: Text(
              'Condition Not Found',
              style: TextStyle(color: Colors.black, fontSize: 20),
            )),
      );
    } else {
      return DefaultTabController(
        length: _conditionModel.data!.conditionLibrary!.length ?? 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Conditions Library'),
              backgroundColor: Color.fromARGB(255, 31, 164, 231),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                isScrollable: true,
                tabs: [
                  for (var i = 0;
                  i < _conditionModel.data!.conditionLibrary!.length;
                  i++)
                    Tab(
                      text: _conditionModel.data!.conditionLibrary![i].name ??
                          'Condition',
                    ),
                ],
                onTap: (value) {
                  setState(() {
                    tabclickindex = value;
                    changeval(value);
                  });
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
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
                  child: TabBarView(controller: _tabController, children: [
                    for (var i = 0;
                    i < _conditionModel.data!.conditionLibrary!.length;
                    i++)

                    //  dropdownvalues = _conditionModel.data!.conditionLibrary![i].dropdownValue.toString();
                    //  usedprogramdropdownstr2 = _conditionModel.data!.conditionLibrary![i].dropdown2.toString();
                    //  valueforwhentrue = _conditionModel.data!.conditionLibrary![i].dropdownvalue.toString();

                    //  String conditiontrue = _conditionModel.data!.conditionLibrary![index].conditionIsTrueWhen!;
                    // bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropdownvalues);
                    // bool containsOnlyOperators = RegExp(r'^[&|^]+$').hasMatch(dropdownvalues);

                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 50),
                    //   child: SingleChildScrollView(
                    //     child: Column(children: [
                    //       Container(
                    //         width: double.infinity,
                    //         height: 40,
                    //         child: Center(
                    //             child: Text(
                    //                 '${i + 1}. ${_conditionModel.data!.conditionLibrary![i].id}')),
                    //         color: Colors.amber,
                    //       ),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[2]),
                    //         trailing: Text(_conditionModel
                    //             .data!.conditionLibrary![i].name
                    //             .toString()),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[3]),
                    //         trailing: MySwitch(
                    //           value: _conditionModel
                    //                   .data!.conditionLibrary![i].enable ??
                    //               false,
                    //           onChanged: ((value) {
                    //             setState(() {
                    //               _conditionModel.data!.conditionLibrary![i]
                    //                   .enable = value;
                    //             });
                    //           }),
                    //         ),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[4]),
                    //         trailing: Text(_conditionModel
                    //             .data!.conditionLibrary![i].state
                    //             .toString()),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[5]),
                    //         trailing: Container(
                    //           child: InkWell(
                    //             child: Text(
                    //               '${_conditionModel.data!.conditionLibrary![i].duration}',
                    //               style: const TextStyle(fontSize: 20),
                    //             ),
                    //             onTap: () async {
                    //               String time = await _selectTime(context);
                    //               setState(() {
                    //                 _conditionModel.data!.conditionLibrary![i]
                    //                     .duration = time;
                    //               });
                    //             },
                    //           ),
                    //         ),
                    //       )),
                    //       //  Card(child: ListTile(title: Text('test',softWrap: true,),trailing: Text(_conditionModel.data!.conditionLibrary![i].conditionIsTrueWhen.toString(),softWrap: true,),)),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[6]),
                    //         trailing: Container(
                    //             width: 200,
                    //             child: Text(
                    //               _conditionModel.data!.conditionLibrary![i]
                    //                   .conditionIsTrueWhen
                    //                   .toString(),
                    //               softWrap: true,
                    //               overflow: TextOverflow.fade,
                    //             )),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[10]),
                    //         trailing: Text(
                    //           _conditionModel
                    //               .data!.conditionLibrary![i].usedByProgram
                    //               .toString(),
                    //           softWrap: true,
                    //         ),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[7]),
                    //         trailing: InkWell(
                    //           child: Text(
                    //             '${_conditionModel.data!.conditionLibrary![i].fromTime}',
                    //             style: const TextStyle(fontSize: 20),
                    //           ),
                    //           onTap: () async {
                    //             String time = await _selectTime(context);
                    //             setState(() {
                    //               _conditionModel.data!.conditionLibrary![i]
                    //                   .fromTime = time;
                    //             });
                    //           },
                    //         ),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[8]),
                    //         trailing: InkWell(
                    //           child: Text(
                    //             '${_conditionModel.data!.conditionLibrary![i].untilTime}',
                    //             style: const TextStyle(fontSize: 20),
                    //           ),
                    //           onTap: () async {
                    //             String time = await _selectTime(context);
                    //             setState(() {
                    //               _conditionModel.data!.conditionLibrary![i]
                    //                   .untilTime = time;
                    //             });
                    //           },
                    //         ),
                    //       )),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text(conditionhdrlist[9]),
                    //         trailing: MySwitch(
                    //           value: _conditionModel.data!
                    //                   .conditionLibrary![i].notification ??
                    //               false,
                    //           onChanged: ((value) {
                    //             setState(() {
                    //               _conditionModel.data!.conditionLibrary![i]
                    //                   .notification = value;
                    //             });
                    //           }),
                    //         ),
                    //       )),
                    //       //  Card(child: ListTile(title: Text(conditionhdrlist[9]),trailing: Text(_conditionModel.data!.conditionLibrary![i].usedByProgram.toString(),softWrap: true,),)),
                    //       Card(
                    //           child: ListTile(
                    //         title: Text('When Program'),
                    //         trailing: DropdownButton(
                    //           items: _conditionModel.data!.dropdown
                    //               ?.map((String? items) {
                    //             return DropdownMenuItem(
                    //               value: items,
                    //               child: Container(
                    //                   padding:
                    //                       const EdgeInsets.only(left: 10),
                    //                   child: Text(items!)),
                    //             );
                    //           }).toList(),
                    //           onChanged: (value) {
                    //             setState(() {
                    //               usedprogramdropdownstr = value.toString();
                    //               _conditionModel.data!.conditionLibrary![i]
                    //                   .dropdown1 = value.toString();
                    //               checklistdropdown();
                    //             });
                    //           },
                    //           value: usedprogramdropdownstr == ''
                    //               ? _conditionModel.data!.conditionLibrary![i]
                    //                       .dropdown1!.isEmpty
                    //                   ? (_conditionModel.data!.dropdown![0])
                    //                   : _conditionModel.data!
                    //                       .conditionLibrary![i].dropdown1!
                    //                       .toString()
                    //               : usedprogramdropdownstr,
                    //         ),
                    //       )),
                    //       if (usedprogramdropdownlist?.length != 0 &&
                    //           usedprogramdropdownstr.contains('Combined'))
                    //         Card(
                    //             child: ListTile(
                    //           title: Text(dropdowntitle),
                    //           trailing: DropdownButton(
                    //             items: usedprogramdropdownlist
                    //                 ?.map((UserNames items) {
                    //               return DropdownMenuItem(
                    //                 value: '${items.name}',
                    //                 child: Container(
                    //                     padding:
                    //                         const EdgeInsets.only(left: 10),
                    //                     child: Text('${items.name}')),
                    //               );
                    //             }).toList(),
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 usedprogramdropdownstr2 =
                    //                     value.toString();
                    //                 _conditionModel.data!.conditionLibrary![i]
                    //                     .dropdown2 = value.toString();
                    //               });
                    //             },
                    //             value: usedprogramdropdownstr2,
                    //           ),
                    //         )),
                    //       if (usedprogramdropdownstr.contains('Sensor') ||
                    //           usedprogramdropdownstr.contains('Contact'))
                    //         Card(
                    //             child: ListTile(
                    //           title: Text(hint),
                    //           trailing: Container(
                    //             height: 40,
                    //             width: 200,
                    //             child: TextFormField(
                    //               keyboardType:
                    //                   const TextInputType.numberWithOptions(
                    //                       decimal: true),
                    //               initialValue: _conditionModel.data!
                    //                   .conditionLibrary![i].dropdownValue,
                    //               showCursor: true,
                    //               decoration: InputDecoration(hintText: hint),
                    //               onChanged: (value) {
                    //                 valueforwhentrue = value;
                    //                 validator:
                    //                 (value) {
                    //                   if (value == null || value.isEmpty) {
                    //                     valueforwhentrue = '0';
                    //                   } else {
                    //                     valueforwhentrue = value;
                    //                   }
                    //                   return null;
                    //                 };
                    //               },
                    //             ),
                    //           ),
                    //         )),
                    //       if (usedprogramdropdownstr.contains('Combined'))
                    //         Card(
                    //             child: ListTile(
                    //           title: Text('Select Operator'),
                    //           trailing: DropdownButton<String>(
                    //             value: containsOnlyOperators
                    //                 ? dropdownvalues
                    //                 : null,
                    //             hint: Text('Select Operator'),
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 dropdownvalues = value!;
                    //                 _conditionModel
                    //                     .data!
                    //                     .conditionLibrary![Selectindexrow]
                    //                     .dropdownValue = value!;
                    //               });
                    //             },
                    //             items: operatorList.map((operator) {
                    //               return DropdownMenuItem(
                    //                 value: operator,
                    //                 child: Text(operator),
                    //               );
                    //             }).toList(),
                    //           ),
                    //         )),

                    //       DropdownButton<String>(
                    //         value: usedprogramdropdownstr2.isEmpty
                    //             ? null
                    //             : usedprogramdropdownstr2,
                    //         hint: Text('$usedprogramdropdownstr2'),
                    //         onChanged: (value) {
                    //           setState(() {
                    //             usedprogramdropdownstr2 = value!;
                    //             _conditionModel
                    //                 .data!
                    //                 .conditionLibrary![Selectindexrow]
                    //                 .dropdown2 = value!;
                    //           });
                    //         },
                    //         items: filterlist(conditionList,
                    //                 conditionList[Selectindexrow])
                    //             .map((condition) {
                    //           return DropdownMenuItem(
                    //             value: condition,
                    //             child: Text(condition),
                    //           );
                    //         }).toList(),
                    //       ),
                    //     ]),
                    //   ),
                    // )
                      ConditionTab(
                        _conditionModel.data!.conditionLibrary![i].id,
                        i,
                      ),
                  ]),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  _conditionModel.data!.conditionLibrary![Selectindexrow]
                      .conditionIsTrueWhen =
                      conditionselection(usedprogramdropdownstr,
                          usedprogramdropdownstr2, valueforwhentrue);
                  _conditionModel.data!.conditionLibrary![Selectindexrow]
                      .program = programstr;
                  _conditionModel.data!.conditionLibrary![Selectindexrow].zone =
                      zonestr;
                  _conditionModel.data!.conditionLibrary![Selectindexrow]
                      .dropdown1 = usedprogramdropdownstr;
                  _conditionModel.data!.conditionLibrary![Selectindexrow]
                      .dropdown2 = usedprogramdropdownstr2;
                  _conditionModel.data!.conditionLibrary![Selectindexrow]
                      .dropdownValue = valueforwhentrue;
                  updateconditions();
                });
              },
              tooltip: 'Send',
              child: const Icon(Icons.send),
            ),
          ),
        ),
      );
    }
  }

  changeval(int Selectindexrow) {
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

  Widget ConditionTab(String? title, int i) {
    if (_tabController.index == i) {
      String conditiontrue =
      _conditionModel.data!.conditionLibrary![i].conditionIsTrueWhen!;

      bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropdownvalues);
      bool containsOnlyOperators = RegExp(r'^[&|^]+$').hasMatch(dropdownvalues);

      if ((usedprogramdropdownstr.contains('Combined') == true)) {
        if (conditionList.contains(usedprogramdropdownstr2)) {
          usedprogramdropdownstr2 =
          _conditionModel.data!.conditionLibrary![i].dropdown2!;
        } else {
          usedprogramdropdownstr2 = "";
        }
      } else {
        List<String> names = usedprogramdropdownlist!
            .map((contact) => contact.name as String)
            .toList();
        if (names.contains(usedprogramdropdownstr2)) {
          usedprogramdropdownstr2 =
          _conditionModel.data!.conditionLibrary![i].dropdown2!;
        } else {
          if (usedprogramdropdownlist!.length > 0) {
            usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
          }
        }
        if (usedprogramdropdownstr2.isEmpty &&
            usedprogramdropdownlist!.isNotEmpty) {
          usedprogramdropdownstr2 = '${usedprogramdropdownlist![0].name}';
        }
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
        padding: const EdgeInsets.only(bottom: 50),
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              height: 40,
              child: Center(
                  child: Text(
                      '${i + 1}. ${_conditionModel.data!.conditionLibrary![i].id}')),
              color: Colors.amber,
            ),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[2]),
                  trailing: Text(
                      _conditionModel.data!.conditionLibrary![i].name.toString()),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[3]),
                  trailing: MySwitch(
                    value:
                    _conditionModel.data!.conditionLibrary![i].enable ?? false,
                    onChanged: ((value) {
                      setState(() {
                        _conditionModel.data!.conditionLibrary![i].enable = value;
                      });
                    }),
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[4]),
                  trailing: Text(
                      _conditionModel.data!.conditionLibrary![i].state.toString()),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[5]),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${_conditionModel.data!.conditionLibrary![i].duration}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time == null) {
                            _conditionModel.data!.conditionLibrary![i].duration =
                                time;
                          }
                        });
                      },
                    ),
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[6]),
                  trailing: Container(
                      width: 200,
                      child: Text(
                        _conditionModel
                            .data!.conditionLibrary![i].conditionIsTrueWhen
                            .toString(),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      )),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[10]),
                  trailing: Text(
                    _conditionModel.data!.conditionLibrary![i].usedByProgram
                        .toString(),
                    softWrap: true,
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[7]),
                  trailing: InkWell(
                    child: Text(
                      '${_conditionModel.data!.conditionLibrary![i].fromTime}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () async {
                      String? time = await _selectTime(context);
                      setState(() {
                        if (time == null) {
                          _conditionModel.data!.conditionLibrary![i].fromTime =
                              time;
                        }
                      });
                    },
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[8]),
                  trailing: InkWell(
                    child: Text(
                      '${_conditionModel.data!.conditionLibrary![i].untilTime}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () async {
                      String? time = await _selectTime(context);
                      setState(() {
                        if (time == null) {
                          _conditionModel.data!.conditionLibrary![i].untilTime =
                              time;
                        }
                      });
                    },
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[9]),
                  trailing: MySwitch(
                    value:
                    _conditionModel.data!.conditionLibrary![i].notification ??
                        false,
                    onChanged: ((value) {
                      setState(() {
                        _conditionModel.data!.conditionLibrary![i].notification =
                            value;
                      });
                    }),
                  ),
                )),
            //  Card(child: ListTile(title: Text(conditionhdrlist[9]),trailing: Text(_conditionModel.data!.conditionLibrary![i].usedByProgram.toString(),softWrap: true,),)),
            Card(
                child: ListTile(
                  title: Text('When Program'),
                  //First DropDown list
                  trailing: DropdownButton(
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
                        _conditionModel.data!.conditionLibrary![i].dropdown1 =
                            value.toString();
                        checklistdropdown();
                      });
                    },
                    value: usedprogramdropdownstr == ''
                        ? _conditionModel
                        .data!.conditionLibrary![i].dropdown1!.isEmpty
                        ? (_conditionModel.data!.dropdown![0])
                        : _conditionModel.data!.conditionLibrary![i].dropdown1!
                        .toString()
                        : usedprogramdropdownstr,
                  ),
                )),
            if (usedprogramdropdownlist?.length != 0 &&
                usedprogramdropdownstr != 'Combined')
            //Second DropDown list
              Card(
                  child: ListTile(
                    title: Text(dropdowntitle),
                    trailing: DropdownButton(
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
                          _conditionModel.data!.conditionLibrary![i].dropdown2 =
                              value;
                        });
                      },
                      value: usedprogramdropdownstr2,
                    ),
                  )),
            //Values
            if (usedprogramdropdownstr.contains('Sensor') ||
                usedprogramdropdownstr.contains('Contact') ||
                usedprogramdropdownstr.contains('Water'))
              Card(
                  child: ListTile(
                    title: Text('Values'),
                    trailing: Container(
                      height: 40,
                      width: 200,
                      child: TextFormField(
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        initialValue: _conditionModel
                            .data!.conditionLibrary![i].dropdownValue,
                        showCursor: true,
                        decoration: InputDecoration(hintText: hint),
                        onChanged: (value) {
                          valueforwhentrue = value;
                          validator:
                              (value) {
                            if (value == null || value.isEmpty) {
                              valueforwhentrue = '0';
                            } else {
                              valueforwhentrue = value;
                              _conditionModel
                                  .data!.conditionLibrary![i].dropdownValue = value;
                            }
                            return null;
                          };
                        },
                      ),
                    ),
                  )),
            if (usedprogramdropdownstr.contains('Combined'))
            //Select operator
              Card(
                  child: ListTile(
                    title: Text('Select Operator'),
                    trailing: DropdownButton<String>(
                      value: containsOnlyOperators ? dropdownvalues : null,
                      hint: Text('Select Operator'),
                      onChanged: (value) {
                        setState(() {
                          dropdownvalues = value!;
                          _conditionModel.data!.conditionLibrary![Selectindexrow]
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
                  )),
            if (usedprogramdropdownstr.contains('Combined'))
              Card(
                  child: ListTile(
                    title: Text('Select Conditions'),
                    trailing: DropdownButton<String>(
                      value: usedprogramdropdownstr2.isEmpty
                          ? null
                          : usedprogramdropdownstr2,
                      hint: Text('$usedprogramdropdownstr2'),
                      onChanged: (value) {
                        setState(() {
                          usedprogramdropdownstr2 = value!;
                          _conditionModel.data!.conditionLibrary![Selectindexrow]
                              .dropdown2 = value!;
                        });
                      },
                      items:
                      filterlist(conditionList, conditionList[Selectindexrow])
                          .map((condition) {
                        return DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        );
                      }).toList(),
                    ),
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
                          conditionselection(
                              usedprogramdropdownstr, '', dropdownvalues);
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown1 = usedprogramdropdownstr;
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdown2 = usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
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
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdownValue = dropdownvalues;
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
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdownValue = dropdownvalues;
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
                      _conditionModel.data!.conditionLibrary![Selectindexrow]
                          .dropdownValue = dropdownvalues;
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
            //  TextButton(onPressed: (){}, child: Text('Apply')),
          ]),
        ),
      );
    } else
      return Center();
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
      "createUser": widget.controllerId
    };
    final response = await HttpService()
        .postRequest("createUserPlanningConditionLibrary", body);
    final jsonDataresponse = json.decode(response.body);

    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);
  }

  List<String> filterlist(List<String> conditionlist, String removevalue) {
    conditionlist =
        conditionlist.where((item) => item != '$removevalue').toList();
    return conditionlist;
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
        } else if (data[i].conditionIsTrueWhen!.contains('not running')) {
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
