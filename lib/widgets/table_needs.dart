import 'package:flutter/material.dart';
import 'package:oro_irrigation_new/constants/theme.dart';


Widget expandedTableCell_Text(String first,String second,[TextStyle? mystyle]){
  return  Expanded(
    child: Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
          color: myTheme.primaryColor
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${first}',style: mystyle == null ? TextStyle(color: Colors.white) : mystyle,),
          if(second != '')
            Text('${second}',style: mystyle == null ? TextStyle(color: Colors.white) : mystyle,),
        ],
      ),
    ),
  );
}
Widget fixedTableCell_Text(String first,String second,double myWidth,[TextStyle? mystyle]){
  return  Container(
    width: myWidth,
    height: 60,
    decoration: BoxDecoration(
        color: myTheme.primaryColor
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${first}',style: mystyle == null ? TextStyle(color: Colors.white) : mystyle,),
        if(second != '')
          Text('${second}',style: mystyle == null ? TextStyle(color: Colors.white) : mystyle,),
      ],
    ),
  );
}


Widget expandedCustomCell(Widget mywidget,[Color? colors]){
  return  Expanded(
    child: Container(
      color: colors,
      width: double.infinity,
      height: 60,
      child: Center(child: mywidget),
    ),
  );
}

Widget expandedNestedCustomCell(List<Widget> listOfWidget){
  print('came');
  return Expanded(
    child: Container(
      width: double.infinity,
      height: listOfWidget.length * 60,
      child: Column(
        children: [
         ...listOfWidget
        ],
      ),
    ),
  );
}



Widget fixedSizeCustomCell(Widget mywidget,double myWidth, [Color? colors]){
  return  Container(
    width : myWidth,
    color: colors,
    height: 60,
    child: Center(child: mywidget),
  );
}



Widget myTable(List<Widget> listOfHeading,Widget tableRows){
  return LayoutBuilder(builder: (BuildContext context,BoxConstraints constrainst){
    var width = constrainst.maxWidth;
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              ...listOfHeading,
            ],
          ),
          tableRows
        ],
      ),
    );
  });
}

Widget returnMyListTile(String heading,Widget mywidget){
  return Container(
    margin: EdgeInsets.only(bottom: 8),
    height: 70,
    padding: EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 0.5),
    ),
    child: Center(
      child: ListTile(
          focusColor: Colors.white,
          selectedColor: Colors.white,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10.0)
            ),
            child: Center(
              child: Icon(Icons.people),
            ),
          ),
          contentPadding: EdgeInsets.all(0),
          title: Text(heading,style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
          trailing: Container(
            width: 150,
              child: Center(
                  child: mywidget)),
      ),
    ),
  );
}

Widget fixedContainer(Widget myWidget){
  return Container(
    width: 150,
    child: myWidget,
  );
}