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
import '../Dealer/DealerScreenController.dart';
import '../Forms/add_product.dart';
import '../Forms/create_account.dart';
import '../Forms/device_list.dart';

enum Calendar {all, year}
typedef CallbackFunction = void Function(String result);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key, required this.userName, required this.countryCode, required this.mobileNo, required this.userId}) : super(key: key);
  final String userName, countryCode, mobileNo;
  final int userId;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {

  Calendar calendarView = Calendar.all;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];
  late DataResponse dataResponse;


  int totalSales = 0;

  bool gettingSR = false;
  bool gettingCL = false;

  @override
  void initState() {
    super.initState();
    gettingSR = true;
    gettingCL = true;
    dataResponse = DataResponse(graph: {}, total: []);
    getProductSalesReport("All");
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


  Future<void> getProductSalesReport(String type) async {
    Map<String, Object> body = {"userId": widget.userId, "userType": 1, "type": type, "year": 2024};
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
        myCustomerList.addAll(tempList);
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
          const SizedBox(width: 10),
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
                  Row(
                    children: [
                      SizedBox(
                        height : 325,
                        width: MediaQuery.sizeOf(context).width-386,
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
                                    label: Text('${dataResponse.total![index].categoryName} - ${index+1}',
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
                      SizedBox(
                        width: 300,
                        height: 325,
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
                              ListTile(
                                title: const Text('My Dealer', style: TextStyle(fontSize: 17)),
                                trailing: IconButton(tooltip: 'Create Dealer account', icon: const Icon(Icons.person_add_outlined), color: myTheme.primaryColor, onPressed: () async
                                {
                                  await showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: CreateAccount(callback: callbackFunction, subUsrAccount: false, customerId: widget.userId, from: 'Admin',),
                                      ));
                                }),
                              ),
                              const Divider(height: 0),
                              Expanded(
                                child : myCustomerList.isNotEmpty? ListView.builder(
                                  itemCount: myCustomerList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ListTile(
                                      leading: const CircleAvatar(
                                        backgroundImage: AssetImage("assets/images/user_thumbnail.png"),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      title: Text(myCustomerList[index].userName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                      subtitle: Text('+${myCustomerList[index].countryCode} ${myCustomerList[index].mobileNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                                      onTap:() {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: myCustomerList[index].userId, userName: myCustomerList[index].userName, userID: widget.userId, userType: 1, productStockList: productStockList, callback: callbackFunction, customerType: 'Dealer',)),);
                                      },
                                      trailing: IconButton(tooltip: 'View Dashboard', onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DealerScreenController(
                                              userName: myCustomerList[index].userName,
                                              countryCode: myCustomerList[index].countryCode,
                                              mobileNo: myCustomerList[index].mobileNumber,
                                              fromLogin: false,
                                              userId: myCustomerList[index].userId,
                                              emailId: myCustomerList[index].emailId,
                                            ),
                                          ),
                                        );
                                      }, icon: const Icon(Icons.space_dashboard_outlined),),
                                    );
                                  },
                                ):
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(25.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Customers not found.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                                        SizedBox(height: 5),
                                        Text('Add your customer using top of the customer adding button.', style: TextStyle(fontWeight: FontWeight.normal)),
                                        Icon(Icons.person_add_outlined),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
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
                              trailing : TextButton.icon(
                                onPressed: () {
                                  {
                                    AlertDialog alert = AlertDialog(
                                      title: const Text("Add new stock"),
                                      content: SizedBox(
                                          width: 640,
                                          height: 300,
                                          child: AddProduct(callback: callbackFunction)
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                      ],
                                    );

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return alert;
                                      },
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("New stock"),
                              ),
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
                                    border: TableBorder.all(color: Colors.teal.shade100),
                                    headingRowHeight: 40,
                                    dataRowHeight: 40,
                                    headingRowColor: WidgetStateProperty.all<Color>(primaryColorDark.withOpacity(0.1)),
                                    columns: const [
                                      DataColumn2(
                                          label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),)),
                                          fixedWidth: 50
                                      ),
                                      DataColumn(
                                        label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                      DataColumn(
                                        label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                      DataColumn2(
                                        label: Center(child: Text('IMEI', style: TextStyle(fontWeight: FontWeight.bold),)),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Center(child: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold),)),
                                        fixedWidth: 150,
                                      ),
                                      DataColumn2(
                                        label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold),)),
                                        fixedWidth: 100,
                                      ),
                                    ],
                                    rows: List<DataRow>.generate(productStockList.length, (index) => DataRow(cells: [
                                      DataCell(Center(child: Text('${index+1}'))),
                                      DataCell(Text(productStockList[index].categoryName)),
                                      DataCell(Text(productStockList[index].model)),
                                      DataCell(Center(child: Text(productStockList[index].imeiNo))),
                                      DataCell(Center(child: Text(productStockList[index].dtOfMnf))),
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