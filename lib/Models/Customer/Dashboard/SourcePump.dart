class SourcePump {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  SourcePump({required this.sNo, required this.id, required this.name, required this.location, required this.selected});

  factory SourcePump.fromJson(Map<String, dynamic> json) {
    return SourcePump(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}