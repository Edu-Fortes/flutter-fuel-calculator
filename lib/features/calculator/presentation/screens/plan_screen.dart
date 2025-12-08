import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/calculator_controller.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // Controllers to keep text fields in sync
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _flightNumController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _plannedFuelController = TextEditingController();

  @override
  void dispose() {
    _regController.dispose();
    _flightNumController.dispose();
    _destController.dispose();
    _modelController.dispose();
    _plannedFuelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalculatorController>();
    final plan = controller.plan;
    final theme = Theme.of(context);

    // Date Format
    final dateStr = DateFormat('MM/dd/yy').format(plan.date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Date & Registration Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Flight Date', style: theme.textTheme.labelMedium),
                  Text(
                    dateStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _regController,
                    decoration: const InputDecoration(
                      labelText: 'Aircraft Registration',
                    ),
                    onChanged: (val) =>
                        controller.updateFlightDetails(reg: val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Flight Details
          TextField(
            controller: _flightNumController,
            decoration: const InputDecoration(
              labelText: 'Flight Number',
              prefixIcon: Icon(Icons.flight_takeoff),
            ),
            onChanged: (val) => controller.updateFlightDetails(flightNum: val),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _destController,
            decoration: const InputDecoration(
              labelText: 'Destination',
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (val) => controller.updateFlightDetails(dest: val),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(
              labelText: 'Aircraft Model',
              prefixIcon: Icon(Icons.airplanemode_active),
            ),
            onChanged: (val) => controller.updateFlightDetails(model: val),
          ),
          const SizedBox(height: 24),

          // 3. Planned Fuel Input
          Text('Fuel Planning', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _plannedFuelController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Planned Fuel (Lbs)',
              suffixText: 'Lbs',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => controller.updatePlannedFuel(val),
          ),

          const SizedBox(height: 16),

          // 4. Dynamic Distribution Display
          if (plan.plannedFuel > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Required Distribution',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTankValue(
                        context,
                        'Left',
                        plan.suggestedDistribution.left,
                      ),
                      _buildTankValue(
                        context,
                        'Center',
                        plan.suggestedDistribution.center,
                      ),
                      _buildTankValue(
                        context,
                        'Right',
                        plan.suggestedDistribution.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTankValue(BuildContext context, String label, double value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value.toStringAsFixed(1), // 1 Decimal Place Rule
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
