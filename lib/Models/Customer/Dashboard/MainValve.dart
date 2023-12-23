class MainValve {
  int sNo;
  String id;
  String name;
  String location;
  bool selected;

  MainValve({required this.sNo, required this.id, required this.name, required this.location, required this.selected});

  factory MainValve.fromJson(Map<String, dynamic> json) {
    return MainValve(
      sNo: json['sNo'],
      id: json['id'],
      name: json['name'],
      location: json['location'],
      selected: json['selected'],
    );
  }
}