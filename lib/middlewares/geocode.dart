import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'geocode.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class Geocode {
  @HiveField(0)
  @JsonKey(name: 'lat', fromJson: _toDouble)
  final double latitude;

  @HiveField(1)
  @JsonKey(name: 'lng', fromJson: _toDouble)
  final double longitude;

  Geocode({required this.latitude, required this.longitude});

  factory Geocode.fromJson(Map<String, dynamic> json) =>
      _$GeocodeFromJson(json);

  Map<String, dynamic> toJson() => _$GeocodeToJson(this);

  static double _toDouble(dynamic value) {
    try {
      return double.parse(value.toString());
    } catch (_) {
      print('Failed to parse geocode: $value');
      return 0.0;
    }
  }
}
