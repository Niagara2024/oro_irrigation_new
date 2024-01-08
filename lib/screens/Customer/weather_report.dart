import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import '../../constants/theme.dart';

enum Segment { Hourly, Weekly, Monthly }

class WeatherReportbar extends StatelessWidget {
  WeatherReportbar(
      {super.key,
        required this.tempdata,
        required this.timedata,required this.title,
        required this.titletype});
  List tempdata = [];
  List timedata = [];
  String title;
  String titletype;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title')),
      body: ScrollableChart(
        tempdata: tempdata,
        timedata: timedata, titletype: titletype,

      ),
    );
  }
}

class ScrollableChart extends StatefulWidget {
  ScrollableChart({super.key, required this.tempdata, required this.timedata,required this.titletype});
  List tempdata = [];
  List timedata = [];
  Segment selectedSegment = Segment.Hourly;
  String titletype;

  @override
  State<ScrollableChart> createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<ScrollableChart> {
  @override

  @override
  Widget build(BuildContext context) {
    List<SalesData> chartData = [];
    List week = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    List Month = ['Jan','Feb','Mar','Apr','May','June','July','Aug','Sep','Oct','Nov','Dec'];
    List<String> charList = widget.titletype.split('');
    for (int index = 0; index < widget.tempdata.length; index++) {
      List<String> part = widget.timedata[index].split('T');
      String replacedValue =  part[1];
      chartData.add(SalesData(replacedValue, widget.tempdata[index]));
    }
    //      String replacedValue = '${part[1]} $index';?
    String yaxixname = 'Hours';
    print('selectedSegment ${widget.selectedSegment}');
    print(chartData);
    if (widget.selectedSegment == Segment.Hourly) {
      yaxixname = 'Hours';
      chartData = chartData.sublist(0, 24);
    } else if (widget.selectedSegment == Segment.Weekly) {
      yaxixname = 'Days';
      chartData = [];
      // chartData = chartData.sublist(0, 7);
      for (int index = 0; index < 7; index++) {
        String replacedValue = '${week[index]}' ;
        chartData.add(SalesData(replacedValue, widget.tempdata[index]));
      }
    }
    else
    {
      chartData = [];
      for (int index = 0; index < 30; index++) {
        String replacedValue = '${index+1}' ;
        chartData.add(SalesData(replacedValue, widget.tempdata[index]));
      }

      // chartData = chartData.sublist(0, 30);
      yaxixname = 'Days';
    }
    print('chartData');
    print(chartData);
    // }
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        SegmentedButton<Segment>(
          style: ButtonStyle(
            backgroundColor:
            MaterialStatePropertyAll(myTheme.primaryColor.withOpacity(0.1)),
            iconColor: MaterialStateProperty.all(myTheme.primaryColor),
          ),
          segments: const <ButtonSegment<Segment>>[
            ButtonSegment<Segment>(
                value: Segment.Hourly,
                label: Text('Hourly'),
                icon: Icon(Icons.calendar_today_outlined)),
            ButtonSegment<Segment>(
                value: Segment.Weekly,
                label: Text('Weekly'),
                icon: Icon(Icons.calendar_view_week)),
            ButtonSegment<Segment>(
                value: Segment.Monthly,
                label: Text('Monthly'),
                icon: Icon(Icons.calendar_month)),
          ],
          selected: <Segment>{widget.selectedSegment},
          onSelectionChanged: (Set<Segment> newSelection) {
            setState(() {
              print('selectedSegment${widget.selectedSegment}');
              widget.selectedSegment = newSelection.first;
            });
          },
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: Center(
            child: widget.selectedSegment == Segment.Hourly ? SfCartesianChart(
              backgroundColor: Colors.grey[200], // Background color
              enableSideBySideSeriesPlacement: true,
              borderColor: Colors.blue, // Border color
              borderWidth: 1.5, // Border width
              plotAreaBackgroundColor: Colors.white,
              plotAreaBorderColor: Colors.grey[400],
              plotAreaBorderWidth: 0.5,

              onMarkerRender: (MarkerRenderArgs markerRenderArgs) {
                markerRenderArgs.color = Colors.red;
                markerRenderArgs.borderWidth = 2;
              },
              palette: const <Color>[
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
              // Add your chart properties and data here
              zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true,
                enablePanning: true,
                enableDoubleTapZooming: true,

              ),
              // Axis names

              primaryXAxis: CategoryAxis(title: AxisTitle(text: yaxixname),autoScrollingMode: AutoScrollingMode.start ),
              primaryYAxis: NumericAxis(title: AxisTitle(text: widget.titletype)),
              series: <ChartSeries>[
                LineSeries<SalesData, String>(
                  dataSource: chartData,
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  xValueMapper: (SalesData sales, _) => sales.year,
                  yValueMapper: (SalesData sales, _) => sales.sales,
                  name: 'name',
                  yAxisName:'Sales',
                  xAxisName:'Year',
                  isVisibleInLegend: true,
                  legendItemText: 'graph',
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    color: Colors.blue,
                    height: 10,
                    width: 10,
                    shape: DataMarkerType.circle,
                  ),

                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: widget.titletype,
                duration: 0.5,

              ),
            ) : SfCartesianChart(
                backgroundColor: Colors.grey[200],
                enableSideBySideSeriesPlacement: true,
                borderColor: Colors.blue, // Border color
                borderWidth: 1.5, // Border width
                plotAreaBackgroundColor: Colors.white,
                plotAreaBorderColor: Colors.grey[400],
                plotAreaBorderWidth: 0.5,
                primaryXAxis: CategoryAxis(title: AxisTitle(text: yaxixname),autoScrollingMode: AutoScrollingMode.start ),
                primaryYAxis: NumericAxis(title: AxisTitle(text: widget.titletype)),
                // primaryXAxis: CategoryAxis(),
                // primaryYAxis: NumericAxis(minimum: 0, maximum: 40, interval: 10),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: widget.titletype,
                  duration: 1.0,

                ),
                series: <ChartSeries>[
                  ColumnSeries<SalesData, String>(
                      width: 0.2,
                      dataSource: chartData,
                      xValueMapper: (SalesData sales, _) => sales.year,
                      yValueMapper: (SalesData sales, _) => sales.sales,
                      name: widget.titletype,
                      color: Color.fromRGBO(8, 142, 255, 1))
                ]) ,

          ),
        ),

      ],
    );
  }
}
class SalesData {
  final String year;
  final double sales;

  SalesData(this.year, this.sales);
}