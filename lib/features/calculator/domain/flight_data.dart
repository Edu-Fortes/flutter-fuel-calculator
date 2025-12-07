import 'package:json_annotation/json_annotation.dart';

part 'flight_data.g.dart';

/// Represents the unit of measurement for fuel.
enum FuelUnit { liters, gallons }

/// Holds the configuration data for the "Plan" tab.
@JsonSerializable(fieldRename: FieldRename.snake)
class FlightPlan {
  final String aircraftRegistration;
  final String flightNumber;
  final String destination;
  final String aircraftModel;
  final double plannedFuel;
  final DateTime date;

  const FlightPlan({
    this.aircraftRegistration = '',
    this.flightNumber = '',
    this.destination = '',
    this.aircraftModel = '',
    this.plannedFuel = 0.0,
    required this.date,
  });

  /// Creates a copy of this object with the given fields replaced with the new values.
  FlightPlan copyWith({
    String? aircraftRegistration,
    String? flightNumber,
    String? destination,
    String? aircraftModel,
    double? plannedFuel,
    DateTime? date,
  }) {
    return FlightPlan(
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      flightNumber: flightNumber ?? this.flightNumber,
      destination: destination ?? this.destination,
      aircraftModel: aircraftModel ?? this.aircraftModel,
      plannedFuel: plannedFuel ?? this.plannedFuel,
      date: date ?? this.date,
    );
  }

  factory FlightPlan.fromJson(Map<String, dynamic> json) =>
      _$FlightPlanFromJson(json);
  Map<String, dynamic> toJson() => _$FlightPlanToJson(this);
}

/// Holds the tank readings (Left, Center, Right).
@JsonSerializable(fieldRename: FieldRename.snake)
class TankReadings {
  final double? left;
  final double? center;
  final double? right;

  const TankReadings({this.left, this.center, this.right});

  double get total => (left ?? 0) + (center ?? 0) + (right ?? 0);

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

/// Holds the data for the "Inputs" tab (Before/After readings and Uplift).
@JsonSerializable(fieldRename: FieldRename.snake)
class FuelInputData {
  final TankReadings readingsBefore;
  final TankReadings readingsAfter;

  // A list to support 1 to N trucks
  final List<double> truckVolumes;

  final double density;
  final FuelUnit uploadUnit;

  const FuelInputData({
    this.readingsBefore = const TankReadings(),
    this.readingsAfter = const TankReadings(),
    this.truckVolumes = const [0.0], // Start with one empty truck by default
    this.density = 0.800,
    this.uploadUnit = FuelUnit.liters,
  });

  /// Helper to get total volume from all trucks
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
