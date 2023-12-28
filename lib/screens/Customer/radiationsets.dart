import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../Models/Customer/radiation_model.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';

class RadiationsetUI extends StatefulWidget {
  const RadiationsetUI(
      {Key? key, required this.userId, required this.controllerId});
  final userId, controllerId;

  @override
  State<RadiationsetUI> createState() => _RadiationsetUIState();
}

class _RadiationsetUIState extends State<RadiationsetUI>
    with SingleTickerProviderStateMixin {
  dynamic jsondata;
  TimeOfDay _selectedTime = TimeOfDay.now();
  RqadiationSet _radiationSet = RqadiationSet();
  int tabclickindex = 0;

  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    //MqttWebClient().init();
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response =
    await HttpService().postRequest("getUserPlanningRadiationSet", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _radiationSet = RqadiationSet.fromJson(jsondata1);
      });
      //MqttWebClient().onSubscribed('tweet/');
    } else {
      //_showSnackBar(response.body);
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

  @override
  Widget build(BuildContext context) {
    if (_radiationSet.data == null) {
      return Center(child: CircularProgressIndicator());
    } else if (_radiationSet.data!.isEmpty) {
      return const Center(child: Text('Currently No Radiation Sets Available'));
    } else {
      return DefaultTabController(
        length: _radiationSet.data!.length ?? 0,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: TabBar(
                    indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                    labelColor: myTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      for (var i = 0; i < _radiationSet.data!.length; i++)
                        Tab(
                          text: '${_radiationSet.data![i].name ?? 'AS'}',
                        ),
                    ],
                    onTap: (value) {
                      setState(() {
                        tabclickindex = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabBarView(children: [
                    for (var i = 0; i < _radiationSet.data!.length; i++)
                      buildTab(_radiationSet.data!, i)
                  ]),
                ),
              ],
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
      );
    }
  }

  Widget buildTab(List<Datum>? list, int i) {
    return Column(
      children: [
        SingleChildScrollView(
          // scrollDirection: Axis.horizontal,
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            width: MediaQuery.of(context).size.width,
            child: DataTable2(
              headingRowColor: MaterialStateProperty.all<Color>(
                  primaryColorDark.withOpacity(0.2)),
              fixedCornerColor: myTheme.primaryColor,

              // border: TableBorder.all(),
              columns: [
                DataColumn2(
                    size: ColumnSize.L,
                    label: Text(
                      'Time Interval 24 Hrs',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _fontSizeheading(),
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                DataColumn2(
                    size: ColumnSize.L,
                    label: Center(
                      child: Text(
                        '00:01 - 5:59',
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: _fontSizeheading(),
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                DataColumn2(
                    size: ColumnSize.L,
                    label: Center(
                      child: Text(
                        '05:59 - 15:59',
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: _fontSizeheading(),
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                DataColumn2(
                  size: ColumnSize.L,
                  label: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: Text(
                        '15:59 - 23:59',
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(
                            fontSize: _fontSizeheading(),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text(
                    "Accumulated radiation threshold ",
                    style: TextStyle(fontSize: _fontSizelabel()),
                  )),
                  DataCell(
                    onTap: () {
                      setState(() {});
                    },
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none,hintText: '0'),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: list![i].accumulated1 != ''
                          ? list![i].accumulated1
                          : '',
                      textAlign: TextAlign.center,

                      onChanged: (value) {
                        setState(() {
                          list[i].accumulated1 = value;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none, hintText: '0'),
                      initialValue: list[i].accumulated2 != ''
                          ? list[i].accumulated2
                          : '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        setState(() {
                          list[i].accumulated2 = value;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none, hintText: '0'),
                      initialValue: list[i].accumulated3 != ''
                          ? list[i].accumulated3
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list[i].accumulated3 = value;
                        });
                      },
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    "Min interval (hh:mm)",
                    style: TextStyle(fontSize: _fontSizelabel()),
                  )),
                  DataCell(
                    Center(
                      child: InkWell(
                        child: Text(
                          '${list[i].minInterval1 != '' ? list[i].minInterval1 : '00:00'}',
                          style: TextStyle(fontSize: _fontSizelabel()),
                        ),
                        onTap: () async {
                          String? time = await _selectTime(context);
                          setState(() {
                            if (time != null) {
                              list[i].minInterval1 = time;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: InkWell(
                        child: Text(
                          '${list[i].minInterval2 != '' ? list[i].minInterval2 : '00:00'}',
                          style: TextStyle(fontSize: _fontSizelabel()),
                        ),
                        onTap: () async {
                          String? time = await _selectTime(context);
                          setState(() {
                            if (time != null) {
                              list[i].minInterval2 = time;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: InkWell(
                        child: Text(
                          '${list[i].minInterval3 != '' ? list[i].minInterval3 : '00:00'}',
                          style: TextStyle(fontSize: _fontSizelabel()),
                        ),
                        onTap: () async {
                          String? time = await _selectTime(context);
                          setState(() {
                            if (time != null) {
                              list[i].minInterval3 = time;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    "Max interval (hh:mm)",
                    style: TextStyle(fontSize: _fontSizelabel()),
                  )),
                  DataCell(
                    Center(
                      child: InkWell(
                        child: Text(
                          '${list[i].maxInterval1 != '' ? list[i].maxInterval1 : '00:00'}',
                          style: TextStyle(fontSize: _fontSizelabel()),
                        ),
                        onTap: () async {
                          String? time = await _selectTime(context);
                          setState(() {
                            if (time != null) {
                              list[i].maxInterval1 = time;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: InkWell(
                        child: Text(
                          '${list[i].maxInterval2 != '' ? list[i].maxInterval2 : '00:00'}',
                          style: TextStyle(fontSize: _fontSizelabel()),
                        ),
                        onTap: () async {
                          String? time = await _selectTime(context);
                          setState(() {
                            if (time != null) {
                              list[i].maxInterval2 = time;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: InkWell(
                        child: Text(
                          '${list[i].maxInterval3 != '' ? list[i].maxInterval3 : '00:00'}',
                          style: TextStyle(fontSize: _fontSizelabel()),
                        ),
                        onTap: () async {
                          String? time = await _selectTime(context);
                          setState(() {
                            if (time != null) {
                              list[i].maxInterval3 = time;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    " Co - efficient",
                    style: TextStyle(fontSize: _fontSizelabel()),
                  )),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none),
                      initialValue: '',
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none, hintText: '0'),
                      initialValue:
                      list[i].coefficient != '' ? list[i].coefficient : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list[i].coefficient = value;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none),
                      initialValue: '',
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text(
                    " Used by program",
                    style: TextStyle(fontSize: _fontSizelabel()),
                  )),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none),
                      initialValue: '',
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none, hintText: '0'),
                      initialValue: list[i].usedByProgram != ''
                          ? list[i].usedByProgram
                          : '',
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          list[i].usedByProgram = value;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      decoration: InputDecoration(border: InputBorder.none),
                      initialValue: '',
                      textAlign: TextAlign.center,
                      readOnly: true,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  updateradiationset() async {
    List<Map<String, dynamic>> radiationset =
    _radiationSet.data!.map((condition) => condition.toJson()).toList();
    String Mqttsenddata = toMqttformat(_radiationSet.data!);

    String payLoadFinal = jsonEncode({
      "1900": [
        {"1901": Mqttsenddata},
      ]
    });
    //MqttWebClient().publishMessage('AppToFirmware/E8FB1C3501D1', payLoadFinal);
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "radiationSet": radiationset,
      "createUser": widget.userId
    };
    final response =
    await HttpService().postRequest("createUserPlanningRadiationSet", body);

    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);
  }

  String toMqttformat(
      List<Datum>? data,
      ) {
    String Mqttdata = '';
    for (var i = 0; i < data!.length; i++) {
      Mqttdata +=
      '${data[i].sNo},${data[i].id},${data[i].name}:00,${data[i].location},${data[i].accumulated1},${data[i].accumulated2},${data[i].accumulated3},${data[i].maxInterval1}:00,${data[i].maxInterval2}:00,${data[i].maxInterval3}:00,${data[i].minInterval1}:00,${data[i].minInterval2}:00,${data[i].minInterval3}:00,${data[i].coefficient},${data[i].usedByProgram};';
    }
    return Mqttdata;
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