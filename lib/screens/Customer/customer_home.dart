import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Models/model_added_nodes.dart';
import '../../Models/node_model.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import 'ProgramSchedule.dart';
import 'controller_dashboard.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.type, required this.customerName}) : super(key: key);
  final int customerID, type;
  final String customerName;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
{
  List<ProductListWithNode> customerSiteList = <ProductListWithNode>[];
  List<List<NodeModel>> usedNodeList = <List<NodeModel>>[];
  List<Program> programs =[];

  @override
  void initState() {
    super.initState();
    getCustomerSite();
  }

  Future<void> getCustomerSite() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getUserDeviceList", body);
    if (response.statusCode == 200)
    {
      customerSiteList.clear();
      usedNodeList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          customerSiteList.add(ProductListWithNode.fromJson(cntList[i]));
          final nodeList = cntList[i]['nodeList'] as List;
          usedNodeList.add([]);
          for (int j=0; j < nodeList.length; j++) {
            usedNodeList[i].add(NodeModel.fromJson(nodeList[j]));
          }
        }
        getProgramList(customerSiteList[0].userDeviceListId ?? 0);
      }
      setState(() {
        customerSiteList;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getProgramList(int controllerId) async
  {
    programs.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);
        List<dynamic> programsJson = jsonResponse['data'];
        setState(() {
          programs = [
            ...programsJson.map((programJson) => Program.fromJson(programJson)).toList(),
          ];
        });
      }
    } catch (e) {
      print('Error: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    if(widget.type==0){
      return DefaultTabController(
        length: customerSiteList.length, // Number of tabs
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TabBar(
                      indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                      isScrollable: true,
                      tabs: [
                        for (var i = 0; i < customerSiteList.length; i++)
                          Tab(text: customerSiteList[i].groupName ?? '',),
                      ],
                      onTap: (index) {
                        getProgramList(customerSiteList[index].userDeviceListId ?? 0 );
                      },
                    ),
                ),
                IconButton(onPressed: () {  }, icon: const Icon(Icons.settings_outlined),),
                const SizedBox(width: 10,),
              ],
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height-104,
              child: TabBarView(
                children: [
                  for (int i = 0; i < customerSiteList.length; i++)
                    SizedBox(
                      child: Row(
                        children: [
                          const VerticalDivider(),
                          Flexible(
                            flex: 1,
                            child: Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex :1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const CircleAvatar(
                                                  radius: 50,
                                                  backgroundImage: AssetImage('assets/images/oro_gem.png'),
                                                  backgroundColor: Colors.transparent,
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(customerSiteList[i].categoryName),
                                                const SizedBox(height: 3,),
                                                Text(customerSiteList[i].modelDescription, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                Text(customerSiteList[i].modelName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const VerticalDivider(),
                                        const Flexible(
                                          flex :1,
                                          child: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.network_wifi_1_bar),
                                                SizedBox(height: 3,),
                                                Text('20 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                                SizedBox(height: 10,),
                                                Icon(Icons.signal_cellular_alt),
                                                SizedBox(height: 5,),
                                                Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                                SizedBox(height: 10,),
                                                Icon(Icons.battery_3_bar_rounded),
                                                SizedBox(height: 5,),
                                                Text('50 %', style: TextStyle(fontWeight: FontWeight.normal),),

                                              ],
                                            ),
                                          ),
                                        ),
                                        const VerticalDivider(),
                                        Flexible(
                                          flex :1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('IMEI Number'),
                                                SizedBox(height: 3,),
                                                Text('${customerSiteList[i].deviceId}', style: TextStyle(fontWeight: FontWeight.normal),),
                                                const SizedBox(height: 10,),
                                                const Text('Controller Sim Number'),
                                                const SizedBox(height: 5,),
                                                Text('+91 7584744578', style: TextStyle(fontWeight: FontWeight.normal),),
                                                const SizedBox(height: 10,),
                                                const Text('Manufacturing Date'),
                                                SizedBox(height: 5,),
                                                Text('${customerSiteList[i].productDescription}', style: TextStyle(fontWeight: FontWeight.normal),),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height-320,
                                    width: MediaQuery.sizeOf(context).width-133,
                                    child: DataTable2(
                                      columnSpacing: 12,
                                      horizontalMargin: 12,
                                      minWidth: 600,
                                      dataRowHeight: 40.0,
                                      headingRowHeight: 35,
                                      headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                                      columns: const [
                                        DataColumn2(
                                            label: Center(child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                            fixedWidth: 50
                                        ),
                                        DataColumn2(
                                            label: Center(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                            size: ColumnSize.M
                                        ),
                                        DataColumn2(
                                            label: Center(child: Text('Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                            size: ColumnSize.M
                                        ),
                                        DataColumn2(
                                          label: Center(child: Text('Device Id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                          fixedWidth: 170,
                                        ),
                                        DataColumn2(
                                          label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                          fixedWidth: 100,
                                        ),
                                      ],
                                      rows: List<DataRow>.generate(usedNodeList[i].length, (index) => DataRow(cells: [
                                        DataCell(Center(child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.normal),))),
                                        DataCell(Center(child: Text(usedNodeList[i][index].categoryName, style: TextStyle(fontWeight: FontWeight.normal)))),
                                        DataCell(Center(child: Text(usedNodeList[i][index].modelName, style: TextStyle(fontWeight: FontWeight.normal)))),
                                        DataCell(Center(child: Text(usedNodeList[i][index].deviceId, style: TextStyle(fontWeight: FontWeight.normal)))),
                                        DataCell(Center(child: Text('Ok', style: TextStyle(fontWeight: FontWeight.normal)))),
                                      ])),
                                    ),
                                  )
                                ],
                              ),
                          ),
                          const VerticalDivider(),
                          SizedBox(
                            width: 400,
                            height: MediaQuery.sizeOf(context).height-112,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: const Text('Manual Mode'),
                                  leading: const Icon(Icons.touch_app_outlined),
                                  trailing: const Icon(Icons.arrow_forward_outlined),
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  ControllerDashboard(siteID: customerSiteList[i].groupId, siteName: customerSiteList[i].groupName, controllerID: customerSiteList[i].userDeviceListId, customerID: widget.customerID, imeiNo: customerSiteList[i].deviceId, programId: 0,)),);
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Program'),
                                  trailing: IconButton(
                                    tooltip: 'New Program',
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProgramSchedule(customerID: widget.customerID, controllerID: customerSiteList[i].userDeviceListId, siteName: customerSiteList[i].groupName, imeiNumber: customerSiteList[i].deviceId,)),);
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.sizeOf(context).height-225,
                                  width: 380,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: programs.length,
                                      itemBuilder: (context, pIdx) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(programs[pIdx].programName),
                                              leading: Icon(Icons.list_alt),
                                              trailing: Icon(Icons.arrow_right),
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) =>  ControllerDashboard(siteID: customerSiteList[i].groupId, siteName: customerSiteList[i].groupName, controllerID: customerSiteList[i].userDeviceListId, customerID: widget.customerID, imeiNo: customerSiteList[i].deviceId, programId: programs[pIdx].programId,)),);
                                              },
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
      return Container(
        color: myTheme.primaryColor.withOpacity(0.1),
        child: ListView.builder(
          //shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: customerSiteList.length,
            itemBuilder: (context, siteIndex) {
              return InkWell(
                child: Card(
                  key: ValueKey([siteIndex]),
                  elevation: 1,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Container(
                    height:380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Container(height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(customerSiteList[siteIndex].groupName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal,),),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          height: 200,
                          child: Row(
                            children: [
                              Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 50,
                                        backgroundImage: AssetImage('assets/images/oro_gem.png'),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(height: 5,),
                                      Text(customerSiteList[siteIndex].categoryName),
                                      const SizedBox(height: 3,),
                                      Text(customerSiteList[siteIndex].modelDescription, style: const TextStyle(fontWeight: FontWeight.normal),),
                                      Text(customerSiteList[siteIndex].modelName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              const Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.network_wifi_1_bar),
                                      SizedBox(height: 3,),
                                      Text('20 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                      SizedBox(height: 10,),
                                      Icon(Icons.signal_cellular_alt),
                                      SizedBox(height: 5,),
                                      Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                      SizedBox(height: 10,),
                                      Icon(Icons.battery_3_bar_rounded),
                                      SizedBox(height: 5,),
                                      Text('50 %', style: TextStyle(fontWeight: FontWeight.normal),),

                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              Flexible(
                                flex :1,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('IMEI Number'),
                                      SizedBox(height: 3,),
                                      Text('${customerSiteList[siteIndex].deviceId}', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(height: 10,),
                                      const Text('Controller Sim Number'),
                                      const SizedBox(height: 5,),
                                      Text('+91 7584744578', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(height: 10,),
                                      const Text('Manufacturing Date'),
                                      SizedBox(height: 5,),
                                      Text('${customerSiteList[siteIndex].productDescription}', style: TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              const Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Irrigation'),
                                      SizedBox(height: 3,),
                                      Text('Running', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.green),),
                                      SizedBox(height: 10,),
                                      Text('Fertilization'),
                                      SizedBox(height: 5,),
                                      Text('Idle', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.orange),),
                                      SizedBox(height: 10,),
                                      Text('Backwash'),
                                      SizedBox(height: 5,),
                                      Text('Idle', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.orange),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.sizeOf(context).width-165,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: usedNodeList[siteIndex].length,
                                    itemBuilder: (context, siteNodeIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO SWITCH'
                                                    || usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO SENSE'?
                                                AssetImage('assets/images/oro_switch.png'):
                                                usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO LEVEL'?
                                                AssetImage('assets/images/oro_sense.png'):
                                                AssetImage('assets/images/oro_rtu.png'),
                                                backgroundColor: Colors.transparent,
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(usedNodeList[siteIndex][siteNodeIndex].categoryName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                  Text('${usedNodeList[siteIndex][siteNodeIndex].productDescription}\n'
                                                      'IMEi : ${usedNodeList[siteIndex][siteNodeIndex].deviceId}',
                                                    style: const TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              )
                                            ]
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ControllerDashboard(siteID: customerSiteList[siteIndex].groupId, siteName: customerSiteList[siteIndex].groupName, controllerID: customerSiteList[siteIndex].userDeviceListId, customerID: widget.customerID, imeiNo: customerSiteList[siteIndex].deviceId, programId: 0,)),);
                },
              );
            }),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.customerName)),
      body: Container(
        color: myTheme.primaryColor.withOpacity(0.1),
        child: ListView.builder(
            //shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: customerSiteList.length,
            itemBuilder: (context, siteIndex) {
              return InkWell(
                child: Card(
                  key: ValueKey([siteIndex]),
                  elevation: 1,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Container(
                    height:380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Container(height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, top: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(customerSiteList[siteIndex].groupName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal,),),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          height: 200,
                          child: Row(
                            children: [
                              Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 50,
                                        backgroundImage: AssetImage('assets/images/oro_gem.png'),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      const SizedBox(height: 5,),
                                      Text(customerSiteList[siteIndex].categoryName),
                                      const SizedBox(height: 3,),
                                      Text(customerSiteList[siteIndex].modelDescription, style: const TextStyle(fontWeight: FontWeight.normal),),
                                      Text(customerSiteList[siteIndex].modelName, style: const TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              const Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.network_wifi_1_bar),
                                      SizedBox(height: 3,),
                                      Text('20 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                      SizedBox(height: 10,),
                                      Icon(Icons.signal_cellular_alt),
                                      SizedBox(height: 5,),
                                      Text('80 %', style: TextStyle(fontWeight: FontWeight.normal),),
                                      SizedBox(height: 10,),
                                      Icon(Icons.battery_3_bar_rounded),
                                      SizedBox(height: 5,),
                                      Text('50 %', style: TextStyle(fontWeight: FontWeight.normal),),

                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              Flexible(
                                flex :1,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('IMEI Number'),
                                      SizedBox(height: 3,),
                                      Text('${customerSiteList[siteIndex].deviceId}', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(height: 10,),
                                      const Text('Controller Sim Number'),
                                      const SizedBox(height: 5,),
                                      Text('+91 7584744578', style: TextStyle(fontWeight: FontWeight.normal),),
                                      const SizedBox(height: 10,),
                                      const Text('Manufacturing Date'),
                                      SizedBox(height: 5,),
                                      Text('${customerSiteList[siteIndex].productDescription}', style: TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                              const VerticalDivider(),
                              const Flexible(
                                flex :1,
                                child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Irrigation'),
                                      SizedBox(height: 3,),
                                      Text('Running', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.green),),
                                      SizedBox(height: 10,),
                                      Text('Fertilization'),
                                      SizedBox(height: 5,),
                                      Text('Idle', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.orange),),
                                      SizedBox(height: 10,),
                                      Text('Backwash'),
                                      SizedBox(height: 5,),
                                      Text('Idle', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.orange),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 80,
                                width: MediaQuery.sizeOf(context).width-165,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: usedNodeList[siteIndex].length,
                                    itemBuilder: (context, siteNodeIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundImage: usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO SWITCH'
                                                    || usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO SENSE'?
                                                AssetImage('assets/images/oro_switch.png'):
                                                usedNodeList[siteIndex][siteNodeIndex].categoryName == 'ORO LEVEL'?
                                                AssetImage('assets/images/oro_sense.png'):
                                                AssetImage('assets/images/oro_rtu.png'),
                                                backgroundColor: Colors.transparent,
                                              ),
                                              const SizedBox(width: 10,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(usedNodeList[siteIndex][siteNodeIndex].categoryName, style: const TextStyle(fontWeight: FontWeight.bold),),
                                                  Text('${usedNodeList[siteIndex][siteNodeIndex].productDescription}\n'
                                                      'IMEi : ${usedNodeList[siteIndex][siteNodeIndex].deviceId}',
                                                    style: const TextStyle(fontWeight: FontWeight.normal),),
                                                ],
                                              )
                                            ]
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ControllerDashboard(siteID: customerSiteList[siteIndex].groupId, siteName: customerSiteList[siteIndex].groupName, controllerID: customerSiteList[siteIndex].userDeviceListId, customerID: widget.customerID, imeiNo: customerSiteList[siteIndex].deviceId, programId: 0,)),);
                },
              );
            }),
      ),
    );
  }


}