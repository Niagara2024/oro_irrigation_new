import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/http_service.dart';
import 'package:oro_irrigation_new/constants/snack_bar.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/dealer_definition_config.dart';

import '../../Models/WaterSource.dart';

class watersourceUI extends StatefulWidget {
  const watersourceUI(
      {Key? key, required this.userId, required this.controllerId});
  final userId, controllerId;

  @override
  State<watersourceUI> createState() => _watersourceUIState();
}

class _watersourceUIState extends State<watersourceUI>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  Watersource _watersource = Watersource();
  int tabclickindex = 0;
  List<String> dropdownlist = ["Static", "Flow", "Nominal"];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //MqttWebClient().init();
    fetchData();
  }

  Future<void> fetchData() async {
    // _watersource = Watersource.fromJson(json);
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response =
    await HttpService().postRequest("getUserPlanningWaterSource", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _watersource = Watersource.fromJson(jsondata1);
        //MqttWebClient().onSubscribed('tweet/');
      });
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
    if (_watersource.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_watersource.data!.isEmpty) {
      return const Center(child: Text('Currently No Water source Available'));
    }
    {
      return DefaultTabController(
        length: _watersource.data!.length ?? 0,
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(left: 8, bottom: 80, right: 8, top: 8),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    child: TabBar(
                      // controller: _tabController,
                      indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                      isScrollable: true,
                      unselectedLabelColor: Colors.grey,
                      labelColor: myTheme.primaryColor,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        for (var i = 0; i < _watersource.data!.length; i++)
                          Tab(
                            text: '${_watersource.data![i].name}',
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
                  Container(
                    height: 300,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: myTheme.primaryColor, // Border color
                    //     // width: 10.0, // Border width
                    //   ),
                    // ),
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
                    child: TabBarView(children: [
                      for (var i = 0; i < _watersource.data!.length; i++)
                        buildTab(
                          _watersource.data![i].source,
                          i,
                          _watersource.data![i].id!,
                          _watersource.data![i].name!,
                        )
                    ]),
                  ),
                ],
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
      );
    }
  }

  double Changesize(int? count, int val) {
    count ??= 0;
    double size = (count * val).toDouble();
    return size;
  }

  changeval(int Selectindexrow) {}
  Widget buildTab(
      List<Source>? Listofvalue, int i, String sourceid, String sourcename) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
              title: Text(sourcename ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              trailing: Text(sourceid ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: Listofvalue?.length ?? 0,
            itemBuilder: (context, index) {
              if (Listofvalue?[index].widgetTypeId == 1) {
                return Column(
                  children: [
                    Card(
                      elevation: 0.1,
                      child: ListTile(
                        title: Text('${Listofvalue?[index].title}'),
                        trailing: SizedBox(
                            width: 100,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              onChanged: (text) {
                                setState(() {
                                  Listofvalue?[index].value = text;
                                });
                              },
                              decoration: InputDecoration(hintText: '0'),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              initialValue: Listofvalue?[index].value == ''
                                  ? ''
                                  : Listofvalue?[index].value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Warranty is required';
                                } else {
                                  setState(() {
                                    Listofvalue?[index].value = value;
                                  });
                                }
                                return null;
                              },
                            )),
                      ),
                    ),
                  ],
                );
              } else if (Listofvalue?[index].widgetTypeId == 2) {
                return Column(
                  children: [
                    Card(
                      elevation: 0.1,
                      child: ListTile(
                        title: Text('${Listofvalue?[index].title}'),
                        trailing: MySwitch(
                          value: Listofvalue?[index].value == '1',
                          onChanged: ((value) {
                            setState(() {
                              Listofvalue?[index].value = !value ? '0' : '1';
                            });
                            // Listofvalue?[index].value = value;
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (Listofvalue?[index].widgetTypeId == 3) {
                print(Listofvalue?[index].value);
                String? dropdownval = Listofvalue?[index].value;
                dropdownlist.contains(dropdownval) == true
                    ? dropdownval
                    : dropdownval = 'Static';

                return Column(
                  children: [
                    Container(
                      child: Card(
                        elevation: 0.1,
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}'),
                          trailing: Container(
                            color: Colors.white70,
                            width: 100,
                            child: DropdownButton(
                                items: dropdownlist.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Container(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(items)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    Listofvalue?[index].value = value!;
                                    dropdownval = Listofvalue?[index].value;
                                  });
                                },
                                value: Listofvalue?[index].value == ''
                                    ? dropdownlist[0]
                                    : Listofvalue?[index].value),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (Listofvalue?[index].widgetTypeId == 5) {
                String? dropdownval = Listofvalue?[index].value;
                return Column(
                  children: [
                    Card(
                      child: ListTile(
                        title: Text('${Listofvalue?[index].title}'),
                        trailing: SizedBox(
                          width: 100,
                          child: Container(
                              child: Center(
                                child: InkWell(
                                  child: Text(
                                    '${Listofvalue?[index].value}' != ''
                                        ? '${Listofvalue?[index].value}'
                                        : '00:00',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  onTap: () async {
                                    String? time = await _selectTime(context);
                                    setState(() {
                                      if (time != null) {
                                        Listofvalue?[index].value = time;
                                      }
                                    });
                                  },
                                ),
                              )),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [Container()],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  updateradiationset() async {
    List<Map<String, dynamic>> watersource =
    _watersource.data!.map((condition) => condition.toJson()).toList();
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "waterSource": watersource,
      "createUser": widget.userId
    };
    print(body);
    String Mqttsenddata = toMqttformat(_watersource.data);
    final response =
    await HttpService().postRequest("createUserPlanningWaterSource", body);
    final jsonDataresponse = jsonDecode(response.body);
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);

    String payLoadFinal = jsonEncode({
      "1600": [
        {"1601": Mqttsenddata},
      ]
    });
    //MqttWebClient().publishMessage('AppToFirmware/E8FB1C3501D1', payLoadFinal);
  }

  String toMqttformat(
      List<Datum>? data,
      ) {
    String Mqttdata = '';

    for (var i = 0; i < data!.length; i++) {
      int sno = data[i].sNo!;
      String id = '${data[i].id!}';
      List<String> time = [];

      String name = '${data[i].name}';

      String mode = '0';
      if (data[i].source![0].value!! == 'Static') {
        mode = '1';
      } else if (data[i].source![0].value!! == 'Flow') {
        mode = '2';
      } else if (data[i].source![0].value!! == 'Nominal') {
        mode = '3';
      } else {
        mode = '0';
      }

      String Pump =
      data[i].source![1].value!.isEmpty ? '0' : data[i].source![1].value!;
      String line = data[i].source![2].value!.isEmpty
          ? '00:00:00'
          : '${data[i].source![2].value!}:00';
      String flow = data[i].source![3].value!.isEmpty
          ? '00:00:00'
          : '${data[i].source![3].value!}:00';

      Mqttdata += '$sno,$id,$name,$mode,$Pump,$line,$flow;';
    }
    return Mqttdata;
  }
}