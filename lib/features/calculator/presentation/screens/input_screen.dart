import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/flight_data.dart';
import '../../logic/calculator_controller.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalculatorController>();
    final inputs = controller.inputs;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- SECTION 1: TANK READINGS ---
          _buildSectionHeader(context, 'Tank Readings'),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Expanded(child: SizedBox()),
                      Expanded(
                        child: Text(
                          'Left',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Center',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Right',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildTankRow(
                    context,
                    label: 'Before',
                    lValue: inputs.readingsBefore.left,
                    cValue: inputs.readingsBefore.center,
                    rValue: inputs.readingsBefore.right,
                    onLeftChanged: (v) => controller.updateReadingBefore(
                      left: double.tryParse(v),
                    ),
                    onCenterChanged: (v) => controller.updateReadingBefore(
                      center: double.tryParse(v),
                    ),
                    onRightChanged: (v) => controller.updateReadingBefore(
                      right: double.tryParse(v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTankRow(
                    context,
                    label: 'After',
                    lValue: inputs.readingsAfter.left,
                    cValue: inputs.readingsAfter.center,
                    rValue: inputs.readingsAfter.right,
                    onLeftChanged: (v) =>
                        controller.updateReadingAfter(left: double.tryParse(v)),
                    onCenterChanged: (v) => controller.updateReadingAfter(
                      center: double.tryParse(v),
                    ),
                    onRightChanged: (v) => controller.updateReadingAfter(
                      right: double.tryParse(v),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION 2: FUEL UPLIFT (TRUCKS) ---
          _buildSectionHeader(context, 'Fuel Uplift'),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hint Text
                  Text(
                    'As provided by fueler / refueling equipment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Unit Selector
                  SegmentedButton<FuelUnit>(
                    segments: const [
                      ButtonSegment(
                        value: FuelUnit.liters,
                        label: Text('Liters'),
                        icon: Icon(Icons.water_drop),
                      ),
                      ButtonSegment(
                        value: FuelUnit.gallons,
                        label: Text('Gallons'),
                        icon: Icon(Icons.local_gas_station),
                      ),
                    ],
                    selected: {inputs.uploadUnit},
                    onSelectionChanged: (Set<FuelUnit> newSelection) {
                      controller.toggleTruckUnit(newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dynamic List of Trucks
                  // Put them inside the column so they share the card background
                  ...List.generate(inputs.truckVolumes.length, (index) {
                    return _TruckInputRow(
                      index: index,
                      value: inputs.truckVolumes[index],
                      unit: inputs.uploadUnit,
                      isRemovable: inputs.truckVolumes.length > 1,
                      onChanged: (val) =>
                          controller.updateTruckVolume(index, val),
                      onRemove: () => controller.removeTruck(index),
                    );
                  }),

                  const SizedBox(height: 12),

                  // "Add Truck" Button inside the card/flow
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.addTruck,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another Truck'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION 3: PARAMETERS ---
          _buildSectionHeader(context, 'Parameters'),
          Card(
            child: ListTile(
              // CHANGED: Clarified Label
              title: const Text('Density (Lbs/Gal)'),
              subtitle: const Text('Standard Jet A1: 6.70'),
              trailing: SizedBox(
                width: 100,
                child: TextFormField(
                  // CHANGED: Logic to display 6.7 default clearly
                  initialValue: inputs.density.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.end,
                  decoration: const InputDecoration(
                    hintText: '6.70',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    border: OutlineInputBorder(),
                    suffixText: 'lbs/gal',
                  ),
                  onChanged: (val) => controller.updateDensity(val),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Helper methods _buildSectionHeader and _buildTankRow remain the same) ...
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTankRow(
    BuildContext context, {
    required String label,
    required double? lValue,
    required double? cValue,
    required double? rValue,
    required Function(String) onLeftChanged,
    required Function(String) onCenterChanged,
    required Function(String) onRightChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
      children: [
        // Label Column
        SizedBox(
          width: 50,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        // Inputs
        Expanded(
          child: _TankInputField(value: lValue, onChanged: onLeftChanged),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TankInputField(value: cValue, onChanged: onCenterChanged),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TankInputField(value: rValue, onChanged: onRightChanged),
        ),
      ],
    );
  }
}

// ... (Helper widgets) ...

class _TankInputField extends StatelessWidget {
  final double? value;
  final Function(String) onChanged;

  const _TankInputField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value == 0.0 || value == null ? '' : value.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        isDense: true,
        hintText: '0.0',
        border: OutlineInputBorder(), // Added border for clarity
      ),
      onChanged: onChanged,
    );
  }
}

// CHANGED: Simplified Truck Row to fit inside the main card
class _TruckInputRow extends StatelessWidget {
  final int index;
  final double value;
  final FuelUnit unit;
  final bool isRemovable;
  final Function(String) onChanged;
  final VoidCallback onRemove;

  const _TruckInputRow({
    required this.index,
    required this.value,
    required this.unit,
    required this.isRemovable,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final unitLabel = unit == FuelUnit.liters ? 'Liters' : 'Gallons';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          // Number Badge
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),

          // Input
          Expanded(
            child: TextFormField(
              initialValue: value == 0.0 ? '' : value.toString(),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Truck ${index + 1}',
                suffixText: unitLabel,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: onChanged,
            ),
          ),

          // Remove Button
          if (isRemovable)
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
              ),
              onPressed: onRemove,
              tooltip: 'Remove truck',
            ),
        ],
      ),
    );
  }
}
