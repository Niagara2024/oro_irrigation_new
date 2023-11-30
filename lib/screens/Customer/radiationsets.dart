import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../Models/Customer/radiation_model.dart';
import '../../Models/condition_model.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';


class RadiationsetUI extends StatefulWidget {
  const RadiationsetUI({Key? key, required this.userId, required this.controllerId});
  final userId, controllerId;

  @override
  State<RadiationsetUI> createState() => _RadiationsetUIState();
}

class _RadiationsetUIState extends State<RadiationsetUI>
    with SingleTickerProviderStateMixin {
  dynamic jsondata;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String usedprogramdropdownstr = '';
  List<UserNames>? usedprogramdropdownlist = [];
  String usedprogramdropdownstr2 = '';
  String dropdownvalues = '';
  RqadiationSet _radiationSet = RqadiationSet();
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
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.controllerId};
    final response =
        await HttpService().postRequest("getUserPlanningRadiationSet", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _radiationSet = RqadiationSet.fromJson(jsondata1);
      });
    } else {
      //_showSnackBar(response.body);
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

    // return '${_selectedTime.hour}:${_selectedTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    print('build${_radiationSet}');
    if (_radiationSet.data == 'null') {
      return Center(child: CircularProgressIndicator());
    } else {
      return DefaultTabController(
        length: _radiationSet.data!.length ?? 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Radiation Sets'),
              backgroundColor: Color.fromARGB(255, 118, 253, 253),
              bottom: TabBar(
                // controller: _tabController,
                indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                isScrollable: true,
                tabs: [
                  for (var i = 0; i < _radiationSet.data!.length; i++)
                    Tab(
                      text: '${_radiationSet.data![i].name ?? 'AS'}',
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
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBarView(children: [
                    for (var i = 0; i < _radiationSet.data!.length; i++)
                      buildTab(_radiationSet.data!, i)
                  ]),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                setState(() {
                  updateradiationset();
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

  changeval(int Selectindexrow) {}

  Widget buildTab(List<Datum>? list, int i) {
    return Column(
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
              ),
              top: BorderSide(
                color: Colors.black,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  child: Text(
                    'Time Interval 24 Hrs',
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Text(
                    '00:01 - 5:59',
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Text(
                    '5:59 - 15:59',
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: Text(
                    '15:59 - 23:59',
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView(
            children: [
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 252, 255, 255),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                    ), // Set bottom border
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        child: Text(
                          "Accumulated radiation threshold ",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          decoration: InputDecoration(border: InputBorder.none),
                          initialValue: list![i].accumulated1 != ''
                              ? list![i].accumulated1
                              : '0',
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              list[i].accumulated1 = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          decoration: InputDecoration(border: InputBorder.none),
                          initialValue: list[i].accumulated2 != ''
                              ? list[i].accumulated2
                              : '0',
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              list[i].accumulated2 = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          decoration: InputDecoration(border: InputBorder.none),
                          initialValue: list[i].accumulated3 != ''
                              ? list[i].accumulated3
                              : '0',
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              list[i].accumulated3 = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 252, 255, 255),
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.black), // Set bottom border
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        child: Text(
                          "Min interval (hh:mm)",
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                          child: Center(
                        child: InkWell(
                          child: Text(
                            '${list[i].minInterval1 != '' ? list[i].minInterval1 : '00:00'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            String time = await _selectTime(context);
                            setState(() {
                              list[i].minInterval1 = time;
                            });
                          },
                        ),
                      )),
                    ),
                    Expanded(
                      child: Container(
                          child: Center(
                        child: InkWell(
                          child: Text(
                            '${list[i].minInterval2 != '' ? list[i].minInterval2 : '00:00'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            String time = await _selectTime(context);
                            setState(() {
                              list[i].minInterval2 = time;
                            });
                          },
                        ),
                      )),
                    ),
                    Expanded(
                      child: Container(
                          child: Center(
                        child: InkWell(
                          child: Text(
                            '${list[i].minInterval3 != '' ? list[i].minInterval3 : '00:00'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            String time = await _selectTime(context);
                            setState(() {
                              list[i].minInterval3 = time;
                            });
                          },
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 252, 255, 255),
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.black), // Set bottom border
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        child: Text(
                          "Max interval (hh:mm)",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          child: Center(
                        child: InkWell(
                          child: Text(
                            '${list[i].maxInterval1 != '' ? list[i].maxInterval1 : '00:00'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            String time = await _selectTime(context);
                            setState(() {
                              list[i].maxInterval1 = time;
                            });
                          },
                        ),
                      )),
                    ),
                    Expanded(
                      child: Container(
                          child: Center(
                        child: InkWell(
                          child: Text(
                            '${list[i].maxInterval2 != '' ? list[i].maxInterval2 : '00:00'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            String time = await _selectTime(context);
                            setState(() {
                              list[i].maxInterval2 = time;
                            });
                          },
                        ),
                      )),
                    ),
                    Expanded(
                      child: Container(
                          child: Center(
                        child: InkWell(
                          child: Text(
                            '${list[i].maxInterval3 != '' ? list[i].maxInterval3 : '00:00'}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          onTap: () async {
                            String time = await _selectTime(context);
                            setState(() {
                              list[i].maxInterval3 = time;
                            });
                          },
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 252, 255, 255),
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.black), // Set bottom border
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        child: Text(
                          " Co - efficient",
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          decoration: InputDecoration(border: InputBorder.none),
                          initialValue: list[i].coefficient != ''
                              ? list[i].coefficient
                              : '0',
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              list[i].coefficient = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 252, 255, 255),
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.black), // Set bottom border
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        child: Text(
                          " Used by program",
                          textAlign: TextAlign.left,
                          softWrap: true,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          decoration: InputDecoration(border: InputBorder.none),
                          initialValue: list[i].usedByProgram != ''
                              ? list[i].usedByProgram
                              : '0',
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            setState(() {
                              list[i].usedByProgram = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTab1(List<Datum>? list, int i) {
    
    return Column(
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width - 10,
                child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,

                    // minWidth: 580,
                    columns: [
                      DataColumn2(
                        label: Center(
                            child: Text(
                          'Time Interval 24 Hrs',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          softWrap: true,
                        )),
                      ),
                      DataColumn2(
                        label: Center(
                          child: Text(
                            '00:01 - 5:59',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
                      DataColumn2(
                        label: Center(
                          child: Text(
                            '05:59 - 15:59',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
                      DataColumn2(
                        label: Center(
                          child: Text(
                            '15:59 - 23:59',
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                    rows: List<DataRow>.generate(
                        4,
                        (index) => DataRow(
                              color: MaterialStateColor.resolveWith((states) {
                                if (index == Selectindexrow) {
                                  return Colors.blue
                                      .withOpacity(0.5); // Selected row color
                                }
                                return Color.fromARGB(0, 176, 35, 35);
                              }),
                              cells: [
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        '_conditionModel.data!.conditionLibrary![index].untilTime}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      onTap: () async {
                                        String time =
                                            await _selectTime(context);
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                    ))),
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        '_conditionModel.data!.conditionLibrary![index].untilTime}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      onTap: () async {
                                        String time =
                                            await _selectTime(context);
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                    ))),
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        '_conditionModel.data!.conditionLibrary![index].untilTime}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      onTap: () async {
                                        String time =
                                            await _selectTime(context);
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                    ))),
                                DataCell(onTap: () {
                                  setState(() {
                                    Selectindexrow = index;
                                  });
                                },
                                    Center(
                                        child: InkWell(
                                      child: Text(
                                        '_conditionModel.data!.conditionLibrary![index].untilTime}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      onTap: () async {
                                        String time =
                                            await _selectTime(context);
                                        setState(() {
                                          Selectindexrow = index;
                                        });
                                      },
                                    )))
                              ],
                            )))),
          ),
        ),
      ],
    );
  }

  updateradiationset() async {
    List<Map<String, dynamic>> radiationset =
        _radiationSet.data!.map((condition) => condition.toJson()).toList();
    Map<String, Object> body = {
      "userId": '15',
      "controllerId": "1",
      "radiationSet": radiationset,
      "createUser": "1"
    };
    final response =
        await HttpService().postRequest("createUserPlanningRadiationSet", body);

    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(context, jsonDataresponse['message'], response.statusCode);
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
