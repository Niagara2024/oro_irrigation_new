import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/MQTTManager.dart';
import 'package:oro_irrigation_new/constants/http_service.dart';
import 'package:oro_irrigation_new/constants/snack_bar.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../Models/reset_AccumalationModel.dart';
import '../../widgets/FontSizeUtils.dart';

class Reset_Accumalation extends StatefulWidget {
  const Reset_Accumalation(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.deviceID});
  final userId, controllerId, deviceID;

  @override
  State<Reset_Accumalation> createState() => _Reset_AccumalationState();
}

class _Reset_AccumalationState extends State<Reset_Accumalation>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  ResetModel _resetModel = ResetModel();
  int tabclickindex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Request();
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final response =
    await HttpService().postRequest("getUserResetAccumulation", body);
    if (response.statusCode == 200) {
      setState(() {
        var jsondata1 = jsonDecode(response.body);
        _resetModel = ResetModel.fromJson(jsondata1);
      });
    } else {
      //_showSnackBar(response.body);`
    }
    //  _resetModel = ResetModel.fromJson(json);
  }

  @override
  Widget build(BuildContext context) {

    if (_resetModel.code != 200) {
      return  Center(child: Text(_resetModel.message ?? 'Currently No data Available'));
    }   else if (_resetModel.data == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_resetModel.data!.accumulation!.isEmpty) {
      return const Center(child: Text('Currently No data Available'));
    }
    else{
      return DefaultTabController(
        length: _resetModel.data!.accumulation!.length ?? 0,
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
                        for (var i = 0; i < _resetModel.data!.accumulation!.length; i++)
                          Tab(
                            text: '${_resetModel.data!.accumulation![i].name}',
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
                  Flexible(
                    fit: FlexFit.tight,
                    child: Container(
                      // decoration: BoxDecoration(
                      //   border: Border.all(
                      //     color: myTheme.primaryColor, // Border color
                      //     // width: 10.0, // Border width
                      //   ),
                      // ),
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withOpacity(0.1),
                      //   borderRadius: BorderRadius.circular(1.0),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.blueGrey.shade100,
                      //       spreadRadius: 5,
                      //       blurRadius: 7,
                      //       offset: Offset(0, 3),
                      //     ),
                      //   ],
                      // ),
                      child: TabBarView(children: [
                        for (var i = 0; i < _resetModel.data!.accumulation!.length; i++)
                          buildTab(_resetModel.data!.accumulation![i].list)
                      ]),
                    ),
                  ),
                  ElevatedButton(
                    child: const Text("RESET ALL"),
                    onPressed: () async {
                      setState(() {
                        ResetAll();
                      });
                    },
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    child: Text("Factory Reset"),
                    onPressed: () async {
                      setState(() {
                        _showMyDialog(context);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to Reset All data?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                FResetAll();
                Navigator.of(context).pop(); // Close the alert dialog
              },
            ),
          ],
        );
      },
    );
  }
  double Changesize(int? count, int val) {
    count ??= 0;
    double size = (count * val).toDouble();
    return size;
  }
  changeval(int Selectindexrow) {}
  Widget buildTab(List<ListElement>? Listofvalue,){
    // List<Source>? Listofvalue, int i, String sourceid, String sourcename) {
    // if (MediaQuery.of(context).size.width > 600) {
    return Container(
      child: DataTable2(
          headingRowColor: MaterialStateProperty.all<Color>(
              primaryColorDark.withOpacity(0.2)),
          // fixedCornerColor: myTheme.primaryColor,
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          // border: TableBorder.all(width: 0.5),
          // fixedColumnsColor: Colors.amber,
          headingRowHeight: 50,
          columns: [
            DataColumn2(
              fixedWidth: 70,
              label: Center(
                  child: Text(
                    'Sno',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              label: Center(
                  child: Text(
                    'Name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Center(
                  child: Text(
                    'Daily Accumalation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Center(
                  child: Text(
                    'Total Accumalation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Center(
                  child: Text(
                    'Reset',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeUtils.fontSizeHeading(context) ?? 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
          ],
          rows: List<DataRow>.generate(Listofvalue!.length, (index) => DataRow(cells: [
            DataCell(Center(child: Text('${Listofvalue![index].sNo}'))),
            DataCell(Center(
              child: Text(
                '${Listofvalue![index].name}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(Center(
              child: Text(
                '${Listofvalue![index].todayCumulativeFlow}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(Center(
              child: Text(
                '${Listofvalue![index].totalCumulativeFlow}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: FontSizeUtils.fontSizeLabel(context) ?? 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(
              Center(
                child: ElevatedButton(
                  style:  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 18)),
                  onPressed: () { Reset(Listofvalue![index].sNo!);},
                  child: const Text('Reset'),
                ),
              ),
            ),]),
          )),
    );
    // }
  }
  updateradiationset() async {
    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "modifyUser": widget.userId
    };
    print(body);
    // String Mqttsenddata = toMqttformat(_resetModel.data);
    final response =
    await HttpService().postRequest("updateUserResetAccumulation", body);
    final jsonDataresponse = jsonDecode(response.body);
    print('response.body:${response.body}');
    GlobalSnackBar.show(
        context, jsonDataresponse['message'], response.statusCode);

    String payLoadFinal = jsonEncode({
      "2900": [
        {"2901": body},
      ]
    });
    MQTTManager().publish( payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }
  Request()   {
    String payLoadFinal = jsonEncode({
      "3000": [
        {"3001": ""},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }


  Reset(int Srno)   {
    String payLoadFinal = jsonEncode({
      "3100": [
        {"3101": Srno},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }
  ResetAll()   {
    String payLoadFinal = jsonEncode({
      "3100": [
        {"3101": ""},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }
  FResetAll()   {
    String payLoadFinal = jsonEncode({
      "3200": [
        {"3201": "FRESET"},
      ]
    });
    MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceID}');
  }
}
