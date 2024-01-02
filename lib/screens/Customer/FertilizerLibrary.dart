import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/state_management/FertilizerSetProvider.dart';
import 'package:provider/provider.dart';

import '../../../constants/http_service.dart';
import 'ListOfFertilizerInSet.dart';

class FertilizerLibrary extends StatefulWidget {
  const FertilizerLibrary({super.key, required this.userId, required this.customerID, required this.controllerId});
  final int userId, controllerId, customerID;

  @override
  State<FertilizerLibrary> createState() => _FertilizerLibraryState();
}

class _FertilizerLibraryState extends State<FertilizerLibrary> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //MqttWebClient().init();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FertilizerSetProvider>(context, listen: false).clearProvider();
        getData();
      });
    }
  }

  void getData()async{
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: false);
    HttpService service = HttpService();
    try{
      var response = await service.postRequest('getUserPlanningFertilizerSet', {'userId' : widget.customerID, 'controllerId' : widget.controllerId});
      var jsonData = jsonDecode(response.body);
      print(jsonData);
      print(response.body);
      fertSetPvd.editRecipe(jsonData);

    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.brown.shade50.withOpacity(0.3),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.send),
        onPressed: (){
          showDialog(context: context, builder: (context){
            return Consumer<FertilizerSetProvider>(builder: (context,fertSetPvd,child){
              return AlertDialog(
                title: Text(fertSetPvd.wantToSendData == 0 ? 'Send to server' : fertSetPvd.wantToSendData == 1 ?  'Sending.....' : fertSetPvd.wantToSendData == 2 ? 'Success...' : 'Oopss!!!',style: TextStyle(color: fertSetPvd.wantToSendData == 3 ? Colors.red : Colors.green),),
                content: fertSetPvd.wantToSendData == 0 ? Text('Are you sure want to send data ? ') : SizedBox(
                  width: 200,
                  height: 200,
                  child: fertSetPvd.wantToSendData == 2 ? Image.asset(fertSetPvd.wantToSendData == 3 ? 'assets/images/serverError.png' : 'assets/images/success.png') :LoadingIndicator(
                    indicatorType: Indicator.pacman,
                  ),
                ),
                actions: [
                  if(fertSetPvd.wantToSendData == 0)
                    InkWell(
                      onTap: ()async{
                        fertSetPvd.hwPayload();
                        fertSetPvd.editWantToSendData(1);
                        HttpService service = HttpService();
                        try{
                          var response = await service.postRequest('createUserPlanningFertilizerSet', {
                            'userId' : widget.customerID,
                            'controllerId' : widget.controllerId,
                            'createUser' : widget.userId,
                            'fertilizerSet' : {
                              'autoIncrement' : fertSetPvd.autoIncrement,
                              'fertilizerSet' : fertSetPvd.listOfRecipe,
                            },
                            // 'fertilizerSet' : {},
                          });
                          var jsonData = jsonDecode(response.body);
                          if(jsonData['code'] == 200){
                            Future.delayed(Duration(seconds: 1), () {
                              fertSetPvd.editWantToSendData(2);
                            });
                          }else{
                            fertSetPvd.editWantToSendData(3);
                          }
                          print('jsonData : ${jsonData['code']}');
                         // MqttWebClient().publishMessage('AppToFirmware/${widget.controllerId}', jsonEncode(fertSetPvd.hwPayload()));
                        }catch(e){
                          print(e.toString());
                        }
                        // store.writeDataInJsonFile('configFile', fertSetPvd.sendData());
                      },
                      child: Container(
                        child: Center(
                          child: Text('Yes',style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                        width: 80,
                        height: 30,
                        color: myTheme.primaryColor,
                      ),
                    ),
                  if([2,3].contains(fertSetPvd.wantToSendData))
                    InkWell(
                      onTap: (){
                        fertSetPvd.editWantToSendData(0);
                        Navigator.pop(context);
                      },
                      child: Container(
                        child: Center(
                          child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                        width: 80,
                        height: 30,
                        color: myTheme.primaryColor,
                      ),
                    )
                ],
              );
            });

          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Fertilizer Library',style: TextStyle(color: Colors.black87),),
        actions: [
          if(fertSetPvd.selectFunction != 0 )
            IconButton(
              onPressed: (){
                fertSetPvd.fertilizerFunctionality(['deleteFertilizer']);
              },
              icon: Icon(Icons.delete),
            ),
          SizedBox(width: 10,),
          if(fertSetPvd.selectFunction != 0 )
            IconButton(
              onPressed: (){
                fertSetPvd.fertilizerFunctionality(['cancelFertilizer']);
              },
              icon: Icon(Icons.cancel,color: Colors.red,),
            ),
          SizedBox(width: 10,),
        ],
      ),
      body: DefaultTabController(
        length: fertSetPvd.listOfRecipe.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
                tabs: [
                  for(var i = 0;i < fertSetPvd.listOfRecipe.length;i++)
                    Tab(
                      child: Text(fertSetPvd.listOfRecipe[i]['name']),
                    )
                ]
            ),
            Expanded(
                child: Container(
                  child: TabBarView(
                    children: [
                      for(var i = 0;i < fertSetPvd.listOfRecipe.length;i++)
                        SiteWiseRecipee(index: i,)
                    ],
                  ),
                )
            )


          ],
        ),
      ),
    );
  }
}

class SiteWiseRecipee extends StatefulWidget {
  final int index;
  const SiteWiseRecipee({super.key, required this.index});

  @override
  State<SiteWiseRecipee> createState() => _SiteWiseRecipeeState();
}

class _SiteWiseRecipeeState extends State<SiteWiseRecipee> {
  TextEditingController name = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: false);
        fertSetPvd.editSite(widget.index);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          children: [
            Container(
              color: Colors.indigo.shade50,
              width: 50,
              height: 50,
              child: PopupMenuButton(
                offset: Offset(10,50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.check_box_outline_blank,size: 20,),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                        onTap: (){
                          fertSetPvd.editSelectFunction(1);
                        },
                        child: Text('Select')
                    ),
                    PopupMenuItem(
                      child: Text('Select All'),
                      onTap: (){
                        fertSetPvd.fertilizerFunctionality(['selectAllFertilizer']);
                      },
                    ),
                  ];
                },

              ),
            ),
            SizedBox(width: 3,),
            Expanded(
                child: Container(
                  color: Colors.indigo.shade50,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 100,),
                      Text('List of fertilization Site',style: TextStyle(fontSize: 18,color: Colors.black87,fontWeight: FontWeight.w100),),
                      Container(
                        margin: EdgeInsets.only(right: 20),
                        width: 30,
                        height: 30,
                        child: IconButton(
                            padding: EdgeInsets.all(0),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.black54)
                            ),
                            onPressed: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return Consumer<FertilizerSetProvider>(
                                        builder: (context, fertSetPvd, child) {
                                          return AlertDialog(
                                            title: Text('Give the name for Fertilizer set',style: TextStyle(fontWeight: FontWeight.w100),),
                                            content: TextFormField(
                                              controller: name,
                                              decoration: InputDecoration(
                                                  label: Text('Enter the name'),
                                                  hintText: 'eg : To tomato farm',
                                                  border: OutlineInputBorder(

                                                  )
                                              ),
                                            ),
                                            actions: [
                                              InkWell(
                                                  onTap: (){
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    child: Center(
                                                      child: Text('cancel',style: TextStyle(color: myTheme.primaryColor,fontSize: 16),
                                                      ),
                                                    ),
                                                    width : 80,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(width: 0.5,color: myTheme.primaryColor),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                  )
                                              ),
                                              InkWell(
                                                onTap: (){
                                                  fertSetPvd.addRecipe(name.text);
                                                  setState(() {
                                                    name.text = '';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  child: Center(
                                                    child: Text('ok',style: TextStyle(color: Colors.white,fontSize: 16),
                                                    ),
                                                  ),
                                                  width: 80,
                                                  height: 30,
                                                  color: myTheme.primaryColor,
                                                ),
                                              )
                                            ],
                                          );
                                        }
                                    );
                                  });
                              // fertSetPvd.addRecipe();
                            },
                            icon: Icon(Icons.add,color: Colors.white,)),
                      ),
                    ],
                  ),
                )
            )
          ],
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            child: ListView.builder(
                itemCount: fertSetPvd.listOfRecipe[widget.index]['recipe'].length,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (cotext){
                          return ListOfFertilizerInSet(index: widget.index, recipeIndex: index,);
                        }));
                      },
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                      tileColor: Colors.white,
                      title: Text('${fertSetPvd.listOfRecipe[widget.index]['recipe'][index]['name']}'),
                      leading: Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green.shade50
                        ),
                        child: Center(
                          child: fertSetPvd.selectFunction == 0 ? Text('F ${index + 1}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w100),) :
                          Checkbox(
                              value: fertSetPvd.listOfRecipe[widget.index]['recipe'][index]['select'],
                              onChanged: (value){
                                fertSetPvd.fertilizerFunctionality(['selectFertilizer',widget.index,index,value]);
                              }),
                        ),
                      ),
                      trailing: Container(
                        width: 400,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('Location : ${fertSetPvd.listOfRecipe[widget.index]['recipe'][index]['fertilizer'][0]['location']}',style: TextStyle(fontSize: 14),),
                            VerticalDivider(
                              width: 1,
                            ),
                            Text('Used in programs : P1,P2',style: TextStyle(fontSize: 14),),
                            Icon(Icons.more_vert)
                          ],
                        ),
                      ),
                    ),
                  );
                }
            ),
          ),
        )
      ],
    );
  }
}