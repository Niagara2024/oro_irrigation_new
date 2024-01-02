import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math' as math;
import '../../constants/theme.dart';

enum Segment { Weekly, Monthly, Yearly }

class WeatherReport extends StatelessWidget {
  WeatherReport(
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
  Segment selectedSegment = Segment.Weekly;
  String titletype;

  @override
  State<ScrollableChart> createState() => _ScrollableChartState();
}

class _ScrollableChartState extends State<ScrollableChart> {
  @override
  Widget build1(BuildContext context) {
    List<SalesData> chartData = [];
    List<String> charList = widget.titletype.split('');
    for (int index = 0; index < widget.tempdata.length; index++) {
      List<String> part = widget.timedata[index].split('T');
      String replacedValue = part[1];
      chartData.add(SalesData(replacedValue, widget.tempdata[index]));
    }
    if (widget.selectedSegment == Segment.Weekly) {
      chartData = chartData.sublist(0, 7);
    } else if (widget.selectedSegment == Segment.Monthly) {
      chartData = chartData.sublist(0, 30);
    }
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
                value: Segment.Weekly,
                label: Text('Weekly'),
                icon: Icon(Icons.calendar_today_outlined)),
            ButtonSegment<Segment>(
                value: Segment.Monthly,
                label: Text('Monthly'),
                icon: Icon(Icons.calendar_view_week)),
            ButtonSegment<Segment>(
                value: Segment.Yearly,
                label: Text('Yearly'),
                icon: Icon(Icons.calendar_month)),
          ],
          selected: <Segment>{widget.selectedSegment},
          onSelectionChanged: (Set<Segment> newSelection) {
            setState(() {
              print('selectedSegment$widget.selectedSegment');
              widget.selectedSegment = newSelection.first;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    for (var i in charList)
                      Text(i)
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width -
                        100, // chartData.length * 20 < MediaQuery.of(context).size.width ? MediaQuery.of(context).size.width : chartData.length * 20, // Set width to ensure chart's width
                    height: 400,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            // spots: chartData,
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 1,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: true),
                          ),
                        ],
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        // rangeAnnotations: RangeAnnotations(),
                      ),
                    ),
                  ),
                  Text('Hours')
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<SalesData> chartData = [];
    List<String> charList = widget.titletype.split('');
    for (int index = 0; index < widget.tempdata.length; index++) {
      List<String> part = widget.timedata[index].split('T');
      String replacedValue = part[1];
      chartData.add(SalesData(replacedValue, widget.tempdata[index]));
    }
    //      String replacedValue = '${part[1]} $index';
    // if (widget.selectedSegment == Segment.Weekly) {
    //   chartData = chartData.sublist(0, 7);
    // } else if (widget.selectedSegment == Segment.Monthly) {

    chartData = chartData.sublist(0, 24);
    if(widget.titletype == 'Temperature')
    {
      chartData = chartData.sublist(8, 24);
    }
    // }
    return Center(
      child: Expanded(
        child: Container(
          // Adjust the container size as needed
          // width: 800,
          // height: 800,
          child: SfCartesianChart(
            backgroundColor: Colors.grey[200], // Background color
            enableSideBySideSeriesPlacement: true,
            borderColor: Colors.blue, // Border color
            borderWidth: 1.5, // Border width
            plotAreaBackgroundColor: Colors.white,
            plotAreaBorderColor: Colors.grey[400],
            plotAreaBorderWidth: 0.5,
            onMarkerRender: (MarkerRenderArgs markerRenderArgs) {
              markerRenderArgs.color = Colors.red; // Custom marker color
              markerRenderArgs.borderWidth = 2; // Custom marker border width
            },
            palette: <Color>[
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

            primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Hours'),autoScrollingMode: AutoScrollingMode.start ),
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
                markerSettings: MarkerSettings(
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
          ),
        ),
      ),

    );
  }
}
class SalesData {
  final String year;
  final double sales;

  SalesData(this.year, this.sales);
}