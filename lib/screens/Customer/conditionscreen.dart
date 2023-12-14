import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

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
          );
          ;
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
  const ConditionUI(
      {Key? key,
        required this.userId,
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
  List<ConditionLibrary>? conditionLibrary = [];

  List<String> operatorList = ['&&', '||', '^'];
  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];

  int _currentSelection = 0;

  final Map<int, Widget> _segmenttab = {
    0: const Text(' Program '),
    1: const Text(' Moisture '),
    2: const Text(' Level '),
  };

  @override
  void initState() {
    super.initState();
    fetchData();

    // initializeData();
  }

  Future<void> initializeData() async {
    await fetchData();
    if (_conditionModel.data != null &&
        _conditionModel.data!.conditionProgram != null &&
        _conditionModel.data!.conditionProgram!.isNotEmpty) {
      setState(() {
        _tabController = TabController(
            length: _conditionModel.data!.conditionProgram!.length,
            vsync: this);
        _tabController.addListener(_handleTabSelection);
        for (var i = 0;
        i < _conditionModel.data!.conditionProgram!.length;
        i++) {
          conditionList.add(_conditionModel.data!.conditionProgram![i].name!);
        }
      });
    }
  }

  void _handleTabSelection() {

    setState(() {
      int selectedTabIndex = _tabController.index;
      changeval(selectedTabIndex);
    });
    // }
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response = await HttpService()
        .postRequest("getUserPlanningConditionLibrary", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _conditionModel = ConditionModel.fromJson(jsondata1);
        _conditionModel.data!.dropdown!.insert(0, '');
        if (_conditionModel.data != null &&
            _conditionModel.data!.conditionProgram != null &&
            _conditionModel.data!.conditionProgram!.isNotEmpty) {
          setState(() {
            _tabController = TabController(
                length: _conditionModel.data!.conditionProgram!.length,
                vsync: this);
            _tabController.addListener(_handleTabSelection);
            conditionLibrary = _conditionModel.data!.conditionProgram!;
            for (var i = 0;
            i < _conditionModel.data!.conditionProgram!.length;
            i++) {
              conditionList
                  .add(_conditionModel.data!.conditionProgram![i].name!);
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
    if (usedprogramdropdownstr.contains('Level')) {
      usedprogramdropdownlist = _conditionModel.data!.levelSensor;
      dropdowntitle = 'Sensor';
      hint = 'Values';
    }
    if (usedprogramdropdownstr.contains('Moisture')) {
      usedprogramdropdownlist = _conditionModel.data!.moistureSensor;
      dropdowntitle = 'Sensor';
      hint = 'Values';
    }
    if (usedprogramdropdownstr.contains('Analog')) {
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
    return conditionselectionstr;
  }

  @override
  Widget build(BuildContext context) {
    if (_conditionModel.data == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (conditionLibrary!.length <= 0) {
      return Container(
        child: const Center(
            child: Text(
              'Condition Not Found',
              style: TextStyle(color: Colors.black, fontSize: 20),
            )),
      );
    } else {
      return DefaultTabController(
        length: conditionLibrary!.length ?? 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Conditions Library'),
              backgroundColor: Color.fromARGB(255, 31, 164, 231),
              //  _currentSelection == 0 ? rain() : buildFrostselection(),
            ),
            body: buildcodition(context),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                      conditionselection(usedprogramdropdownstr,
                          usedprogramdropdownstr2, valueforwhentrue);
                  conditionLibrary![Selectindexrow].program = programstr;
                  conditionLibrary![Selectindexrow].zone = zonestr;
                  conditionLibrary![Selectindexrow].dropdown1 =
                      usedprogramdropdownstr;
                  conditionLibrary![Selectindexrow].dropdown2 =
                      usedprogramdropdownstr2;
                  conditionLibrary![Selectindexrow].dropdownValue =
                      valueforwhentrue;
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

  @override
  Widget buildcodition(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          CupertinoSegmentedControl<int>(
            children: _segmenttab,
            onValueChanged: (value) {
              setState(() {
                _currentSelection = value!;
                if (value == 0) {
                  conditionLibrary = _conditionModel.data!.conditionProgram!;
                } else if (value == 1) {
                  conditionLibrary = _conditionModel.data!.conditionMoisture!;
                } else {
                  conditionLibrary = _conditionModel.data!.conditionLevel!;
                }
              });
            },
            groupValue: _currentSelection,
          ),
          Expanded(
            child: DefaultTabController(
              length: conditionLibrary!.length, // Number of tabs
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                    isScrollable: true,
                    tabs: [
                      for (var i = 0; i < conditionLibrary!.length; i++)
                        Tab(
                          text: conditionLibrary![i].name ?? 'Condition',
                        ),
                    ],
                    onTap: (value) {
                      setState(() {
                        tabclickindex = value;
                        changeval(value);
                      });
                    },
                  ),
                  const SizedBox(height: 10.0),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height - 200,
                    child: TabBarView(controller: _tabController, children: [
                      for (var i = 0; i < conditionLibrary!.length; i++)
                        ConditionTab(i, conditionLibrary),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  changeval(int Selectindexrow) {
    usedprogramdropdownstr = conditionLibrary![Selectindexrow].dropdown1!;
    usedprogramdropdownstr2 = conditionLibrary![Selectindexrow].dropdown2!;
    // valueforwhentrue =
    //     _conditionModel.data!.conditionLibrary![Selectindexrow].dropdownValue!;
    dropdownvalues = conditionLibrary![Selectindexrow].dropdownValue!;

    checklistdropdown();
  }

//TODO:-  ConditionTab
  Widget ConditionTab(int i, List<ConditionLibrary>? conditionLibrary) {
    // tabclickindex = i;
    // changeval(i);
    // _handleTabSelection
    //  _tabController.index = i;
    if (_tabController.index == i) {
      String conditiontrue = conditionLibrary![i].conditionIsTrueWhen!;

      bool containsOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(dropdownvalues);
      bool containsOnlyOperators = RegExp(r'^[&|^]+$').hasMatch(dropdownvalues);

      if ((usedprogramdropdownstr.contains('Combined') == true)) {
        if (conditionList.contains(usedprogramdropdownstr2)) {
          usedprogramdropdownstr2 = conditionLibrary[i].dropdown2!;
        } else {
          usedprogramdropdownstr2 = "";
        }
      } else {
        List<String> names = usedprogramdropdownlist!
            .map((contact) => contact.name as String)
            .toList();
        if (names.contains(usedprogramdropdownstr2)) {
          usedprogramdropdownstr2 = conditionLibrary[i].dropdown2!;
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
              child:
              Center(child: Text('${i + 1}. ${conditionLibrary![i].id}')),
              color: Colors.amber,
            ),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[2]),
                  trailing: Text(conditionLibrary![i].name.toString()),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[3]),
                  trailing: MySwitch(
                    value: conditionLibrary![i].enable ?? false,
                    onChanged: ((value) {
                      setState(() {
                        conditionLibrary![i].enable = value;
                      });
                    }),
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[4]),
                  trailing: Text(conditionLibrary![i].state.toString()),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[5]),
                  trailing: Container(
                    child: InkWell(
                      child: Text(
                        '${conditionLibrary![i].duration}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      onTap: () async {
                        String? time = await _selectTime(context);
                        setState(() {
                          if (time == null) {
                            conditionLibrary![i].duration = time;
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
                        conditionLibrary![i].conditionIsTrueWhen.toString(),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      )),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[10]),
                  trailing: Text(
                    conditionLibrary![i].usedByProgram.toString(),
                    softWrap: true,
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[7]),
                  trailing: InkWell(
                    child: Text(
                      '${conditionLibrary![i].fromTime}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () async {
                      String? time = await _selectTime(context);
                      setState(() {
                        if (time == null) {
                          conditionLibrary![i].fromTime = time;
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
                      '${conditionLibrary![i].untilTime}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () async {
                      String? time = await _selectTime(context);
                      setState(() {
                        if (time == null) {
                          conditionLibrary![i].untilTime = time;
                        }
                      });
                    },
                  ),
                )),
            Card(
                child: ListTile(
                  title: Text(conditionhdrlist[9]),
                  trailing: MySwitch(
                    value: conditionLibrary![i].notification ?? false,
                    onChanged: ((value) {
                      setState(() {
                        conditionLibrary![i].notification = value;
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
                        conditionLibrary![i].dropdown1 = value.toString();
                        checklistdropdown();
                      });
                    },
                    value: usedprogramdropdownstr == ''
                        ? conditionLibrary![i].dropdown1!.isEmpty
                        ? (_conditionModel.data!.dropdown![0])
                        : conditionLibrary![i].dropdown1!.toString()
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
                          conditionLibrary![i].dropdown2 = value;
                        });
                      },
                      value: usedprogramdropdownstr2,
                    ),
                  )),
            //Values
            if (usedprogramdropdownstr.contains('Analog') ||
                usedprogramdropdownstr.contains('Moisture') ||
                usedprogramdropdownstr.contains('Level') ||
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
                        initialValue: conditionLibrary![i].dropdownValue,
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
                              conditionLibrary![i].dropdownValue = value;
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
                          conditionLibrary![Selectindexrow].dropdownValue = value!;
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
                          conditionLibrary![Selectindexrow].dropdown2 = value!;
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
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, '');
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      conditionLibrary![Selectindexrow].usedByProgram =
                          programstr;

                      List<UserNames>? program = _conditionModel.data!.program!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Contact')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(
                              usedprogramdropdownstr, '', dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      List<UserNames>? program = _conditionModel.data!.contact!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Analog')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.analogSensor!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Moisture')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.moistureSensor!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Level')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          conditionselection(usedprogramdropdownstr,
                              usedprogramdropdownstr2, dropdownvalues);
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.levelSensor!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Water')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      List<UserNames>? program =
                      _conditionModel.data!.waterMeter!;
                      if (program != null) {
                        String? sNo =
                        getSNoByName(program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('condition')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                      '$usedprogramdropdownstr ${conditionList[Selectindexrow]} $dropdownvalues $usedprogramdropdownstr2';
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 =
                          usedprogramdropdownstr2;
                      conditionLibrary![Selectindexrow].dropdownValue =
                          dropdownvalues;
                      // _conditionModel.data!.conditionLibrary![Selectindexrow].program = dropdownvalues;

                      List<ConditionLibrary>? program = conditionLibrary;
                      if (program != null) {
                        String? sNo = getSNoByNamecondition(
                            program, usedprogramdropdownstr2);
                        if (sNo != null) {
                          conditionLibrary![Selectindexrow].program = '$sNo';
                        } else {
                          conditionLibrary![Selectindexrow].program = '0';
                        }
                      }
                    } else if (usedprogramdropdownstr.contains('Zone')) {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown1 =
                          usedprogramdropdownstr;
                      conditionLibrary![Selectindexrow].dropdown2 = '';
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      conditionLibrary![Selectindexrow].program = '0';
                    } else {
                      conditionLibrary![Selectindexrow].conditionIsTrueWhen =
                      '';
                      conditionLibrary![Selectindexrow].dropdown1 = '';
                      conditionLibrary![Selectindexrow].dropdown2 = '';
                      // _conditionModel.data!.conditionLibrary![Selectindexrow]
                      //     .dropdownValue = '';
                      conditionLibrary![Selectindexrow].program = '0';
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
    List<Map<String, dynamic>> programJson = _conditionModel
        .data!.conditionProgram!
        .map((condition) => condition.toJson())
        .toList();
    List<Map<String, dynamic>> levelJson = _conditionModel.data!.conditionLevel!
        .map((condition) => condition.toJson())
        .toList();
    List<Map<String, dynamic>> moistureJson = _conditionModel
        .data!.conditionMoisture!
        .map((condition) => condition.toJson())
        .toList();

    Map<String, dynamic> conditionJo2n = _conditionModel.data!.toJson();
    //    print('  print(conditionJso2n["conditionLibrary"]) ${conditionJo2n[
    // "conditionLibrary"]["program"]}');
    Map<String, dynamic> finaljson = {
      "program": programJson,
      "moisture": moistureJson,
      "level": levelJson
    };

    String Mqttsenddata = toMqttformat(conditionLibrary);
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "condition": finaljson,
      "createUser": widget.userId
    };
    final response = await HttpService()
        .postRequest("createUserPlanningConditionLibrary", body);
    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);

    String payLoadFinal = jsonEncode({
      "700": [
        {"708": Mqttsenddata},
      ]
    });
    // MqttWebClient().publishMessage('AppToFirmware/E8FB1C3501D1', payLoadFinal);
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
