import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'propowner.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class PropertyOwener {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String valuation;
  @HiveField(2)
  final String amount;
  @HiveField(3)
  final String latitude;
  @HiveField(4)
  final String longitude;

  PropertyOwener({
    required this.name,
    required this.valuation,
    required this.amount,
    required this.latitude,
    required this.longitude,
  });
  factory PropertyOwener.fromJson(Map<String, dynamic> json) =>
      _$PropertyOwenerFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyOwenerToJson(this);
}
