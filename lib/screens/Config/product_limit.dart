import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../Models/product_limit.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';

class ProductLimits extends StatefulWidget {
  const ProductLimits({Key? key, required this.userID,  required this.customerID, required this.userType, required this.siteID, required this.nodeCount}) : super(key: key);
  final int userID, customerID, userType, siteID, nodeCount;


  @override
  State<ProductLimits> createState() => _ProductLimitsState();
}

class _ProductLimitsState extends State<ProductLimits> {

  String userID = '0';
  String userType = '0';
  int filledRelayCount = 0;
  int currentTxtFldVal = 0;
  List<MdlProductLimit> productLimits = <MdlProductLimit>[];

  var myControllers = [];
  bool visibleLoading = false;

  @override
  void initState() {
    super.initState();
    getProductLimits();
  }

  @override
  void dispose() {
    for (var c in myControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> getProductLimits() async
  {
    indicatorViewShow();
    await Future.delayed(const Duration(milliseconds: 500));
    Map<String, dynamic> body = {"userId" : widget.customerID, "controllerId" : widget.siteID};
    print(body);
    final response = await HttpService().postRequest("getUserProductLimit", body);
    if (response.statusCode == 200)
    {
      productLimits.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        myControllers = [];
        for (int i=0; i < cntList.length; i++) {
          productLimits.add(MdlProductLimit.fromJson(cntList[i]));
          myControllers.add(TextEditingController());
          myControllers[i].text = '${productLimits[i].quantity}';
          filledRelayCount = filledRelayCount + productLimits[i].quantity;

        }
      }
      setState(() {
        print('${filledRelayCount}');
        productLimits;
        indicatorViewHide();
      });

    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> updateProductLimit() async
  {
    for (int i=0; i < productLimits.length; i++) {
      productLimits[i].quantity = int.parse(myControllers[i].text);
    }

    Map<String, dynamic> body = {
      "userId": widget.customerID,
      "controllerId": widget.siteID,
      "productLimit": productLimits,
      "createUser": widget.userID,
    };
    print(body);
    final response = await HttpService().postRequest("createUserProductLimit", body);
    if(response.statusCode == 200)
    {
      var data = jsonDecode(response.body);
      if(data["code"]==200) {
        _showSnackBar(data["message"]);
      }
      else{
        _showSnackBar(data["message"]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return visibleLoading? Visibility(
      visible: visibleLoading,
      child: Container(
        padding: EdgeInsets.fromLTRB(mediaQuery.size.width/2 - 30, 0, mediaQuery.size.width/2 - 30, 0),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    ) :
    Container(
      color:  Colors.blueGrey.shade50,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                      child: GridView.builder(
                        itemCount: productLimits.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsetsDirectional.all(5.0),
                            decoration:  BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: myTheme.primaryColor.withOpacity(0.5),
                                  blurRadius: 2,
                                  offset: const Offset(2, 2), // Shadow position
                                ),
                              ],
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded (
                                  flex:1,
                                  child : Container(
                                    constraints: const BoxConstraints.expand(),
                                    decoration: BoxDecoration(
                                      color: myTheme.primaryColor.withOpacity(0.2),
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(5.0), bottomLeft: Radius.circular(5.0)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        backgroundColor: myTheme.primaryColor.withOpacity(0.5),
                                        child: Icon(Icons.reset_tv, color: Colors.white,),
                                      ),
                                    ),
                                  ),),
                                Expanded(
                                  flex :2,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                        child: TextField(
                                          controller: myControllers[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                              labelText: productLimits[index].product,
                                          ),
                                          onTap: () {
                                            currentTxtFldVal = int.parse(myControllers[index].text);
                                            print(currentTxtFldVal);
                                          },
                                          onChanged: (input) async {
                                            await Future.delayed(const Duration(milliseconds: 50));
                                            setState(() {
                                              String crTvVal = myControllers[index].text;
                                              if (widget.nodeCount < filledRelayCount + int.parse(myControllers[index].text.isEmpty ? '0' : myControllers[index].text) - currentTxtFldVal) {
                                                if (crTvVal.isNotEmpty) {
                                                  myControllers[index].text = crTvVal.substring(0, crTvVal.length - 1);
                                                }
                                                _showSnackBar('Limit reached');
                                              } else {
                                                filledRelayCount = myControllers.fold<int>(0,(sum, controller) => sum + (int.tryParse(controller.text) ?? 0),);
                                              }

                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),)
                              ],
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: mediaQuery.size.width > 1200 ? 6 : 4,
                          childAspectRatio: mediaQuery.size.width / 460,
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 60,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Relay Total :'),
                const SizedBox(width: 10,),
                Text('${widget.nodeCount}', style: const TextStyle(fontSize: 17),),
                const SizedBox(width: 20,),
                const Text('Remaining :'),
                const SizedBox(width: 10,),
                Text('${widget.nodeCount - filledRelayCount}', style: const TextStyle(fontSize: 17),),
                const SizedBox(width: 20,),
                TextButton.icon(
                  onPressed: () {
                    updateProductLimit();
                  },
                  label: const Text('Save'),
                  icon: Icon(
                    Icons.save_as_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20,)
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void indicatorViewShow() {
    setState(() {
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

}
