import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../constants/http_service.dart';
import '../../../state_management/config_maker_provider.dart';
import '../../../state_management/constant_provider.dart';
import '../constant/constant_tab_bar_view.dart';
import 'config_maker.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key, required this.userID, required this.customerID, required this.siteID, required this.siteName, required  this.controllerId, required this.imeiNumber});
  final int userID, customerID, siteID, controllerId;
  final String siteName, imeiNumber;

  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    var constantPvd = Provider.of<ConstantProvider>(context,listen: true);
    return Center(
      child: Container(
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                onPressed: ()async{
                  HttpService service = HttpService();
                  try{
                    var response = await service.postRequest('getUserConfigMaker', {'userId' : 21,'controllerId' : 10});
                    var jsonData = jsonDecode(response.body);
                    print('jsonData : ${jsonData['data']}');
                    configPvd.fetchAll(jsonData['data']);
                  }catch(e){
                    print(e.toString());
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ConfigMakerScreen(userID: userID, customerID: customerID, siteID: siteID, imeiNumber: imeiNumber,);
                  }));
                },
                child: Text('Config Maker')
            ),
            ElevatedButton(
              onPressed: ()async{
                HttpService service = HttpService();
                try{
                  var response = await service.postRequest('getUserConstant', {'userId' : 21,'controllerId' : 10});
                  var jsonData = jsonDecode(response.body);
                  print('jsonData : ${jsonEncode(jsonData)}');
                  constantPvd.fetchAll(jsonData['data']);
                }catch(e){
                  print(e.toString());
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ConstantInConfig(userID: userID, customerID: customerID, siteID: siteID,);
                }));
              },
              child: Text('Click to go constant'),
            )
          ],
        ),
      ),
    );
  }
}
