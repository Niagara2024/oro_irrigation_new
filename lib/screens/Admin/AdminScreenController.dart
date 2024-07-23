import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Models/DataResponse.dart';
import '../../Models/customer_list.dart';
import '../../Models/product_stock.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../my_preference.dart';
import '../product_entry.dart';
import '../product_inventory.dart';
import 'AdminDashboard.dart';

enum Calendar {day, week, month, year}
typedef CallbackFunction = void Function(String result);

class AdminScreenController extends StatefulWidget {
  const AdminScreenController({Key? key, required this.userName, required this.countryCode, required this.mobileNo, required this.fromLogin, required this.userId, required this.userType}) : super(key: key);

  final String userName, countryCode, mobileNo;
  final bool fromLogin;
  final int userId, userType;

  @override
  State<AdminScreenController> createState() => _AdminScreenControllerState();
}

class _AdminScreenControllerState extends State<AdminScreenController> {
  Calendar calendarView = Calendar.day;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];
  late DataResponse dataResponse;

  bool isHovering = false;

  String selectedValue = 'All';
  List<String> dropdownItems = ['All', 'Last year', 'Last month', 'Last Week'];
  bool visibleLoading = false;

  int _selectedIndex = 0;
  String appBarTitle = 'Home';

  @override
  void initState() {
    super.initState();
    dataResponse = DataResponse(graph: {}, total: []);
    getProductSalesReport();
    getProductStock();
    getCustomerList();
  }

  void callbackFunction(String message)
  {
    if(message=='reloadStock'){
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 500), () {
        getProductStock();
      });
    }else{
      Future.delayed(const Duration(milliseconds: 500), () {
        getCustomerList();
      });
    }
  }

  Future<void> getProductSalesReport() async {
    Map<String, Object> body = {"userId": widget.userId, "userType": 1, "type": "All"};
    final response = await HttpService().postRequest("getProductSalesReport", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data["code"] == 200) {
        try {
          dataResponse = DataResponse.fromJson(data);
        }catch (e) {
          print('Error parsing data response: $e');
        }
      }
    } else {
      //_showSnackBar(response.body);
    }
  }

  Future<void> getProductStock() async
  {
    Map<String, dynamic> body = {"fromUserId" : null, "toUserId" : null};
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
        setState(() {
          productStockList;
        });
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getCustomerList() async {
    Map<String, Object> body = {"userType" : 1, "userId" : widget.userId};
    final response = await HttpService().postRequest("getUserList", body);
    if (response.statusCode == 200) {
      myCustomerList.clear();
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        final cntList = data["data"] as List;
        List<CustomerListMDL> tempList = [];
        for (int i = 0; i < cntList.length; i++) {
          tempList.add(CustomerListMDL.fromJson(cntList[i]));
        }
        setState(() {
          myCustomerList.addAll(tempList);
          tempList=[];
        });
      }
    } else {
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: myTheme.primaryColor.withOpacity(0.01),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            backgroundColor: myTheme.primaryColorDark,
            labelType: NavigationRailLabelType.all,
            indicatorColor: myTheme.primaryColorLight,
            elevation: 5,
            leading: const Column(
              children: [
                Image(image: AssetImage("assets/images/oro_logo_white.png"), height: 40, width: 60,),
                SizedBox(height: 20),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout, color: Colors.redAccent,),
                    autofocus: true,
                    focusColor: Colors.white,
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('userId');
                      await prefs.remove('userName');
                      await prefs.remove('userType');
                      await prefs.remove('countryCode');
                      await prefs.remove('mobileNumber');
                      await prefs.remove('subscribeTopic');
                      await prefs.remove('password');
                      await prefs.remove('email');

                      if (mounted){
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
              ),
            ),
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
                if(_selectedIndex==0){
                  appBarTitle = 'Home';
                }else if(_selectedIndex==1){
                  appBarTitle = 'Product';
                }else{
                  appBarTitle = 'My Preference';
                }
              });
            },
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                padding: EdgeInsets.only(top: 5),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white,),
                label: Text(''),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_outlined, color: Colors.white,),
                label: Text(''),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.topic_outlined),
                selectedIcon: Icon(Icons.topic_outlined, color: Colors.white,),
                label: Text(''),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.manage_accounts_outlined),
                selectedIcon: Icon(Icons.manage_accounts_outlined, color: Colors.white,),
                label: Text(''),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info_outline, color: Colors.white,),
                label: Text(''),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.help_outline),
                selectedIcon: Icon(Icons.help_outline, color: Colors.white,),
                label: Text(''),
              ),
            ],
          ),
          Expanded(
            child: widget.userType==0? const Center(child: Text('Super admin')): mainMenu(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget mainMenu(int index) {
    switch (index) {
      case 0:
        return AdminDashboard(userName: widget.userName, countryCode: widget.countryCode, mobileNo: widget.mobileNo, userId: widget.userId,);
      case 1:
        return ProductInventory(
          userName: widget.userName,
        );
      case 2:
        return const AllEntry();
      case 3:
        return MyPreference(userID: widget.userId);
      default:
        return const SizedBox();
    }
  }

}

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}

class MySalesChart extends StatefulWidget {
  const MySalesChart({Key? key}) : super(key: key);

  @override
  _MySalesChartState createState() => _MySalesChartState();
}

class _MySalesChartState extends State<MySalesChart> {
  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    data = [
      _ChartData('2019', 15, 8, 10, 12, 23),
      _ChartData('2020', 30, 15, 24, 15, 12),
      _ChartData('2021', 6, 4, 10, 17, 32),
      _ChartData('2022', 14, 2, 17, 25, 10),
      _ChartData('2023', 14, 2, 17, 25, 27)
    ];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
        tooltipBehavior: _tooltip,
        series: <ChartSeries<_ChartData, String>>[
          ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.period,
              yValueMapper: (_ChartData data, _) => data.gem,
              name: 'GEM',
              color: Colors.blue.shade300),
          ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.period,
              yValueMapper: (_ChartData data, _) => data.sRtu,
              name: 'Smart RTU',
              color: Colors.green.shade300),
          ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.period,
              yValueMapper: (_ChartData data, _) => data.rtu,
              name: 'RTU',
              color: Colors.orange.shade300),
          ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.period,
              yValueMapper: (_ChartData data, _) => data.oSwitch,
              name: 'ORO Switch',
              color: Colors.pink.shade300),
          ColumnSeries<_ChartData, String>(
              dataSource: data,
              xValueMapper: (_ChartData data, _) => data.period,
              yValueMapper: (_ChartData data, _) => data.oSpot,
              name: 'ORO Spot',
              color: Colors.deepPurpleAccent.shade100),
        ]);
  }
}

class _ChartData {
  _ChartData(this.period, this.gem, this.sRtu, this.rtu, this.oSwitch, this.oSpot);
  final String period;
  final int gem;
  final int sRtu;
  final int rtu;
  final int oSwitch;
  final int oSpot;
}
