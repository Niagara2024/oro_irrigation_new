import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/constants/theme.dart';
import 'package:oro_irrigation_new/screens/Customer/configDashboard/pumpView.dart';

class IrrigationLinesView extends StatefulWidget {
  final dynamic irrigationLine;
  const IrrigationLinesView({super.key,required this.irrigationLine});
  @override
  State<IrrigationLinesView> createState() => _IrrigationLinesViewState();
}

class _IrrigationLinesViewState extends State<IrrigationLinesView> {
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
                  child: Text('Line',style: TextStyle(color: Colors.white)),
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
                    itemCount: widget.irrigationLine.length,
                    itemBuilder: (context,index){
                      return Container(
                        color: index % 2 == 0 ? const Color(0xfff3f3f3) : Colors.white,
                        margin: EdgeInsets.only(bottom: index == widget.irrigationLine.length - 1 ? 100 : 0),
                        // height: getHeight(widget.sourcePump[index]) as double,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            Container(
                              // color: index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50,
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          widget.irrigationLine[index]['visible'] = !widget.irrigationLine[index]['visible'];
                                        });
                                      }, icon: Icon(widget.irrigationLine[index]['visible'] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset('assets/images/irrigation_line.png'),
                                  ),
                                  Text('   ${widget.irrigationLine[index]['name']}',style: TextStyle(fontSize: 13),)

                                ],
                              ),
                            ),
                            expandAndCollaps(index,'valveVisible','valve','valve'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['valveVisible'])
                                for(var i in widget.irrigationLine[index]['valveConnection'])
                                  object('${i['name']}',true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(check(widget.irrigationLine[index]['main_valveConnection'],false))
                              expandAndCollaps(index,'mvVisible','main_valve','main valve'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['mvVisible'])
                                for(var i in widget.irrigationLine[index]['main_valveConnection'])
                                  object('${i['name']}',true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(widget.irrigationLine[index]['fanConnection'].isEmpty)
                              expandAndCollaps(index,'fanVisible','fan','fan'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['fanVisible'])
                                if(widget.irrigationLine[index]['fanConnection'].isEmpty)
                                  for(var i in widget.irrigationLine[index]['fanConnection'])
                                    object('${i['name']}',true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(widget.irrigationLine[index]['foggerConnection'].isNotEmpty)
                              expandAndCollaps(index,'foggerVisible','fogger','fogger'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['foggerVisible'])
                                if(widget.irrigationLine[index]['foggerConnection'].isNotEmpty)
                                  for(var i in widget.irrigationLine[index]['foggerConnection'])
                                    object('${i['name']}',true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            const SizedBox(height: 5,),
                            if(widget.irrigationLine[index]['filterConnection'] != null)
                              expandAndCollaps(index,'filterVisible','filter','filter'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['filterVisible'])
                                if(widget.irrigationLine[index]['filterConnection'] != null)
                                  for(var i in widget.irrigationLine[index]['filterConnection'])
                                    object('${i['name']}',true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(widget.irrigationLine[index]['dv'] != null)
                              if(check([widget.irrigationLine[index]['dv']],false))
                                expandAndCollaps(index,'dvVisible','relief_valve','downstream valve'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['dvVisible'])
                                if(widget.irrigationLine[index]['dv'] != null)
                                  if(check([widget.irrigationLine[index]['dv']],false))
                                    if(widget.irrigationLine[index]['dv'] != null)
                                      object('dv',true,widget.irrigationLine[index]['dv'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(widget.irrigationLine[index]['injector'] != null)
                              expandAndCollaps(index,'injectorVisible','channel','channel'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['injectorVisible'])
                                if(widget.irrigationLine[index]['injector'] != null)
                                  for(var i in widget.irrigationLine[index]['injector'])
                                    object(i['name'],true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(widget.irrigationLine[index]['boosterConnection'] != null)
                              if(check(widget.irrigationLine[index]['boosterConnection'],false))
                                expandAndCollaps(index,'boosterVisible','booster_pump','booster'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['boosterVisible'])
                                if(widget.irrigationLine[index]['boosterConnection'] != null)
                                  for(var i in widget.irrigationLine[index]['boosterConnection'])
                                    object('booster',true,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            const SizedBox(height: 5,),
                            if(widget.irrigationLine[index]['ecConnection'] != null)
                              if(check(widget.irrigationLine[index]['ecConnection'],false))
                                expandAndCollaps(index,'ecVisible','ec_sensor','ec'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['ecVisible'])
                                if(widget.irrigationLine[index]['ecConnection'] != null)
                                  for(var i in widget.irrigationLine[index]['ecConnection'])
                                    object('${i['name']}',false,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            if(widget.irrigationLine[index]['phConnection'] != null)
                              if(check(widget.irrigationLine[index]['phConnection'],false))
                                expandAndCollaps(index,'phVisible','ph_sensor','ph'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['phVisible'])
                                if(widget.irrigationLine[index]['phConnection'] != null)
                                  for(var i in widget.irrigationLine[index]['phConnection'])
                                    object('${i['name']}',false,i,index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            const SizedBox(height: 5,),

                            // if(check([widget.irrigationLine[index]['pressureIn']],false))
                            expandAndCollaps(index,'psVisible','pressure_sensor','pressure sensor'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['psVisible'])
                                if(check([widget.irrigationLine[index]['pressureIn']],false))
                                  object('${widget.irrigationLine[index]['pressureIn']['name']}',false,widget.irrigationLine[index]['pressureIn'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['psVisible'])
                                if(widget.irrigationLine[index]['lf_pressureIn'] != null)
                                  object('${widget.irrigationLine[index]['lf_pressureIn']['name']}',false,widget.irrigationLine[index]['lf_pressureIn'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['psVisible'])
                                object('${widget.irrigationLine[index]['pressureOut']['name']}',false,widget.irrigationLine[index]['pressureOut'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['psVisible'])
                                if(widget.irrigationLine[index]['lf_pressureOut'] != null)
                                  object('${widget.irrigationLine[index]['lf_pressureOut']['name']}',false,widget.irrigationLine[index]['lf_pressureOut'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['psVisible'])
                                if(widget.irrigationLine[index]['diffPressureSensor'] != null)
                                  object('${widget.irrigationLine[index]['diffPressureSensor']['name']}',false,widget.irrigationLine[index]['diffPressureSensor'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            const SizedBox(height: 5,),
                            if(widget.irrigationLine[index]['waterMeter'] != null)
                              if(check([widget.irrigationLine[index]['waterMeter']],false))
                                expandAndCollaps(index,'wmVisible','water_meter','water meter'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['wmVisible'])
                                if(widget.irrigationLine[index]['waterMeter'] != null)
                                  object(widget.irrigationLine[index]['waterMeter']['name'],false,widget.irrigationLine[index]['waterMeter'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            const SizedBox(height: 5,),
                            if(widget.irrigationLine[index]['lf_pressureSwitch'] != null)
                              if(check([widget.irrigationLine[index]['lf_pressureSwitch']],false))
                                expandAndCollaps(index,'pSwitchVisible','pressure_switch','pressure switch'),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['pSwitchVisible'])
                                if(widget.irrigationLine[index]['lf_pressureSwitch'] != null)
                                  object('pressure switch',false,widget.irrigationLine[index]['lf_pressureSwitch'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(widget.irrigationLine[index]['visible'])
                              if(widget.irrigationLine[index]['pSwitchVisible'])
                                if(widget.irrigationLine[index]['lf_pressureSwitch'] != null)
                                  object('pressure switch',false,widget.irrigationLine[index]['lf_pressureSwitch'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            SizedBox(height: 30,),
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

  Widget expandAndCollaps(int index,String title, String image,String name){
    return Visibility(
      visible: widget.irrigationLine[index]['visible'],
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: Row(
          children: [
            SizedBox(width: 5,),
            IconButton(
                onPressed: (){
                  setState(() {
                    widget.irrigationLine[index][title] = !widget.irrigationLine[index][title];
                  });
                }, icon: Icon(widget.irrigationLine[index][title] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
            ),
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset('assets/images/$image.png'),
            ),
            SizedBox(width: 5,),
            Text(name)
          ],
        ),
      ),
    );

  }
}
