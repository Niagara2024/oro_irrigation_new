import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_irrigation_new/constants/http_service.dart';
import 'package:oro_irrigation_new/constants/snack_bar.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/dealer_definition_config.dart';
import '../../Models/Customer/back_wash_model.dart';
import '../../constants/MQTTManager.dart';
import '../../widgets/FontSizeUtils.dart';

class FilterBackwashUI extends StatefulWidget {
  const FilterBackwashUI(
      {Key? key, required this.userId, required this.controllerId, this.deviceID});
  final userId, controllerId,deviceID;

  @override
  State<FilterBackwashUI> createState() => _FilterBackwashUIState();
}

class _FilterBackwashUIState extends State<FilterBackwashUI>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  TimeOfDay _selectedTime = TimeOfDay.now();
  Filterbackwash _filterbackwash = Filterbackwash();
  int tabclickindex = 0;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //MqttWebClient().init();
    fetchData();
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response = await HttpService()
        .postRequest("getUserPlanningFilterBackwashing", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _filterbackwash = Filterbackwash.fromJson(jsondata1);
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
    if (_filterbackwash.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_filterbackwash.data!.isEmpty) {
      return const Center(child: Text('Currently No Filter Available'));
    } else {
      return DefaultTabController(
        length: _filterbackwash.data!.length ?? 0,
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
                        for (var i = 0; i < _filterbackwash.data!.length; i++)
                          Tab(
                            text: '${_filterbackwash.data![i].name}',
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
                  Expanded(
                    child: TabBarView(children: [
                      for (var i = 0; i < _filterbackwash.data!.length; i++)
                        buildTab(
                          _filterbackwash.data![i].filter,
                          i,
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

  Widget buildTab(List<Filter>? Listofvalue, int i) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Listofvalue?.length ?? 0,
              itemBuilder: (context, index) {
                if (Listofvalue?[index].widgetTypeId == 1) {
                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',style:  TextStyle(
                            fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                            fontWeight: FontWeight.bold,),
                            softWrap: true,),
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
                                initialValue: Listofvalue?[index].value ?? '',
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
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',style:  TextStyle(
                            fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                            fontWeight: FontWeight.bold,),
                            softWrap: true,),
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
                  final dropdownlist = [
                    'Stop Irrigation',
                    'Continue Irrigation',
                    'No Fertilization'
                  ];
                  print(Listofvalue?[index].value);
                  String dropdownval = Listofvalue?[index].value;
                  dropdownlist.contains(dropdownval) == true
                      ? dropdownval
                      : dropdownval = 'Stop Irrigation';

                  return Column(
                    children: [
                      Container(
                        child: Card(
                          child: ListTile(
                            title: Text('${Listofvalue?[index].title}',style:  TextStyle(
                              fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                              fontWeight: FontWeight.bold,),
                              softWrap: true,),
                            trailing: Container(
                              color: Colors.white70,
                              width: 180,
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
                } else if (Listofvalue?[index].widgetTypeId == 5 &&
                    Listofvalue?[index].title != "FLUSHING TIME") {
                  return Column(
                    children: [
                      Card(
                        child: ListTile(
                          title: Text('${Listofvalue?[index].title}',style:  TextStyle(
                            fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                            fontWeight: FontWeight.bold,),
                            softWrap: true,),
                          trailing: SizedBox(
                            width: 85,
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
                    children: [
                      Container(
                        height:
                        Changesize(Listofvalue?[index].value.length, 60),
                        width: double.infinity,
                        child: ListView.builder(
                            itemCount: Listofvalue?[index].value!.length ?? 0,
                            itemBuilder: (context, flusingindex) {
                              return Column(
                                children: [
                                  Card(
                                    child: ListTile(
                                      title: Text(
                                        '${Listofvalue?[index].value[flusingindex]['name']}',style:  TextStyle(
                                        fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                                        fontWeight: FontWeight.bold,),
                                        softWrap: true,),
                                      trailing: SizedBox(
                                        width: 80,
                                        child: Container(
                                            child: Center(
                                              child: InkWell(
                                                child: Text(
                                                  '${Listofvalue?[index].value![flusingindex]['value']}' !=
                                                      ''
                                                      ? '${Listofvalue?[index].value![flusingindex]['value']}'
                                                      : '00:00',
                                                  style:
                                                  const TextStyle(fontSize: 20),
                                                ),
                                                onTap: () async {
                                                  String? time =
                                                  await _selectTime(context);
                                                  setState(() {
                                                    if (time != null) {
                                                      Listofvalue?[index]
                                                          .value![flusingindex]
                                                      ['value'] = time;
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
                            }),
                      )
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  updateradiationset() async {
    List<Map<String, dynamic>> Filterbackwash =
    _filterbackwash.data!.map((condition) => condition.toJson()).toList();
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "filterBackwash": Filterbackwash,
      "createUser": widget.userId
    };
    String Mqttsenddata = toMqttformat(_filterbackwash.data);
    final response = await HttpService()
        .postRequest("createUserPlanningFilterBackwashing", body);
    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);

    String payLoadFinal = jsonEncode({
      "900": [
        {"901": Mqttsenddata},
      ]
    });

    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }

  String toMqttformat(
      List<Datum>? data,
      ) {
    String Mqttdata = '';

    for (var i = 0; i < data!.length; i++) {
      int sno = data[i].sNo!;
      String id = '${data[i].id!}';
      List<String> time = [];
      for (var j = 0; j < data[i].filter![0].value.length; j++) {
        time.add('${data[i].filter![0].value[j]['value']}:00');
      }
      String flushingTime = time.join(',');
      String filterInterval = data[i].filter![1].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![1].value!}:00';
      String flushingInterval = data[i].filter![2].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![2].value!}:00';
      String whileFlushing = '0';
      if (data[i].filter![3].value! == 'Stop Irrigation') {
        whileFlushing = '1';
      } else if (data[i].filter![3].value! == 'Continue Irrigation') {
        whileFlushing = '2';
      } else if (data[i].filter![3].value! == 'No Fertilization') {
        whileFlushing = '2';
      } else {
        whileFlushing = '0';
      }

      String cycles =
      data[i].filter![4].value!.isEmpty ? '0' : data[i].filter![4].value!;
      String pressureValues =
      data[i].filter![5].value!.isEmpty ? '0' : data[i].filter![5].value!;
      String deltaPressureDelay = data[i].filter![6].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![6].value!}:00';
      String dwellTimeMainFilter = data[i].filter![7].value!.isEmpty
          ? '00:00:00'
          : '${data[i].filter![7].value!}:00';
      String manualFlushingStatus =
      data[i].filter![8].value! == false ? '0' : '1';

      Mqttdata +=
      '$sno,$id,$flushingTime,$filterInterval,$flushingInterval,$whileFlushing,$cycles,$pressureValues,$deltaPressureDelay,$dwellTimeMainFilter,$manualFlushingStatus;';
    }
    return Mqttdata;
  }
}