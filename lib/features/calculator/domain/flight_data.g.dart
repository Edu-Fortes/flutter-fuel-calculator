// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlightPlan _$FlightPlanFromJson(Map<String, dynamic> json) => FlightPlan(
  aircraftRegistration: json['aircraft_registration'] as String? ?? '',
  flightNumber: json['flight_number'] as String? ?? '',
  destination: json['destination'] as String? ?? '',
  aircraftModel: json['aircraft_model'] as String? ?? '',
  plannedFuel: (json['planned_fuel'] as num?)?.toDouble() ?? 0.0,
  extraFuel: (json['extra_fuel'] as num?)?.toDouble() ?? 0.0,
  date: DateTime.parse(json['date'] as String),
  suggestedDistribution: json['suggested_distribution'] == null
      ? const TankReadings(left: 0, center: 0, right: 0)
      : TankReadings.fromJson(
          json['suggested_distribution'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$FlightPlanToJson(FlightPlan instance) =>
    <String, dynamic>{
      'aircraft_registration': instance.aircraftRegistration,
      'flight_number': instance.flightNumber,
      'destination': instance.destination,
      'aircraft_model': instance.aircraftModel,
      'planned_fuel': instance.plannedFuel,
      'extra_fuel': instance.extraFuel,
      'date': instance.date.toIso8601String(),
      'suggested_distribution': instance.suggestedDistribution,
    };

TankReadings _$TankReadingsFromJson(Map<String, dynamic> json) => TankReadings(
  left: (json['left'] as num?)?.toDouble() ?? 0.0,
  center: (json['center'] as num?)?.toDouble() ?? 0.0,
  right: (json['right'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$TankReadingsToJson(TankReadings instance) =>
    <String, dynamic>{
      'left': instance.left,
      'center': instance.center,
      'right': instance.right,
    };

FuelInputData _$FuelInputDataFromJson(
  Map<String, dynamic> json,
) => FuelInputData(
  readingsBefore: json['readings_before'] == null
      ? const TankReadings()
      : TankReadings.fromJson(json['readings_before'] as Map<String, dynamic>),
  readingsAfter: json['readings_after'] == null
      ? const TankReadings()
      : TankReadings.fromJson(json['readings_after'] as Map<String, dynamic>),
  truckVolumes:
      (json['truck_volumes'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      const [0.0],
  density: (json['density'] as num?)?.toDouble() ?? 6.70,
  uploadUnit:
      $enumDecodeNullable(_$FuelUnitEnumMap, json['upload_unit']) ??
      FuelUnit.liters,
);

Map<String, dynamic> _$FuelInputDataToJson(FuelInputData instance) =>
    <String, dynamic>{
      'readings_before': instance.readingsBefore,
      'readings_after': instance.readingsAfter,
      'truck_volumes': instance.truckVolumes,
      'density': instance.density,
      'upload_unit': _$FuelUnitEnumMap[instance.uploadUnit]!,
    };

const _$FuelUnitEnumMap = {
  FuelUnit.liters: 'liters',
  FuelUnit.gallons: 'gallons',
};
