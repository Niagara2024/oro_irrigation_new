import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../Models/Customer/program_queue_model.dart';
import '../../../constants/http_service.dart';
import '../../../state_management/program_queue_provider.dart';


class ProgramQueueScreen extends StatefulWidget {
  final int userId;
  final int controllerId;

  const ProgramQueueScreen({Key? key, required this.userId, required this.controllerId}) : super(key: key);

  @override
  _ProgramQueueScreenState createState() => _ProgramQueueScreenState();
}

class _ProgramQueueScreenState extends State<ProgramQueueScreen> {
  final programQueueProvider = ProgramQueueProvider();

  @override
  void initState() {
    super.initState();
    if(mounted){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getUserProgramQueueData(widget.userId, widget.controllerId);
      });
    }
  }

  Future<void> getUserProgramQueueData(userId, controllerId) async {
    try {
      HttpService httpService = HttpService();
      var userData = {
        "userId": userId,
        "controllerId": controllerId,
      };

      var getUserProgramQueue = await httpService.postRequest("getUserProgramQueue", userData);

      if (getUserProgramQueue.statusCode == 200) {
        final responseJson = getUserProgramQueue.body;
        final convertedJson = jsonDecode(responseJson);
        setState(() {
          programQueueProvider.updateData(convertedJson);

        });
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(onPressed: (){}, child: const Text("REMOVE")),
          const SizedBox(width: 20,),
          OutlinedButton(onPressed: (){}, child: const Text("Move To High Priority")),
          const SizedBox(width: 20,),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return programQueueProvider.programQueueResponse?.data != null
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildColumn(context, programQueueProvider.programQueueResponse!.data.low, "NORMAL PRIORITY"),
              _buildColumn(context, programQueueProvider.programQueueResponse!.data.high, "HIGH PRIORITY"),
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildColumn(BuildContext context, programs, priorityType) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8)
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            _buildCategory(context, priorityType),
            _buildHeaderRow(context),
            _buildProgramList(context, programs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
      ),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildHeaderText(context, "ID"),
            _buildHeaderText(context, 'Program Name'),
            _buildHeaderText(context, 'Waiting in Q'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(BuildContext context, String text,) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            text,
            style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          OutlinedButton(onPressed: (){}, child: const Text("REMOVE ALL"))
        ],
      ),
    );
  }

  Widget _buildProgramList(BuildContext context, programs) {
    return Expanded(
      child: ListView.builder(
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return InkWell(
            onTap: (){

            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
              ),
              // surfaceTintColor: Colors.white.withOpacity(0.1),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgramInfo(context, CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary,child: Text('${program.programQueueId}', style: const TextStyle(color: Colors.black),),)),
                    _buildProgramInfo(context, '${program.programName}'),
                    _buildProgramInfo(context, '${program.startTime}'),
                    // _buildProgramInfo(
                    //   context,
                    //   CustomNativeTimePicker(
                    //     initialValue: program.startTime,
                    //     onChanged: (newTime) {},
                    //     is24HourMode: true,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgramInfo(BuildContext context, dynamic content) {
    return Expanded(
      child: Center(
        child: content is Widget ? content : Text(content),
      ),
    );
  }
}

