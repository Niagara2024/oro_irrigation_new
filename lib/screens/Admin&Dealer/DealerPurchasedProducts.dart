import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../Models/customer_product.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';

class DealerPurchasedProducts extends StatefulWidget {
  const DealerPurchasedProducts({Key? key, required this.userId, required this.dealerId, required this.dealerName}) : super(key: key);
  final int userId, dealerId;
  final String dealerName;

  @override
  State<DealerPurchasedProducts> createState() => _DealerPurchasedProductsState();
}

class _DealerPurchasedProductsState extends State<DealerPurchasedProducts> {

  bool visibleLoading = false;
  List<CustomerProductModel> customerProductList = <CustomerProductModel>[];

  final double itemWidth = 200;
  final double itemHeight = 100;

  @override
  void initState() {
    super.initState();
    getMyAllProduct();
  }

  Future<void> getMyAllProduct() async
  {
    indicatorViewShow();
    final body = {"fromUserId": widget.userId, "toUserId": widget.dealerId ,"set":1, "limit":150};
    final response = await HttpService().postRequest("getCustomerProduct", body);
    if (response.statusCode == 200)
    {
      customerProductList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200) {
        final cntList = data["data"]['product'] as List;
        for (int i=0; i < cntList.length; i++) {
          customerProductList.add(CustomerProductModel.fromJson(cntList[i]));
        }
        indicatorViewHide();
      }
    }
    else{
      indicatorViewHide();
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / itemWidth).floor();

    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        title: Text(widget.dealerName),
      ),
      body: visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 25, 0, MediaQuery.sizeOf(context).width/2 - 25, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('DEVICE STOCKS', style: TextStyle(fontSize: 17),),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: 100,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemCount: customerProductList.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        surfaceTintColor: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const CircleAvatar(
                                radius: 15,
                              ),
                              title: Text(customerProductList[index].categoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                              subtitle: Text(customerProductList[index].deviceId, style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 127.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
                          ),
                          width: 75,
                          height: 15,
                          child: const Text('Activated', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),textAlign: TextAlign.center,),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 198.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(70)),
                          ),
                          width: 4,
                          height: 2,
                        ),
                      ),
                    ],
                  );
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    surfaceTintColor: Colors.teal,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            radius: 15,
                          ),
                          title: Text(customerProductList[index].categoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                          subtitle: Text(customerProductList[index].deviceId, style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const ListTile(
              title: Text('SALES DEVICES', style: TextStyle(fontSize: 17),),
            ),
            Expanded(
              flex: 1,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: itemWidth / itemHeight,
                ),
                itemCount: customerProductList.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Card(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                        surfaceTintColor: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const CircleAvatar(
                                radius: 15,
                              ),
                              title: Text(customerProductList[index].categoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                              subtitle: Text(customerProductList[index].deviceId, style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 127.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)),
                          ),
                          width: 75,
                          height: 15,
                          child: const Text('Activated', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),textAlign: TextAlign.center,),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 198.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.shade300,
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(70)),
                          ),
                          width: 4,
                          height: 2,
                        ),
                      ),
                    ],
                  );
                  return Card(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    surfaceTintColor: Colors.teal,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            radius: 15,
                          ),
                          title: Text(customerProductList[index].categoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
                          subtitle: Text(customerProductList[index].deviceId, style: TextStyle(fontSize: 12,fontWeight: FontWeight.normal),),
                        )
                      ],
                    ),
                  );
                },
              ),
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
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          visibleLoading = false;
        });
      });
    }
  }
}
