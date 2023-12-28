import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../constants/http_service.dart';
import '../../../state_management/overall_use.dart';
import '../../../widgets/SCustomWidgets/custom_date_picker.dart';
import '../../../widgets/time_picker.dart';
import '../../state_management/GlobalFertLimitProvider.dart';
import '../../widgets/TextFieldForGlobalFert.dart';

class GlobalFertLimit extends StatefulWidget {
  const GlobalFertLimit({Key? key, required this.userId, required this.controllerId, required this.customerId});
  final userId, controllerId,customerId;

  @override
  State<GlobalFertLimit> createState() => _GlobalFertLimitState();
}

class _GlobalFertLimitState extends State<GlobalFertLimit> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //MqttWebClient().init();
  }
  @override
  Widget build(BuildContext context) {
    var gfertpvd = Provider.of<GlobalFertLimitProvider>(context, listen: true);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          gfertpvd.hwPayload();
          try{
            var body = {
              "userId" : widget.customerId,
              "createUser" : widget.userId,
              "controllerId" : widget.controllerId,
              'globalFertilizerLimit' : gfertpvd.globalFert
            };
            HttpService service = HttpService();
            var response = await service.postRequest('createUserPlanningGlobalFertilizerLimit', body);
            var jsonData = jsonDecode(response.body);
            print('response code : ${jsonData['code']}');
            print('response data : $jsonData');
          }catch(e){
            print(e.toString());
          }
          // store.writeDataInJsonFile('configFile', configPvd.sendData());
          //MqttWebClient().publishMessage('AppToFirmware/${widget.controllerId}', jsonEncode(gfertpvd.hwPayload()));
        },
        child: Icon(Icons.send),

      ),
      body: GlobalFertLimitTable(userId: widget.userId, controllerId: widget.controllerId,),
    );

  }
}

class GlobalFertLimitTable extends StatefulWidget {
  const GlobalFertLimitTable({Key? key, required this.userId, required this.controllerId});
  final userId, controllerId;

  @override
  State<GlobalFertLimitTable> createState() => _GlobalFertLimitTableState();
}

class _GlobalFertLimitTableState extends State<GlobalFertLimitTable> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getUserPlanningGlobalFertilizerLimit();
      });
    }
  }
  Future<void> getUserPlanningGlobalFertilizerLimit() async {
    print('userid : ${widget.userId}');
    print('controllerId : ${widget.controllerId}');
    var gfertpvd = Provider.of<GlobalFertLimitProvider>(context, listen: false);
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserPlanningGlobalFertilizerLimit', {'userId' : widget.userId,'controllerId' : widget.controllerId});
      var jsonData = jsonDecode(response.body);
      gfertpvd.editGlobalFert(jsonData['data']);
    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var gfertpvd = Provider.of<GlobalFertLimitProvider>(context, listen: true);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraint){
      var width = constraint.maxWidth;
      return Container(
        padding: EdgeInsets.all(10),
        color: Color(0xFFCCD9E4),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5,),
            Container(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 60,
                    child: Center(child: Text('Line',style: TextStyle(color: Colors.white),)),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        border: Border(
                          top: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                          right: BorderSide(width: 1),
                          left: BorderSide(width: 1),
                        )
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),

                          )
                      ),
                      width: double.infinity,
                      height: 60,
                      child: Center(child: Text('Valve',style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Center(child: Text('Name',style: TextStyle(color: Colors.white),)),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      child: Center(child: Text('Date',style: TextStyle(color: Colors.white),)),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          border: Border(
                            top: BorderSide(width: 1),
                            bottom: BorderSide(width: 1),
                            right: BorderSide(width: 1),
                          )
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Irrigation',style: TextStyle(color: Colors.white),),
                        Row(
                          children: [
                            returChannel('Time',Colors.blue.shade200),
                            returChannel('Quantity',Colors.blue.shade200,false),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        border: Border(
                          top: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                          right: BorderSide(width: 1),
                        )
                    ),
                  ),
                  Container(
                    width: gfertpvd.central * 62.5 + (gfertpvd.central == 1 || gfertpvd.central == 2 ? 100 : 0),
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Central Fertilization',style: TextStyle(color: Colors.white),),
                        Row(
                          children: [
                            if(gfertpvd.central >= 1)
                              returChannel('CH1',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 2)
                              returChannel('CH2',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 3)
                              returChannel('CH3',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 4)
                              returChannel('CH4',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 5)
                              returChannel('CH5',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 6)
                              returChannel('CH6',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 7)
                              returChannel('CH7',Colors.blueGrey.shade200),
                            if(gfertpvd.central >= 8)
                              returChannel('CH8',Colors.blueGrey.shade200,false),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        border: Border(
                          top: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                          right: BorderSide(width: 1),
                        )
                    ),
                  ),
                  Container(
                    width: gfertpvd.local * 62.5 + (gfertpvd.local == 1 || gfertpvd.local == 2  ? 100 : 0),
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Local Fertilization',style: TextStyle(color: Colors.white),),
                        Row(
                          children: [
                            if(gfertpvd.local >= 1)
                              returChannel('CH1',Colors.orange.shade200),
                            if(gfertpvd.local >= 2)
                              returChannel('CH2',Colors.orange.shade200),
                            if(gfertpvd.local >= 3)
                              returChannel('CH3',Colors.orange.shade200),
                            if(gfertpvd.local >= 4)
                              returChannel('CH4',Colors.orange.shade200),
                            if(gfertpvd.local >= 5)
                              returChannel('CH5',Colors.orange.shade200),
                            if(gfertpvd.local >= 6)
                              returChannel('CH6',Colors.orange.shade200),
                            if(gfertpvd.local >= 7)
                              returChannel('CH7',Colors.orange.shade200),
                            if(gfertpvd.local >= 8)
                              returChannel('CH8',Colors.orange.shade200,false),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        border: Border(
                          top: BorderSide(width: 1),
                          bottom: BorderSide(width: 1),
                          right: BorderSide(width: 1),
                        )
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                // controller: scrollController,
                  itemCount: gfertpvd.globalFert.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      decoration: BoxDecoration(
                          color: index % 2 == 0 ? Colors.white : Colors.brown.shade50,
                          border: Border(bottom: BorderSide(width: 1))
                      ),
                      margin: index == gfertpvd.globalFert.length - 1 ? EdgeInsets.only(bottom: 60) : null,
                      child: Row(
                        children: [
                          Container(
                            height: gfertpvd.globalFert[index]['valve'].length * 50,
                            decoration: BoxDecoration(
                              border: Border(left: BorderSide(width: 1),right: BorderSide(width: 1)),
                            ),
                            width: 50,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${gfertpvd.globalFert[index]['id']}',style: TextStyle(color: Colors.black),),
                                ],
                              ),
                            ),
                          ),
                          // returnValveDetailsFixed('index',gfertpvd,index),
                          returnValveDetails('id',gfertpvd,index),
                          returnValveDetails('name',gfertpvd,index),
                          returnValveDetails('date',gfertpvd,index),
                          Container(
                            height: gfertpvd.globalFert[index]['valve'].length * 50,
                            width: 150,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  returnValveDetails('time',gfertpvd,index),
                                  returnValveDetails('quantity',gfertpvd,index),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: gfertpvd.globalFert[index]['valve'].length * 50,
                            width: gfertpvd.central * 62.5 + (gfertpvd.central == 1 || gfertpvd.central == 2 ? 100 : 0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(gfertpvd.central >= 1)
                                    returnValveDetails('central1',gfertpvd,index),
                                  if(gfertpvd.central >= 2)
                                    returnValveDetails('central2',gfertpvd,index),
                                  if(gfertpvd.central >= 3)
                                    returnValveDetails('central3',gfertpvd,index),
                                  if(gfertpvd.central >= 4)
                                    returnValveDetails('central4',gfertpvd,index),
                                  if(gfertpvd.central >= 5)
                                    returnValveDetails('central5',gfertpvd,index),
                                  if(gfertpvd.central >= 6)
                                    returnValveDetails('central6',gfertpvd,index),
                                  if(gfertpvd.central >= 7)
                                    returnValveDetails('central7',gfertpvd,index),
                                  if(gfertpvd.central >= 8)
                                    returnValveDetails('central8',gfertpvd,index),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: gfertpvd.globalFert[index]['valve'].length * 50,
                            width: gfertpvd.local * 62.5 + (gfertpvd.local == 1 || gfertpvd.local == 2 ? 100 : 0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(gfertpvd.local >= 1)
                                    returnValveDetails('local1',gfertpvd,index),
                                  if(gfertpvd.local >= 2)
                                    returnValveDetails('local2',gfertpvd,index),
                                  if(gfertpvd.local >= 3)
                                    returnValveDetails('local3',gfertpvd,index),
                                  if(gfertpvd.local >= 4)
                                    returnValveDetails('local4',gfertpvd,index),
                                  if(gfertpvd.local >= 5)
                                    returnValveDetails('local5',gfertpvd,index),
                                  if(gfertpvd.local >= 6)
                                    returnValveDetails('local6',gfertpvd,index),
                                  if(gfertpvd.local >= 7)
                                    returnValveDetails('local7',gfertpvd,index),
                                  if(gfertpvd.local >= 8)
                                    returnValveDetails('local8',gfertpvd,index),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }

  Widget returnValveDetails(String title,GlobalFertLimitProvider gfertpvd,int index,[int? innerIndex,Color? color,bool? input,String? method]){
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
    String value =  '';
    return Expanded(
      child: Container(
        height: gfertpvd.globalFert[index]['valve'].length * 50,
        child: Column(
          children: [
            for(var val = 0;val < gfertpvd.globalFert[index]['valve'].length;val++)
              Container(
                  height: 50,
                  //   width: 50,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: val == gfertpvd.globalFert[index]['valve'].length -1 ? 0 : 1))
                  ),
                  child: title == 'name'
                      ?
                  Center(child: Text('${gfertpvd.globalFert[index][title]}'))
                      :
                  title == 'id'
                      ?
                  Center(child: Text('${gfertpvd.globalFert[index]['valve'][val]['id']}'))
                      :
                  title == 'date'
                      ?
                  Center(
                    child: DatePickerField(
                      value: gfertpvd.globalFert[index]['valve'][val]['date'] != '' ? DateFormat('dd-MM-yyyy').parse(gfertpvd.globalFert[index]['valve'][val]['date']) : DateTime.parse(DateTime.now().toString()),
                      onChanged: (newDate) {
                        print(newDate.day);
                        print(newDate.month);
                        print(newDate.year);
                        gfertpvd.editGfert('date', index, val, title, '${newDate.day}-${newDate.month}-${newDate.year}');
                      },
                    ),
                  )
                      :
                  title == 'time'
                      ?
                  Center(child: CustomTimePickerSiva(purpose: 'time/$index/$val/$title', index: index, value: '${gfertpvd.globalFert[index]['valve'][val][title]}', displayHours: true, displayMins: true, displaySecs: true, displayCustom: false, CustomString: '', CustomList: [1,10], displayAM_PM: false,additional: 'split',))
                      :
                  title.contains('central')
                      ?
                  gfertpvd.globalFert[index]['valve'][val][title]['value'] == null ? Center(child: Text('N/A')) : Center(child: TextFieldForGlobalFert(purpose: 'central_local/$index/$val/$title', initialValue: '${gfertpvd.globalFert[index]['valve'][val][title]['value']}', index: index))
                      :
                  title.contains('local')
                      ?
                  gfertpvd.globalFert[index]['valve'][val][title]['value'] == null ? Center(child: Text('N/A')) : Center(child: TextFieldForGlobalFert(purpose: 'central_local/$index/$val/$title', initialValue: '${gfertpvd.globalFert[index]['valve'][val][title]['value']}', index: index))
                      :
                  Center(child: TextFieldForGlobalFert(purpose: 'quantity/$index/$val/$title', initialValue: '${gfertpvd.globalFert[index]['valve'][val][title]}', index: index))
              )
          ],
        ),
        decoration:  BoxDecoration(
          border: Border(
            right: BorderSide(width: 1),
          ),
        ),
      ),
    );
  }

  Widget returnValveDetailsFixed(String title,GlobalFertLimitProvider gfertpvd,int index,[int? innerIndex,Color? color]){
    return Container(
      width: 50,
      child: Column(
        children: [
          for(var i = 0;i < gfertpvd.globalFert[index]['valve'].length;i++)
            Container(
                decoration: BoxDecoration(
                    color: color == null ? null : color,
                    border: Border(
                        bottom: BorderSide(width: i == gfertpvd.globalFert[index]['valve'][i].length - 1 ? 0 : 1)
                    )
                ),
                height: 50,
                child: Center(
                    child: Text('${gfertpvd.globalFert[index]['valve'][i]['name']}')))
        ],
      ),
      decoration:  BoxDecoration(
        border: Border(
          right: BorderSide(width: 1),
        ),
      ),
    );
  }
  // double returnHeight(int index, GlobalFertLimitProvider gfertpvd){
  //   double length = 0;
  //   for(var i = 0 ; i < gfertpvd.globalFert[index]['valve'].length;i++){
  //     for(var j in i.entries){
  //       if(j.key == 'valve'){
  //         length = j.value.length * 50;
  //       }
  //     }
  //   }
  //   return gfertpvd.globalFert[index]['valve'].length ;
  // }
  Widget returChannel(String title,Color color,[bool? lastone]){
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: color,
            border: Border(
              top: BorderSide(width: 1),
              right: BorderSide(width: lastone == null ? 1 : 0),
            )
        ),
        width: double.infinity,
        height: 30,
        child: Center(child: Text(title)),
      ),
    );
  }

}