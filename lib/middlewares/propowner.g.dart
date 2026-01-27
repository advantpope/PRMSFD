// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'propowner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyOwenerAdapter extends TypeAdapter<PropertyOwener> {
  @override
  final typeId = 3;

  @override
  PropertyOwener read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyOwener(
      name: fields[0] as String,
      valuation: fields[1] as String,
      amount: fields[2] as String,
      latitude: fields[3] as String,
      longitude: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PropertyOwener obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyOwenerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyOwener _$PropertyOwenerFromJson(Map<String, dynamic> json) =>
    PropertyOwener(
      name: json['name'] as String,
      valuation: json['valuation'] as String,
      amount: json['amount'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
    );

Map<String, dynamic> _$PropertyOwenerToJson(PropertyOwener instance) =>
    <String, dynamic>{
      'name': instance.name,
      'valuation': instance.valuation,
      'amount': instance.amount,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
