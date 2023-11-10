import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../Models/customer_list.dart';
import '../Models/product_stock.dart';
import '../constants/http_service.dart';
import '../constants/theme.dart';
import '../state_management/mqtt_message_provider.dart';
import 'Forms/add_product.dart';
import 'Forms/device_list.dart';

enum Calendar { day, week, month, year }
typedef CallbackFunction = void Function(String result);

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  State<HomePage> createState() => HomePageState();

}

class HomePageState extends State<HomePage>
{
  Calendar calendarView = Calendar.day;
  List<ProductStockModel> productStockList = <ProductStockModel>[];
  List<CustomerListMDL> myCustomerList = <CustomerListMDL>[];

  int userType = 0;
  int userId = 0;
  bool isHovering = false;

  void callbackFunction(String message)
  {
    if(message=='reloadStock'){
      getProductStock();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    print("dashbard call");
  }

  Future<void> getUserInfo() async
  {
    final prefs = await SharedPreferences.getInstance();
    userType = int.parse(prefs.getString('userType') ?? "");
    userId = int.parse(prefs.getString('userId') ?? "");

    getProductStock();
    getCustomerList();
  }

  Future<void> getProductStock() async
  {
    print('call back');
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
        for (int i=0; i < cntList.length; i++) {
          productStockList.add(ProductStockModel.fromJson(cntList[i]));
        }
      }

      setState(() {
      });

    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getCustomerList() async
  {
    Map<String, Object> body = {"userType" : userType, "userId" : userId};
    print(body);
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

      setState(() {
      });

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

    return Container(
      color: Colors.blueGrey.shade50,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.blueGrey.shade50,
              child: Row(
                children: [
                  Flexible(
                    flex :1,
                    fit: FlexFit.loose,
                    child: Container(
                      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 0),
                      child: Column(
                        children: [
                          Consumer<MessageProvider>(
                            builder: (context, myDataModel, child) {
                              if (myDataModel.hasFetchedData) {
                                myDataModel.setHasFetchedData(); // Set a flag to avoid unnecessary calls
                                getCustomerList();
                              }
                              return const SizedBox(height: 0,);
                            },
                          ),
                          SizedBox(
                            height: height-70,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        )
                                    ),
                                    child: ListTile(
                                      title: const Text("Analytics Overview", style: TextStyle(fontSize: 20, color: Colors.black),),
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
                                  ),
                                  SizedBox(height: 2,child: Container(color: Colors.grey.shade200,)),
                                  Container(
                                    height: 350,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        /*const SizedBox(
                                          width: 170,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text("ORO GEM", style: TextStyle(fontSize: 12),),
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.blue,
                                                  maxRadius: 5,
                                                ),
                                              ),
                                              ListTile(
                                                title: Text("ORO Smart RTU", style: TextStyle(fontSize: 12),),
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.green,
                                                  maxRadius: 5,
                                                ),
                                              ),
                                              ListTile(
                                                title: Text("ORO RTU", style: TextStyle(fontSize: 12),),
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.orange,
                                                  maxRadius: 5,
                                                ),
                                              ),
                                              ListTile(
                                                title: Text("ORO Switch", style: TextStyle(fontSize: 12),),
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.pink,
                                                  maxRadius: 5,
                                                ),
                                              ),
                                              ListTile(
                                                title: Text("ORO Spot", style: TextStyle(fontSize: 12),),
                                                leading: CircleAvatar(
                                                  backgroundColor: Colors.deepPurpleAccent,
                                                  maxRadius: 5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),*/
                                        const Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 50,
                                                  child: Row(children: [
                                                    SizedBox(width: 20,),
                                                    CircleAvatar(
                                                      backgroundColor: Colors.blue,
                                                      maxRadius: 5,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text('ORO GEM'),
                                                    SizedBox(width: 15,),

                                                    CircleAvatar(
                                                      backgroundColor: Colors.green,
                                                      maxRadius: 5,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text('ORO Smart RTU'),
                                                    SizedBox(width: 25,),

                                                    CircleAvatar(
                                                      backgroundColor: Colors.orange,
                                                      maxRadius: 5,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text('ORO RTU'),
                                                    SizedBox(width: 25,),

                                                    CircleAvatar(
                                                      backgroundColor: Colors.pink,
                                                      maxRadius: 5,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text('ORO Switch'),
                                                    SizedBox(width: 25,),

                                                    CircleAvatar(
                                                      backgroundColor: Colors.deepPurpleAccent,
                                                      maxRadius: 5,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text('ORO Spot'),
                                                    SizedBox(width: 25,),
                                                  ]),
                                                ),
                                                MySalesChart(),
                                              ],
                                            ),
                                        ),
                                        SizedBox(
                                          width: 400,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            padding: const EdgeInsets.only(top: 30, bottom: 10, right: 5, left: 5),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: GridView.count(
                                                    childAspectRatio : (1.2/1.0),
                                                    crossAxisCount: width > 1050? 3 : 3,
                                                    children: List.generate(5, (index) {
                                                      if(index==0){
                                                        return Container(
                                                          padding: const EdgeInsets.all(8.0),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(width: 5.0, color: Colors.blue.shade200),
                                                            ),
                                                          ),
                                                          child: const Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('ORO GEM'),
                                                              Text('2510', style: TextStyle(fontSize: 33, color: Colors.black, fontWeight: FontWeight.bold),),
                                                              Text('In Stock : 10'),
                                                            ],
                                                          ),
                                                        );
                                                      }else if(index==1){
                                                        return Container(
                                                          padding: const EdgeInsets.all(8.0),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(width: 5.0, color: Colors.green.shade200),
                                                            ),
                                                          ),
                                                          child: const Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('ORO Smart RTU'),
                                                              Text('2510', style: TextStyle(fontSize: 33, color: Colors.black, fontWeight: FontWeight.bold),),
                                                              Text('In Stock : 10'),
                                                            ],
                                                          ),
                                                        );
                                                      }else if(index==2){
                                                        return Container(
                                                          padding: const EdgeInsets.all(8.0),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(width: 5.0, color: Colors.orange.shade200),
                                                            ),
                                                          ),
                                                          child: const Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('ORO RTU'),
                                                              Text('2510', style: TextStyle(fontSize: 33, color: Colors.black, fontWeight: FontWeight.bold),),
                                                              Text('In Stock : 10'),
                                                            ],
                                                          ),
                                                        );
                                                      }else if(index==3){
                                                        return Container(
                                                          padding: const EdgeInsets.all(8.0),
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              left: BorderSide(width: 5.0, color: Colors.pink.shade200),
                                                            ),
                                                          ),
                                                          child: const Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('ORO Switch'),
                                                              Text('2510', style: TextStyle(fontSize: 33, color: Colors.black, fontWeight: FontWeight.bold),),
                                                              Text('In Stock : 10'),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                      return Container(
                                                        padding: const EdgeInsets.all(8.0),
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            left: BorderSide(width: 5.0, color: Colors.deepPurple.shade200),
                                                          ),
                                                        ),
                                                        child: const Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('ORO Sport'),
                                                            Text('2510', style: TextStyle(fontSize: 33, color: Colors.black, fontWeight: FontWeight.bold),),
                                                            Text('In Stock : 10'),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10,child: Container(color: Colors.grey.shade200,)),
                                  Container(
                                    height: 350,
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
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
                                                  title: Text('Product Stock(${productStockList.length})', style: TextStyle(fontSize: 20, color: Colors.black),),
                                                  trailing : ElevatedButton.icon(
                                                    onPressed: () async {
                                                      await showDialog<void>(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                            content: AddProduct(callback: callbackFunction)),);
                                                    },
                                                    icon: const Icon(Icons.add_circle),
                                                    label: const Text('New stock'),
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
                                                  child: DataTable2(
                                                      columnSpacing: 12,
                                                      horizontalMargin: 12,
                                                      minWidth: 580,
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
                                                          fixedWidth: 90,
                                                        ),
                                                        DataColumn2(
                                                          label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold),)),
                                                          fixedWidth: 100,
                                                        ),
                                                      ],
                                                      rows: List<DataRow>.generate(productStockList.length, (index) => DataRow(cells: [
                                                        DataCell(Text('${index+1}')),
                                                        DataCell(Row(children: [const CircleAvatar(radius: 17, child: Icon(Icons.gas_meter_outlined),), SizedBox(width: 10,), Text(productStockList[index].categoryName)],)),
                                                        DataCell(Text(productStockList[index].model)),
                                                        DataCell(Text('${productStockList[index].imeiNo}')),
                                                        DataCell(Text(productStockList[index].dtOfMnf)),
                                                        DataCell(Center(child: Text('${productStockList[index].warranty}'))),
                                                      ]))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: width*0.01, child: Container(color: Colors.grey.shade200,)),
                                        SizedBox(
                                          width: 300,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            padding: const EdgeInsets.all(5),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 44,
                                                  color: Colors.white,
                                                  child: const ListTile(title: Text('Members', style: TextStyle(fontSize: 20, color: Colors.black),),trailing: Text('View all', style: TextStyle(color: Colors.blue),),),
                                                ),
                                                Expanded(child: GridView.count(
                                                  childAspectRatio : 1.0,
                                                  crossAxisCount: 2,
                                                  children: List.generate(myCustomerList.length, (index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  DeviceList(customerID: myCustomerList[index].userId, userName: myCustomerList[index].userName, userID: userId, userType: userType, productStockList: productStockList, callback: callbackFunction,)),);
                                                      }, // Handle your callback
                                                      child: Container(
                                                        margin: const EdgeInsets.all(5),
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.all(Radius.circular(10.0),),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(height: 10,),
                                                            const CircleAvatar(
                                                              radius: 30,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                children: [
                                                                  const SizedBox(height: 5,),
                                                                  Text(myCustomerList[index].userName),
                                                                  const SizedBox(height: 5,),
                                                                  Text('+${myCustomerList[index].countryCode} ${myCustomerList[index].mobileNumber}'),
                                                                  //Text(myCustomerList[index].),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                )),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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


