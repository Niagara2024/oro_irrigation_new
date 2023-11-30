import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Models/Customer/frost_model.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../Config/dealer_definition_config.dart';


class FrostMobUI extends StatefulWidget {
  const FrostMobUI({Key? key, required this.userId, required this.controllerId});
  final userId, controllerId;

  @override
  State<FrostMobUI> createState() => _ConditionUIState();
}

class _ConditionUIState extends State<FrostMobUI>
    with SingleTickerProviderStateMixin {
  FrostProtectionModel _frostProtectionModel = FrostProtectionModel();

  final _formKey = GlobalKey<FormState>();
  List<String> conditionList = [];
  int _currentSelection = 0;

  final Map<int, Widget> _children = {
    0: const Text(' Frost Protection '),
    1: const Text(' Rain Delay '),
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Map<String, Object> body = {"userId": widget.userId, "controllerId": widget.controllerId};
    final response = await HttpService()
        .postRequest("getUserPlanningFrostProtectionAndRainDelay", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _frostProtectionModel = frostProtectionModelFromJson(response.body);
      });
    } else {
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_frostProtectionModel.frostProtection == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Frost Protection'),
            backgroundColor: const Color.fromARGB(255, 31, 164, 231),
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CupertinoSegmentedControl<int>(
                      children: _children,
                      onValueChanged: (value) {
                        setState(() {
                          _currentSelection = value!;
                        });
                      },
                      groupValue: _currentSelection,
                    ),
                    buildFrostselection1(),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              setState(() {
                updateconditions();
              });
            },
            tooltip: 'Send',
            child: const Icon(Icons.send),
          ),
        ),
      );
    }
  }

  Widget buildFrostselection1() {
    List<FrostProtection>? Listofvalue = _currentSelection == 0
        ? _frostProtectionModel.frostProtection
        : _frostProtectionModel.rainDelay;

    return Expanded(
      child: ListView.builder(
        itemCount: Listofvalue?.length ?? 0,
        itemBuilder: (context, index) {
          int iconcode = int.parse(Listofvalue?[index].iconCodePoint ?? "");
          String C = '\u00B0C';
          String iconfontfamily =
              Listofvalue?[index].iconFontFamily ?? "MaterialIcons";
          if (Listofvalue?[index].widgetTypeId == 1) {
            return Column(
              children: [
                Container(
                  child: ListTile(
                    title: Text('${Listofvalue?[index].title}'),
                    // leading:
                    //     Icon(IconData(iconcode, fontFamily: iconfontfamily)),
                    trailing: SizedBox(
                        width: 50,
                        child: CustomTextField(
                          onChanged: (text) {
                            setState(() {
                              _currentSelection == 0
                                  ? _frostProtectionModel
                                      .frostProtection![index].value = text
                                  : _frostProtectionModel
                                      .rainDelay![index].value = text;
                            });
                          },
                          initialValue: '${Listofvalue?[index].value}' ?? '0',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Value is required';
                            } else {
                              setState(() {
                                _currentSelection == 0
                                    ? _frostProtectionModel
                                        .frostProtection![index].value = value
                                    : _frostProtectionModel
                                        .rainDelay![index].value = value;
                              });
                            }
                            return null;
                          },
                        )),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 70,
                  ),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  child: ListTile(
                    title: Text('${Listofvalue?[index].title}'),
                    // leading:
                    //     Icon(IconData(iconcode, fontFamily: iconfontfamily)),
                    trailing: MySwitch(
                      value: Listofvalue?[index].value == '1',
                      onChanged: ((value) {
                        setState(() {
                          Listofvalue?[index].value = !value ? '0' : '1';
                          _currentSelection == 0
                              ? _frostProtectionModel.frostProtection![index]
                                  .value = !value ? '0' : '1'
                              : _frostProtectionModel.rainDelay![index].value =
                                  !value ? '0' : '1';
                        });
                        // Listofvalue?[index].value = value;
                      }),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    left: 70,
                  ),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  updateconditions() async {
    //  final frostProtection = jsonEncode(_frostProtectionModel.frostProtection);
    // final rainDelay = jsonEncode(_frostProtectionModel.rainDelay);

    List<Map<String, dynamic>> frostProtection = _frostProtectionModel
        .frostProtection!
        .map((frost) => frost.toJson())
        .toList();
    List<Map<String, dynamic>> rainDelay = _frostProtectionModel.rainDelay!
        .map((frost) => frost.toJson())
        .toList();
    Map<String, Object> body = {
      "userId": '15',
      "controllerId": "1",
      "frostProtection": frostProtection,
      "rainDelay": rainDelay,
      "createUser": "1"
    };
    final response = await HttpService()
        .postRequest("createUserPlanningFrostProtectionAndRainDelay", body);
    final jsonDataresponse = json.decode(response.body);
    GlobalSnackBar.show(context, jsonDataresponse['message'], response.statusCode);
  }
}
