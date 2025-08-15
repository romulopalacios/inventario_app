import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reportes')),
        body: const Center(child: Text('Pantalla de Reportes - En desarrollo')),
      ),
    );
  }
}
