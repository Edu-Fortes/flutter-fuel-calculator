import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // We need to add provider to pubspec
import 'features/calculator/logic/calculator_controller.dart';
import 'features/calculator/presentation/screens/plan_screen.dart';
import 'features/calculator/presentation/screens/input_screen.dart';
import 'features/calculator/presentation/screens/tech_log_screen.dart';

void main() {
  runApp(const FuelUpliftApp());
}

// Router Configuration
final _router = GoRouter(
  initialLocation: '/plan',
  routes: [
    // We use a ShellRoute to keep the "Segmented Button" (Navigation)
    // persistent across all three screens.
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(path: '/plan', builder: (context, state) => const PlanScreen()),
        GoRoute(
          path: '/input',
          builder: (context, state) => const InputScreen(),
        ),
        GoRoute(
          path: '/techlog',
          builder: (context, state) => const TechLogScreen(),
        ),
      ],
    ),
  ],
);

class FuelUpliftApp extends StatelessWidget {
  const FuelUpliftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculatorController(),
      child: MaterialApp.router(
        title: 'Fuel Uplift',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueGrey, // Professional aviation feel
            brightness: Brightness.dark, // Defaulting to dark as per image
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

// This widget holds the Segmented Button and switches pages
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Uplift'),
        centerTitle: true,
        actions: [
          // RESET BUTTON
          IconButton(
            tooltip: 'Reset All Data',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Calculation?'),
                  content: const Text(
                    'This will clear all aircraft and fuel data.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Call the reset method
                        context.read<CalculatorController>().reset();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Segmented Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: '/plan', label: Text('Plan')),
                ButtonSegment(value: '/input', label: Text('Inputs')),
                ButtonSegment(value: '/techlog', label: Text('Tech Log')),
              ],
              selected: {location},
              onSelectionChanged: (Set<String> newSelection) {
                context.go(newSelection.first);
              },
            ),
          ),
          // The active screen content
          Expanded(child: child),
        ],
      ),
    );
  }
}
