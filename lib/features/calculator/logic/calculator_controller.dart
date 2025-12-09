import 'package:flutter/foundation.dart';
import 'dart:math' as math; // Import math for min function
import '../domain/flight_data.dart';

class CalculatorController extends ChangeNotifier {
  // --- Constants ---
  static const double kMaxTankSafe = 40.1;
  static const double kLitersToGallons = 0.2641;

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

  // --- Logic: Flight Details ---
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
      station: dest?.toUpperCase(),
      aircraftModel: model,
      date: date,
    );
    notifyListeners();
  }

  // --- Logic: Planning & Distribution ---
  void updatePlannedFuel(String value) {
    final double? base = double.tryParse(value);
    if (base == null) return;
    _plan = _plan.copyWith(plannedFuel: base);
    _recalculateDistribution();
  }

  void updateExtraFuel(double delta) {
    double newExtra = _plan.extraFuel + delta;
    newExtra = double.parse(newExtra.toStringAsFixed(1));
    if (newExtra < 0) newExtra = 0.0;
    _plan = _plan.copyWith(extraFuel: newExtra);
    _recalculateDistribution();
  }

  void _recalculateDistribution() {
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

  /// 1. Total Metered Fuel (Gallons)
  double get totalMeteredGallons {
    double totalRaw = _inputs.totalTruckVolume;
    double valInGallons;

    if (_inputs.uploadUnit == FuelUnit.liters) {
      valInGallons = totalRaw * kLitersToGallons;
    } else {
      valInGallons = totalRaw;
    }
    // Round to 3 decimal places
    return (valInGallons * 1000).roundToDouble() / 1000;
  }

  /// 2. Total Weight Added (KLBS)
  double get totalPoundsAdded {
    double effectiveDensity = _inputs.density;
    if (effectiveDensity < 1.0 && effectiveDensity > 0) {
      effectiveDensity = effectiveDensity * 8.345;
    }

    double rawPounds = totalMeteredGallons * effectiveDensity;
    double kLbs = rawPounds / 1000;

    // Truncate to 1 decimal
    return (kLbs * 10).truncateToDouble() / 10;
  }

  /// 3. Total Computed Fuel (KLBS)
  double get totalComputedFuel {
    double beforeTotal = _inputs.readingsBefore.total;
    return beforeTotal + totalPoundsAdded;
  }

  /// 4. Discrepancy (KLBS)
  double get discrepancy {
    return _inputs.readingsAfter.total - totalComputedFuel;
  }

  // --- SAFETY & VALIDATION RULES ---

  /// Rule 1: Tolerance Limit
  /// "Within 5% OR 5,000 Lb of total after, whichever is less"
  double get toleranceLimit {
    final double totalAfter = _inputs.readingsAfter.total;

    final double percentLimit = totalAfter * 0.05; // 5%
    const double flatLimit = 5.0; // 5,000 lbs (in KLBS)

    return math.min(percentLimit, flatLimit);
  }

  bool get isWithinTolerance {
    return discrepancy.abs() <= toleranceLimit;
  }

  /// Rule 2: Minimum Fuel
  /// "In no case can Total After fueling be less than raw planned fuel"
  bool get isFuelSufficient {
    // If planned fuel is 0 (not entered), we might skip this check or return true
    if (_plan.plannedFuel == 0) return true;

    // Compare After Readings with Base Plan
    return _inputs.readingsAfter.total >= _plan.plannedFuel;
  }

  /// Overall Safety Status
  bool get isSafe {
    return isWithinTolerance && isFuelSufficient;
  }
}
