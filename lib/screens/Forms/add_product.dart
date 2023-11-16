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
  int sldCatID = 0;


  late List<DropdownMenuEntry<PrdModel>> selectedModel;
  List<PrdModel> activeModelList = <PrdModel>[];
  int sldModID = 0;
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
    print(response);
    if (response.statusCode == 200)
    {
      activeCategoryList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

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
    Map<String, Object> body = {
      "categoryId" : catID.toString(),
    };
    final response = await HttpService().postRequest("getModelByCategoryId", body);
    print(response);
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
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new product stock'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.blueGrey.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10, top: 5),
                      child: Column(
                        children: [
                          Expanded(
                              child: DataTable2(
                                columnSpacing: 12,
                                horizontalMargin: 12,
                                minWidth: 600,
                                dataRowHeight: 40.0,
                                headingRowHeight: 40,
                                headingRowColor: MaterialStateProperty.all<Color>(primaryColorDark.withOpacity(0.2)),
                                columns: const [
                                  DataColumn2(
                                      label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                      fixedWidth: 40
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
                                    label: Text('IMEI Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                    fixedWidth: 170,
                                  ),
                                  DataColumn2(
                                    label: Center(child: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                    fixedWidth: 95,
                                  ),
                                  DataColumn2(
                                    label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                    fixedWidth: 80,
                                  ),
                                  DataColumn2(
                                    label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)),
                                    fixedWidth: 50,
                                  ),
                                ],
                                rows: List<DataRow>.generate(addedProductList.length, (index) => DataRow(cells: [
                                  DataCell(Center(child: Text('${index + 1}'))),
                                  DataCell(Text(addedProductList[index]['categoryName'])),
                                  DataCell(Text(addedProductList[index]['modelName'])),
                                  DataCell(Text('${addedProductList[index]['deviceId']}')),
                                  DataCell(Center(child: Text(addedProductList[index]['dateOfManufacturing']))),
                                  DataCell(Center(child: Text('${addedProductList[index]['warrantyMonths']}'))),
                                  DataCell(Center(child: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red,), // Specify the icon
                                    onPressed: () {
                                      setState(() {
                                        addedProductList.removeAt(index);
                                      });
                                    },
                                  ), ))
                                ])),
                              )
                          ),
                          Container(
                            height: 60,
                            width: width,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextButton.icon(
                                  onPressed: () async
                                  {
                                    if(addedProductList.isNotEmpty)
                                    {
                                      final prefs = await SharedPreferences.getInstance();
                                      String userID = (prefs.getString('userId') ?? "");

                                      Map<String, Object> body = {
                                        'products': addedProductList,
                                        'createUser': userID,
                                      };

                                      final Response response = await HttpService().postRequest("createProduct", body);;
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
                                          if(mounted){
                                            Navigator.pop(context);
                                          }
                                        }
                                        else{
                                          _showAlertDialog('Error', '${data["message"]}\n${data["data"].toString()}');
                                        }
                                      }
                                    }
                                    else{
                                      _showSnackBar('Product Empty');
                                    }

                                  },
                                  label: const Text('Save to Inventory'),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 30,),
                                    DropdownMenu<PrdCateModel>(
                                      enableFilter: true,
                                      requestFocusOnTap: true,
                                      controller: ddCatList,
                                      errorText: vldErrorCTL ? 'Select category' : null,
                                      hintText: 'Category',
                                      width: 300,
                                      dropdownMenuEntries: selectedCategory,
                                      inputDecorationTheme: const InputDecorationTheme(
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                        border: OutlineInputBorder(),
                                      ),
                                      onSelected: (PrdCateModel? ptdCat) {
                                        setState(() {
                                          sldCatID = ptdCat!.categoryId;
                                          vldErrorCTL = false;
                                          ddModelList.clear();
                                          getModelByActiveList(sldCatID);
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15,),
                                    DropdownMenu<PrdModel>(
                                      controller: ddModelList,
                                      errorText: vldErrorMDL ? 'Select model' : null,
                                      hintText: 'Model',
                                      width: 300,
                                      dropdownMenuEntries: selectedModel,
                                      inputDecorationTheme: const InputDecorationTheme(
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                        border: OutlineInputBorder(),
                                      ),
                                      onSelected: (PrdModel? mdl) {
                                        setState(() {
                                          sldModID = mdl!.modelId;
                                          ctrlPrdDis.text = mdl.modelDescription;
                                          vldErrorMDL = false;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 15,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: ListTile(
                                        title: TextFormField(
                                          validator: (value){
                                            if(value==null ||value.isEmpty){
                                              return 'Please fill out this field';
                                            }
                                            return null;
                                          },
                                          controller: ctrlIMI,
                                          maxLength: 20,
                                          decoration: InputDecoration(
                                            counterText: '',
                                            labelText: 'Enter IMEi number',
                                            border: const OutlineInputBorder(),
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: ListTile(
                                        title: TextFormField(
                                          controller: ctrlWrM,
                                          validator: (value){
                                            if(value==null || value.isEmpty){
                                              return 'Please fill out this field';
                                            }
                                          },
                                          maxLength: 2,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          decoration: InputDecoration(
                                            counterText: '',
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                            errorText: vldErrorWrr ? 'Enter warranty months' : null,
                                            labelText: 'warranty months',
                                            suffixIcon: const Icon(Icons.close),
                                            border: const OutlineInputBorder(),
                                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: ListTile(
                                        title: TextFormField(
                                          validator: (value){
                                            if(value==null || value.isEmpty){
                                              return 'Please fill out this field';
                                            }
                                          },
                                          controller: ctrlDofM,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
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
                                    ),
                                    const SizedBox(height: 10,),
                                    ListTile(
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ElevatedButton(
                                            child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          const SizedBox(width: 10,),
                                          ElevatedButton(
                                            child: const Text('Add'),
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate() && sldCatID!=0) {
                                                _formKey.currentState!.save();

                                                String newIMEI = ctrlIMI.text;
                                                if (!isIMEIAlreadyExists(newIMEI, addedProductList)) {
                                                  Map<String, dynamic> productMap = {
                                                    "categoryName": ddCatList.text,
                                                    "categoryId": sldCatID.toString(),
                                                    "modelName": ddModelList.text,
                                                    "modelId": sldModID.toString(),
                                                    "deviceId": newIMEI,
                                                    "productDescription": ctrlPrdDis.text,
                                                    'dateOfManufacturing': ctrlDofM.text,
                                                    'warrantyMonths': ctrlWrM.text,
                                                  };

                                                  setState(() {
                                                    addedProductList.add(productMap);
                                                    //ctrlIMI.clear();
                                                  });
                                                } else {
                                                  _showSnackBar('IMEI already exists!');
                                                }

                                              }
                                              else{
                                                if(sldCatID==0){
                                                  setState(() {
                                                    vldErrorCTL = true;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
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

  bool isIMEIAlreadyExists(String newIMEI, List<Map<String, dynamic>> productList) {
    for (var product in productList) {
      if (product['deviceId'] == newIMEI) {
        return true; // IMEI already exists
      }
    }
    return false; // IMEI does not exist
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
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
