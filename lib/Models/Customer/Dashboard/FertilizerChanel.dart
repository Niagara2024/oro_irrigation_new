class FertilizerChanel {
  int sNo;
  String id;
  String name;
  String location;
  String time;
  String flow;

  FertilizerChanel({required this.sNo, required this.id, required this.name, required this.location,
    required this.time, required this.flow});

  factory FertilizerChanel.fromJson(Map<String, dynamic> json) {
    return FertilizerChanel(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      time: json['time'],
      flow: json['flow'],
    );
  }
}