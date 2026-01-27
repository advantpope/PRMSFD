import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:map/middlewares/geocode.dart';
part 'address.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class Address {
  @HiveField(0)
  final String street;
  @HiveField(1)
  final String city;
  @HiveField(2)
  @JsonKey(name: 'geo')
  final Geocode? geocode;

  Address({required this.street, required this.city, required this.geocode});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
