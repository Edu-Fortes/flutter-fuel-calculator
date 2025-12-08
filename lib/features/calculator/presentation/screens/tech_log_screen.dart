import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/flight_data.dart';
import '../../logic/calculator_controller.dart';

class TechLogScreen extends StatelessWidget {
  const TechLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CalculatorController>();
    final plan = controller.plan;
    final inputs = controller.inputs;
    final theme = Theme.of(context);

    // Safety Checks
    final bool isSafe = controller.isSafe;
    // final bool toleranceOk = controller.isWithinTolerance;
    final bool fuelOk = controller.isFuelSufficient;

    final double discrepancy = controller.discrepancy;
    final double limit = controller.toleranceLimit;

    // Formatting
    final weightFormat = NumberFormat("#,##0.0");
    final volFormat = NumberFormat("#,##0");
    final intFormat = NumberFormat("#,##0");
    final dateFormat = DateFormat('MM/dd/yy');

    // Determine Status Message & Color
    String statusTitle;
    String statusSubtitle;
    Color statusColor;
    IconData statusIcon;

    if (isSafe) {
      statusTitle = "WITHIN LIMITS";
      statusSubtitle =
          "Discrepancy: ${weightFormat.format(discrepancy)} (Limit: +/-${weightFormat.format(limit)})";
      statusColor = Colors.green.shade800;
      statusIcon = Icons.check_circle;
    } else if (!fuelOk) {
      // Priority Error: Not enough fuel
      statusTitle = "BELOW PLANNED FUEL";
      statusSubtitle =
          "Total After (${weightFormat.format(inputs.readingsAfter.total)}) < Planned (${weightFormat.format(plan.plannedFuel)})";
      statusColor = Colors.red.shade900;
      statusIcon = Icons.error;
    } else {
      // Tolerance Error
      statusTitle = "EXCEEDS TOLERANCE";
      statusSubtitle =
          "Discrepancy ${weightFormat.format(discrepancy)} > Limit ${weightFormat.format(limit)}";
      statusColor = Colors.orange.shade900;
      statusIcon = Icons.warning_amber_rounded;
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // DATE HEADER
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Date: ${dateFormat.format(plan.date)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 1. STATUS BANNER (Dynamic)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        statusSubtitle,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. AIRCRAFT INFO SUMMARY
          _buildSectionHeader(context, 'Flight Info'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(context, 'Flight', plan.flightNumber),
                  _buildInfoItem(
                    context,
                    'Registration',
                    controller.formattedRegistration,
                  ),
                  _buildInfoItem(context, 'Destination', plan.destination),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. TANK TABLE
          _buildSectionHeader(context, 'Tank Analysis'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
                verticalInside: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Tank',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Before',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'After',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                _buildTableRow(
                  'Left',
                  inputs.readingsBefore.left,
                  inputs.readingsAfter.left,
                ),
                _buildTableRow(
                  'Center',
                  inputs.readingsBefore.center,
                  inputs.readingsAfter.center,
                ),
                _buildTableRow(
                  'Right',
                  inputs.readingsBefore.right,
                  inputs.readingsAfter.right,
                ),
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'TOTAL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        weightFormat.format(inputs.readingsBefore.total),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        weightFormat.format(inputs.readingsAfter.total),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. COMPUTED DATA
          _buildSectionHeader(context, 'Computed Data'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    'Total Metered Fuel',
                    '${volFormat.format(controller.totalMeteredGallons)} gal',
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    context,
                    'Fuel Density',
                    inputs.density < 1.0
                        ? '${inputs.density} (SG)'
                        : '${inputs.density} lbs/gal',
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    context,
                    'Total Pounds Added',
                    weightFormat.format(controller.totalPoundsAdded),
                    isBold: true,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    context,
                    'Total Computed Fuel',
                    weightFormat.format(controller.totalComputedFuel),
                    isBold: true,
                    highlightColor: theme.colorScheme.primary,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    context,
                    'Total Requested',
                    weightFormat.format(plan.totalTargetFuel),
                  ),
                  if (inputs.uploadUnit == FuelUnit.liters) ...[
                    const Divider(),
                    _buildSummaryRow(
                      context,
                      'Total Liters',
                      '${intFormat.format(controller.totalTruckRawVolume)} L',
                      color: Colors.orange,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helpers
  TableRow _buildTableRow(String label, double? before, double? after) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: Text(label)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(before?.toString() ?? '-', textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(after?.toString() ?? '-', textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: highlightColor ?? color,
            ),
          ),
        ],
      ),
    );
  }

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
}
