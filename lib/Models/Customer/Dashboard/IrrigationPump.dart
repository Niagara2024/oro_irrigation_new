class IrrigationPump {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  IrrigationPump({required this.sNo, required this.id, required this.name, required this.location, required this.selected});

  factory IrrigationPump.fromJson(Map<String, dynamic> json) {
    return IrrigationPump(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}