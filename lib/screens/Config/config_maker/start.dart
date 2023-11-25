import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state_management/config_maker_provider.dart';


class StartPageConfigMaker extends StatefulWidget {
  const StartPageConfigMaker({super.key});
  @override
  State<StartPageConfigMaker> createState() => _StartPageConfigMakerState();
}

class _StartPageConfigMakerState extends State<StartPageConfigMaker> {
  bool isHovered = false;
  bool isHovered1 = false;
  @override
  Widget build(BuildContext context) {
    var configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFFF3F3F3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            onEnter: (_) {
              setState(() {
                isHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                isHovered = false;
              });
            },
            child: InkWell(
              onTap: (){
                print(jsonEncode(configPvd.oldData));
                configPvd.fetchFromServer();
              },
              child: Container(
                width: 250,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isHovered == false ? Colors.white : Colors.blueGrey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.asset('assets/images/data-transfer.png')),
                    Text('Get Data',style: TextStyle(fontSize: 20,color: isHovered == false ? Colors.black : Colors.white,),),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
    // return Container(
    //   color: Color(0XFFF3F3F3),
    //   width: double.infinity,
    //   child: GridView.builder(
    //       padding: EdgeInsets.all(10),
    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6,mainAxisSpacing: 10,crossAxisSpacing: 10),
    //       itemCount: 2,
    //       itemBuilder: (context, index){
    //         return GestureDetector(
    //           child: Container(
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(20),
    //                 color: Colors.white
    //             ),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               children: [
    //                 SizedBox(width: 100,
    //                   height: 100,
    //                   child: Image.asset(returnTitleAndImage(index)[1]),
    //                 ),
    //                 Text('${returnTitleAndImage(index)[0]}',style: TextStyle(fontSize: 20),)
    //               ],
    //             ),
    //           ),
    //         );
    //       }
    //
    //   ),
    // );
  }

  List<String> returnTitleAndImage(int index){
    print('index : ${index}');
    if(index == 0){
      return ['Get Data', 'assets/images/get data.png'];
    }else{
      return ['Start Config', 'assets/images/start_config.png'];
    }
  }

  String returnDeviceName(String title){
    if(title == '2'){
      return 'ORO Smart RTU';
    }else if(title == '3'){
      return 'ORO RTU';
    }else if(title == '5'){
      return 'ORO Switch';
    }else if(title == '7'){
      return 'ORO Sense';
    }else{
      return '-';
    }
  }
}
