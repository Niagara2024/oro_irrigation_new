import 'CentralFertilizerSite.dart';
import 'CentralFilterSite.dart';
import 'IrrigationPump.dart';
import 'LineOrSequence.dart';
import 'MainValve.dart';
import 'SourcePump.dart';

class DashboardDataProvider
{
  bool startTogether;
  String time, flow;
  int method;
  List<SourcePump> sourcePump;
  List<IrrigationPump> irrigationPump;
  List<MainValve> mainValve;
  List<LineOrSequence> lineOrSequence;
  List<CentralFertilizerSite> centralFertilizerSite;
  List<CentralFilterSite> centralFilterSite;

  DashboardDataProvider({
    required this.startTogether,
    required this.time,
    required this.flow,
    required this.method,
    required this.sourcePump,
    required this.irrigationPump,
    required this.mainValve,
    required this.lineOrSequence,
    required this.centralFertilizerSite,
    required this.centralFilterSite,
  });

  factory DashboardDataProvider.fromJson(Map<String, dynamic> json) {
    bool startTogetherStatus = json['startTogether'];
    String timeVal = json['time'];
    String flowVal = json['flow'];
    int method = json['method'];
    List<SourcePump> sourcePumpList = (json['sourcePump'] as List)
        .map((sourcePumpJson) => SourcePump.fromJson(sourcePumpJson))
        .toList();

    List<IrrigationPump> irrigationPump = (json['irrigationPump'] as List)
        .map((sourcePumpJson) => IrrigationPump.fromJson(sourcePumpJson))
        .toList();

    List<MainValve> mainValve = (json['mainValve'] as List)
        .map((sourcePumpJson) => MainValve.fromJson(sourcePumpJson))
        .toList();

    List<LineOrSequence> lineOrSequence = (json['lineOrSequence'] as List)
        .map((irrigationLineJson) => LineOrSequence.fromJson(irrigationLineJson))
        .toList();

    List<CentralFilterSite> centralFilterSite = (json['centralFilterSite'] as List)
        .map((irrigationLineJson) => CentralFilterSite.fromJson(irrigationLineJson))
        .toList();

    List<CentralFertilizerSite> centralFertilizerSite = (json['centralFertilizerSite'] as List)
        .map((irrigationLineJson) => CentralFertilizerSite.fromJson(irrigationLineJson))
        .toList();

    return DashboardDataProvider(
      startTogether: startTogetherStatus,
      time: timeVal,
      flow: flowVal,
      method: method,
      sourcePump: sourcePumpList,
      mainValve: mainValve,
      lineOrSequence: lineOrSequence,
      irrigationPump: irrigationPump,
      centralFertilizerSite: centralFertilizerSite,
      centralFilterSite: centralFilterSite,
    );
  }

}