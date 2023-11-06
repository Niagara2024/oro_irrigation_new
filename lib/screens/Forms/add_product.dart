import 'dart:convert';
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

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("ADD PRODUCT STOCK        ", style: myTheme.textTheme.titleLarge,),
                  subtitle: Text("Please fill out all fields correctly.", style: myTheme.textTheme.titleSmall,),
                ),
                ListTile(
                  leading: Icon(CupertinoIcons.macwindow),
                  title: DropdownMenu<PrdCateModel>(
                    controller: ddCatList,
                    errorText: vldErrorCTL ? 'Select category' : null,
                    hintText: 'Category',
                    width: 258,
                    dropdownMenuEntries: selectedCategory,
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                    ),
                    onSelected: (PrdCateModel? ptdCat) {
                      setState(() {
                        sldCatID = ptdCat!.categoryId;
                        vldErrorCTL = false;
                        getModelByActiveList(sldCatID);
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.square_stack_3d_up),
                  title: DropdownMenu<PrdModel>(
                    controller: ddModelList,
                    errorText: vldErrorMDL ? 'Select model' : null,
                    hintText: 'Model',
                    width: 258,
                    dropdownMenuEntries: selectedModel,
                    inputDecorationTheme: const InputDecorationTheme(
                      filled: false,
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
                ),
                ListTile(
                  title: TextFormField(
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                      return null;
                    },
                    controller: ctrlIMI,
                    decoration: InputDecoration(
                      icon: const Icon(CupertinoIcons.number_square),
                      errorText: vldErrorIMI ? 'Enter IMEI Number' : null,
                      labelText: 'IMEI Number',
                      border: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    controller: ctrlPrdDis,
                    enabled: false,
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.add_moderator_outlined),
                      errorText: vldErrorDis ? 'Enter Product Description' : null,
                      labelText: 'Product Description',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    controller: ctrlWrM,
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: InputDecoration(
                      icon: const Icon(Icons.calendar_view_month),
                      errorText: vldErrorWrr ? 'Enter warranty months' : null,
                      labelText: 'warranty months',
                      suffixIcon: const Icon(Icons.close),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    controller: ctrlDofM,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.date_range),
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
                const SizedBox(height: 5),
                ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10,),
                      ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: () async {

                          if (_formKey.currentState!.validate() && sldCatID!=0) {
                            _formKey.currentState!.save();

                            final prefs = await SharedPreferences.getInstance();
                            String userID = (prefs.getString('userId') ?? "");
                            final Response response;


                            if(editActive)
                            {
                              /* print(sldModelID);
                            Map<String, Object> body = {
                              "categoryId": sldCatID.toString(),
                              "modelId": sldModelID.toString(),
                              'modelName': modelName.text,
                              'modelDescription': modelDisc.text,
                              'modifyUser': userID,
                            };*/
                              response = await HttpService().putRequest("updateModel",
                                  {});
                            }
                            else{
                              Map<String, Object> body = {
                                'categoryId': sldCatID.toString(),
                                "modelId": sldModID.toString(),
                                "deviceId": ctrlIMI.text,
                                "productDescription": ctrlPrdDis.text,
                                'dateOfManufacturing': ctrlDofM.text,
                                'warrentyMonths': ctrlWrM.text,
                                'createUser': userID,
                              };
                              print(body);
                              response = await HttpService().postRequest("createProduct", body);
                            }
                            print(response);
                            if(response.statusCode == 200)
                            {
                              var data = jsonDecode(response.body);
                              if(data["code"]==200)
                              {
                                ctrlIMI.clear();
                                ctrlPrdDis.clear();
                                ctrlDofM.clear();
                                ctrlWrM.clear();

                                //_showAlertDialog('Message', data["message"]);
                                //ProductInventoryState().callBackAddProduct();
                                Navigator.pop(context);

                               // _showSnackBar(data["message"]);
                                /*showDdError = false;
                              sldCatID = 0;
                              _showSnackBar(data["message"]);
                              getModelList();*/
                              }
                              else{
                                _showAlertDialog('Warning', data["message"]);
                                //Navigator.pop(context);
                                //_showSnackBar(data["message"]);

                              }
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Container(
      margin: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 64,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  )
              ),
              child: ListTile(
                title: const Text("ADD PRODUCT STOCK", style: TextStyle(color: Colors.black),),
                subtitle: Text("Please fill out all fields correctly.", style: myTheme.textTheme.titleSmall,),
              ),
            ),
            Container(
             // height: height-142,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  )
              ),
              child: Expanded(child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(CupertinoIcons.macwindow),
                        title: DropdownMenu<PrdCateModel>(
                          controller: ddCatList,
                          errorText: vldErrorCTL ? 'Select category' : null,
                          hintText: 'Category',
                          width: 305,
                          dropdownMenuEntries: selectedCategory,
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            border: OutlineInputBorder(),
                          ),
                          onSelected: (PrdCateModel? icon) {
                            setState(() {
                              sldCatID = icon!.categoryId;
                              vldErrorCTL = false;
                              getModelByActiveList(sldCatID);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(CupertinoIcons.square_stack_3d_up),
                        title: DropdownMenu<PrdModel>(
                          controller: ddModelList,
                          errorText: vldErrorMDL ? 'Select model' : null,
                          hintText: 'Model',
                          width: 305,
                          dropdownMenuEntries: selectedModel,
                          inputDecorationTheme: const InputDecorationTheme(
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                            border: OutlineInputBorder(),
                          ),
                          onSelected: (PrdModel? icon) {
                            setState(() {
                              sldModID = icon!.categoryId;
                              vldErrorMDL = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: TextFormField(
                          controller: ctrlIMI,
                          decoration: InputDecoration(
                            icon: const Icon(CupertinoIcons.number_square),
                            errorText: vldErrorIMI ? 'Enter IMEI Number' : null,
                            labelText: 'IMEI Number',
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: TextFormField(
                          controller: ctrlPrdDis,
                          validator: (value){
                            if(value==null || value.isEmpty){
                              return 'Please fill out this field';
                            }
                          },
                          decoration: InputDecoration(
                            icon: const Icon(Icons.add_moderator_outlined),
                            errorText: vldErrorDis ? 'Enter Product Description' : null,
                            labelText: 'Product Description',
                            border: const OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: TextFormField(
                          controller: ctrlWrM,
                          validator: (value){
                            if(value==null || value.isEmpty){
                              return 'Please fill out this field';
                            }
                          },
                          decoration: InputDecoration(
                            icon: const Icon(Icons.calendar_view_month),
                            errorText: vldErrorWrr ? 'Enter warranty months' : null,
                            labelText: 'warranty months',
                            suffixIcon: const Icon(Icons.close),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: TextFormField(
                          validator: (value){
                            if(value==null || value.isEmpty){
                              return 'Please fill out this field';
                            }
                          },
                          controller: ctrlDofM,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.date_range),
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),),
            ),
            Container(
              height: 64,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  )
              ),
              child: ListTile(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      child: const Text('Cancel', style: TextStyle(color: Colors.red),),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {

                        if (_formKey.currentState!.validate() && sldCatID!=0) {
                          _formKey.currentState!.save();

                          final prefs = await SharedPreferences.getInstance();
                          String userID = (prefs.getString('userId') ?? "");
                          final Response response;


                          if(editActive)
                          {
                            /* print(sldModelID);
                            Map<String, Object> body = {
                              "categoryId": sldCatID.toString(),
                              "modelId": sldModelID.toString(),
                              'modelName': modelName.text,
                              'modelDescription': modelDisc.text,
                              'modifyUser': userID,
                            };*/
                            response = await HttpService().putRequest("updateModel",
                                {});
                          }
                          else{
                            Map<String, Object> body = {
                              'categoryId': sldCatID.toString(),
                              "modelId": sldModID.toString(),
                              "deviceId": ctrlIMI.text,
                              "productDescription": ctrlPrdDis.text,
                              'dateOfManufacturing': ctrlDofM.text,
                              'warrentyMonths': ctrlWrM.text,
                              'createUser': userID,
                            };
                            print(body);
                            response = await HttpService().postRequest("createProduct", body);
                          }
                          print(response);
                          if(response.statusCode == 200)
                          {
                            var data = jsonDecode(response.body);
                            if(data["code"]==200)
                            {
                              ctrlIMI.clear();
                              ctrlPrdDis.clear();
                              ctrlDofM.clear();
                              ctrlWrM.clear();
                              //Navigator.pop(context);
                              _showSnackBar(data["message"]);

                              /*showDdError = false;
                              sldCatID = 0;
                              _showSnackBar(data["message"]);
                              getModelList();*/
                            }
                            else{
                              //Navigator.pop(context);
                              _showSnackBar(data["message"]);
                            }
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
              ),
            ),
          ],
        ),
      ),
    );
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
