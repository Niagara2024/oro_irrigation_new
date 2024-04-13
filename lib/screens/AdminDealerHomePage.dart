import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Models/DataResponse.dart';
import '../Models/customer_list.dart';
import '../Models/product_stock.dart';
import '../constants/http_service.dart';
import '../constants/theme.dart';
import '../state_management/mqtt_message_provider.dart';
import 'Customer/CustomerScreenController.dart';
import 'Forms/add_product.dart';
import 'Forms/create_account.dart';
import 'Forms/device_list.dart';
import 'my_dealers.dart';

enum Calendar { day, week, month, year }
typedef CallbackFunction = void Function(String result);

class AdminDealerHomePage extends StatefulWidget {
  const AdminDealerHomePage({Key? key, required this.userName, required this.countryCode, required this.mobileNo, required this.fromLogin, required this.userId, required this.userType}) : super(key: key);
  final String userName, countryCode, mobileNo;
  final bool fromLogin;
  final int userId, userType;

  @override
  State<AdminDealerHomePage> createState() => AdminDealerHomePageHomePageState();

}

class AdminDealerHomePageHomePageState extends State<AdminDealerHomePage>
{
  Calendar calendarView = Calendar.day;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];
  late DataResponse dataResponse;

  int userType = 0;
  int userId = 0;
  bool isHovering = false;

  String selectedValue = 'All';
  List<String> dropdownItems = ['All', 'Last year', 'Last month', 'Last Week'];
  bool visibleLoading = false;

  @override
  void initState() {
    super.initState();
    dataResponse = DataResponse();
    indicatorViewShow();
    getUserInfo();
  }

  void callbackFunction(String message)
  {
    if(message=='reloadStock'){
      print('reloadStock');
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 500), () {
        getProductStock();
      });
    }
  }

  Future<void> getUserInfo() async
  {
    final prefs = await SharedPreferences.getInstance();
    if(widget.fromLogin){
      userType = int.parse(prefs.getString('userType') ?? "0");
      userId = int.parse(prefs.getString('userId') ?? "0");
    }else{
      userType = widget.userType;
      userId = widget.userId;
    }

    getProductSalesReport();
    getProductStock();
    getCustomerList();
  }

  Future<void> getProductSalesReport() async {
    Map<String, Object> body = {"userId": userId, "userType": userType, "type": "All"};
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
      indicatorViewHide();
    } else {
      //_showSnackBar(response.body);
    }
  }

  Future<void> getProductStock() async
  {
    Map<String, dynamic> body = {};
    if(userType==1){
      body = {"fromUserId" : null, "toUserId" : null};
    }else{
      body = {"fromUserId" : null, "toUserId" : userId};
    }

    final response = await HttpService().postRequest("getProductStock", body);
    if (response.statusCode == 200)
    {
      productStockList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        setState(() {
          for (int i=0; i < cntList.length; i++) {
            productStockList.add(ProductStockModel.fromJson(cntList[i]));
          }
        });
      }
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getCustomerList() async
  {
    Map<String, Object> body = {"userType" : userType, "userId" : userId};
    final response = await HttpService().postRequest("getUserList", body);
    if (response.statusCode == 200)
    {
      myCustomerList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          myCustomerList.add(CustomerListMDL.fromJson(cntList[i]));
        }
      }
    }
    else{
      //_showSnackBar(response.body);
    }

  }


  @override
  Widget build(BuildContext context)
  {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: myTheme.primaryColor.withOpacity(0.01),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('+${widget.countryCode} ${widget.mobileNo}', style: const TextStyle(fontWeight: FontWeight.normal,color: Colors.white)),
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
        //scrolledUnderElevation: 5.0,
        //shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          height: height,
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(width/2 - 60, 0, width/2 - 60, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ):
      Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height : 325,
                    child: Card(
                      elevation: 5,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text(
                              "Analytics Overview",
                              style: TextStyle(fontSize: 20, color: Colors.black),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SegmentedButton<Calendar>(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.1)),
                                    iconColor: MaterialStateProperty.all(myTheme.primaryColor),
                                  ),
                                  segments: const <ButtonSegment<Calendar>>[
                                    ButtonSegment<Calendar>(
                                        value: Calendar.day,
                                        label: Text('All'),
                                        icon: Icon(Icons.calendar_view_day)),
                                    ButtonSegment<Calendar>(
                                        value: Calendar.week,
                                        label: Text('Week'),
                                        icon: Icon(Icons.calendar_view_week)),
                                    ButtonSegment<Calendar>(
                                        value: Calendar.month,
                                        label: Text('Month'),
                                        icon: Icon(Icons.calendar_view_month)),
                                    ButtonSegment<Calendar>(
                                        value: Calendar.year,
                                        label: Text('Year'),
                                        icon: Icon(Icons.calendar_today)),
                                  ],
                                  selected: <Calendar>{calendarView},
                                  onSelectionChanged: (Set<Calendar> newSelection) {
                                    setState(() {
                                      // By default there is only a single segment that can be
                                      // selected at one time, so its value is always the first
                                      // item in the selected set.
                                      calendarView = newSelection.first;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: MySalesChart(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.spaceBetween,
                              children: List.generate(
                                dataResponse.total!.length, (index) => Chip(
                                avatar: CircleAvatar(backgroundColor: index==0? Colors.cyan : index==1? Colors.pink: index==2 ? Colors.purple : index==3 ? Colors.orange :
                                index==4? Colors.deepPurple : index==5? Colors.red: index==6 ? Colors.yellow : index==7 ? Colors.black54 :
                                index==8 ? Colors.purple: index==9 ? Colors.redAccent: index == 10? Colors.blueGrey : index == 11?
                                Colors.lightGreen : index == 12?Colors.purpleAccent:Colors.brown),
                                elevation: 3,
                                shape: const LinearBorder(),
                                label: Text('${dataResponse.total![index].categoryName} - ${dataResponse.total![index].totalProduct}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
                                // Customize Chip properties based on your needs
                              ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                      ),
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
                              trailing : userType ==1? IconButton(tooltip: 'Add new stock', icon: const Icon(Icons.add_box_outlined), color: myTheme.primaryColor, onPressed: () async
                              {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 600,
                                      color: Colors.white,
                                      child: Center(
                                        child: AddProduct(callback: callbackFunction),
                                      ),
                                    );
                                  },
                                );
                                //Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddProduct(callback: (String ) {},)),);
                              }) : null,
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
                                        fixedWidth: 95,
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
                                      DataCell(Text('${productStockList[index].imeiNo}')),
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
                ],
              ),
            ),
            SizedBox(
              width: 270,
              child: Card(
                elevation: 5,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(userType==1? 'My Dealer':'My Customer', style: const TextStyle(fontSize: 17)),
                      trailing: IconButton(tooltip: userType==1? 'Add Dealer account' : 'Add Customer account', icon: const Icon(Icons.person_add_outlined), color: myTheme.primaryColor, onPressed: () async
                      {
                        await showDialog<void>(
                            context: context,
                            builder: (context) => const AlertDialog(
                              content: CreateAccount(),
                            ));
                      }),
                    ),
                    const Divider(height: 0), // Optional: Add a divider between sections
                    Expanded(child : ListView.builder(
                      itemCount: myCustomerList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                            backgroundColor: Colors.transparent,
                          ),
                          trailing: IconButton(tooltip: userType==1? 'View Dealer Dashboard' : 'View Customer Dashboard', icon: const Icon(Icons.view_quilt_outlined), color: myTheme.primaryColor, onPressed: () async
                          {
                            if(userType==1){
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  MyDealers(dealerId: myCustomerList[index].userId, dealerName: myCustomerList[index].userName)),);
                            }else{
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  CustomerScreenController(customerID: myCustomerList[index].userId, comingFrom: 'AdminORDealer', customerName: myCustomerList[index].userName, mobileNo: '+${myCustomerList[index].countryCode}-${myCustomerList[index].mobileNumber}',)));
                            }
                          }),
                          title: Text(myCustomerList[index].userName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                          subtitle: Text('+${myCustomerList[index].countryCode} ${myCustomerList[index].mobileNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                          onTap:() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: myCustomerList[index].userId, userName: myCustomerList[index].userName, userID: userId, userType: userType, productStockList: productStockList, callback: callbackFunction,)),);
                          },
                        );
                      },
                    )),
                  ],
                ),
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
      setState(() {
        visibleLoading = false;
      });
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

class MyCustomWidget extends StatelessWidget {
  final String text;

  const MyCustomWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.blue,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
    );
  }
}


