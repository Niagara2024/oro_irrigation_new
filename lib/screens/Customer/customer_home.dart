import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../constants/MQTTManager.dart';
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
  bool loadingSite = true;
  bool visibleLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getCustomerSite(widget.customerID);
  }

  Future<void> getCustomerSite(userId) async
  {
    Map<String, Object> body = {"userId" : userId ?? 0};
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      siteListFinal.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        try {
          siteListFinal = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          setState((){
            loadingSite = false;
          });
          subscribeAndUpdateSite();
        } catch (e) {
          print('Error: $e');
          indicatorViewHide();
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  void subscribeAndUpdateSite() {
    indicatorViewShow();
    Future.delayed(const Duration(seconds: 2), () {
      MQTTManager().subscribeToTopic('FirmwareToApp/${siteListFinal[siteIndex].deviceId}');
      indicatorViewHide();
    });

  }

  @override
  Widget build(BuildContext context)
  {
    final screenWidth = MediaQuery.of(context).size.width;
    return loadingSite? buildLoadingIndicator(loadingSite, screenWidth):
    DefaultTabController(
      length: siteListFinal.length,
      animationDuration: Duration.zero,
      child: Scaffold(
        appBar: widget.comingFrom == 'AdminORDealer'? AppBar(title: Text('${widget.customerName} - DASHBOARD')) : null,
        backgroundColor: myTheme.primaryColor.withOpacity(0.05),
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
              widget.comingFrom == 'Customer' ? Expanded(
                child: visibleLoading ? buildLoadingIndicator(visibleLoading, screenWidth) : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      backgroundColor: myTheme.secondaryHeaderColor,
                      labelType: NavigationRailLabelType.all,
                      indicatorColor: myTheme.primaryColor,
                      elevation: 5,
                      minWidth: 100,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      destinations: const <NavigationRailDestination>[
                        NavigationRailDestination(
                          padding: EdgeInsets.only(top: 5),
                          icon: Icon(Icons.dashboard_outlined),
                          selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                          label: Text('Dashboard'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.devices_other),
                          selectedIcon: Icon(Icons.devices_other, color: Colors.white),
                          label: Text('Product'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.message_outlined),
                          selectedIcon: Icon(Icons.message_outlined, color: Colors.white,),
                          label: Text('Irrigation Logs'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.question_answer_outlined),
                          selectedIcon: Icon(Icons.question_answer_outlined, color: Colors.white,),
                          label: Text('Sent &\nReceived'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings_outlined, color: Colors.white,),
                          label: Text('Settings'),
                        ),
                      ],
                    ),
                    VerticalDivider(width: 2, color: myTheme.primaryColorLight),
                    Expanded(
                      child:
                      _selectedIndex == 0 ? CustomerDashboard(customerID: widget.customerID, type: 0, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex], siteLength: siteListFinal.length) :
                      _selectedIndex == 1 ? ProductInventory(userName: widget.customerName) :
                      _selectedIndex == 2 ? ProductInventory(userName: widget.customerName):
                      _selectedIndex == 3 ?  ProductInventory(userName: widget.customerName) :  ProductInventory(userName: widget.customerName),
                    ),
                  ],
                ),
              ):
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: siteListFinal.length >1? MediaQuery.sizeOf(context).height-104 : MediaQuery.sizeOf(context).height-56,
                  color: myTheme.primaryColor.withOpacity(0.1),
                  child: CustomerDashboard(customerID: widget.customerID, type: 0, customerName: widget.customerName, userID: widget.customerID, mobileNo: '+${widget.mobileNo}', siteData: siteListFinal[siteIndex], siteLength: siteListFinal.length,),
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