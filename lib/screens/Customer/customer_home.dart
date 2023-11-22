import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Models/model_added_nodes.dart';
import '../../Models/node_model.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import 'controller_dashboard.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID}) : super(key: key);
  final int customerID;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome>
{
  List<ProductListWithNode> customerSiteList = <ProductListWithNode>[];
  List<List<NodeModel>> usedNodeList = <List<NodeModel>>[];

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
      }
      setState(() {
        customerSiteList;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {

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
                                    const CircleAvatar(radius: 50),
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
                                            const CircleAvatar(radius: 20),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  ControllerDashboard(siteID: customerSiteList[siteIndex].groupId, siteName: customerSiteList[siteIndex].groupName, controllerID: customerSiteList[siteIndex].userDeviceListId, customerID: widget.customerID, imeiNo: customerSiteList[siteIndex].deviceId,)),);
              },
            );
          }),
    );
  }


}