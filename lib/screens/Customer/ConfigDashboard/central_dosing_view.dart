import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/pumpView.dart';

import '../../../constants/theme.dart';

class CentralDosingView extends StatefulWidget {
  final dynamic centralDosing;
  const CentralDosingView({super.key,required this.centralDosing});

  @override
  State<CentralDosingView> createState() => _CentralDosingViewState();
}

class _CentralDosingViewState extends State<CentralDosingView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,constraints){
      return Column(
        children: [
          SizedBox(height: 5,),
          Row(
            children: [
              Container(
                width: 230,
                height: 50,
                color: myTheme.primaryColor,
                child: const Center(
                  child: Text('Site',style: TextStyle(color: Colors.white)),
                ),
              ),

              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('Connected to',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('Reference no',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('O/P',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('I/P',style: TextStyle(color: Colors.white)),
                    ),
                  )
              ),
              Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: myTheme.primaryColor,
                    child: const Center(
                      child: Text('I/0 Type',style: TextStyle(color: Colors.white),),
                    ),
                  )
              ),
            ],
          ),

          Expanded(
              child: Container(
                width: double.infinity,
                child: ListView.builder(
                    itemCount: widget.centralDosing.length,
                    itemBuilder: (context,index){
                      return Container(
                        color: index % 2 == 0 ? const Color(0xfff3f3f3) : Colors.white,
                        margin: EdgeInsets.only(bottom: index == widget.centralDosing.length - 1 ? 100 : 0),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20,),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          widget.centralDosing[index]['visible'] = !widget.centralDosing[index]['visible'];
                                        });
                                      }, icon: Icon(widget.centralDosing[index]['visible'] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset('assets/images/central_fertilizer_site.png'),
                                  ),
                                  Text('   ${widget.centralDosing[index]['name']}',style: TextStyle(fontSize: 16,color: Colors.teal.shade800,fontWeight: FontWeight.w900),)

                                ],
                              ),
                            ),
                            const SizedBox(height: 5,),
                            expandAndCollaps(index,'injectorVisible','channel','channel',Colors.indigo),
                            if(widget.centralDosing[index]['visible'])
                              if(widget.centralDosing[index]['injectorVisible'])
                                for(var i = 0;i < widget.centralDosing[index]['injector'].length;i++)
                                  object('${widget.centralDosing[index]['injector'][i]['name']}',true,widget.centralDosing[index]['injector'][i],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(check(widget.centralDosing[index]['injector'],true,'dosingMeter'))
                              expandAndCollaps(index,'dmVisible','fertilizer_meter','fertilizer meter',Colors.indigo),
                            for(var i = 0;i < widget.centralDosing[index]['injector'].length;i++)
                              if(widget.centralDosing[index]['injector'][i]['dosingMeter'].isNotEmpty)
                                if(widget.centralDosing[index]['visible'])
                                  if(widget.centralDosing[index]['dmVisible'])
                                    object('${widget.centralDosing[index]['injector'][i]['dosingMeter']['name']}',false,widget.centralDosing[index]['injector'][i]['dosingMeter'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(check(widget.centralDosing[index]['injector'],true,'levelSensor'))
                              expandAndCollaps(index,'levelVisible','level_sensor','level sensor',Colors.indigo),
                            for(var i = 0;i < widget.centralDosing[index]['injector'].length;i++)
                              if(widget.centralDosing[index]['injector'][i]['levelSensor'].isNotEmpty)
                                if(widget.centralDosing[index]['visible'])
                                  if(widget.centralDosing[index]['levelVisible'])
                                    object('level sensor ${i+1}',false,widget.centralDosing[index]['injector'][i]['levelSensor'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(check(widget.centralDosing[index]['boosterConnection'],false))
                              expandAndCollaps(index,'boosterVisible','booster_pump','booster',Colors.indigo),
                            for(var i = 0;i < widget.centralDosing[index]['boosterConnection'].length;i++)
                              if(widget.centralDosing[index]['visible'])
                                if(widget.centralDosing[index]['boosterVisible'])
                                  object('Booster ${i+1}',true,widget.centralDosing[index]['boosterConnection'][i],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(check(widget.centralDosing[index]['ecConnection'],false))
                              expandAndCollaps(index,'ecVisible','ec_sensor','ec',Colors.indigo),
                            for(var i in widget.centralDosing[index]['ecConnection'])
                              if(widget.centralDosing[index]['visible'])
                                if(widget.centralDosing[index]['ecVisible'])
                                  object('${i['name']}',false,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(check(widget.centralDosing[index]['phConnection'],false))
                              expandAndCollaps(index,'phVisible','ph_sensor','ph',Colors.indigo),
                            if(widget.centralDosing[index]['visible'])
                              if(widget.centralDosing[index]['phVisible'])
                                for(var i in widget.centralDosing[index]['phConnection'])
                                  object('${i['name']}',false,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            SizedBox(height: 50,)
                          ],
                        ),
                      );
                    }),
              )
          )
        ],
      );
    });
  }
  Widget expandAndCollaps(int index,String title, String image,String name,[Color? color]){
    return Visibility(
      visible: widget.centralDosing[index]['visible'],
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: Row(
          children: [
            SizedBox(width: 5,),
            IconButton(
                onPressed: (){
                  setState(() {
                    widget.centralDosing[index][title] = !widget.centralDosing[index][title];
                  });
                }, icon: Icon(widget.centralDosing[index][title] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
            ),
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset('assets/images/$image.png'),
            ),
            SizedBox(width: 5,),
            Text('$name',style: TextStyle(color: color),)
          ],
        ),
      ),
    );

  }
}


