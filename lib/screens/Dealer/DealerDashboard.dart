import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Models/DataResponse.dart';
import '../../Models/customer_list.dart';
import '../../Models/product_stock.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../Customer/CustomerScreenController.dart';
import '../Forms/add_product.dart';
import '../Forms/create_account.dart';
import '../Forms/device_list.dart';
import 'ServiceRequestsTable.dart';

enum Calendar {day, week, month, year}
typedef CallbackFunction = void Function(String result);

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({Key? key, required this.userName, required this.countryCode, required this.mobileNo, required this.userId, required this.emailId}) : super(key: key);

  final String userName, countryCode, mobileNo, emailId;
  final int userId;

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {

  Calendar calendarView = Calendar.day;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];
  List<CustomerListMDL> filteredCustomerList = [];
  late DataResponse dataResponse;

  String selectedValue = 'All';
  List<String> dropdownItems = ['All', 'Last year', 'Last month', 'Last Week'];
  bool visibleLoading = false;

  bool searched = false;
  TextEditingController txtFldSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    searched=false;
    dataResponse = DataResponse(graph: {}, total: []);
    indicatorViewShow();
    Future.delayed(const Duration(seconds: 2), () {
      getProductSalesReport();
      getProductStock();
      getCustomerList();
    });

  }

  void callbackFunction(String message)
  {
    Future.delayed(const Duration(milliseconds: 500), () {
      getCustomerList();
    });
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

  Future<void> getProductSalesReport() async {
    Map<String, Object> body = {"userId": widget.userId, "userType": 2, "type": "All"};
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
    Map<String, dynamic> body = {"fromUserId" : null, "toUserId" : widget.userId};
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

  Future<void> getCustomerList() async {
    Map<String, Object> body = {"userType" : 2, "userId" : widget.userId};
    final response = await HttpService().postRequest("getUserList", body);
    if (response.statusCode == 200) {
      myCustomerList.clear();
      //print(response.body);
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        final cntList = data["data"] as List;
        List<CustomerListMDL> tempList = [];
        for (int i = 0; i < cntList.length; i++) {
          tempList.add(CustomerListMDL.fromJson(cntList[i]));
        }
        setState(() {
          myCustomerList.addAll(tempList);
          filteredCustomerList = myCustomerList;
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
                          const Expanded(
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
                                    headingRowColor: WidgetStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
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
                                        const AssetImage('assets/images/oro_switch.png'):
                                        productStockList[index].categoryName == 'ORO LEVEL'?
                                        const AssetImage('assets/images/oro_sense.png'):
                                        productStockList[index].categoryName == 'OROGEM'?
                                        const AssetImage('assets/images/oro_gem.png'): const AssetImage('assets/images/oro_rtu.png'),
                                        backgroundColor: Colors.transparent,
                                      ), const SizedBox(width: 10,), Text(productStockList[index].categoryName)],)),
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
                ],
              ),
            ),
            SizedBox(
              width: 300,
              child: Card(
                elevation: 5,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                ),
                child: Column(
                  children: [
                    searched?ListTile(
                      title: TextField(
                          controller: txtFldSearch,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.red,),
                                onPressed: () {
                                  searched = false;
                                  filteredCustomerList = myCustomerList;
                                  txtFldSearch.clear();
                                  setState(() {
                                  });
                                },
                              ),
                              hintText: 'Search by name',
                              border: InputBorder.none),
                          onChanged: (value) {
                            setState(() {
                              filteredCustomerList = myCustomerList.where((customer) {
                                return customer.userName.toLowerCase().startsWith(value.toLowerCase());
                              }).toList();
                            });
                          },
                      ),
                    ):
                    ListTile(
                      title: const Text('My Customer', style: TextStyle(fontSize: 17)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          myCustomerList.length>25?IconButton(tooltip: 'Search Customer', icon: const Icon(Icons.search), color: myTheme.primaryColor, onPressed: () async
                          {
                            setState(() {
                              searched=true;
                            });
                          }):
                          const SizedBox(),
                          IconButton(tooltip: 'Create Customer account', icon: const Icon(Icons.person_add_outlined), color: myTheme.primaryColor, onPressed: () async
                          {
                            await showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: CreateAccount(callback: callbackFunction, subUsrAccount: false, customerId: widget.userId, from: 'Dealer',),
                                ));
                          }),
                        ],
                      ),
                    ),
                    const Divider(height: 0),
                    Expanded(
                        child : filteredCustomerList.isNotEmpty? ListView.builder(
                          itemCount:filteredCustomerList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final customer = filteredCustomerList[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                                backgroundColor: Colors.transparent,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (customer.criticalAlarmCount + customer.serviceRequestCount)>0? BadgeButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return  Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.sizeOf(context).width,
                                                color: Colors.teal.shade100,
                                                height: 30,
                                                child: Center(child: Text(customer.userName)),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.sizeOf(context).width,
                                                height: MediaQuery.sizeOf(context).height-345,
                                                child: ServiceRequestsTable(userId: customer.userId),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icons.hail,
                                    badgeNumber: customer.criticalAlarmCount + customer.serviceRequestCount,
                                  ):
                                  const SizedBox(),
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      setState(() {
                                        if(value=='View'){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CustomerScreenController(
                                                customerId: customer.userId,
                                                customerName: customer.userName,
                                                mobileNo: '+${customer.countryCode}-${customer.mobileNumber}',
                                                comingFrom: 'AdminORDealer',
                                                emailId: customer.emailId, userId: widget.userId,),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'View',
                                          child: Row(
                                            children: [
                                              Icon(Icons.view_quilt_outlined, color: Colors.black),
                                              SizedBox(width: 8),
                                              Text('View Customer Dashboard'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Edit Account'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.redAccent),
                                              SizedBox(width: 8),
                                              Text('Delete Account'),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ],
                              ),
                              title: Text(customer.userName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                              subtitle: Text('+${customer.countryCode} ${customer.mobileNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                              onTap:() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: customer.userId, userName: customer.userName, userID: widget.userId, userType: 2, productStockList: productStockList, callback: callbackFunction,)),);
                              },
                            );
                          },
                        ):
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Customers not found.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                                const SizedBox(height: 5),
                                !searched? const Text('Add your customer using top of the customer adding button.', style: TextStyle(fontWeight: FontWeight.normal)):
                                const SizedBox(),
                                !searched?const Icon(Icons.person_add_outlined):const SizedBox(),
                              ],
                            ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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


class BadgeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final int badgeNumber;

  const BadgeButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.badgeNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          tooltip: 'My alarm and Service request',
          onPressed: onPressed,
          icon: Icon(icon,),
        ),
        if (badgeNumber > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
