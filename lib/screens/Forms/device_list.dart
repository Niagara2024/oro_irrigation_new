import 'dart:convert';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../../Models/ProductListWithNode.dart';
import '../../Models/customer_list.dart';
import '../../Models/customer_product.dart';
import '../../Models/interface_model.dart';
import '../../Models/node_model.dart';
import '../../Models/product_stock.dart';
import '../../constants/MQTTManager.dart';
import '../../constants/http_service.dart';
import '../Config/product_limit.dart';
import '../Customer/ConfigDashboard/configMakerView.dart';

enum MasterController {gem1, gem2, gem3, gem4, gem5, gem6, gem7, gem8, gem9, gem10,}

class DeviceList extends StatefulWidget {
  final int customerID, userID, userType;
  final String userName;
  final List<ProductStockModel> productStockList;
  final void Function(String) callback;
  const DeviceList({super.key, required this.customerID, required this.userName, required this.userID, required this.userType, required this.productStockList, required this.callback});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> with SingleTickerProviderStateMixin
{
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> productSalesList = {};
  bool checkboxValue = false;

  List<CustomerProductModel> customerProductList = <CustomerProductModel>[];
  List<ProductStockModel> myMasterControllerList = <ProductStockModel>[];

  List<ProductListWithNode> customerSiteList = <ProductListWithNode>[];
  List<ProductStockModel> nodeStockList = <ProductStockModel>[];
  List<List<NodeModel>> usedNodeList = <List<NodeModel>>[];

  late  List<Object> _configTabs = [];
  late final TabController _tabCont;

  int selectedRadioTile = 0;
  final ValueNotifier<MasterController> _selectedItem = ValueNotifier<MasterController>(MasterController.gem1);
  final TextEditingController _textFieldSiteName = TextEditingController();
  final TextEditingController _textFieldSiteDisc = TextEditingController();

  final List<InterfaceModel> interfaceType = <InterfaceModel>[];
  List<int> selectedProduct = [];

  bool checkboxValueNode = false;
  final List<String> _interfaceInterval = ['0 sec', '5 sec', '10 sec', '20 sec', '30 sec', '45 sec','1 min','5 min','10 min','30 min','1 hr']; // Option 2
  List<CustomerListMDL> myCustomerChildList = <CustomerListMDL>[];
  List<int> nodeStockSelection = [];
  int currentSite = 0;
  bool visibleLoading = false;


  @override
  void initState() {
    super.initState();

    List<Object> configList = (widget.userType == 1) ? ['Product List'] : ['Product List', 'Site Config'];
    _configTabs = List.generate(configList.length, (index) => configList[index]);
    _tabCont = TabController(length: configList.length, vsync: this);
    _tabCont.addListener(() {
      setState(() {
        int tabIndex = _tabCont.index;
      });
    });

    selectedRadioTile = 0;
    getCustomerType();

    selectedProduct.clear();
    for(int i=0; i<widget.productStockList.length; i++){
      selectedProduct.add(0);
    }
  }

  @override
  void dispose() {
    _tabCont.dispose();
    super.dispose();
  }

  void resetPopop(){
    checkboxValue = false;
  }

  void removeProductStockById(int productId) {
    widget.productStockList.removeWhere((productStock) => productStock.productId == productId);
  }

  Future<void> getCustomerType() async
  {
    getMyAllProduct();
    getMasterProduct();
    getNodeStockList();
    getCustomerSite();
    getNodeInterfaceTypes();
  }

  Future<void> getMyAllProduct() async
  {
    indicatorViewShow();
    final body = widget.userType == 1 ? {"fromUserId": widget.userID, "toUserId": widget.customerID ,"set":1, "limit":100} : {"fromUserId": widget.userID, "toUserId": widget.customerID, "set":1, "limit":100};
    final response = await HttpService().postRequest("getCustomerProduct", body);
    if (response.statusCode == 200)
    {
      customerProductList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"]['product'] as List;
        for (int i=0; i < cntList.length; i++) {
          customerProductList.add(CustomerProductModel.fromJson(cntList[i]));
        }
        indicatorViewHide();
      }
    }
    else{
      indicatorViewHide();
    }
  }

  Future<void> getMasterProduct() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getMasterControllerStock", body);
    if (response.statusCode == 200)
    {
      myMasterControllerList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          myMasterControllerList.add(ProductStockModel.fromJson(cntList[i]));
        }
      }

      indicatorViewHide();

    }
    else{
      indicatorViewHide();
    }
  }

  Future<void> getCustomerSite() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getUserDeviceList", body);
    if (response.statusCode == 200)
    {
      customerSiteList.clear();
      usedNodeList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          customerSiteList.add(ProductListWithNode.fromJson(cntList[i]));
          try {
            MQTTManager().subscribeToTopic('FirmwareToApp/${customerSiteList[i].deviceId}'); // This won't be executed due to the exception
          } catch (e, stackTrace) {
            print('Error: $e');
            print('Stack Trace: $stackTrace');
          }

          final nodeList = cntList[i]['nodeList'] as List;
          usedNodeList.add([]);
          for (int j=0; j < nodeList.length; j++) {
            usedNodeList[i].add(NodeModel.fromJson(nodeList[j]));
          }
        }
      }

      indicatorViewHide();
    }
    else{
      indicatorViewHide();
    }
  }

  Future<void> getNodeStockList() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getNodeDeviceStock", body);
    if (response.statusCode == 200)
    {
      nodeStockList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          nodeStockList.add(ProductStockModel.fromJson(cntList[i]));
        }
      }
      indicatorViewHide();
    }
    else{
      indicatorViewHide();
    }
  }

  Future<void> getNodeInterfaceTypes() async
  {
    Map<String, Object> body = {"active" : '1'};
    final response = await HttpService().postRequest("getInterfaceTypeByActive", body);
    if (response.statusCode == 200)
    {
      interfaceType.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          interfaceType.add(InterfaceModel.fromJson(cntList[i]));
        }
      }
      indicatorViewHide();

    }
    else{
      indicatorViewHide();
    }
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
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          visibleLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        title: Text(widget.userName),
        actions: [
        PopupMenuButton(
          tooltip: _tabCont.index==0 ?'Add Product' : 'Create new site',
          child: const Icon(Icons.add, color: Colors.white,),
          onCanceled: () {
            checkboxValue = false;
          },
          itemBuilder: (context) {
            return _tabCont.index==0 ?
            List.generate(widget.productStockList.length+1 ,(index) {
              if(widget.productStockList.isEmpty){
                return const PopupMenuItem(
                  child: Text('No stock available to add in the site'),
                );
              }
              else if(widget.productStockList.length == index){
                return PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MaterialButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: const Text('CANCEL'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      ),
                      const SizedBox(width: 5,),
                      MaterialButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: const Text('ADD'),
                        onPressed: () async {
                          List<dynamic> salesList = [];
                          for(int i=0; i<selectedProduct.length; i++)
                          {
                            if(selectedProduct[i]==1){
                              Map<String, String> myMap = {"productId": widget.productStockList[i].productId.toString(), 'categoryName': widget.productStockList[i].categoryName};
                              salesList.add(myMap);
                            }
                          }

                          if(salesList.isNotEmpty)
                          {
                            Map<String, dynamic> body = {
                              "fromUserId": widget.userID,
                              "toUserId": widget.customerID,
                              "createUser": widget.userID,
                              "products": salesList,
                            };

                            final response = await HttpService().postRequest("transferProduct", body);
                            if(response.statusCode == 200)
                            {
                              var data = jsonDecode(response.body);
                              if(data["code"]==200)
                              {
                                checkboxValue = false;
                                for(var sl in salesList){
                                  removeProductStockById(int.parse(sl['productId']));
                                }

                                setState(() {
                                  salesList.clear();
                                  checkboxValue=false;
                                  getNodeStockList();
                                  widget.callback('reloadStock');
                                });

                                if(mounted){
                                  Navigator.pop(context);
                                }

                                getMyAllProduct();
                                getMasterProduct();
                              }
                              else{
                                //_showSnackBar(data["message"]);
                                //_showAlertDialog('Warning', data["message"]);
                              }
                            }
                          }

                        },
                      ),
                    ],
                  ),
                );
              }

              return PopupMenuItem(
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return CheckboxListTile(
                      title: Text(widget.productStockList[index].categoryName),
                      subtitle: Text(widget.productStockList[index].imeiNo),
                      value: checkboxValue,
                      onChanged:(bool? value) { setState(() {
                        checkboxValue = value!;
                        if(value){
                          selectedProduct[index] = 1;
                        }else{
                          selectedProduct[index] = 0;
                        }
                      });},
                    );
                  },
                ),
              );
            },) :
            List.generate(myMasterControllerList.length+1 ,(index) {
              if(myMasterControllerList.isEmpty){
                return const PopupMenuItem(
                  child: Text('No master controller available to create site'),
                );
              }
              else if(myMasterControllerList.length == index){
                return PopupMenuItem(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: const Text('CANCEL'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      ),
                      MaterialButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: const Text('CREATE'),
                        onPressed: () async {
                          Navigator.pop(context);
                          _displayCustomerSiteDialog(context, myMasterControllerList[selectedRadioTile].categoryName,
                              myMasterControllerList[selectedRadioTile].model,
                              myMasterControllerList[selectedRadioTile].imeiNo.toString());
                        },
                      ),
                    ],
                  ),
                );
              }
              return PopupMenuItem(
                value: index,
                child: AnimatedBuilder(
                    animation: _selectedItem,
                    builder: (context, child) {
                      return RadioListTile(
                        value: MasterController.values[index],
                        groupValue: _selectedItem.value,
                        title: child,  onChanged: (value) {
                          _selectedItem.value = value!;
                          selectedRadioTile = value.index;
                        },
                        subtitle: Text(myMasterControllerList[index].model),
                      );
                    },
                    child: Text(myMasterControllerList[index].categoryName)

                ),
              );
            },
            );
          },
        ),
        const SizedBox(width: 20,),
      ],
        bottom: TabBar(
          controller: _tabCont,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          tabs: [
            ..._configTabs.map((label) => Tab(
              child: Text(label.toString(),),
            ),
            ),
          ],
        ),
      ),
      body: visibleLoading? Visibility(
        visible: visibleLoading,
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 25, 0, MediaQuery.sizeOf(context).width/2 - 25, 0),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ):
      TabBarView(
        controller: _tabCont,
        children: [
          displayProductList(),
          displaySiteConfigPage(),
        ],
      ),
      /*body: TabBarView(
        controller: _tabCont,
        children: [
          ..._configTabs.map((label) =>
              CustomerSalesPage(
              label: label.toString(), customerID: widget.customerID, customerProductList: customerProductList, customerSiteList: customerSiteList, nodeStockList: nodeStockList,
                usedNodeList: usedNodeList, interfaceType: interfaceType, userID : widget.userID, callBackFunction: callBackFunction, getCustomerSite : getCustomerSite, userType: widget.userType, userName: widget.userName,
            ),
          ),
        ],
      ),*/
    );
  }

  Future<void> _displayCustomerSiteDialog(BuildContext context, String ctrlName, String ctrlModel, String ctrlIemi) async {
    return showDialog(context: context,  builder: (context) {
          return AlertDialog(
            title: const Text('Create Customer Site'),
            content: SizedBox(
              height: 223,
              child : Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const CircleAvatar(),
                      title: Text(ctrlName),
                      subtitle: Text('$ctrlModel\n$ctrlIemi'),
                    ),
                    TextFormField(
                      controller: _textFieldSiteName,
                      decoration: const InputDecoration(hintText: "Enter your site name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _textFieldSiteDisc,
                      decoration: const InputDecoration(hintText: "Description"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('CREATE'),
                onPressed: () async {

                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> body = {
                      "userId": widget.customerID,
                      "dealerId": widget.userID,
                      "productId": myMasterControllerList[selectedRadioTile].productId,
                      "categoryName": myMasterControllerList[selectedRadioTile].categoryName,
                      "createUser": widget.userID,
                      "groupName": _textFieldSiteName.text,
                    };
                    print(body);
                    final response = await HttpService().postRequest("createUserGroupAndDeviceList", body);
                    print(response.body);
                    if(response.statusCode == 200)
                    {
                      var data = jsonDecode(response.body);
                      if(data["code"]==200)
                      {
                        getCustomerSite();
                        getMasterProduct();
                        getNodeStockList();
                        if(mounted){
                          Navigator.pop(context);
                        }

                      }
                      else{
                        //_showSnackBar(data["message"]);
                        //_showAlertDialog('Warning', data["message"]);
                      }
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  Widget displayProductList() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 580,
          columns: [
            const DataColumn2(
                label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),),
                fixedWidth: 100
            ),
            const DataColumn2(
              label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold),),
              size: ColumnSize.M,
            ),
            const DataColumn2(
              label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold),),
              size: ColumnSize.M,
            ),
            const DataColumn2(
              label: Text('IMEI', style: TextStyle(fontWeight: FontWeight.bold),),
              size: ColumnSize.M,
            ),
            const DataColumn2(
              label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            const DataColumn2(
              label: Text('Modify Date', style: TextStyle(fontWeight: FontWeight.bold),),
              fixedWidth: 100,
            ),
            DataColumn2(
              label: const Text('Action', style: TextStyle(fontWeight: FontWeight.bold),),
              fixedWidth: widget.userType==2 ? 70 : 0,
            ),
          ],
          rows: List<DataRow>.generate(customerProductList.length, (index) => DataRow(cells: [
            DataCell(Text('${index+1}')),
            DataCell(Row(children: [ CircleAvatar(
              radius: 17,
              backgroundColor: Colors.transparent,
              backgroundImage: customerProductList[index].categoryName == 'ORO SWITCH'
                  || customerProductList[index].categoryName == 'OROSENSE'?
              AssetImage('assets/images/oro_switch.png'):
              customerProductList[index].categoryName == 'ORO LEVEL'?
              AssetImage('assets/images/oro_sense.png'):
              customerProductList[index].categoryName == 'OROGEM'?
              AssetImage('assets/images/oro_gem.png'): AssetImage('assets/images/oro_rtu.png'),
            ), const SizedBox(width: 10,), Text(customerProductList[index].categoryName)],)),
            DataCell(Text(customerProductList[index].model)),
            DataCell(Text(customerProductList[index].deviceId)),
            //DataCell(widget.userType==2 ? Text(widget.customerProductList[index].siteName) : widget.customerProductList[index].buyer == widget.userName? const Text('-') : Text(widget.customerProductList[index].buyer)),
            DataCell(
                Center(
                  child: widget.userType == 1? Row(
                    children: [
                      CircleAvatar(radius: 5,
                        backgroundColor:
                        customerProductList[index].productStatus==1? Colors.pink:
                        customerProductList[index].productStatus==2? Colors.blue:
                        customerProductList[index].productStatus==3? Colors.purple:
                        customerProductList[index].productStatus==4? Colors.yellow:
                        customerProductList[index].productStatus==5? Colors.deepOrangeAccent:
                        Colors.green,
                      ),
                      const SizedBox(width: 5,),
                      customerProductList[index].productStatus==1? const Text('In-Stock'):
                      customerProductList[index].productStatus==2? const Text('Stock'):
                      customerProductList[index].productStatus==3? const Text('Sold-Out'):
                      customerProductList[index].productStatus==4? const Text('Pending'):
                      customerProductList[index].productStatus==5? const Text('Installed'):
                      const Text('Active'),
                    ],
                  ) :
                  widget.userType == 2? Row(
                    children: [
                      CircleAvatar(radius: 5,
                        backgroundColor:
                        customerProductList[index].productStatus==2? Colors.pink:
                        customerProductList[index].productStatus==3? Colors.blue:
                        customerProductList[index].productStatus==4? Colors.yellow:
                        customerProductList[index].productStatus==5? Colors.deepOrangeAccent:
                        Colors.green,
                      ),
                      const SizedBox(width: 5,),
                      customerProductList[index].productStatus==2? const Text('In-Stock'):
                      customerProductList[index].productStatus==3? const Text('Stock'):
                      customerProductList[index].productStatus==4? const Text('Pending'):
                      customerProductList[index].productStatus==5? const Text('Installed'):
                      const Text('Active'),
                    ],
                  ) :
                  Row(
                    children: [
                      CircleAvatar(radius: 5,
                        backgroundColor:
                        customerProductList[index].productStatus==3? Colors.pink:
                        customerProductList[index].productStatus==4? Colors.yellow:
                        customerProductList[index].productStatus==5? Colors.deepOrangeAccent:
                        Colors.green,
                      ),
                      const SizedBox(width: 5,),
                      customerProductList[index].productStatus==3? const Text('In-Stock'):
                      customerProductList[index].productStatus==4? const Text('Pending'):
                      customerProductList[index].productStatus==5? const Text('Installed'):
                      const Text('Active'),
                    ],
                  ),
                )
            ),
            DataCell(Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(customerProductList[index].modifyDate)))),
            widget.userType==2 ? DataCell(Center(child: IconButton(tooltip:'Delete product',onPressed: () {
              print('IconButton click');
            }, icon: const Icon(Icons.delete_outline, color:  Colors.red,),))) : DataCell.empty,
          ]))),
    );
  }

  DefaultTabController displaySiteConfigPage() {
    return DefaultTabController(
      length: customerSiteList.length, // Number of tabs
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  indicatorColor: myTheme.primaryColor,
                  isScrollable: true,
                  tabs: [
                    for (var i = 0; i < customerSiteList.length; i++)
                      Tab(text: customerSiteList[i].groupName,),
                  ],
                  onTap: (index) {
                    currentSite = index;
                  },
                ),
              ),
              PopupMenuButton(
                elevation: 10,
                tooltip: 'Add node list',
                child: Center(child: Icon(Icons.add, color: myTheme.primaryColor,)),
                onOpened: (){
                  nodeStockSelection.clear();
                  for(int i=0; i< nodeStockList.length; i++){
                    nodeStockSelection.add(0);
                  }
                },
                onCanceled: () {
                  checkboxValueNode = false;
                },
                itemBuilder: (context) {
                  return List.generate(nodeStockList.length+1 ,(nodeIndex) {
                    if(nodeStockList.isEmpty){
                      return const PopupMenuItem(
                        child: Text('No node available to add in this site'),
                      );
                    }
                    else if(nodeStockList.length == nodeIndex){
                      return PopupMenuItem(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            MaterialButton(
                              color: Colors.red,
                              textColor: Colors.white,
                              child: const Text('CANCEL'),
                              onPressed: () {
                                setState(() {
                                  checkboxValueNode = false;
                                  Navigator.pop(context);
                                });
                              },
                            ),
                            MaterialButton(
                              color: Colors.green,
                              textColor: Colors.white,
                              child: const Text('ADD'),
                              onPressed: () async
                              {
                                generateRFNumber();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return PopupMenuItem(
                      child: StatefulBuilder(
                        builder: (BuildContext context, void Function(void Function()) setState) {
                          return CheckboxListTile(
                            title: Text(nodeStockList[nodeIndex].categoryName),
                            subtitle: Text(nodeStockList[nodeIndex].imeiNo),
                            value: checkboxValueNode,
                            onChanged:(bool? value) { setState(() {
                              checkboxValueNode = value!;
                              if(value){
                                nodeStockSelection[nodeIndex] = 1;
                              }else{
                                nodeStockSelection[nodeIndex] = 0;
                              }
                            });},
                          );
                        },
                      ),
                    );
                  });
                },
              ),
              const SizedBox(width: 10,),
            ],
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            height: MediaQuery.sizeOf(context).height-160,
            child: TabBarView(
              children: [
                for (int siteIndex = 0; siteIndex < customerSiteList.length; siteIndex++)
                  Column(
                    children: [
                      ListTile(
                        leading: Image.asset('assets/images/oro_gem.png'),
                        title: Text(customerSiteList[siteIndex].categoryName),
                        subtitle: Text(customerSiteList[siteIndex].deviceId.toString()),
                        trailing: usedNodeList[siteIndex].isNotEmpty? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                tooltip : 'view config overview',
                                onPressed: () async {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConfigMakerView(userID: widget.userID, siteID: customerSiteList[siteIndex].controllerId, customerID: widget.customerID)),);
                                },
                                icon: const Icon(Icons.view_list_outlined)),// Replace icon1 with your first icon
                            IconButton(
                                tooltip : 'Product Limit',
                                onPressed: () async {
                                  int outputCnt = 0;
                                  int inputCnt = 0;
                                  List<int> catId = [];
                                  for(int i=0; i<usedNodeList[siteIndex].length; i++){
                                    outputCnt = outputCnt + usedNodeList[siteIndex][i].outputCount;
                                    inputCnt = inputCnt + usedNodeList[siteIndex][i].inputCount;
                                    catId.add(usedNodeList[siteIndex][i].categoryId);
                                  }
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  ProductLimits(userID: widget.userID, customerID: widget.customerID, userType: 2, outputCount: outputCnt, siteName: customerSiteList[siteIndex].groupName, controllerId: customerSiteList[siteIndex].controllerId, deviceId: customerSiteList[siteIndex].deviceId, inputCount: inputCnt, myCatIds: catId)),);
                                },
                                icon: const Icon(Icons.list_alt)),
                            IconButton(
                                tooltip : 'Send to target',
                                onPressed: () async {
                                  List<dynamic> updatedInterface = [];
                                  for(int i=0; i<usedNodeList[siteIndex].length; i++){
                                    Map<String, dynamic> myMap = {"serialNumber": usedNodeList[siteIndex][i].serialNumber, "productId": usedNodeList[siteIndex][i].productId,
                                      'interfaceTypeId': usedNodeList[siteIndex][i].interfaceTypeId, 'interfaceInterval': usedNodeList[siteIndex][i].interfaceInterval};
                                    updatedInterface.add(myMap);
                                  }
                                  Map<String, dynamic> body = {
                                    "userId": widget.customerID,
                                    "products": updatedInterface,
                                    "modifyUser": widget.userID,
                                  };

                                  List<dynamic> payLoad = [];
                                  payLoad.add('${0},${customerSiteList[siteIndex].categoryName},${'1'}, ${'1'}, ${customerSiteList[siteIndex].deviceId.toString()},'
                                      '${'0'},${"00:00:30"};');

                                  for(int i=0; i<usedNodeList[siteIndex].length; i++){
                                    //String paddedNumber = widget.usedNodeList[siteIndex][i].deviceId.toString().padLeft(20, '0');
                                    String formattedTime = convertToHHmmss(usedNodeList[siteIndex][i].interfaceInterval);
                                    payLoad.add('${usedNodeList[siteIndex][i].serialNumber},${usedNodeList[siteIndex][i].categoryName},${usedNodeList[siteIndex][i].categoryId},'
                                        '${usedNodeList[siteIndex][i].referenceNumber},${usedNodeList[siteIndex][i].deviceId},'
                                        '${usedNodeList[siteIndex][i].interfaceTypeId},$formattedTime;');
                                  }

                                  String inputString = payLoad.toString();
                                  List<String> parts = inputString.split(';');
                                  String resultString = parts.map((part) {return part.replaceFirst(',', '');
                                  }).join(';');

                                  String resultStringFinal = resultString.replaceAll('[', '').replaceAll(']', '');
                                  String modifiedString = resultStringFinal.replaceAll(', ', ',');
                                  String modifiedStringFinal = '${modifiedString.substring(0, 1)},${modifiedString.substring(1)}';
                                  String stringWithoutSpace = modifiedStringFinal.replaceAll('; ', ';');
                                  //print(stringWithoutSpace);

                                  String payLoadFinal = jsonEncode({
                                    "100": [
                                      {"101": stringWithoutSpace},
                                    ]
                                  });

                                  //print(payLoadFinal);

                                  //publish payload to mqtt
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${customerSiteList[siteIndex].deviceId}');

                                  final response = await HttpService().putRequest("updateUserDeviceNodeList", body);
                                  //print(body);
                                  if(response.statusCode == 200)
                                  {
                                    var data = jsonDecode(response.body);
                                    if(data["code"]==200)
                                    {
                                      updatedInterface.clear();
                                      _showSnackBar(data["message"]);
                                    }
                                    else{
                                      _showSnackBar(data["message"]);
                                    }
                                  }
                                },
                                icon: const Icon(Icons.send)),
                            IconButton(
                                tooltip : 'Clear serial',
                                onPressed: () async {
                                  String payLoadFinal = jsonEncode({
                                    "2400": [{"2401": ''},]
                                  });
                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${customerSiteList[siteIndex].deviceId}');
                                },
                                icon: const Icon(Icons.cleaning_services_rounded)),
                          ],
                        ) : null,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 1000,
                            dataRowHeight: 40.0,
                            headingRowHeight: 35,
                            headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                            columns: const [
                              DataColumn2(
                                  label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                  fixedWidth: 70
                              ),
                              DataColumn2(
                                  label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                  label: Text('Model Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                  size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Text('Device Id', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                size: ColumnSize.M
                              ),
                              DataColumn2(
                                label: Center(child: Text('Interface', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                fixedWidth: 120,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Interval', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                fixedWidth: 120,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                fixedWidth: 70,
                              ),
                            ],
                            rows: usedNodeList[siteIndex].map((data) {
                              return DataRow(cells: [
                                DataCell(Center(child: Text('${data.serialNumber}'))),
                                DataCell(Text(data.categoryName)),
                                DataCell(Text(data.modelName)),
                                DataCell(Text(data.deviceId)),
                                DataCell(Center(child: DropdownButton(
                                  value: data.interface,
                                  style: const TextStyle(fontSize: 12),
                                  onChanged: (newValue) {
                                    setState(() {
                                      data.interface = newValue!;
                                      int infIndex = interfaceType.indexWhere((model) =>  model.interface == newValue);
                                      data.interfaceTypeId = interfaceType[infIndex].interfaceTypeId;
                                    });
                                  },
                                  items: interfaceType.map((interface) {
                                    return DropdownMenuItem(
                                      value: interface.interface,
                                      child: Text(interface.interface, style: const TextStyle(fontWeight: FontWeight.normal),),
                                    );
                                  }).toList(),
                                )
                                )),
                                DataCell(Center(
                                  child: DropdownButton(
                                    value: data.interfaceInterval ?? '0 sec',
                                    style: const TextStyle(fontSize: 12), onChanged: (newValue) {
                                    setState(() {
                                      data.interfaceInterval = newValue!;
                                    });
                                  },
                                    items: _interfaceInterval.map((interface) {
                                      return DropdownMenuItem(value: interface,
                                        child: Text(interface, style: const TextStyle(fontWeight: FontWeight.normal),),
                                      );
                                    }).toList(),
                                  ),
                                )),
                                DataCell(Center(
                                  child: IconButton(
                                      onPressed: () async {
                                        Map<String, dynamic> body = {
                                          "userId": widget.customerID,
                                          "controllerId": data.userDeviceListId,
                                          "modifyUser": widget.userID,
                                          "productId": data.productId,
                                        };
                                        final response = await HttpService().putRequest("removeNodeInMaster", body);
                                        if (response.statusCode == 200) {
                                          var data = jsonDecode(response.body);
                                          if (data["code"] == 200) {
                                            _showSnackBar(data["message"]);
                                            getCustomerSite();
                                            getNodeStockList();
                                          }
                                          else {
                                            _showSnackBar(data["message"]);
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline, color: Colors.red,)),
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> generateRFNumber() async
  {
    List<int> oldNodeListRfNo = [];
    int refNo = 0;
    String refNoUpdatingNode = '';
    List<dynamic> selectedNodeList = [];

    List<int> oldNodeListSrlNo = [];
    for(int i=0; i<usedNodeList[currentSite].length; i++){
      oldNodeListSrlNo.add(usedNodeList[currentSite][i].serialNumber);
    }

    List missingSrlNumber = missingArray(oldNodeListSrlNo);
    //print(missingSrlNumber);
    for(int i=0; i<nodeStockSelection.length; i++)
    {
      if(nodeStockSelection[i]==1) {
        Map<String, dynamic> myMap = {};
        if(missingSrlNumber.isNotEmpty){
          myMap = {"productId": nodeStockList[i].productId.toString(), 'categoryName': nodeStockList[i].categoryName, 'referenceNumber': 0, 'serialNumber': missingSrlNumber[0]};
          missingSrlNumber.removeAt(0);
        }else{
          myMap = {"productId": nodeStockList[i].productId.toString(), 'categoryName': nodeStockList[i].categoryName, 'referenceNumber': 0, 'serialNumber': usedNodeList[currentSite].length+1};
        }
        selectedNodeList.add(myMap);
      }
    }

    if(selectedNodeList.isNotEmpty)
    {
      for(int i = 0; i < selectedNodeList.length; i++)
      {
        if(selectedNodeList[i]['referenceNumber'] == 0){
          if(refNoUpdatingNode != selectedNodeList[i]['categoryName'])
          {
            refNoUpdatingNode = selectedNodeList[i]['categoryName'];
            var contain = usedNodeList[currentSite].where((element) => element.categoryName == refNoUpdatingNode);
            if (contain.isNotEmpty)
            {
              for(int j = 0; j < usedNodeList[currentSite].length; j++)
              {
                if(usedNodeList[currentSite][j].categoryName == refNoUpdatingNode)
                {
                  oldNodeListRfNo.add(usedNodeList[currentSite][j].referenceNumber);
                }
              }
              List missingRN = missingArray(oldNodeListRfNo);
              if(missingRN.isNotEmpty)
              {
                refNo = oldNodeListRfNo.reduce((value, element) => value > element ? value : element);
                for(int k = 0; k < selectedNodeList.length; k++)
                {
                  if(missingRN.isNotEmpty)
                  {
                    if(selectedNodeList[k]['categoryName'] == refNoUpdatingNode)
                    {
                      selectedNodeList[k]['referenceNumber'] = missingRN[0];
                      missingRN.removeAt(0);
                    }
                  }else{
                    refNo = refNo+1;
                    selectedNodeList[k]['referenceNumber'] = refNo;
                  }
                }
              }
              else
              {
                refNo = oldNodeListRfNo.reduce((value, element) => value > element ? value : element);
                for(int k = 0; k < selectedNodeList.length; k++)
                {
                  if(selectedNodeList[k]['categoryName'] == refNoUpdatingNode)
                  {
                    refNo = refNo+1;
                    selectedNodeList[k]['referenceNumber'] = refNo;
                  }
                }
              }
            }
            else
            {
              refNo = 0;
              for(int k = 0; k < selectedNodeList.length; k++)
              {
                if(refNoUpdatingNode == selectedNodeList[k]['categoryName'])
                {
                  refNo = refNo+1;
                  selectedNodeList[k]['referenceNumber'] = refNo;
                }
              }
            }
          }
          else{
          }
        }else{
          //refNo already created
        }
      }

      Navigator.pop(context);

      if(selectedNodeList.isNotEmpty)
      {
        Map<String, dynamic> body = {
          "userId": widget.customerID,
          "dealerId": widget.userID,
          "masterId": customerSiteList[currentSite].controllerId,
          "groupId": customerSiteList[currentSite].groupId,
          "products": selectedNodeList,
          "createUser": widget.userID,
        };

        final response = await HttpService().postRequest("createUserNodeListWithMaster", body);
        print(response.body);
        if(response.statusCode == 200)
        {
          var data = jsonDecode(response.body);
          if(data["code"]==200)
          {
            setState(() {
              selectedNodeList.clear();
              nodeStockSelection.clear();
              checkboxValueNode = false;
            });
            getCustomerSite();
            getNodeStockList();
          }
          else{
            //_showSnackBar(data["message"]);
            //_showAlertDialog('Warning', data["message"]);
          }
        }
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<int> missingArray(List<int> no) {
    List<int> missingValues = [];
    if(no.isNotEmpty){
      int n = no.reduce(max);
      List<int> intArray = List.generate(n, (index) => index + 1);
      for (var value in intArray) {
        if (!no.contains(value)) {
          missingValues.add(value);
        }
      }
    }
    return missingValues;
  }

  String convertToHHmmss(String timeString)
  {
    List<String> parts = timeString.split(' ');
    int quantity = int.parse(parts[0]);
    String unit = parts[1];

    int seconds;
    switch (unit) {
      case 'sec':
        seconds = quantity;
        break;
      case 'min':
        seconds = quantity * 60;
        break;
      case 'hr':
        seconds = quantity * 3600;
        break;
      default:
        return 'Invalid input';
    }

    String formattedTime = formatSecondsToTime(seconds);

    return formattedTime;
  }

  String formatSecondsToTime(int seconds) {
    // Calculate hours, minutes, and remaining seconds
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    // Format as HH:mm:ss
    String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

}