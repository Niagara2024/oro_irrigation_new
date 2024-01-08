import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/screens/Customer/ConfigDashboard/pumpView.dart';

import '../../../constants/theme.dart';

class CentralFiltrationView extends StatefulWidget {
  final dynamic centralFiltration;
  const CentralFiltrationView({super.key,required this.centralFiltration});

  @override
  State<CentralFiltrationView> createState() => _CentralFiltrationViewState();
}

class _CentralFiltrationViewState extends State<CentralFiltrationView> {
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
                    itemCount: widget.centralFiltration.length,
                    itemBuilder: (context,index){
                      return Container(
                        color: index % 2 == 0 ? const Color(0xfff3f3f3) : Colors.white,
                        margin: EdgeInsets.only(bottom: index == widget.centralFiltration.length - 1 ? 100 : 0),
                        // height: getHeight(widget.sourcePump[index]) as double,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20,),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        setState(() {
                                          widget.centralFiltration[index]['visible'] = !widget.centralFiltration[index]['visible'];
                                        });
                                      }, icon: Icon(widget.centralFiltration[index]['visible'] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
                                  ),
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset('assets/images/central_filtration_site.png'),
                                  ),
                                  Text('   ${widget.centralFiltration[index]['name']}',style: TextStyle(fontSize: 13),)

                                ],
                              ),
                            ),

                            expandAndCollaps(index,'filterVisible','filter','filter'),
                            if(widget.centralFiltration[index]['visible'])
                              if(widget.centralFiltration[index]['filterVisible'])
                                for(var i = 0;i < widget.centralFiltration[index]['filterConnection'].length;i++)
                                  object('${widget.centralFiltration[index]['filterConnection'][i]['name']}',true,widget.centralFiltration[index]['filterConnection'][i],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            if(check([widget.centralFiltration[index]['dv']],false))
                              expandAndCollaps(index,'dvVisible','downstream_valve','downstream valve'),
                            if(check([widget.centralFiltration[index]['dv']],false))
                              if(widget.centralFiltration[index]['visible'])
                                if(widget.centralFiltration[index]['dvVisible'])
                                  object('dv',true,widget.centralFiltration[index]['dv'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            if(check([widget.centralFiltration[index]['pressureIn']],false) == true || check([widget.centralFiltration[index]['pressureOut']],false) || check([widget.centralFiltration[index]['diffPressureSensor']],false))
                              expandAndCollaps(index,'psVisible','pressure_sensor','pressure sensor'),
                            if(check([widget.centralFiltration[index]['pressureIn']],false))
                              if(widget.centralFiltration[index]['visible'])
                                if(widget.centralFiltration[index]['psVisible'])
                                  object('${widget.centralFiltration[index]['pressureIn']['name']}',false,widget.centralFiltration[index]['pressureIn'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(check([widget.centralFiltration[index]['pressureOut']],false))
                              if(widget.centralFiltration[index]['visible'])
                                if(widget.centralFiltration[index]['psVisible'])
                                  object('${widget.centralFiltration[index]['pressureOut']['name']}',false,widget.centralFiltration[index]['pressureOut'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            if(check([widget.centralFiltration[index]['diffPressureSensor']],false))
                              if(widget.centralFiltration[index]['visible'])
                                if(widget.centralFiltration[index]['psVisible'])
                                  object('Diff. Pressure Sensor',false,widget.centralFiltration[index]['diffPressureSensor'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),

                            if(check([widget.centralFiltration[index]['pressureSwitch']],false))
                              expandAndCollaps(index,'pSwitchVisible','pressure_switch','pressure switch'),
                            if(check([widget.centralFiltration[index]['pressureSwitch']],false))
                              if(widget.centralFiltration[index]['visible'])
                                if(widget.centralFiltration[index]['pSwitchVisible'])
                                  object('pressureSwitch',false,widget.centralFiltration[index]['pressureSwitch'],index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.orange.shade50),
                            SizedBox(height: 30,)

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
      visible: widget.centralFiltration[index]['visible'],
      child: SizedBox(
        width: double.infinity,
        height: 35,
        child: Row(
          children: [
            SizedBox(width: 5,),
            IconButton(
                onPressed: (){
                  setState(() {
                    widget.centralFiltration[index][title] = !widget.centralFiltration[index][title];
                  });
                }, icon: Icon(widget.centralFiltration[index][title] == true ? Icons.add_box_rounded : Icons.indeterminate_check_box)
            ),
            SizedBox(
              width: 35,
              height: 35,
              child: Image.asset('assets/images/$image.png'),
            ),
            Text('$name')
          ],
        ),
      ),
    );

  }
}
