import 'package:json_annotation/json_annotation.dart';

part 'flight_data.g.dart';

enum FuelUnit { liters, gallons }

@JsonSerializable(fieldRename: FieldRename.snake)
class FlightPlan {
  final String aircraftRegistration;
  final String flightNumber;
  final String destination;
  final String aircraftModel;
  final double plannedFuel;
  final DateTime date;

  // NEW: Holds the calculated distribution (Target values)
  final TankReadings suggestedDistribution;

  const FlightPlan({
    this.aircraftRegistration = '',
    this.flightNumber = '',
    this.destination = '',
    this.aircraftModel = '',
    this.plannedFuel = 0.0,
    required this.date,
    this.suggestedDistribution = const TankReadings(
      left: 0,
      center: 0,
      right: 0,
    ),
  });

  FlightPlan copyWith({
    String? aircraftRegistration,
    String? flightNumber,
    String? destination,
    String? aircraftModel,
    double? plannedFuel,
    DateTime? date,
    TankReadings? suggestedDistribution,
  }) {
    return FlightPlan(
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      flightNumber: flightNumber ?? this.flightNumber,
      destination: destination ?? this.destination,
      aircraftModel: aircraftModel ?? this.aircraftModel,
      plannedFuel: plannedFuel ?? this.plannedFuel,
      date: date ?? this.date,
      suggestedDistribution:
          suggestedDistribution ?? this.suggestedDistribution,
    );
  }

  factory FlightPlan.fromJson(Map<String, dynamic> json) =>
      _$FlightPlanFromJson(json);
  Map<String, dynamic> toJson() => _$FlightPlanToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TankReadings {
  final double left;
  final double center;
  final double right;

  const TankReadings({this.left = 0.0, this.center = 0.0, this.right = 0.0});

  double get total => left + center + right;

  TankReadings copyWith({double? left, double? center, double? right}) {
    return TankReadings(
      left: left ?? this.left,
      center: center ?? this.center,
      right: right ?? this.right,
    );
  }

  factory TankReadings.fromJson(Map<String, dynamic> json) =>
      _$TankReadingsFromJson(json);
  Map<String, dynamic> toJson() => _$TankReadingsToJson(this);
}

// ... (FuelInputData remains the same as previous step) ...
@JsonSerializable(fieldRename: FieldRename.snake)
class FuelInputData {
  final TankReadings readingsBefore;
  final TankReadings readingsAfter;
  final List<double> truckVolumes;
  final double density;
  final FuelUnit uploadUnit;

  const FuelInputData({
    this.readingsBefore = const TankReadings(),
    this.readingsAfter = const TankReadings(),
    this.truckVolumes = const [0.0],
    this.density = 6.70,
    this.uploadUnit = FuelUnit.liters,
  });

  double get totalTruckVolume =>
      truckVolumes.fold(0, (sum, current) => sum + current);

  FuelInputData copyWith({
    TankReadings? readingsBefore,
    TankReadings? readingsAfter,
    List<double>? truckVolumes,
    double? density,
    FuelUnit? uploadUnit,
  }) {
    return FuelInputData(
      readingsBefore: readingsBefore ?? this.readingsBefore,
      readingsAfter: readingsAfter ?? this.readingsAfter,
      truckVolumes: truckVolumes ?? this.truckVolumes,
      density: density ?? this.density,
      uploadUnit: uploadUnit ?? this.uploadUnit,
    );
  }

  factory FuelInputData.fromJson(Map<String, dynamic> json) =>
      _$FuelInputDataFromJson(json);
  Map<String, dynamic> toJson() => _$FuelInputDataToJson(this);
}
