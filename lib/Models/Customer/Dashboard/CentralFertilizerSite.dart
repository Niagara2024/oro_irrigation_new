import 'FertilizerChanel.dart';

class CentralFertilizerSite {
  int sNo;
  String id;
  String name;
  String location;
  List<FertilizerChanel> fertilizer;

  CentralFertilizerSite({required this.sNo, required this.id, required this.name, required this.location, required this.fertilizer});

  factory CentralFertilizerSite.fromJson(Map<String, dynamic> json) {

    var fertilizerList = json['fertilizer'] as List;
    List<FertilizerChanel> fertilizer = fertilizerList.map((valveJson) => FertilizerChanel.fromJson(valveJson)).toList();

    return CentralFertilizerSite(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      fertilizer: fertilizer,
    );
  }
}