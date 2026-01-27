import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'address.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
@JsonSerializable(explicitToJson: true)
class User {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String username;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final Address? address;
  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
