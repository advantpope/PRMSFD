// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geocode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeocodeAdapter extends TypeAdapter<Geocode> {
  @override
  final typeId = 2;

  @override
  Geocode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Geocode(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Geocode obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeocodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Geocode _$GeocodeFromJson(Map<String, dynamic> json) => Geocode(
  latitude: Geocode._toDouble(json['lat']),
  longitude: Geocode._toDouble(json['lng']),
);

Map<String, dynamic> _$GeocodeToJson(Geocode instance) => <String, dynamic>{
  'lat': instance.latitude,
  'lng': instance.longitude,
};
