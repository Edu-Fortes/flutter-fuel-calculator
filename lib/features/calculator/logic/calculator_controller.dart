import 'package:flutter/foundation.dart';
import '../domain/flight_data.dart';

class CalculatorController extends ChangeNotifier {
  // --- Constants for Limits ---
  static const double kMaxTankSafe = 40.1; // Distribution limit
  static const double kMaxTankPhysical = 40.7; // Physical limit left/right
  static const double kMaxCenterPhysical = 80.4; // Physical limit center

  // --- State ---
  FlightPlan _plan = FlightPlan(date: DateTime.now(), aircraftModel: '767');
  FuelInputData _inputs = const FuelInputData();

  // --- Getters ---
  FlightPlan get plan => _plan;
  FuelInputData get inputs => _inputs;

  // --- Actions ---
  /// Resets the entire session to default values
  void reset() {
    // Reset Plan (keep current date, default to 767)
    _plan = FlightPlan(date: DateTime.now(), aircraftModel: '767');

    // Reset Inputs (default density 6.70)
    _inputs = const FuelInputData(density: 6.70, uploadUnit: FuelUnit.liters);

    notifyListeners();
  }

  // --- Helpers for Display ---

  /// Helper to get the raw total volume (for display in Tech Log)
  double get totalTruckRawVolume => _inputs.totalTruckVolume;

  // --- Formatting Helper ---
  /// Rounds a double to 1 decimal place for calculations
  double _roundTo1Decimal(double value) {
    return (value * 10).round() / 10;
  }

  String get formattedRegistration {
    final raw = _plan.aircraftRegistration;
    if (raw.isEmpty) return 'N/A';
    // Format: N + number + FE
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
      aircraftRegistration: reg, // Storing raw number "123"
      flightNumber: flightNum,
      // Logic: Force Uppercase for Destination
      destination: dest?.toUpperCase(),
      aircraftModel: model,
      date: date,
    );
    notifyListeners();
  }

  /// Updates planned fuel and auto-calculates tank distribution
  void updatePlannedFuel(String value) {
    final double? totalRequested = double.tryParse(value);
    if (totalRequested == null) return;

    // 1. Calculate Distribution Logic
    double left = 0;
    double right = 0;
    double center = 0;

    // The threshold is when both wings are at safe max (40.1 * 2 = 80.2)
    const double wingCapacity = kMaxTankSafe * 2;

    if (totalRequested <= wingCapacity) {
      // Scenario: Less than wing capacity. Split equally.
      left = totalRequested / 2;
      right = totalRequested / 2;
      center = 0;
    } else {
      // Scenario: Fill wings to safe max, rest to center.
      left = kMaxTankSafe;
      right = kMaxTankSafe;
      center = totalRequested - wingCapacity;
    }

    // 2. Update Plan with new values (rounded to 1 decimal)
    _plan = _plan.copyWith(
      plannedFuel: totalRequested,
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

    // Ensure we store it rounded to 1 decimal if needed,
    // though usually raw input is preferred until display.
    final updatedList = List<double>.from(_inputs.truckVolumes);
    updatedList[index] = parsed;
    _inputs = _inputs.copyWith(truckVolumes: updatedList);
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

  void toggleTruckUnit(FuelUnit unit) {
    _inputs = _inputs.copyWith(uploadUnit: unit);
    notifyListeners();
  }

  // --- Calculations ---

  double get totalUpliftVolumeGallons {
    double totalRaw = _inputs.totalTruckVolume;
    if (_inputs.uploadUnit == FuelUnit.liters) {
      return totalRaw * 0.2641;
    } else {
      return totalRaw;
    }
  }

  /// Returns total Weight Added in Lbs
  int get totalPoundsAdded {
    double effectiveDensity = _inputs.density;

    // SMART LOGIC:
    // If user enters specific gravity (e.g. 0.800), convert to Lbs/Gal.
    // Uses 8.345 (approx weight of water in lbs/gal).
    if (effectiveDensity < 1.0 && effectiveDensity > 0) {
      effectiveDensity = effectiveDensity * 8.345;
    }

    return (totalUpliftVolumeGallons * effectiveDensity).round();
  }

  double get gaugeDifference {
    return _roundTo1Decimal(
      _inputs.readingsAfter.total - _inputs.readingsBefore.total,
    );
  }

  double get discrepancy {
    return _roundTo1Decimal((totalPoundsAdded - gaugeDifference).abs());
  }
}
