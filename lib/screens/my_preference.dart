import 'dart:convert';
import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oro_irrigation_new/constants/theme.dart';

import '../Models/language.dart';
import '../constants/http_service.dart';

class MyPreference extends StatefulWidget {
  const MyPreference({Key? key, required this.userID}) : super(key: key);
  final int userID;

  @override
  State<MyPreference> createState() => _MyPreferenceState();
}

class _MyPreferenceState extends State<MyPreference>
{
  final List<LanguageList> languageList = <LanguageList>[];
  String _mySelection = 'English';

  ImagePicker picker = ImagePicker();
  XFile? image;

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  _getFromGallery() async {
    image = await picker.pickImage(source: ImageSource.gallery);
  }

  Future<void> getLanguage() async
  {
    final response = await HttpService().postRequest("getLanguageByActive", {"active": '1'});
    if (response.statusCode == 200)
    {
      languageList.clear();
      var data = jsonDecode(response.body);
      if(data["code"]==200)
      {
        final cntList = data["data"] as List;
        for (int i=0; i < cntList.length; i++) {
          languageList.add(LanguageList.fromJson(cntList[i]));
        }
      }
      setState(() {
        languageList;
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
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: height-80,
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
                                    child: const ListTile(
                                      title: Text("Account Settings", style: TextStyle(fontSize: 20, color: Colors.black),),
                                      trailing: Icon(Icons.more_horiz, color: Colors.blue,),
                                    ),
                                  ),
                                  SizedBox(height: 2,child: Container(color: Colors.grey.shade200,)),
                                  Container(
                                    height: 380,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.0),
                                        bottomRight: Radius.circular(10.0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex :1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                Stack(
                                                  children: [
                                                    Center(
                                                      child: CircleAvatar(
                                                        radius: 60.0,
                                                        //backgroundImage: image == null? AssetImage('assets/your_image.png') : File(image!.path),
                                                      ),
                                                    ),
                                                    // Positioned button in the bottom-right corner
                                                    Positioned(
                                                      bottom: 10.0,
                                                      right: 50.0,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          print('Button tapped!');
                                                          //_getFromGallery();
                                                        },
                                                        child: const CircleAvatar(
                                                          radius: 20.0,
                                                          backgroundColor: Colors.blue,
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex :2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Mobile Number'),
                                                SizedBox(height: 5,),
                                                SizedBox(
                                                  height: 44,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Enter Mobile Number',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Text('Username'),
                                                SizedBox(height: 5,),
                                                SizedBox(
                                                  height: 44,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Enter Username',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Text('Password'),
                                                SizedBox(height: 5,),
                                                SizedBox(
                                                  height: 44,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Enter Password',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 10,),
                                                Text('Email'),
                                                SizedBox(height: 5,),
                                                SizedBox(
                                                  height: 44,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                      hintText: 'Enter Your Email',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20,),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    MaterialButton(
                                                      color: Colors.grey,
                                                      textColor: Colors.white,
                                                      child: const Text('CANCEL'),
                                                      onPressed: () {

                                                      },
                                                    ),
                                                    const SizedBox(width: 20,),
                                                    MaterialButton(
                                                      color: Colors.blue,
                                                      textColor: Colors.white,
                                                      child: const Text('SAVE CHANGES'),
                                                      onPressed: () async {

                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex :2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              child: const Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('When Mobile Number and Email update', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text("OTP (One-Time Password) is crucial when changing your "
                                                            "mobile number or email associated with the account"
                                                          , style: TextStyle(fontWeight: FontWeight.normal),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15,),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text("When you initiate such changes, the app often sends"
                                                            " an OTP to your current registered mobile number or email address."
                                                            " You need to enter this OTP to confirm and complete the update"
                                                          , style: TextStyle(fontWeight: FontWeight.normal),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(height: 20,),
                                                  Text('Password requirement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      Text('1.'),
                                                      SizedBox(width: 10,),
                                                      Text('at least 6 characters password', style: TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      Text('2.'),
                                                      SizedBox(width: 10,),
                                                      Text('at least one uppercase letter', style: TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Row(
                                                    children: [
                                                      Text('3.'),
                                                      SizedBox(width: 10,),
                                                      Text('at least one number', style: TextStyle(fontWeight: FontWeight.normal),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10,child: Container(color: Colors.grey.shade200,)),
                                  Container(
                                    height: 170,
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
                                                child: const ListTile(
                                                  title: Text('Other Settings', style: TextStyle(fontSize: 20, color: Colors.black),),
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
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                        flex :1,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(15.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              ListTile(
                                                                title: const Text('Language'),
                                                                leading: Icon(Icons.language, color: myTheme.primaryColor,),
                                                                trailing: DropdownButton(
                                                                  items: languageList.map((item) {
                                                                    return DropdownMenuItem(
                                                                      value: item.languageName,
                                                                      child: Text(item.languageName),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged: (newVal) {
                                                                    setState(() {
                                                                      _mySelection = newVal!;
                                                                    });
                                                                  },
                                                                  value: _mySelection,
                                                                ),
                                                              ),
                                                              ListTile(
                                                                title: const Text('Theme(Light/Dark)'),
                                                                leading: Icon(Icons.color_lens_outlined,  color: myTheme.primaryColor,),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex :1,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: Container(
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SwitchListTile(
                                                                  tileColor: Colors.red,
                                                                  secondary: Icon(Icons.notifications_none, color: myTheme.primaryColor,),
                                                                  title:  const Text('Push Notification'),
                                                                  value: true,
                                                                  onChanged:(bool? value) { },
                                                                ),
                                                                SwitchListTile(
                                                                  tileColor: Colors.red,
                                                                  secondary: Icon(Icons.volume_up_outlined, color: myTheme.primaryColor,),
                                                                  title:  const Text('Sound'),
                                                                  value: true,
                                                                  onChanged:(bool? value) { },
                                                                ),
                                                              ],
                                                            ),
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
