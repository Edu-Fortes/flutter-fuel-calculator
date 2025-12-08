import 'package:flutter/foundation.dart';
import '../domain/flight_data.dart';

class CalculatorController extends ChangeNotifier {
  // --- Constants for Limits ---
  static const double kMaxTankSafe = 40.1; // Distribution limit
  static const double kLitersToGallons = 0.2641; // Conversion Factor

  // --- State ---
  FlightPlan _plan = FlightPlan(date: DateTime.now(), aircraftModel: '767');
  FuelInputData _inputs = const FuelInputData();

  // --- Getters ---
  FlightPlan get plan => _plan;
  FuelInputData get inputs => _inputs;

  // --- Actions ---
  void reset() {
    _plan = FlightPlan(date: DateTime.now(), aircraftModel: '767');
    _inputs = const FuelInputData(density: 6.70, uploadUnit: FuelUnit.liters);
    notifyListeners();
  }

  // --- Helpers for Display ---
  double get totalTruckRawVolume => _inputs.totalTruckVolume;

  double _roundTo1Decimal(double value) {
    return (value * 10).round() / 10;
  }

  String get formattedRegistration {
    final raw = _plan.aircraftRegistration;
    if (raw.isEmpty) return 'N/A';
    return 'N${raw}FE';
  }

  // --- Logic: Plan & Distribution ---

  void updateFlightDetails({
    String? reg,
    String? flightNum,
    String? dest,
    String? model,
    DateTime? date,
  }) {
    _plan = _plan.copyWith(
      aircraftRegistration: reg,
      flightNumber: flightNum,
      destination: dest?.toUpperCase(),
      aircraftModel: model,
      date: date,
    );
    notifyListeners();
  }

  void updatePlannedFuel(String value) {
    final double? base = double.tryParse(value);
    if (base == null) return;

    // Update Base
    _plan = _plan.copyWith(plannedFuel: base);
    _recalculateDistribution();
  }

  // NEW: Update Extra Fuel
  void updateExtraFuel(double delta) {
    double newExtra = _plan.extraFuel + delta;
    // Fix floating point errors (e.g. 0.3000004)
    newExtra = double.parse(newExtra.toStringAsFixed(1));

    // Prevent negative? Assuming yes for now.
    if (newExtra < 0) newExtra = 0.0;

    _plan = _plan.copyWith(extraFuel: newExtra);
    _recalculateDistribution();
  }

  void _recalculateDistribution() {
    // 1. Calculate Target (Base + Extra)
    final double totalRequested = _plan.totalTargetFuel;

    double left = 0;
    double right = 0;
    double center = 0;

    const double wingCapacity = kMaxTankSafe * 2;

    if (totalRequested <= wingCapacity) {
      left = totalRequested / 2;
      right = totalRequested / 2;
      center = 0;
    } else {
      left = kMaxTankSafe;
      right = kMaxTankSafe;
      center = totalRequested - wingCapacity;
    }

    // 2. Update Plan
    _plan = _plan.copyWith(
      suggestedDistribution: TankReadings(
        left: _roundTo1Decimal(left),
        right: _roundTo1Decimal(right),
        center: _roundTo1Decimal(center),
      ),
    );
    notifyListeners();
  }

  // --- Logic: Truck Management ---
  void addTruck() {
    final updatedList = List<double>.from(_inputs.truckVolumes)..add(0.0);
    _inputs = _inputs.copyWith(truckVolumes: updatedList);
    notifyListeners();
  }

  void removeTruck(int index) {
    if (_inputs.truckVolumes.length <= 1) return;
    final updatedList = List<double>.from(_inputs.truckVolumes)
      ..removeAt(index);
    _inputs = _inputs.copyWith(truckVolumes: updatedList);
    notifyListeners();
  }

  void updateTruckVolume(int index, String value) {
    final double? parsed = double.tryParse(value);
    if (parsed == null) return;
    final updatedList = List<double>.from(_inputs.truckVolumes);
    updatedList[index] = parsed;
    _inputs = _inputs.copyWith(truckVolumes: updatedList);
    notifyListeners();
  }

  void toggleTruckUnit(FuelUnit unit) {
    _inputs = _inputs.copyWith(uploadUnit: unit);
    notifyListeners();
  }

  // --- Logic: Tank Readings ---
  void updateReadingBefore({double? left, double? center, double? right}) {
    _inputs = _inputs.copyWith(
      readingsBefore: _inputs.readingsBefore.copyWith(
        left: left,
        center: center,
        right: right,
      ),
    );
    notifyListeners();
  }

  void updateReadingAfter({double? left, double? center, double? right}) {
    _inputs = _inputs.copyWith(
      readingsAfter: _inputs.readingsAfter.copyWith(
        left: left,
        center: center,
        right: right,
      ),
    );
    notifyListeners();
  }

  void updateDensity(String value) {
    final double? parsed = double.tryParse(value);
    if (parsed != null) {
      _inputs = _inputs.copyWith(density: parsed);
      notifyListeners();
    }
  }

  // --- TECH LOG CALCULATIONS ---

  // 1. Total Metered Fuel (Normalized to Gallons)
  double get totalMeteredGallons {
    double totalRaw = _inputs.totalTruckVolume;
    if (_inputs.uploadUnit == FuelUnit.liters) {
      return totalRaw * kLitersToGallons;
    }
    return totalRaw;
  }

  // 2. Total Pounds Added
  double get totalPoundsAdded {
    double effectiveDensity = _inputs.density;
    // Handle SG logic
    if (effectiveDensity < 1.0 && effectiveDensity > 0) {
      effectiveDensity = effectiveDensity * 8.345;
    }

    double rawPounds = totalMeteredGallons * effectiveDensity;
    double kLbs = rawPounds / 1000;

    return (kLbs * 10).truncateToDouble() / 10;
  }

  // 3. Total Computed Fuel
  double get totalComputedFuel {
    double beforeTotal = _inputs.readingsBefore.total;

    return beforeTotal + totalPoundsAdded;
  }

  double get discrepancy {
    return _inputs.readingsAfter.total - totalComputedFuel;
  }
}
