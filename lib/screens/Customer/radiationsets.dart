import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/mqtt_web_client.dart';
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
    MqttWebClient().init();
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
      MqttWebClient().onSubscribed('tweet/');
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
    } else {
      return DefaultTabController(
        length: _radiationSet.data!.length ?? 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Radiation Sets'),
              backgroundColor: myTheme.primaryColor,
              bottom: TabBar(
                indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
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
                  });
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flexible(
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

  Widget buildTab(List<Datum>? list, int i) {
    return SingleChildScrollView(
      // scrollDirection: Axis.horizontal,
      child: Container(
        height: MediaQuery.of(context).size.height - 150,
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          // dataRowMaxHeight: 80,
          // dataRowMinHeight: 40,
          // headingRowHeight: 180,
          columns: [
            DataColumn(
                label: Text(
                  'Time Interval 24 Hrs',
                  softWrap: true,
                )),
            DataColumn(
                label: Text(
                  '00:01 - 5:59',
                  textAlign: TextAlign.center,
                  softWrap: true,
                )),
            DataColumn(label: Text('5:59 - 15:59', textAlign: TextAlign.center, softWrap: true)),
            DataColumn(label: Text('15:59 - 23:59', textAlign: TextAlign.center, softWrap: true)),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text("Accumulated radiation threshold ")),
              DataCell(
                TextFormField(
                  decoration: InputDecoration(border: InputBorder.none),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue:
                  list![i].accumulated1 != '' ? list![i].accumulated1 : '0',
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
                  decoration: InputDecoration(border: InputBorder.none),
                  initialValue:
                  list[i].accumulated2 != '' ? list[i].accumulated2 : '0',
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
                  decoration: InputDecoration(border: InputBorder.none),
                  initialValue:
                  list[i].accumulated3 != '' ? list[i].accumulated3 : '0',
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
              DataCell(Text("Min interval (hh:mm)")),
              DataCell(
                Center(
                  child: InkWell(
                    child: Text(
                      '${list[i].minInterval1 != '' ? list[i].minInterval1 : '00:00'}',
                      style: const TextStyle(fontSize: 20),
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
                      style: const TextStyle(fontSize: 20),
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
                      style: const TextStyle(fontSize: 20),
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
              DataCell(Text("Max interval (hh:mm)")),
              DataCell(
                Center(
                  child: InkWell(
                    child: Text(
                      '${list[i].maxInterval1 != '' ? list[i].maxInterval1 : '00:00'}',
                      style: const TextStyle(fontSize: 20),
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
                      style: const TextStyle(fontSize: 20),
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
                      style: const TextStyle(fontSize: 20),
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
              DataCell(Text(" Co - efficient")),
              DataCell(
                TextFormField(
                  decoration: InputDecoration(border: InputBorder.none),
                  initialValue: '',
                  textAlign: TextAlign.center,
                ),
              ),
              DataCell(
                TextFormField(
                  decoration: InputDecoration(border: InputBorder.none),
                  initialValue:
                  list[i].coefficient != '' ? list[i].coefficient : '0',
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
                ),
              ),
            ]),
            DataRow(cells: [
              DataCell(Text(" Used by program")),
              DataCell(
                TextFormField(
                  decoration: InputDecoration(border: InputBorder.none),
                  initialValue: '',
                  textAlign: TextAlign.center,
                ),
              ),
              DataCell(
                TextFormField(
                  decoration: InputDecoration(border: InputBorder.none),
                  initialValue:
                  list[i].usedByProgram != '' ? list[i].usedByProgram : '0',
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
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  updateradiationset() async {
    List<Map<String, dynamic>> radiationset =
    _radiationSet.data!.map((condition) => condition.toJson()).toList();
    String Mqttsenddata  = toMqttformat(_radiationSet.data!);

    String payLoadFinal = jsonEncode({
      "1900": [
        {"1901": Mqttsenddata},
      ]
    });
    MqttWebClient().publishMessage('AppToFirmware/E8FB1C3501D1', payLoadFinal);
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
}
