import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/calculator_controller.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // Controllers
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _flightNumController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  final TextEditingController _plannedFuelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // PERSISTENCE FIX: Initialize controllers with existing data from Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CalculatorController>();
      final plan = controller.plan;

      _regController.text = plan.aircraftRegistration;
      _flightNumController.text = plan.flightNumber;
      _destController.text = plan.destination;
      if (plan.plannedFuel > 0) {
        _plannedFuelController.text = plan.plannedFuel.toString();
      }
    });
  }

  @override
  void dispose() {
    _regController.dispose();
    _flightNumController.dispose();
    _destController.dispose();
    _plannedFuelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalculatorController>();
    final plan = controller.plan;
    final theme = Theme.of(context);
    final dateStr = DateFormat('MM/dd/yy').format(plan.date);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Date & Registration Header
          Card(
            elevation: 2,
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Flight Number',
              prefixIcon: Icon(Icons.flight_takeoff),
            ),
            onChanged: (val) => controller.updateFlightDetails(flightNum: val),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _destController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Destination',
              prefixIcon: Icon(Icons.location_on),
            ),
            onChanged: (val) => controller.updateFlightDetails(dest: val),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: plan.aircraftModel.isEmpty
                ? null
                : plan.aircraftModel,
            decoration: const InputDecoration(
              labelText: 'Aircraft Model',
              prefixIcon: Icon(Icons.airplanemode_active),
              border: OutlineInputBorder(),
            ),
            items: const [DropdownMenuItem(value: '767', child: Text('B767'))],
            onChanged: (value) {
              if (value != null) {
                controller.updateFlightDetails(model: value);
              }
            },
          ),
          const SizedBox(height: 24),

          // 3. Planned Fuel Input
          Text('Fuel Planning', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _plannedFuelController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Planned Fuel (Base)',
              suffixText: 'Lbs',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => controller.updatePlannedFuel(val),
          ),

          const SizedBox(height: 12),

          // NEW: Extra Fuel UI
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Extra Fuel", style: theme.textTheme.titleMedium),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove),
                      onPressed: () => controller.updateExtraFuel(-0.1),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "+ ${plan.extraFuel.toStringAsFixed(1)}",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      onPressed: () => controller.updateExtraFuel(0.1),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Dynamic Distribution Display
          if (plan.totalTargetFuel > 0) ...[
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
                    'Required Distribution (Total: ${plan.totalTargetFuel.toStringAsFixed(1)})',
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
          value.toStringAsFixed(1),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
