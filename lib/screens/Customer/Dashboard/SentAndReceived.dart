import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/Models/Customer/Dashboard/SentAndReceivedModel.dart';

import '../../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../../constants/http_service.dart';

class SentAndReceived extends StatefulWidget {
  const SentAndReceived({Key? key, required this.customerID, required this.siteList}) : super(key: key);
  final int customerID;
  final List<DashboardModel> siteList;

  @override
  State<SentAndReceived> createState() => _SentAndReceivedState();
}

class _SentAndReceivedState extends State<SentAndReceived> {

  List<SentAndReceivedModel> sentAndReceivedList =[];

  int logFlag = 0;
  bool visibleLoading = false;
  DateTime selectedDate = DateTime.now();
  String fetchDate = "", finalDate = "";

  @override
  void initState() {
    super.initState();
    logFlag = 0;
    visibleLoading = true;
    finalDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    getLogs(widget.siteList[0].controllerId, DateFormat('yyyy-MM-dd').format(selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Column(children: [
          const Text("Sent And Received",),
          GestureDetector(child: Text(finalDate, style: const TextStyle(fontSize: 15.0),),
          )
        ]),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {_selectDate(context); }),
          const SizedBox(width: 10,),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: sentAndReceivedList.length,
        itemBuilder: (context, index)
        {
          if(sentAndReceivedList[index].messageType == 'RECEIVED')
          {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BubbleSpecialOne(
                textStyle: const TextStyle(fontSize: 12),
                text: '${sentAndReceivedList[index].message}\n\n${sentAndReceivedList[index].time},',
                color: Colors.red.shade100,
              ),
            );
          }
          else
          {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BubbleSpecialTwo(
                text: '${sentAndReceivedList[index].message}\n${sentAndReceivedList[index].time}',
                isSender: false,
                color: Colors.blue.shade100,
                textStyle: const TextStyle(fontSize: 12,),
              ),
            );
          }

        },
      ),

    );
  }

  Future<void> getLogs(int controllerId, String date) async {
    try {
      sentAndReceivedList.clear();
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId, "fromDate":date, "toDate":date};
      final response = await HttpService().postRequest("getUserSentAndReceivedMessage", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //print(jsonResponse);
        if(jsonResponse['code']==200){
          sentAndReceivedList = [
            ...jsonResponse['data'].map((programJson) => SentAndReceivedModel.fromJson(programJson)).toList(),
          ];

          setState(() {});

        }else{

        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now().subtract(const Duration(days: 0)));
    if (picked != null && picked != selectedDate) {
      setState(() {
        logFlag = 0;
        selectedDate = picked;
        finalDate = DateFormat('dd-MM-yyyy').format(selectedDate);
        getLogs(widget.siteList[0].controllerId, DateFormat('yyyy-MM-dd').format(selectedDate));
      });
    }
  }
}

class SearchPage extends StatelessWidget
{
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The search area here
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          )),
    );
  }
}
