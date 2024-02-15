import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/UserData.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../product_inventory.dart';
import 'CustomerDashboard.dart';


class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.customerName, required this.mobileNo, required this.comingFrom}) : super(key: key);
  final customerID;
  final String customerName, mobileNo, comingFrom;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with SingleTickerProviderStateMixin
{

  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  bool visibleLoading = false;
  int wifiStrength = 0;

  String standaloneTime = '', standaloneFlow = '';
  int standaloneMethod = 0;
  String currentTap = 'Dashboard';

  late Widget _centerWidget = Container();

  @override
  void initState() {
    super.initState();
    indicatorViewShow();
    getCustomerSite(widget.customerID);
  }

  Future<void> getCustomerSite(userId) async
  {
    Map<String, Object> body = {"userId" : userId ?? 0};
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      indicatorViewHide();
      siteListFinal.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        //print(response.body);
        try {
          siteListFinal = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          subscribeAndUpdateSite();
        } catch (e) {
          print('Error: $e');
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  void subscribeAndUpdateSite() {
    MQTTManager().subscribeToTopic('FirmwareToApp/${siteListFinal[siteIndex].deviceId}');
    indicatorViewHide();
    Future.delayed(const Duration(milliseconds: 500), () {
      onOptionSelected('Dashboard');
    });

  }

  @override
  Widget build(BuildContext context)
  {
    final screenWidth = MediaQuery.of(context).size.width;
    return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
    DefaultTabController(
      length: siteListFinal.length,
      animationDuration: Duration.zero,
      child: Scaffold(
        appBar: widget.comingFrom == 'AdminORDealer'? AppBar(title: Text('${widget.customerName} - DASHBOARD')) : null,
        backgroundColor: myTheme.primaryColor.withOpacity(0.1),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              siteListFinal.length >1 ? TabBar(
                indicatorColor: myTheme.primaryColor,
                isScrollable: true,
                labelColor: myTheme.primaryColor,
                unselectedLabelColor: Colors.black,
                tabs: [
                  for (var i = 0; i < siteListFinal.length; i++)
                    Tab(text: siteListFinal[i].siteName ?? '',),
                ],
                onTap: (index) {
                  siteIndex = index;
                  subscribeAndUpdateSite();
                },
              ) :
              const SizedBox(),
              widget.comingFrom == 'Customer' ? Stack(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 250,
                        height: siteListFinal.length >1? MediaQuery.sizeOf(context).height-104 : MediaQuery.sizeOf(context).height-56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                            ),
                            buildCustomListTile('Dashboard', Icons.dashboard_outlined, 'Dashboard'),
                            buildCustomListTile('Product List', Icons.topic_outlined, 'Product List'),
                            buildCustomListTile('Report Overview', Icons.my_library_books_outlined, 'Report Overview'),
                            buildCustomListTile('Sent And Received', Icons.question_answer_outlined, 'Sent And Received'),
                            buildCustomListTile('Controller Logs', Icons.message_outlined, 'Controller Logs'),
                            buildCustomListTile('Device Settings', Icons.settings_outlined, 'Device Settings'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: siteListFinal.length >1? MediaQuery.sizeOf(context).height-104 : MediaQuery.sizeOf(context).height-56,
                          color: myTheme.primaryColor.withOpacity(0.2),
                          child: _centerWidget,
                        ),
                      ),
                    ],
                  ),
                ],
              ) :
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: siteListFinal.length >1? MediaQuery.sizeOf(context).height-104 : MediaQuery.sizeOf(context).height-56,
                  color: myTheme.primaryColor.withOpacity(0.2),
                  child: _centerWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoadingIndicator(bool isVisible, double width)
  {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }

   Widget buildCustomListTile(String title, IconData icon, String tapOption) {
     return Padding(
       padding: const EdgeInsets.only(left: 8, right: 8),
       child: Container(
         decoration: BoxDecoration(
           color: currentTap == tapOption ? myTheme.primaryColor.withOpacity(0.7) : Colors.transparent,
           borderRadius: const BorderRadius.all(Radius.circular(10)), // Adjust the radius as needed
         ),
         child: ListTile(
           leading: Icon(
             icon,
             color: currentTap == tapOption ? Colors.white : Colors.black.withOpacity(0.6),
           ),
           title: Text(
             title,
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold,
               color: currentTap == tapOption ? Colors.white : Colors.black.withOpacity(0.8),
             ),
           ),
           onTap: () {
             onOptionSelected(tapOption);
           },
         ),
       ),
     );
   }

   void onOptionSelected(String option) {
     currentTap = option;
     setState(() {
       if (option == 'Dashboard') {
         _centerWidget = CustomerDashboard(customerID: widget.customerID, type: 0, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex], siteLength: siteListFinal.length,);
       } else if (option == 'Product List') {
         _centerWidget = ProductInventory(userName: widget.customerName);
       } else if (option == 'Device Settings') {
         //_centerWidget = FarmSettings(customerID: widget.userID, siteList: [],);
       }
       else if (option == 'Sent And Received') {
        // _centerWidget = SentAndReceived(customerID: widget.userID, siteList: const [],);
       }
     });
   }


  void indicatorViewShow() {
    setState((){
      visibleLoading = true;
    });
  }

  void indicatorViewHide() {
    setState(() {
      visibleLoading = false;
    });
  }

}