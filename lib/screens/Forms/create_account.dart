import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:oro_irrigation_new/screens/dash_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/country_list.dart';
import '../../Models/state_list.dart';
import '../../constants/CounterBloc.dart';
import '../../constants/http_service.dart';
import '../../constants/mqtt_manager.dart';
import '../../constants/mqtt_service.dart';
import '../../constants/theme.dart';
import '../home_page.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  String userID = '0';
  String userType = '0';
  String userMobileNo = '0';

  final _formKey = GlobalKey<FormState>();
  bool clearSuffixIcon = false;

  final TextEditingController _cusNameController = TextEditingController();
  final TextEditingController _cusMobileNoController = TextEditingController();
  final TextEditingController _cusEmailController = TextEditingController();
  final TextEditingController _cusCityController = TextEditingController();
  final TextEditingController _cusAdd1Controller = TextEditingController();
  final TextEditingController _cusAdd2Controller = TextEditingController();
  final TextEditingController _cusAdd3Controller = TextEditingController();
  final TextEditingController _cusPinCodeController = TextEditingController();

  final TextEditingController ddCountryList = TextEditingController();
  late List<DropdownMenuEntry<CountryListMDL>> selectedCountry;
  List<CountryListMDL> countryList = <CountryListMDL>[];
  int sldCountryID = 0;
  bool showConError = false;

  final TextEditingController ddStateList = TextEditingController();
  late List<DropdownMenuEntry<StateListMDL>> selectedState;
  List<StateListMDL> stateList = <StateListMDL>[];
  int sldStateID = 0;
  bool showStateError = false;

  String dialCode = '91';

  String message = "No message yet";
  void updateMessage(String newMessage) {
    setState(() {
      message = newMessage;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedCountry =  <DropdownMenuEntry<CountryListMDL>>[];
    selectedState =  <DropdownMenuEntry<StateListMDL>>[];
    getUserInfo();
    getCountryList();
  }

  Future<void> getUserInfo() async
  {
    final prefs = await SharedPreferences.getInstance();
    userID = (prefs.getString('userId') ?? "");
    userType = (prefs.getString('userType') ?? "");
    userMobileNo = (prefs.getString('mobileNumber') ?? "");
  }

  Future<void> getCountryList() async
  {
    Map<String, Object> body = {};
    final response = await HttpService().postRequest("getCountry", body);
    if (response.statusCode == 200)
    {
      countryList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        countryList.add(CountryListMDL.fromJson(cntList[i]));
      }

      selectedCountry =  <DropdownMenuEntry<CountryListMDL>>[];
      for (final CountryListMDL index in countryList) {
        selectedCountry.add(DropdownMenuEntry<CountryListMDL>(value: index, label: index.countryName));
      }

      setState(() {
      });
    }
    else{
      //_showSnackBar(response.body);
    }
  }

  Future<void> getStateList(String countryId) async
  {
    Map<String, Object> body = {
      "countryId": countryId,
    };

    final response = await HttpService().postRequest("getState", body);
    if (response.statusCode == 200)
    {
      stateList.clear();
      var data = jsonDecode(response.body);
      final cntList = data["data"] as List;

      for (int i=0; i < cntList.length; i++) {
        stateList.add(StateListMDL.fromJson(cntList[i]));
      }

      selectedState =  <DropdownMenuEntry<StateListMDL>>[];
      for (final StateListMDL index in stateList) {
        selectedState.add(DropdownMenuEntry<StateListMDL>(value: index, label: index.stateName));
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
    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text(userType=='1'? "Create Dealer account      " : "Create customer account", style: myTheme.textTheme.titleLarge),
                    subtitle: Text("Please fill out all details correctly.", style: myTheme.textTheme.titleSmall),
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    controller: _cusNameController,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Customer Name',
                      icon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 13,),
                  InternationalPhoneNumberInput(
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    inputDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: const OutlineInputBorder(),
                      icon: const Icon(Icons.phone_outlined),
                      labelText: 'Phone Number',
                      suffixIcon: IconButton(icon: Icon(clearSuffixIcon ? Icons.clear : null, color: myTheme.primaryColor,),
                          onPressed: () {
                            _cusMobileNoController.clear();
                            setState(() {
                              clearSuffixIcon = false;
                            });
                          }),
                    ),
                    onInputChanged: (PhoneNumber number) {
                      if(number.phoneNumber!.length > 5){
                        setState(() {
                          clearSuffixIcon = true;
                        });
                      }else{
                        setState(() {
                          clearSuffixIcon = false;
                        });
                      }
                    },

                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      setSelectorButtonAsPrefixIcon: true,
                      leadingPadding: 10,
                      useEmoji: true,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: myTheme.textTheme.titleMedium,
                    initialValue: PhoneNumber(isoCode: 'IN'),
                    textFieldController: _cusMobileNoController,
                    formatInput: false,
                    keyboardType:
                    const TextInputType.numberWithOptions(signed: true, decimal: true),
                    onSaved: (PhoneNumber number) {
                      print('On Saved: $number');
                      dialCode = number.dialCode.toString();
                    },
                  ),
                  const SizedBox(height: 13,),
                  TextFormField(
                    controller: _cusEmailController,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Customer Email',
                      icon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 13,),
                  Row(
                    children: [
                      const Icon(Icons.map_outlined),
                      const SizedBox(width: 15,),
                      DropdownMenu<CountryListMDL>(
                        controller: ddCountryList,
                        errorText: showConError ? 'Select Country' : null,
                        hintText: 'Country',
                        width: 297,
                        //label: const Text('Category'),
                        dropdownMenuEntries: selectedCountry,
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(),
                        ),
                        onSelected: (CountryListMDL? icon) {
                          setState(() {
                            sldCountryID = icon!.countryId;
                            showConError = false;
                            getStateList(sldCountryID.toString());
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 13,),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_outlined),
                      const SizedBox(width: 15,),
                      DropdownMenu<StateListMDL>(
                        controller: ddStateList,
                        errorText: showConError ? 'Select State' : null,
                        hintText: 'State',
                        width: 297,
                        //label: const Text('Category'),
                        dropdownMenuEntries: selectedState,
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(),
                        ),
                        onSelected: (StateListMDL? icon) {
                          setState(() {
                            sldStateID = icon!.stateId;
                            showStateError = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 13,),
                  TextFormField(
                    controller: _cusCityController,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Customer City',
                      icon: Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 13,),
                  TextFormField(
                    controller: _cusAdd1Controller,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Address line 1',
                      icon: Icon(Icons.linear_scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 13,),
                  TextFormField(
                    controller: _cusAdd2Controller,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Address line 2',
                      icon: Icon(Icons.linear_scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 13,),
                  TextFormField(
                    controller: _cusAdd3Controller,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Address line 3',
                      icon: Icon(Icons.linear_scale_rounded),
                    ),
                  ),
                  const SizedBox(height: 13,),
                  TextFormField(
                    controller: _cusPinCodeController,
                    validator: (value){
                      if(value==null ||value.isEmpty){
                        return 'Please fill out this field';
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                      labelText: 'Postal code',
                      icon: Icon(Icons.local_post_office_outlined),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    height:65,
                    child: Column(
                      children: [
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
                                child: const Text('Create'),
                                onPressed: () async {

                                  if (_formKey.currentState!.validate()) {
                                    String cusType = '';
                                    if(userType=='1'){
                                      cusType = '2';
                                    }else if(userType=='2'){
                                      cusType = '3';
                                    }else{
                                      cusType = '4';
                                    }

                                    Map<String, Object> body = {
                                      'userName': _cusNameController.text,
                                      'countryCode': dialCode,
                                      'mobileNumber': _cusMobileNoController.text,
                                      'userType': cusType,
                                      'macAddress': '123456',
                                      'deviceToken': '12346789abcdefghijklmnopqrstuvwxyz987654321',
                                      'mobCctv': '987654321zyxwvutsrqponmlkjihgfedcba123456789',
                                      'createUser': userID,
                                      'address1': _cusAdd1Controller.text,
                                      'address2': _cusAdd2Controller.text,
                                      'address3': _cusAdd3Controller.text,
                                      'city': _cusCityController.text,
                                      'postalCode': _cusPinCodeController.text,
                                      'country': sldCountryID.toString(),
                                      'state': sldStateID.toString(),
                                      'email': _cusEmailController.text,
                                    };
                                    //print(body);
                                    final response = await HttpService().postRequest("createUser", body);
                                    print(response.body);
                                    if(response.statusCode == 200)
                                    {
                                      var data = jsonDecode(response.body);
                                      if(data["code"]==200)
                                      {
                                        MqttService().publishMessage('tweet/$userMobileNo', 'updateCustomerAccount');
                                        if(mounted){
                                          Navigator.pop(context);
                                        }
                                      }
                                      else{
                                        //_showSnackBar(data["message"]);
                                        _showAlertDialog('Warning', data["message"]);
                                      }
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
            ),
          ),
        ],
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


