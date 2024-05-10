import 'dart:convert';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_irrigation_new/Models/Customer/Dashboard/SentAndReceivedModel.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../../constants/http_service.dart';

class SentAndReceived extends StatefulWidget {
  const SentAndReceived({Key? key, required this.customerID, required this.controllerId}) : super(key: key);
  final int customerID, controllerId;

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
    getLogs(widget.controllerId, DateFormat('yyyy-MM-dd').format(selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height:  MediaQuery.sizeOf(context).height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
       children: [
         SizedBox(
           width: 150,
           child: TextButton(
             onPressed: () {
               _selectDate(context);
             },
             style: ButtonStyle(
               backgroundColor: MaterialStateProperty.all<Color>(myTheme.primaryColor.withOpacity(0.2)),
               shape: MaterialStateProperty.all<OutlinedBorder>(
                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
               ),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 const Icon(Icons.calendar_month_outlined, color: Colors.black),
                 const SizedBox(width: 10),
                 Text(finalDate, style: const TextStyle(color: Colors.black, fontSize: 15)),
               ],
             ),
           ),
         ),
         Padding(
           padding: const EdgeInsets.only(top: 5),
           child: SizedBox(
             width: MediaQuery.sizeOf(context).width,
             height: MediaQuery.sizeOf(context).height-110,
             child: ListView.builder(
               padding: const EdgeInsets.only(top: 10),
               itemCount: sentAndReceivedList.length,
               itemBuilder: (context, index)
               {
                 if(sentAndReceivedList[index].messageType == 'RECEIVED')
                 {
                   return Padding(
                     padding: const EdgeInsets.all(5.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         Text('${convertToAMPM(sentAndReceivedList[index].time)} - ', style: const TextStyle(fontSize: 11),),
                         BubbleSpecialOne(
                           textStyle: const TextStyle(fontSize: 12),
                           text: sentAndReceivedList[index].message,
                           color: Colors.green.shade100,
                         ),
                       ],
                     ),
                   );
                 }
                 else
                 {
                   return Padding(
                     padding: const EdgeInsets.all(5.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         BubbleSpecialTwo(
                           text: sentAndReceivedList[index].message,
                           isSender: false,
                           color: Colors.blue.shade100,
                           textStyle: const TextStyle(fontSize: 12),
                         ),
                         Text(' - ${convertToAMPM(sentAndReceivedList[index].time)}', style: const TextStyle(fontSize: 11),)
                       ],
                     ),
                   );
                 }
               },
             ),
           ),
         )
       ],
      ),
    );
  }

  String convertToAMPM(String timeString) {
    DateTime dateTime = DateFormat("HH:mm:ss").parse(timeString);
    String formattedTime = DateFormat("h:mm a").format(dateTime);
    return formattedTime;
  }


  Future<void> getLogs(int controllerId, String date) async {
    try {
      sentAndReceivedList.clear();
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId, "fromDate":date, "toDate":date};
      final response = await HttpService().postRequest("getUserSentAndReceivedMessageStatus", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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
        getLogs(widget.controllerId, DateFormat('yyyy-MM-dd').format(selectedDate));
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
