import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../Models/Customer/Dashboard/DashboardNode.dart';
import '../../Models/Customer/Dashboard/ProgramList.dart';
import '../../Models/Customer/Dashboard/ProgramServiceDevices.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../product_inventory.dart';
import 'CustomerDashboard.dart';


class CustomerHome extends StatefulWidget {
  const CustomerHome({Key? key, required this.customerID, required this.type, required this.customerName, required this.userID, required this.mobileNo}) : super(key: key);
  final int userID, customerID, type;
  final String customerName, mobileNo;

  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> with SingleTickerProviderStateMixin
{

  List<DashboardModel> siteListFinal = [];
  int siteIndex = 0;
  List<ProgramList> programList = [];
  bool visibleLoading = false;
  int wifiStrength = 0;
  ProgramServiceDevices programServiceDevices = ProgramServiceDevices(irrigationPump: [], mainValve: [], centralFertilizerSite: [], centralFertilizer: [], localFertilizer: [], centralFilterSite: [], localFilter: []);

  String standaloneTime = '', standaloneFlow = '';
  int standaloneMethod = 0;
  String currentTap = 'Dashboard';

  late Widget _centerWidget;

  @override
  void initState() {
    super.initState();
    indicatorViewShow();
    getCustomerSite(widget.customerID);
  }

  Future<void> getCustomerSite(userId) async
  {
    Map<String, Object> body = {"userId" : userId ?? 0};
    //print(body);
    final response = await HttpService().postRequest("getUserDeviceListForCustomer", body);
    if (response.statusCode == 200)
    {
      siteListFinal.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        //print(response.body);
        try {
          siteListFinal = cntList.map((json) => DashboardModel.fromJson(json)).toList();
          //live call
          String payLoadFinal = jsonEncode({"3000": [{"3001": ""}]});
          MQTTManager().publish(payLoadFinal, 'AppToFirmware/${siteListFinal[siteIndex].deviceId}');
          fetchDashboardData();
        } catch (e) {
          print('Error: $e');
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  void fetchDashboardData()
  {
    _centerWidget = CustomerDashboard(customerID: widget.userID, type: 0, customerName: widget.customerName, userID: widget.userID, mobileNo: '+${91}-${widget.mobileNo}', siteListFinal: siteListFinal,);
    getStandaloneDetails(siteListFinal[siteIndex].controllerId ?? 0);
    getProgramList(siteListFinal[siteIndex].controllerId ?? 0);
    MQTTManager().subscribeToTopic('FirmwareToApp/${siteListFinal[siteIndex].deviceId}');
  }

  Future<void> getProgramList(int controllerId) async
  {
    programList.clear();
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserProgramNameList", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //print(jsonResponse);
        List<dynamic> programsJson = jsonResponse['data'];
        setState(() {
          programList = [
            ...programsJson.map((programJson) => ProgramList.fromJson(programJson)).toList(),
          ];
        });
        indicatorViewHide();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getStandaloneDetails(int controllerId) async
  {
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": controllerId};
      final response = await HttpService().postRequest("getUserManualOperation", body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if(jsonResponse['code']==200){
          standaloneMethod = jsonResponse['data']['method'];
          standaloneTime = jsonResponse['data']['time'];
          standaloneFlow = jsonResponse['data']['flow'];
        }else{
          standaloneMethod = 0;
        }
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context)
  {

    final screenWidth = MediaQuery.of(context).size.width;
    if(widget.type==0){
      return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
      DefaultTabController(
        length: siteListFinal.length,
        animationDuration: Duration.zero,
        child: Scaffold(
          backgroundColor: myTheme.primaryColor.withOpacity(0.1),
          body: buildBodyContent(),
        ),
      );
    }else{
      return visibleLoading? buildLoadingIndicator(visibleLoading, screenWidth):
      DefaultTabController(
        length: siteListFinal.length, // Set the number of tabs
        child: Scaffold(
          backgroundColor: myTheme.primaryColor.withOpacity(0.1),
          appBar: buildAppBar('${widget.customerName} - DASHBOARD', context),
          body: buildBodyContent(),
        ),
      );
    }

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

  AppBar buildAppBar(String title, BuildContext context)
  {
    return AppBar(
      title: Text(title),
      backgroundColor: myTheme.primaryColor,
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(widget.mobileNo, style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.white)),
              ],
            ),
            const SizedBox(width: 05),
            const CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
            ),
          ],),
        const SizedBox(width: 10)
      ],
    );
  }

  Container buildBodyContent()
  {
    return Container(
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
              getProgramList(siteListFinal[index].controllerId ?? 0 );
              siteIndex = index;
            },
          ) :
          const SizedBox(),
          Stack(
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
                      color: myTheme.primaryColor.withOpacity(0.1),
                      child: _centerWidget,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

  }

   Widget buildCustomListTile(String title, IconData icon, String tapOption) {
     return Padding(
       padding: const EdgeInsets.only(left: 8, right: 8),
       child: Container(
         decoration: BoxDecoration(
           color: currentTap == tapOption ? myTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
           borderRadius: const BorderRadius.all(Radius.circular(5)), // Adjust the radius as needed
         ),
         child: ListTile(
           leading: Icon(
             icon,
             color: currentTap == tapOption ? myTheme.primaryColor : Colors.black.withOpacity(0.6),
           ),
           title: Text(
             title,
             style: TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold,
               color: currentTap == tapOption ? myTheme.primaryColor : Colors.black.withOpacity(0.8),
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
         _centerWidget = CustomerDashboard(customerID: widget.userID, type: 0, customerName: widget.customerName, userID: widget.userID, mobileNo: '+${91}-${widget.mobileNo}', siteListFinal: siteListFinal,);
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