class UnitType
{
  UnitType({
    this.unitTypeId = 0,
    this.unit = '',
    this.unitDescription = '',
    this.active = '',
  });

  int unitTypeId;
  String unit, unitDescription, active;

  factory UnitType.fromJson(Map<String, dynamic> json) => UnitType(
    unitTypeId: json['unitTypeId'],
    unit: json['unit'],
    unitDescription: json['unitDescription'],
    active: json['active'],
  );

  Map<String, dynamic> toJson() => {
    'unitTypeId': unitTypeId,
    'unit': unit,
    'unitDescription': unitDescription,
    'active': active,
  };
}