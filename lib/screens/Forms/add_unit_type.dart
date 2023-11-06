import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/unit_type.dart';
import '../../constants/http_service.dart';
import '../../constants/theme.dart';

class AddUnitType extends StatefulWidget {
  const AddUnitType({Key? key}) : super(key: key);

  @override
  State<AddUnitType> createState() => _AddUnitTypeState();
}

class _AddUnitTypeState extends State<AddUnitType> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController unitTypeCtl = TextEditingController();
  TextEditingController unitDisCtl = TextEditingController();

  List<UnitType> unitTypeList = <UnitType>[];
  bool editUnitType = false;
  bool editActive = false;
  int sldUnitTypeID = 0;

  @override
  void initState() {
    super.initState();
    getUnitTypeList();
  }

  Future<void> getUnitTypeList() async
  {
    Map<String, Object> body = {};
    final response = await HttpService().postRequest("getUnitType", body);
    if (response.statusCode == 200)
    {
      unitTypeList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        unitTypeList.add(UnitType.fromJson(cntList[i]));
      }
      setState(() {
        unitTypeList;
      });
    }
    else{
      _showSnackBar(response.body);
    }
  }

  @override
  Widget build(BuildContext context)
  {
    final mediaQuery = MediaQuery.of(context);
    //final Color color = Colors.primaries[contactList.length % Colors.primaries.length];
    return Container(
      color:  Colors.blueGrey.shade50,
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    color: Colors.white,
                    child: ListTile(
                      title: Text('Unit Types', style: myTheme.textTheme.titleLarge),
                      subtitle: Text('Unit types with Description', style: myTheme.textTheme.titleSmall),
                      trailing: IconButton(onPressed: ()
                      {
                        setState(() {
                          editUnitType = !editUnitType;
                          editActive = false;
                        });
                        unitTypeCtl.clear();
                        unitDisCtl.clear();
                      }, icon: editUnitType ? Icon(Icons.done_all, color: myTheme.primaryColor,) : Icon(Icons.edit_note_outlined, color: myTheme.primaryColor,)),
                    ),
                  ),
                  Expanded(
                      child: GridView.builder(
                        itemCount: unitTypeList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsetsDirectional.all(5.0),
                            decoration: BoxDecoration(
                              color: unitTypeList[index].active=='1'? myTheme.primaryColor.withOpacity(0.2) : Colors.red.shade100,
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: ListTile(
                              title: Text(unitTypeList[index].unit),
                              subtitle: Text(unitTypeList[index].unitDescription,),
                              trailing: editUnitType ? Wrap(
                                spacing: 12, // space between two icons
                                children: <Widget>[
                                  IconButton(onPressed: ()
                                  {
                                    unitTypeCtl.text = unitTypeList[index].unit;
                                    unitDisCtl.text = unitTypeList[index].unitDescription;
                                    sldUnitTypeID = unitTypeList[index].unitTypeId;

                                    setState(() {
                                      editActive = true;
                                    });

                                  }, icon: Icon(Icons.edit_outlined, color: myTheme.primaryColor,),),
                                  IconButton(onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    String userID = (prefs.getString('userId') ?? "");

                                    Map<String, Object> body = {
                                      'unitTypeId': unitTypeList[index].unitTypeId.toString(),
                                      'modifyUser': userID,
                                    };

                                    final Response response;
                                    if(unitTypeList[index].active=='1'){
                                      response = await HttpService().putRequest("inactiveUnitType", body);
                                    }else{
                                      response = await HttpService().putRequest("activeUnitType", body);
                                    }

                                    if(response.statusCode == 200)
                                    {
                                      var data = jsonDecode(response.body);
                                      if(data["code"]==200)
                                      {
                                        _showSnackBar(data["message"]);
                                        getUnitTypeList();
                                      }
                                      else{
                                        _showSnackBar(data["message"]);
                                      }
                                    }else{
                                      _showSnackBar(response.body);
                                    }

                                  }, icon: unitTypeList[index].active=='1'? Icon(Icons.check_circle_outlined, color: Colors.green,):Icon(Icons.unpublished_outlined, color: Colors.red,)),
                                ],
                              ): null,
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: mediaQuery.size.width > 1200 ? 2 : 1,
                          childAspectRatio: mediaQuery.size.width / 250,
                        ),
                      )),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    color: Colors.white,
                    child: ListTile(
                      title: Text("Add Unit Type", style: myTheme.textTheme.titleLarge),
                      subtitle: Text("Please fill out all details correctly.", style: myTheme.textTheme.titleSmall),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 10,),
                              TextFormField(
                                controller: unitTypeCtl,
                                validator: (value){
                                  if(value==null ||value.isEmpty){
                                    return 'Please fill out this field';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  border: OutlineInputBorder(),
                                  labelText: 'Unit Type',
                                  icon: Icon(Icons.contactless_outlined),
                                ),
                              ),
                              const SizedBox(height: 13,),
                              TextFormField(
                                controller: unitDisCtl,
                                validator: (value){
                                  if(value==null ||value.isEmpty){
                                    return 'Please fill out this field';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  border: OutlineInputBorder(),
                                  labelText: 'Unit Description',
                                  icon: Icon(Icons.content_paste_go),
                                ),
                              ),
                              const SizedBox(height: 20,),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                  Container(
                    height: 60,
                    color: Colors.white,
                    child: ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            child: editActive ? const Text('Save'): const Text('Submit'),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                final prefs = await SharedPreferences.getInstance();
                                String userID = (prefs.getString('userId') ?? "");
                                final Response response;

                                if(editActive){
                                  print(sldUnitTypeID);
                                  Map<String, Object> body = {
                                    "unitTypeId": sldUnitTypeID.toString(),
                                    'unit': unitTypeCtl.text,
                                    'unitDescription': unitDisCtl.text,
                                    'modifyUser': userID,
                                  };
                                  response = await HttpService().putRequest("updateUnitType", body);
                                }
                                else{
                                  Map<String, Object> body = {
                                    'unit': unitTypeCtl.text,
                                    'unitDescription': unitDisCtl.text,
                                    'createUser': userID,
                                  };
                                  response = await HttpService().postRequest("createUnitType", body);
                                }

                                if(response.statusCode == 200)
                                {
                                  var data = jsonDecode(response.body);
                                  if(data["code"]==200)
                                  {
                                    unitTypeCtl.clear();
                                    unitDisCtl.clear();
                                    _showSnackBar(data["message"]);
                                    getUnitTypeList();
                                  }
                                  else{
                                    _showSnackBar(data["message"]);
                                  }
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
          ),
        ],
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
}
