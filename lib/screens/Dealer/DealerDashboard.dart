import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Models/DataResponse.dart';
import '../../Models/Dealer/CustomerAlarmList.dart';
import '../../Models/customer_list.dart';
import '../../Models/product_stock.dart';
import '../../constants/MyFunction.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';
import '../Customer/CustomerScreenController.dart';
import '../Customer/Dashboard/UserChatScreen.dart';
import '../Forms/create_account.dart';
import '../Forms/device_list.dart';
import 'ServiceRequestsTable.dart';

enum Calendar {all, year}
typedef CallbackFunction = void Function(String result);

class DealerDashboard extends StatefulWidget {
  const DealerDashboard({Key? key, required this.userName, required this.countryCode, required this.mobileNo, required this.userId, required this.emailId, required this.fromLogin, required this.userType}) : super(key: key);
  final String userName, countryCode, mobileNo, emailId;
  final int userId, userType;
  final bool fromLogin;

  @override
  State<DealerDashboard> createState() => _DealerDashboardState();
}

class _DealerDashboardState extends State<DealerDashboard> {

  Calendar calendarView = Calendar.all;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];
  List<CustomerListMDL> filteredCustomerList = [];
  late DataResponse dataResponse;

  bool gettingSR = false;
  bool gettingCL = false;

  int totalSales = 0;
  bool searched = false;
  TextEditingController txtFldSearch = TextEditingController();


  @override
  void initState() {
    super.initState();
    searched=false;
    gettingSR = true;
    gettingCL = true;
    dataResponse = DataResponse(graph: {}, total: []);
    getProductSalesReport('All');
    getProductStock();
    getCustomerList();

  }

  void callbackFunction(String message)
  {
    Future.delayed(const Duration(milliseconds: 500), () {
      getCustomerList();
    });
  }

  Future<void> getProductSalesReport(String type) async {
    Map<String, Object> body = {"userId": widget.userId, "userType": 2, "type": type, "year": 2024};
    final response = await HttpService().postRequest("getProductSalesReport", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data["code"] == 200) {
        try {
          totalSales=0;
          dataResponse = DataResponse.fromJson(data);
          for (int i = 0; i < dataResponse.total!.length; i++) {
            totalSales += dataResponse.total![i].totalProduct;
          }
          setState(() {
            gettingSR = false;
          });
        }catch (e) {
          print('Error parsing data response: $e');
        }
      }else{
        setState(() {
          gettingSR = false;
        });
      }
    }else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getProductStock() async
  {
    Map<String, dynamic> body = {"fromUserId": null, "toUserId": widget.userId,};
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
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        final cntList = data["data"] as List;
        List<CustomerListMDL> tempList = [];
        for (int i = 0; i < cntList.length; i++) {
          tempList.add(CustomerListMDL.fromJson(cntList[i]));
        }

        myCustomerList.addAll(tempList);
        filteredCustomerList = myCustomerList;
        tempList=[];

        setState(() {
          gettingCL = false;
        });
      }else{
        setState(() {
          gettingCL = false;
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
      body: Padding(
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
                                    backgroundColor: WidgetStateProperty.all(myTheme.primaryColor.withOpacity(0.1)),
                                    iconColor: WidgetStateProperty.all(myTheme.primaryColor),
                                  ),
                                  segments: const <ButtonSegment<Calendar>>[
                                    ButtonSegment<Calendar>(
                                      value: Calendar.all,
                                      label: SizedBox(
                                        width: 45,
                                        child: Text('All', textAlign: TextAlign.center),
                                      ),
                                      icon: Icon(Icons.calendar_view_day),
                                    ),
                                    ButtonSegment<Calendar>(
                                      value: Calendar.year,
                                      label: SizedBox(
                                        width: 45,
                                        child: Text('Year', textAlign: TextAlign.center),
                                      ),
                                      icon: Icon(Icons.calendar_view_month),
                                    ),
                                  ],
                                  selected: <Calendar>{calendarView},
                                  onSelectionChanged: (Set<Calendar> newSelection) {
                                    setState(() {
                                      calendarView = newSelection.first;
                                      String sldName = calendarView.name[0].toUpperCase() + calendarView.name.substring(1);
                                      getProductSalesReport(sldName);
                                    });
                                  },
                                ),
                                const SizedBox(width: 16,),
                                Text.rich(
                                  TextSpan(
                                    text: 'Total Sales: ', // Regular text
                                    style: const TextStyle(fontSize: 15),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '$totalSales',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: gettingSR?const Center(child: SizedBox(width:40,child: LoadingIndicator(indicatorType: Indicator.ballPulse))):
                            MySalesChart(graph: dataResponse.graph,),
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
                                avatar: CircleAvatar(backgroundColor: dataResponse.total![index].color),
                                elevation: 3,
                                shape: const LinearBorder(),
                                label: Text('${dataResponse.total![index].categoryName} - ${dataResponse.total![index].totalProduct}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                visualDensity: VisualDensity.compact,
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
              width: 330,
              height: MediaQuery.sizeOf(context).height,
              child: Card(
                elevation: 5,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                ),
                child: gettingCL?
                const Center(child: SizedBox(width:40,child: LoadingIndicator(indicatorType: Indicator.ballPulse))):
                Column(
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
                          myCustomerList.length>15?IconButton(tooltip: 'Search Customer', icon: const Icon(Icons.search), color: myTheme.primaryColor, onPressed: () async
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
                                  IconButton(
                                    tooltip: 'chart',
                                    onPressed: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserChatScreen(userId: customer.userId, dealerId: customer.userId, userName: customer.userName,),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.question_answer_rounded),
                                  ),
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
                                              customer.serviceRequestCount>0?SizedBox(
                                                width: MediaQuery.sizeOf(context).width,
                                                height: (customer.serviceRequestCount*45)+45,
                                                child: ServiceRequestsTable(userId: customer.userId),
                                              ):
                                              const SizedBox(),
                                              customer.criticalAlarmCount>0?SizedBox(
                                                width: MediaQuery.sizeOf(context).width,
                                                height: customer.criticalAlarmCount*45+40,
                                                child: DisplayCriticalAlarm(userId: customer.userId,),
                                              ):
                                              const SizedBox(),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icons.hail,
                                    badgeNumber: customer.criticalAlarmCount + customer.serviceRequestCount,
                                  ):
                                  const SizedBox(),
                                  IconButton(
                                    tooltip: 'View dashboard',
                                    onPressed: (){
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
                                    },
                                    icon: const Icon(Icons.view_quilt_rounded),
                                  ),
                                ],
                              ),
                              title: Text(customer.userName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                              subtitle: Text('+${customer.countryCode} ${customer.mobileNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                              onTap:() {
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: customer.userId, userName: customer.userName, userID: widget.userId, userType: widget.fromLogin?2:1, productStockList: productStockList, callback: callbackFunction, customerType: 'Customer',)),);
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
  const MySalesChart({Key? key, required this.graph}) : super(key: key);
  final Map<String, List<Category>>? graph;

  @override
  _MySalesChartState createState() => _MySalesChartState();
}

class _MySalesChartState extends State<MySalesChart> {
  List<BarSeries<Category, String>> seriesList = [];
  int? selectedSeriesIndex = 0;

  @override
  void didUpdateWidget(MySalesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.graph != widget.graph) {
      selectedSeriesIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {

    List<BarSeries<Category, String>> seriesList = [];

    for (var entry in widget.graph!.entries) {
      String month = entry.key;
      List<Category> categories = entry.value;

      seriesList.add(
        BarSeries<Category, String>(
          dataSource: categories,
          xValueMapper: (Category category, int index) => (index + 1).toString(),
          //xValueMapper: (Category category, _) => category.categoryName,
          yValueMapper: (Category category, _) => category.totalProduct,
          pointColorMapper: (Category category, _) => category.color,
          name: month,
          dataLabelSettings: const DataLabelSettings(isVisible: true,),
          isVisible: selectedSeriesIndex == null || selectedSeriesIndex == seriesList.length,

        ),
      );
    }

    return SfCartesianChart(
      primaryYAxis: NumericAxis(),
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(
          color: Colors.black45,
        ),
      ),
      enableAxisAnimation: true,
      legend: const Legend(
        isVisible: true,
        toggleSeriesVisibility: false,
      ),
      series: seriesList,
      tooltipBehavior: TooltipBehavior(enable: false),
      isTransposed: true,
      onLegendTapped: (LegendTapArgs args) {
        setState(() {
          if (selectedSeriesIndex == args.seriesIndex) {
            selectedSeriesIndex = null;
          } else {
            selectedSeriesIndex = args.seriesIndex;
          }
        });
      },
    );

  }
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

class DisplayCriticalAlarm extends StatefulWidget{
  const DisplayCriticalAlarm({super.key, required this.userId});
  final int userId;

  @override
  State<DisplayCriticalAlarm> createState() => _DisplayCriticalAlarmState();
}

class _DisplayCriticalAlarmState extends State<DisplayCriticalAlarm> {

  List<CriticalAlarmFinal> alarms = [];

  @override
  void initState() {
    super.initState();
    getCriticalAlarmList();
  }


  Future<void> getCriticalAlarmList() async {
    Map<String, Object> body = {"userId" : widget.userId};
    final response = await HttpService().postRequest("getUserCriticalAlarmForDealer", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        List<AlarmGroupData> alarmGroupDataList = List<AlarmGroupData>.from(jsonMap['data'].map((item) => AlarmGroupData.fromJson(item)));
        alarms.clear();
        for(int i=0; i<alarmGroupDataList.length; i++){
          for(int j=0; j<alarmGroupDataList[i].master.length; j++){
            for(int k=0; k<alarmGroupDataList[i].master[j].criticalAlarm.length; k++){
              String msg = getAlarmMessage(alarmGroupDataList[i].master[j].criticalAlarm[k].alarmType);
              alarms.add(CriticalAlarmFinal(fmName: alarmGroupDataList[i].groupName, dvcName: alarmGroupDataList[i].master[j].deviceName, location: alarmGroupDataList[i].master[j].criticalAlarm[k].location, message: msg));
            }
          }
        }
        setState((){
        });
      }
    } else {
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      dataRowHeight: 45.0,
      headingRowHeight: 40.0,
      headingRowColor: WidgetStateProperty.all<Color>(Colors.yellow.shade50),
      columns:  const [
        DataColumn2(
          label: Text('Farm', style: TextStyle(fontSize: 13),),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Device', style: TextStyle(fontSize: 13),),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('Location', style: TextStyle(fontSize: 13)),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('Alarm Message', style: TextStyle(fontSize: 13)),
          size: ColumnSize.L,
        ),
      ],
      rows: List<DataRow>.generate(alarms.length, (index) {

        return DataRow(cells: [
          DataCell(Text(alarms[index].fmName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.normal),)),
          DataCell(Text(alarms[index].dvcName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.normal),)),
          DataCell(Text(alarms[index].location, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.normal),)),
          DataCell(Text(alarms[index].message, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.normal),)),
        ]);
      }),
    );
  }
}
