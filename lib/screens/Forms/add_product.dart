import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/prd_cat_model.dart';
import '../../Models/product_model.dart';
import '../../constants/http_service.dart';
import '../../constants/snack_bar.dart';
import '../product_inventory.dart';


enum SampleItem { itemOne, itemTwo}

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key, required this.callback}) : super(key: key);
  final void Function(String) callback;

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController ddCatList = TextEditingController();
  final TextEditingController ddModelList = TextEditingController();
  final TextEditingController ctrlIMI = TextEditingController();
  final TextEditingController ctrlPrdDis = TextEditingController();
  final TextEditingController ctrlWrM = TextEditingController();
  final TextEditingController ctrlDofM = TextEditingController();

  late List<DropdownMenuEntry<PrdCateModel>> selectedCategory;
  List<PrdCateModel> activeCategoryList = <PrdCateModel>[];
  int sldCatID = 0, sldModID = 0;


  late List<DropdownMenuEntry<PrdModel>> selectedModel;
  List<PrdModel> activeModelList = <PrdModel>[];
  String mdlDis = 'Product Description';

  bool vldErrorCTL = false;
  bool vldErrorMDL = false;
  bool vldErrorIMI = false;
  bool vldErrorDis = false;
  bool vldErrorWrr = false;
  bool vldErrorDT = false;
  bool editActive = false;

  List<Map<String, dynamic>> addedProductList = [];
  SampleItem? selectedMenu;

  late PrdModel selectedValue;

  @override
  void initState() {
    super.initState();

    selectedCategory =  <DropdownMenuEntry<PrdCateModel>>[];
    selectedModel =  <DropdownMenuEntry<PrdModel>>[];
    getCategoryByActiveList();
  }

  Future<void> getCategoryByActiveList() async
  {
    Map<String, Object> body = {
      "active" : "1",
    };
    final response = await HttpService().postRequest("getCategoryByActive", body);
    //print(response);
    if (response.statusCode == 200)
    {
      activeCategoryList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;
      print(response.body);
      for (int i=0; i < cntList.length; i++) {
        activeCategoryList.add(PrdCateModel.fromJson(cntList[i]));
      }

      selectedCategory =  <DropdownMenuEntry<PrdCateModel>>[];
      for (final PrdCateModel index in activeCategoryList) {
        selectedCategory.add(DropdownMenuEntry<PrdCateModel>(value: index, label: index.categoryName));
      }

      setState(() {
        activeCategoryList;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getModelByActiveList(int catID) async
  {
    Map<String, Object> body = {"categoryId" : catID.toString(),};
    final response = await HttpService().postRequest("getModelByCategoryId", body);
    if (response.statusCode == 200)
    {
      activeModelList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        activeModelList.add(PrdModel.fromJson(cntList[i]));
      }

      selectedModel =  <DropdownMenuEntry<PrdModel>>[];
      for (final PrdModel index in activeModelList) {
        selectedModel.add(DropdownMenuEntry<PrdModel>(value: index, label: index.modelName));
      }

      setState(() {
        selectedModel;
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
          child: Row(
            children: [
              DropdownMenu<PrdCateModel>(
                enableFilter: true,
                requestFocusOnTap: true,
                controller: ddCatList,
                errorText: vldErrorCTL ? 'Select category' : null,
                width: 200,
                label: const Text('Category'),
                dropdownMenuEntries: selectedCategory,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(),
                  fillColor: Colors.teal.shade50,
                ),
                onSelected: (PrdCateModel? ptdCat) {
                  setState(() {
                    sldCatID = ptdCat!.categoryId;
                    vldErrorCTL = false;
                    ddModelList.clear();
                    sldModID = 0;
                    getModelByActiveList(sldCatID);
                  });
                },
              ),
              const SizedBox(width: 8),
              DropdownMenu<PrdModel>(
                controller: ddModelList,
                errorText: vldErrorMDL ? 'Select model' : null,
                width: 205,
                label: const Text('Model'),
                dropdownMenuEntries: selectedModel,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(),
                  fillColor: Colors.teal.shade50,
                ),
                onSelected: (PrdModel? mdl) {
                  setState(() {
                    sldModID = mdl!.modelId;
                    ddModelList.clear();
                    ddModelList.text = mdl.modelName;
                  });
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: TextFormField(
                  maxLength: 12,
                  controller: ctrlIMI,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: 'Device ID',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
          child: Row(
            children: [
              SizedBox(
                width: 175,
                child: TextFormField(
                  controller: ctrlWrM,
                  validator: (value){
                    if(value==null || value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  maxLength: 2,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    errorText: vldErrorWrr ? 'Enter warranty months' : null,
                    labelText: 'warranty months',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 125,
                child: TextFormField(
                  validator: (value){
                    if(value==null || value.isEmpty){
                      return 'Please fill out this field';
                    }
                    return null;
                  },
                  controller: ctrlDofM,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    errorText: vldErrorDT? 'Select Date' : null,
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  ),
                  onTap: ()
                  async
                  {
                    DateTime? date = DateTime(1900);
                    FocusScope.of(context).requestFocus(FocusNode());
                    date = await showDatePicker(
                        context: context,
                        initialDate:DateTime.now(),
                        firstDate:DateTime(1900),
                        lastDate: DateTime(2100));

                    ctrlDofM.text =  DateFormat('dd-MM-yyyy').format(date!);
                  },

                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 100,
                child: MaterialButton(
                  color: Colors.teal,
                  textColor: Colors.white,
                  height: 55,
                  child: const Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8,),
                      Text('ADD'),
                    ],
                  ),
                  onPressed: () async {
                    if (sldCatID!=0 && sldModID!=0) {
                      if (isNotEmpty(ctrlIMI.text.trim()) && isNotEmpty(ctrlDofM.text) && isNotEmpty(ctrlWrM.text)) {
                        if (!isIMEIAlreadyExists(ctrlIMI.text.trim(), addedProductList)) {
                          Map<String, Object> body = {"deviceId" : ctrlIMI.text.trim(),};
                          final response = await HttpService().postRequest("checkProduct", body);
                          if (response.statusCode == 200)
                          {
                            var data = jsonDecode(response.body);
                            if(data['code']==404){
                              Map<String, dynamic> productMap = {
                                "categoryName": ddCatList.text,
                                "categoryId": sldCatID.toString(),
                                "modelName": ddModelList.text,
                                "modelId": sldModID.toString(),
                                "deviceId": ctrlIMI.text.trim(),
                                "productDescription": ctrlPrdDis.text,
                                'dateOfManufacturing': ctrlDofM.text,
                                'warrantyMonths': ctrlWrM.text,
                              };
                              setState(() {
                                addedProductList.add(productMap);
                              });
                            }else{
                              _showAlertDialog('Alert Message', 'The product id already exists!');
                            }
                          }
                          else{
                            //_showSnackBar(response.body);
                          }
                        } else {
                          _showAlertDialog('Error!', 'Device id already exists!');
                        }
                      }else{
                        _showAlertDialog('Error!', 'Empty filed not allowed!');
                      }

                    }
                    else{
                      if(sldCatID==0){
                        setState(() {
                          vldErrorCTL = true;
                        });
                      }else if(sldModID==0){
                        setState(() {
                          vldErrorMDL = true;
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 25),
              SizedBox(
                width: 170,
                child: MaterialButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  height: 55,
                  child: const Row(
                    children: [
                      Icon(Icons.save_as_outlined),
                      SizedBox(width: 8,),
                      Text('SAVE TO STOCK'),
                    ],
                  ),
                  onPressed: () async {
                    if(addedProductList.isNotEmpty)
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text('Are you sure! You want to save the product to Stock list?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final prefs = await SharedPreferences.getInstance();
                                  String userID = (prefs.getString('userId') ?? "");
                                  Map<String, Object> body = {
                                    'products': addedProductList,
                                    'createUser': userID,
                                  };

                                  final Response response = await HttpService().postRequest("createProduct", body);
                                  if(response.statusCode == 200)
                                  {
                                    var data = jsonDecode(response.body);
                                    if(data["code"]==200)
                                    {
                                      ctrlIMI.clear();
                                      ctrlPrdDis.clear();
                                      ctrlDofM.clear();
                                      ctrlWrM.clear();
                                      widget.callback('reloadStock');
                                    }
                                    else{
                                      _showAlertDialog('Error', '${data["message"]}\n${data["data"].toString()}');
                                    }
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          );
                        },
                      );

                    }else{
                      _showAlertDialog('Alert Message', 'Product Empty!');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16,),
        Expanded(
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 600,
            dataRowHeight: 35.0,
            headingRowHeight: 25.0,
            headingRowColor: WidgetStateProperty.all<Color>(myTheme.primaryColor.withOpacity(0.1)),
            columns: const [
              DataColumn2(
                  label: Center(child: Text('S.No')),
                  fixedWidth: 32
              ),
              DataColumn2(
                  label: Text('Category'),
                  size: ColumnSize.M
              ),
              DataColumn2(
                  label: Text('Model Name'),
                  size: ColumnSize.M
              ),
              DataColumn2(
                label: Text('Device Id'),
                fixedWidth: 150,
              ),
              DataColumn2(
                label: Center(child: Text('M.Date')),
                fixedWidth: 75,
              ),
              DataColumn2(
                label: Center(child: Text('Warranty')),
                fixedWidth: 70,
              ),
              DataColumn2(
                label: Center(child: Text('Action')),
                fixedWidth: 45,
              ),
            ],
            rows: List<DataRow>.generate(addedProductList.length, (index) => DataRow(cells: [
              DataCell(Center(child: Text('${index + 1}',style: const TextStyle(fontSize: 10)))),
              DataCell(Text(addedProductList[index]['categoryName'],style: const TextStyle(fontSize: 10))),
              DataCell(Text(addedProductList[index]['modelName'],style: const TextStyle(fontSize: 10))),
              DataCell(Text('${addedProductList[index]['deviceId']}',style: const TextStyle(fontSize: 10))),
              DataCell(Center(child: Text(addedProductList[index]['dateOfManufacturing'],style: const TextStyle(fontSize: 10)))),
              DataCell(Center(child: Text('${addedProductList[index]['warrantyMonths']}',style: const TextStyle(fontSize: 10)))),
              DataCell(Center(child: IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.delete_outline, color: Colors.red,), // Specify the icon
                onPressed: () {
                  setState(() {
                    addedProductList.removeAt(index);
                  });
                },
              ), )),
            ])),
          ),
        ),
      ],
    );
  }

  bool isNotEmpty(String text) {
    return text.isNotEmpty;
  }

  bool isIMEIAlreadyExists(String newIMEI, List<Map<String, dynamic>> productList) {
    for (var product in productList) {
      if (product['deviceId'] == newIMEI) {
        return true; // IMEI already exists
      }
    }
    return false; // IMEI does not exist
  }



  void _showAlertDialog(String title , String message)
  {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Text("okay"),
            ),
          ),
        ],
      ),
    );
  }

}
