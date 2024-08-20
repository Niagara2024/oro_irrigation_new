import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../Models/customer_list.dart';
import '../Models/product_stock.dart';
import '../constants/http_service.dart';
import '../constants/theme.dart';
import 'Customer/CustomerScreenController.dart';
import 'Forms/create_account.dart';
import 'Forms/device_list.dart';

class MyDealers extends StatefulWidget {
  final int dealerId;
  final String dealerName;
  const MyDealers({Key? key, required this.dealerId, required this.dealerName}) : super(key: key);

  @override
  State<MyDealers> createState() => MyDealersState();
}

class MyDealersState extends State<MyDealers> {
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> customerOfDealer = <CustomerListMDL>[];
  bool visibleLoading = false;

  @override
  void initState() {
    super.initState();
    indicatorViewShow();
    getDealerProductStock();
    getDealerCustomerList();
  }

  void callbackFunction(String message)
  {
    Future.delayed(const Duration(milliseconds: 500), () {
      getDealerCustomerList();
    });
  }

  Future<void> getDealerProductStock() async
  {
    Map<String, dynamic> body = {"fromUserId" : null, "toUserId" : widget.dealerId};
    final response = await HttpService().postRequest("getProductStock", body);
    if (response.statusCode == 200)
    {
      productStockList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          productStockList.add(ProductStockModel.fromJson(cntList[i]));
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getDealerCustomerList() async
  {
    Map<String, Object> body = {"userType" : 2, "userId" : widget.dealerId};
    final response = await HttpService().postRequest("getUserList", body);
    if (response.statusCode == 200)
    {
      customerOfDealer.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          customerOfDealer.add(CustomerListMDL.fromJson(cntList[i]));
        }
        indicatorViewHide();
      }
    }
    else{
      //_showSnackBar(response.body);
    }

  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: myTheme.primaryColor.withOpacity(0.1),
      appBar: AppBar(title: Text(widget.dealerName)),
      body: visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          height: height,
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(width/2 - 75, 0, width/2 - 75, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                elevation: 5,
                surfaceTintColor: Colors.white,
                child: Column(
                  children: [
                    Container(
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      child: ListTile(
                        title: Text('Product Stock(${productStockList.length})', style: const TextStyle(fontSize: 20, color: Colors.black),),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: productStockList.isNotEmpty ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: DataTable2(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 600,
                              headingRowHeight: 40,
                              dataRowHeight: 40,
                              headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                              columns: const [
                                DataColumn2(
                                    label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),),
                                    fixedWidth: 50
                                ),
                                DataColumn(
                                  label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                DataColumn(
                                  label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                DataColumn2(
                                  label: Text('IMEI', style: TextStyle(fontWeight: FontWeight.bold),),
                                  size: ColumnSize.L,
                                ),
                                DataColumn2(
                                  label: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold),),
                                  fixedWidth: 90,
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold),)),
                                  fixedWidth: 100,
                                ),
                              ],
                              rows: List<DataRow>.generate(productStockList.length, (index) => DataRow(cells: [
                                DataCell(Text('${index+1}')),
                                DataCell(Row(children: [CircleAvatar(radius: 17,
                                  backgroundImage: productStockList[index].categoryName == 'ORO SWITCH'
                                      || productStockList[index].categoryName == 'ORO SENSE'?
                                  AssetImage('assets/images/oro_switch.png'):
                                  productStockList[index].categoryName == 'ORO LEVEL'?
                                  AssetImage('assets/images/oro_sense.png'):
                                  productStockList[index].categoryName == 'OROGEM'?
                                  AssetImage('assets/images/oro_gem.png'):AssetImage('assets/images/oro_rtu.png'),
                                  backgroundColor: Colors.transparent,
                                ), SizedBox(width: 10,), Text(productStockList[index].categoryName)],)),
                                DataCell(Text(productStockList[index].model)),
                                DataCell(Text(productStockList[index].imeiNo)),
                                DataCell(Text(productStockList[index].dtOfMnf)),
                                DataCell(Center(child: Text('${productStockList[index].warranty}'))),
                              ]))),
                        ) :
                        const Center(child: Text('SOLD OUT', style: TextStyle(fontSize: 20),)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 05),
            SizedBox(
                width: 300,
                child: Card(
                  elevation: 5,
                  surfaceTintColor: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Customer', style: TextStyle(fontSize: 17)),
                        trailing: IconButton(tooltip: 'Add New Customer', icon: const Icon(Icons.person_add_outlined), color: myTheme.primaryColor, onPressed: () async
                        {
                          await showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: CreateAccount(callback: callbackFunction, subUsrAccount: false, customerId: 0, from: 'Dealer',),
                              ));
                  
                        }), // Customize the leading icon
                      ),
                      const Divider(height: 0), // Optional: Add a divider between sections
                      Expanded(child : ListView.builder(
                        itemCount: customerOfDealer.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                              backgroundColor: Colors.transparent,
                            ),
                            trailing: IconButton(tooltip: 'View Customer Dashboard', icon: const Icon(Icons.view_quilt_outlined), color: myTheme.primaryColor, onPressed: () async
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  CustomerScreenController(customerId: customerOfDealer[index].userId, comingFrom: 'AdminORDealer', customerName: customerOfDealer[index].userName, mobileNo: '+${customerOfDealer[index].countryCode}-${customerOfDealer[index].mobileNumber}', emailId: customerOfDealer[index].emailId, userId: widget.dealerId,)),);
                            }),
                            title: Text(customerOfDealer[index].userName),
                            subtitle: Text('+${customerOfDealer[index].countryCode} ${customerOfDealer[index].mobileNumber}'),
                            onTap:() {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: customerOfDealer[index].userId, userName: customerOfDealer[index].userName, userID: widget.dealerId, userType: 2, productStockList: productStockList, callback: (String ) {},)),);
                            },
                          );
                        },
                      )),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  void indicatorViewShow() {
    if(mounted){
      setState(() {
        visibleLoading = true;
      });
    }
  }

  void indicatorViewHide() {
    if(mounted){
      setState(() {
        visibleLoading = false;
      });
    }
  }
}
