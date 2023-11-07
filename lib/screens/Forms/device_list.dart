import 'dart:convert';
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Config/config_screen.dart';
import 'package:provider/provider.dart';

import '../../Models/customer_list.dart';
import '../../Models/customer_product.dart';
import '../../Models/interface_model.dart';
import '../../Models/model_added_nodes.dart';
import '../../Models/node_model.dart';
import '../../Models/product_stock.dart';
import '../../constants/http_service.dart';
import '../../constants/mqtt_web_client.dart';
import '../../state_management/config_maker_provider.dart';

enum SampleItem { itemOne, itemTwo, itemThree }
enum MasterController {gem1, gem2, gem3, gem4, gem5, gem6, gem7, gem8, gem9, gem10,}

class DeviceList extends StatefulWidget {
  final int customerID, userID, userType;
  final String userName;
  final List<ProductStockModel> productStockList;
  const DeviceList({super.key, required this.customerID, required this.userName, required this.userID, required this.userType, required this.productStockList});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> with SingleTickerProviderStateMixin
{
  final _formKey = GlobalKey<FormState>();

  SampleItem? selectedMenu;

  Map<String, dynamic> productSalesList = {};
  List<dynamic> salesList = [];
  bool checkboxValue = false;

  List<CustomerProductModel> customerProductList = <CustomerProductModel>[];
  List<ProductStockModel> myMasterControllerList = <ProductStockModel>[];
  bool checkboxTick = false;

  List<ProductListWithNode> customerSiteList = <ProductListWithNode>[];
  List<ProductStockModel> nodeStockList = <ProductStockModel>[];
  List<List<NodeModel>> usedNodeList = <List<NodeModel>>[];

  static List<Object> configList = ['Product List','Site Config'];
  late  List<Object> _configTabs = [];
  late final TabController _tabCont;

  int selectedRadioTile = 0;
  final ValueNotifier<MasterController> _selectedItem = ValueNotifier<MasterController>(MasterController.gem1);
  final TextEditingController _textFieldSiteName = TextEditingController();
  final TextEditingController _textFieldSiteDisc = TextEditingController();

  final List<InterfaceModel> interfaceType = <InterfaceModel>[];


  @override
  void initState() {
    super.initState();
    configList[1] = (widget.userType == 1) ? 'Customer' : 'Site Config';
    _configTabs = List.generate(configList.length, (index) => configList[index]);
    _tabCont = TabController(length: configList.length, vsync: this);
    selectedRadioTile = 0;
    getCustomerType();
  }

  @override
  void dispose() {
    _tabCont.dispose();

    for (int i=0; i < customerSiteList.length; i++) {
      Future.delayed(const Duration(milliseconds: 100), () async {
        MqttWebClient().unsubscribeFromTopic('FirmwareToApp/${customerSiteList[i].deviceId}');
      });
    }

    super.dispose();
  }

  void resetPopop(){
    checkboxValue = false;
    checkboxTick = false;
  }

  void removeProductStockById(int productId) {
    print(productId);
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
    final body = widget.userType == 1 ? {"fromUserId": widget.userID, "toUserId": widget.customerID} : {"fromUserId": widget.userID, "toUserId": widget.customerID};
    print(body);
    final response = await HttpService().postRequest("getCustomerProduct", body);
    if (response.statusCode == 200)
    {
      customerProductList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          customerProductList.add(CustomerProductModel.fromJson(cntList[i]));
        }
      }
      setState(() {
        customerProductList;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getMasterProduct() async
  {
    Map<String, Object> body = {"userId" : widget.customerID};
    final response = await HttpService().postRequest("getMasterControllerStock", body);
    print(body);
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

      setState(() {
        myMasterControllerList;
      });

    }
    else{
      //_showSnackBar(response.body);
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

          Future.delayed(const Duration(milliseconds: 100), () async {
            MqttWebClient().onSubscribed('FirmwareToApp/${customerSiteList[i].deviceId}');
          });

          final nodeList = cntList[i]['nodeList'] as List;
          usedNodeList.add([]);
          for (int j=0; j < nodeList.length; j++) {
            usedNodeList[i].add(NodeModel.fromJson(nodeList[j]));
          }
        }
      }
      setState(() {
        customerSiteList;
      });
    }
    else{
      //_showSnackBar(response.body);
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
      setState(() {
        nodeStockList;
      });

    }
    else{
      //_showSnackBar(response.body);
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
      setState(() {
        interfaceType;
      });

    }
    else{
      //_showSnackBar(response.body);
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
          tooltip: 'Add Product',
          child: const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.add_box_outlined, color: Colors.white,)),
          itemBuilder: (context) {
            return _tabCont.index==0 ? List.generate(widget.productStockList.length+1 ,(index) {
              if(widget.productStockList.length == index)
              {
                return PopupMenuItem(
                  child : Row(
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
                      subtitle: Text('${widget.productStockList[index].imeiNo}'),
                      value: checkboxValue,
                      onChanged:(bool? value) { setState(() {
                        checkboxValue = value!;
                        if(value){
                          Map<String, String> myMap = {"productId": widget.productStockList[index].productId.toString(), 'categoryName': widget.productStockList[index].categoryName};
                          salesList.add(myMap);
                        }else{
                          salesList.removeAt(index);
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
                          _displayTextInputDialog(context, myMasterControllerList[selectedRadioTile].categoryName,
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
      body: TabBarView(
        controller: _tabCont,
        children: [
          ..._configTabs.map((label) =>
              CustomerSalesPage(
              label: label.toString(), customerID: widget.customerID, customerProductList: customerProductList, customerSiteList: customerSiteList, nodeStockList: nodeStockList,
                usedNodeList: usedNodeList, interfaceType: interfaceType, userID : widget.userID, getNodeStockList: getNodeStockList, getCustomerSite : getCustomerSite, userType: widget.userType, userName: widget.userName,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, String ctrl_name, String ctrl_model, String ctrl_iemi) async {
    return showDialog(
        context: context,
        builder: (context) {
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
                      title: Text(ctrl_name),
                      subtitle: Text('$ctrl_model\n$ctrl_iemi'),
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
                        Navigator.pop(context);
                      }
                      else{
                        //_showSnackBar(data["message"]);
                        //_showAlertDialog('Warning', data["message"]);
                      }
                    }
                  }
                  /*setState(() {
                    //codeDialog = valueText;
                    Navigator.pop(context);
                  });*/
                },
              ),
            ],
          );
        });
  }
}

class CustomerSalesPage extends StatefulWidget
{
  const CustomerSalesPage({Key? key, required this.label, required this.customerID, required this.userType, required this.userName, required this.customerProductList, required this.customerSiteList, required this.nodeStockList, required this.usedNodeList,
    required this.interfaceType, required this.userID, required this.getNodeStockList, required this.getCustomerSite}) : super(key: key);
  final String label, userName;
  final int customerID;
  final int userID;
  final int userType;
  final List<CustomerProductModel> customerProductList;
  final List<ProductListWithNode> customerSiteList;
  final List<ProductStockModel> nodeStockList;
  final List<List<NodeModel>> usedNodeList;
  final List<InterfaceModel> interfaceType;
  final Function getNodeStockList;
  final Function getCustomerSite;


  @override
  State<CustomerSalesPage> createState() => _CustomerSalesPageState();
}

class _CustomerSalesPageState extends State<CustomerSalesPage> {

  bool checkboxValueNode = false;
  List<dynamic> selectedNodeList = [];
  final List<String> _interfaceInterval = ['0 Sec', '5 Sec', '10 Sec', '20 Sec', '30 Sec', '45 Sec','1 minute','5 minutes','10 minutes','30 minutes','1 hour']; // Option 2
  SampleItem? selectedMenu;
  List<CustomerListMDL> myCustomerChildList = <CustomerListMDL>[];

  @override
  void initState() {
    super.initState();
    if(widget.label.toString()=='Customer'){
      getCustomerChildList();
    }
  }

  Future<void> getCustomerChildList() async
  {
    Map<String, Object> body = {"userType" : widget.userType+1, "userId" : widget.customerID};
    final response = await HttpService().postRequest("getUserList", body);
    print(body);
    if (response.statusCode == 200)
    {
      myCustomerChildList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        myCustomerChildList.add(CustomerListMDL.fromJson(cntList[i]));
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
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    if(widget.label.toString()=='Product List')
    {
      return  Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 580,
              columns: const [
                DataColumn2(
                    label: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold),),
                    fixedWidth: 70
                ),
                DataColumn2(
                  label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                DataColumn2(
                  label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                DataColumn2(
                  label: Text('IMEI', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                DataColumn2(
                  label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                DataColumn2(
                  label: Text('Sales person', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                DataColumn2(
                  label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                  fixedWidth: 50,
                )
              ],
              rows: List<DataRow>.generate(widget.customerProductList.length, (index) => DataRow(cells: [
                DataCell(Text('${index+1}')),
                DataCell(Row(children: [const CircleAvatar(radius: 17, child: Icon(Icons.gas_meter_outlined),), const SizedBox(width: 10,), Text(widget.customerProductList[index].catName)],)),
                DataCell(Text(widget.customerProductList[index].model)),
                DataCell(Text('${widget.customerProductList[index].imei}')),
                DataCell(Center(child: widget.userType+1 == widget.customerProductList[index].prdStatus? const Row(children: [CircleAvatar(backgroundColor: Colors.orange, radius: 5,), SizedBox(width: 5,), Text('Free')],):
                const Row(children: [CircleAvatar(backgroundColor: Colors.green, radius: 5,), SizedBox(width: 5,), Text('Active')],))),
                DataCell(widget.customerProductList[index].buyer == widget.userName? const Text('-') : Text(widget.customerProductList[index].buyer)),
                DataCell(Center(child: PopupMenuButton<SampleItem>(
                  initialValue: selectedMenu,
                  // Callback that sets the selected popup menu item.
                  onSelected: (SampleItem item) {
                    setState(() {
                      selectedMenu = item;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('Delete'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemThree,
                      child: Text('Replace'),
                    ),
                  ],
                )))
              ]))),
        ),
      );
    }
    else if(widget.label.toString()=='Site Config')
    {
      return  ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: widget.customerSiteList.length,
          itemBuilder: (context, siteIndex) {
            return InkWell(
              child: Card(
                key: ValueKey([siteIndex]),
                elevation: 1,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                        width:500,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                        child: Column(
                          children: [
                            Container(height: 50,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20, left: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(widget.customerSiteList[siteIndex].groupName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal,),),
                                    PopupMenuButton(
                                      elevation: 10,
                                      tooltip: 'Add node list',
                                      child: Center(child: Icon(Icons.add_card, color: myTheme.primaryColor,)),
                                      itemBuilder: (context) {
                                        return List.generate(widget.nodeStockList.length+1 ,(nodeIndex) {
                                          if(widget.nodeStockList.isEmpty){
                                            return const PopupMenuItem(
                                              child: Text('No node available to add in this site'),
                                            );
                                          }
                                          else if(widget.nodeStockList.length == nodeIndex){
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
                                                        selectedNodeList.clear();
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
                                                      List<int> oldNodeListRN = [];
                                                      int refNo = 0;
                                                      String rnUpdatedNode = '';

                                                      for(int j = 0; j < selectedNodeList.length; j++)
                                                      {
                                                        if(rnUpdatedNode != selectedNodeList[j]['categoryName'])
                                                        {
                                                          rnUpdatedNode = selectedNodeList[j]['categoryName'];
                                                          var contain = widget.usedNodeList[siteIndex].where((element) => element.categoryName == rnUpdatedNode);
                                                          if (contain.isNotEmpty)
                                                          {
                                                            for(int i = 0; i < widget.usedNodeList[siteIndex].length; i++)
                                                            {
                                                              if(widget.usedNodeList[siteIndex][i].categoryName == rnUpdatedNode)
                                                              {
                                                                oldNodeListRN.add(widget.usedNodeList[siteIndex][i].referenceNumber);
                                                                refNo = refNo + 1;
                                                              }
                                                            }

                                                            List missingRN = missingArray(oldNodeListRN);
                                                            if(missingRN.isNotEmpty)
                                                            {
                                                              refNo = 0;
                                                              for(int k = 0; k < selectedNodeList.length; k++)
                                                              {
                                                                if(missingRN.isNotEmpty)
                                                                {
                                                                  if(widget.usedNodeList[siteIndex][k].categoryName == selectedNodeList[k]['categoryName'])
                                                                  {
                                                                    refNo = missingRN[0];
                                                                    selectedNodeList[k]['referenceNumber'] = refNo;
                                                                    missingRN.removeAt(0);
                                                                  }
                                                                }else{
                                                                  refNo = refNo+2;
                                                                  selectedNodeList[k]['referenceNumber'] = refNo;
                                                                }
                                                              }
                                                            }
                                                            else
                                                            {
                                                              for(int k = 0; k < selectedNodeList.length; k++)
                                                              {
                                                                if(widget.usedNodeList[siteIndex][k].categoryName == selectedNodeList[k]['categoryName'])
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
                                                              if(rnUpdatedNode == selectedNodeList[k]['categoryName'])
                                                              {
                                                                refNo = refNo+1;
                                                                selectedNodeList[k]['referenceNumber'] = refNo;
                                                              }
                                                            }
                                                          }
                                                        }
                                                        else{
                                                        }
                                                      }

                                                      print(selectedNodeList);

                                                      if(selectedNodeList.isNotEmpty)
                                                      {
                                                        Map<String, dynamic> body = {
                                                          "userId": widget.customerID,
                                                          "dealerId": widget.userID,
                                                          "masterId": widget.customerSiteList[siteIndex].userDeviceListId,
                                                          "groupId": widget.customerSiteList[siteIndex].groupId,
                                                          "products": selectedNodeList,
                                                          "createUser": widget.userID,
                                                        };

                                                        final response = await HttpService().postRequest("createUserDeviceListWithMaster", body);
                                                        print(response.body);
                                                        if(response.statusCode == 200)
                                                        {
                                                          var data = jsonDecode(response.body);
                                                          if(data["code"]==200)
                                                          {
                                                            setState(() {
                                                              selectedNodeList.clear();
                                                              checkboxValueNode = false;
                                                            });

                                                            widget.getCustomerSite();
                                                            widget.getNodeStockList();
                                                            Navigator.pop(context);
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
                                              builder: (BuildContext context, void Function(void Function()) setState) {
                                                return CheckboxListTile(
                                                  title: Text(widget.nodeStockList[nodeIndex].categoryName),
                                                  subtitle: Text('${widget.nodeStockList[nodeIndex].imeiNo}'),
                                                  value: checkboxValueNode,
                                                  onChanged:(bool? value) { setState(() {
                                                    checkboxValueNode = value!;
                                                    if(value){
                                                      Map<String, dynamic> myMap = {"productId": widget.nodeStockList[nodeIndex].productId.toString(), 'categoryName': widget.nodeStockList[nodeIndex].categoryName, 'referenceNumber': 0};
                                                      selectedNodeList.add(myMap);
                                                    }else{
                                                      selectedNodeList.removeAt(nodeIndex);
                                                    }
                                                    print(selectedNodeList);
                                                  });},
                                                );
                                              },
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(widget.customerSiteList[siteIndex].categoryName,),
                              subtitle: Text(widget.customerSiteList[siteIndex].productDescription),
                              leading: const CircleAvatar(radius: 40),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,//add this line if you used column widget in your code
                                    children: [
                                      Text('IMEi Number : ${widget.customerSiteList[siteIndex].deviceId.toString()}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                      Text('Model Name  : ${widget.customerSiteList[siteIndex].modelName}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                      Text('Description : ${widget.customerSiteList[siteIndex].modelDescription}', style: const TextStyle(fontWeight: FontWeight.normal),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Divider(color: myTheme.primaryColor.withOpacity(0.3),),
                            ),
                            Expanded(
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: widget.usedNodeList[siteIndex].length,
                                    itemBuilder: (context, siteNodeIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: ListTile(
                                          title: Text(widget.usedNodeList[siteIndex][siteNodeIndex].categoryName),
                                          subtitle: Text('${widget.usedNodeList[siteIndex][siteNodeIndex].modelName}\n'
                                              'IMEi : ${widget.usedNodeList[siteIndex][siteNodeIndex].deviceId}',
                                            style: const TextStyle(fontWeight: FontWeight.normal),),
                                          leading: const CircleAvatar(radius: 20),
                                          trailing: Wrap(
                                            spacing: 12, // space between two icons
                                            children: <Widget>[
                                              DropdownButton(
                                                value: widget.usedNodeList[siteIndex][siteNodeIndex].interface,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    widget.usedNodeList[siteIndex][siteNodeIndex].interface = newValue!;
                                                    int index = widget.interfaceType.indexWhere((model) => model.interface == newValue);
                                                    widget.usedNodeList[siteIndex][siteNodeIndex].interfaceTypeId = widget.interfaceType[index].interfaceTypeId;
                                                  });
                                                },
                                                items: widget.interfaceType.map((interface) {
                                                  return DropdownMenuItem(
                                                    value: interface.interface,
                                                    child: Text(interface.interface, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  );
                                                }).toList(),
                                              ), // icon-1
                                              DropdownButton(
                                                value: widget.usedNodeList[siteIndex][siteNodeIndex].interfaceInterval,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    widget.usedNodeList[siteIndex][siteNodeIndex].interfaceInterval = newValue!;
                                                  });
                                                },
                                                items: _interfaceInterval.map((interface) {
                                                  return DropdownMenuItem(
                                                    value: interface,
                                                    child: Text(interface, style: const TextStyle(fontWeight: FontWeight.normal),),
                                                  );
                                                }).toList(),
                                              ),
                                              IconButton(onPressed: () async {
                                                print(widget.usedNodeList[siteIndex][siteNodeIndex].userDeviceListId);

                                                Map<String, dynamic> body = {
                                                  "userId": widget.customerID,
                                                  "controllerId": widget.usedNodeList[siteIndex][siteNodeIndex].userDeviceListId,
                                                  "modifyUser": widget.userID,
                                                };

                                                final response = await HttpService().putRequest("removeNodeInMaster", body);
                                                if(response.statusCode == 200)
                                                {
                                                  var data = jsonDecode(response.body);
                                                  if(data["code"]==200)
                                                  {
                                                    widget.usedNodeList[siteIndex].removeWhere((node) => node.userDeviceListId == widget.usedNodeList[siteIndex][siteNodeIndex].userDeviceListId);
                                                    _showSnackBar(data["message"]);

                                                    setState(() {
                                                      selectedNodeList.clear();
                                                      checkboxValueNode = false;
                                                    });
                                                    widget.getNodeStockList();
                                                  }
                                                  else{
                                                    _showSnackBar(data["message"]);
                                                  }
                                                }

                                              }, icon: const Icon(Icons.delete_outline, color: Colors.red,))// icon-2
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                            ),
                            Container(
                              height: 60,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5)),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () async {
                                      List<dynamic> updatedInterface = [];
                                      for(int i=0; i<widget.usedNodeList[siteIndex].length; i++){
                                        Map<String, dynamic> myMap = {"productId": widget.usedNodeList[siteIndex][i].productId,
                                          'interfaceTypeId': widget.usedNodeList[siteIndex][i].interfaceTypeId, 'interfaceInterval': widget.usedNodeList[siteIndex][i].interfaceInterval};
                                        updatedInterface.add(myMap);
                                      }
                                      Map<String, dynamic> body = {
                                        "userId": widget.customerID,
                                        "products": updatedInterface,
                                        "modifyUser": widget.userID,
                                      };

                                      List<dynamic> payLoad = [];
                                      payLoad.add('${1},${widget.customerSiteList[siteIndex].categoryName},${'1'}, ${'1'}, ${widget.customerSiteList[siteIndex].deviceId.toString()},'
                                          '${'1'},${"00:00:30"};');

                                      for(int i=0; i<widget.usedNodeList[siteIndex].length; i++){

                                        String paddedNumber = widget.usedNodeList[siteIndex][i].deviceId.toString().padLeft(20, '0');
                                        String formattedTime = convertToHHmmss(widget.usedNodeList[siteIndex][i].interfaceInterval);

                                        payLoad.add('${i+2},${widget.usedNodeList[siteIndex][i].categoryName},${widget.usedNodeList[siteIndex][i].categoryId},'
                                            '${widget.usedNodeList[siteIndex][i].referenceNumber},$paddedNumber,'
                                            '${widget.usedNodeList[siteIndex][i].interfaceTypeId},$formattedTime;');
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

                                      print(body);

                                      MqttWebClient().publishMessage('AppToFirmware/${widget.customerSiteList[siteIndex].deviceId}', payLoadFinal);

                                      final response = await HttpService().putRequest("updateUserDeviceNodeList", body);
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
                                    label: const Text('Send to Target'),
                                    icon: const Icon(
                                      Icons.save_as_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 20,)
                                ],
                              ),
                            ),
                          ],
                        ),
                    )
                ),
              ),
              onTap: (){
                int relayCnt = 0;
                for(int i=0; i<widget.usedNodeList[siteIndex].length; i++){
                  relayCnt = relayCnt + widget.usedNodeList[siteIndex][i].relayCount;
                }
                configPvd.clearConfig();
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  ConfigScreen(userID: widget.userID, customerID: widget.customerID, siteName: widget.customerSiteList[siteIndex].groupName, siteID: widget.customerSiteList[siteIndex].groupId, nodeCount: relayCnt, controllerId: widget.customerSiteList[siteIndex].userDeviceListId, imeiNumber:'${widget.customerSiteList[siteIndex].deviceId}',)),);
              },
            );
          });
    }
    else if(widget.label.toString()=='Customer')
    {
      return  Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // Number of columns
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: myCustomerChildList.length,
          itemBuilder: (BuildContext context, int index) {
            return UserCard(user: myCustomerChildList, index: index,);
          },
        ),
      );
    }

    return Center(child: Text('Page of ${widget.label}'));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  List<int> missingArray(List<int> referenceArr) {
    List<int> missingValues = [];
    int n = referenceArr.reduce(max);
    List<int> intArray = List.generate(n, (index) => index + 1);
    for (var value in intArray) {
      if (!referenceArr.contains(value)) {
        missingValues.add(value);
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
      case 'Sec':
        seconds = quantity;
        break;
      case 'minutes'||'minute':
        seconds = quantity * 60;
        break;
      case 'hour':
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


class UserCard extends StatelessWidget
{
  final List<CustomerListMDL> user;
  final int index;
  const UserCard({Key? key, required this.user, required this.index}) : super(key: key);

  static const SizedBox _sizedBox = SizedBox(height: 10.0);
  static const TextStyle _boldTextStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  static const TextStyle _normalTextStyle = TextStyle(fontSize: 12.0);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.supervised_user_circle_outlined)),
            _sizedBox,
            Text(
              user[index].userName,
              style: _boldTextStyle,
            ),
            _sizedBox,
            Text(
              user[index].mobileNumber,
              style: _normalTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}