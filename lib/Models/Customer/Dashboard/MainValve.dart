class MainValve {
  int sNo;
  String id;
  String name;
  String location;

  MainValve({required this.sNo, required this.id, required this.name, required this.location});

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}