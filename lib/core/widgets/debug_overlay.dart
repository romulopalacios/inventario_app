import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../utils/debug_tools.dart';

/// Overlay de debugging para mostrar información en pantalla
class DebugOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const DebugOverlay({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  bool _showDebugInfo = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      Logger.debug('Debug Overlay initialized');
    }
  }

  void _addLog(String message) {
    if (!widget.enabled) return;
    setState(() {
      _logs.add(
        '${DateTime.now().toIso8601String().substring(11, 19)}: $message',
      );
      if (_logs.length > 10) {
        _logs.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,

        // Botón de debug flotante
        Positioned(
          top: 50,
          right: 10,
          child: FloatingActionButton.small(
            heroTag: 'debug_toggle',
            backgroundColor: Colors.orange.withOpacity(0.8),
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
              });
              Logger.debug('Debug overlay toggled: $_showDebugInfo');
            },
            child: const Icon(Icons.bug_report, size: 16),
          ),
        ),

        // Panel de información
        if (_showDebugInfo)
          Positioned(
            top: 100,
            right: 10,
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Debug Info',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Información del dispositivo
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Platform', defaultTargetPlatform.name),
                        _buildInfoRow('Debug Mode', kDebugMode.toString()),
                        _buildInfoRow(
                          'Screen Size',
                          '${MediaQuery.of(context).size}',
                        ),
                        _buildInfoRow(
                          'Pixel Ratio',
                          '${MediaQuery.of(context).devicePixelRatio}',
                        ),
                      ],
                    ),
                  ),

                  // Separador
                  const Divider(color: Colors.grey, height: 1),

                  // Logs recientes
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Recent Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Text(
                          _logs[index],
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        );
                      },
                    ),
                  ),

                  // Botones de acción
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            DebugTools.memoryInfo();
                            _addLog('Memory info logged');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          child: const Text(
                            'Memory',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _logs.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
