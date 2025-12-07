import 'package:flutter/foundation.dart';
import '../domain/flight_data.dart';

class CalculatorController extends ChangeNotifier {
  // --- State ---
  final FlightPlan _plan = FlightPlan(date: DateTime.now());
  FuelInputData _inputs = const FuelInputData();

  // --- Getters ---
  FlightPlan get plan => _plan;
  FuelInputData get inputs => _inputs;

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

  // --- Logic: Unit Selection ---
  void toggleTruckUnit(FuelUnit unit) {
    _inputs = _inputs.copyWith(uploadUnit: unit);
    notifyListeners();
  }

  // --- CORE CALCULATIONS (LBS) ---

  /// Returns the total Uplifted Volume in Gallons
  double get totalUpliftVolumeGallons {
    double totalRaw = _inputs.totalTruckVolume;

    if (_inputs.uploadUnit == FuelUnit.liters) {
      // Logic: Liters * 0.2641 = Gallons
      return totalRaw * 0.2641;
    } else {
      // Already in Gallons
      return totalRaw;
    }
  }

  /// Returns total Weight Added in Lbs
  int get totalPoundsAdded {
    // Logic: Gallons * Density = Lbs
    // Note: User must enter density in Lbs/Gal (approx 6.7) OR we handle SG conversion logic later.
    // For now, assuming user inputs specific Lbs/Gal density.
    return (totalUpliftVolumeGallons * _inputs.density).round();
  }

  /// Returns the Fuel Quantity Difference (After - Before)
  double get gaugeDifference {
    return _inputs.readingsAfter.total - _inputs.readingsBefore.total;
  }

  /// Returns the discrepancy between Metered(Trucks) and Gauge(Tanks)
  double get discrepancy {
    return (totalPoundsAdded - gaugeDifference).abs();
  }
}
