import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/offline_sync_service.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _autoSyncEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // Cargar configuraciones guardadas
    _baseUrlController.text = 'https://tu-backend.com/api';
    _apiKeyController.text = 'tu-api-key';
    _autoSyncEnabled = false;
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(offlineSyncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Sincronización'),
        backgroundColor: Colors.indigo[50],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de estado actual
              _buildCurrentStatusCard(context, syncState),

              const SizedBox(height: 24),

              // Configuración del servidor
              _buildServerConfigCard(context),

              const SizedBox(height: 24),

              // Opciones de sincronización
              _buildSyncOptionsCard(context),

              const SizedBox(height: 24),

              // Estadísticas de sincronización
              _buildSyncStatsCard(context),

              const SizedBox(height: 32),

              // Botones de acción
              _buildActionButtons(context, syncState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context, SyncState syncState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSyncIcon(syncState.status),
                  color: _getSyncColor(syncState.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Estado de Sincronización',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSyncColor(syncState.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSyncColor(syncState.status).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getSyncStatusText(syncState.status),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _getSyncColor(syncState.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (syncState.message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      syncState.message!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                  if (syncState.status == SyncStatus.syncing &&
                      syncState.totalToSync > 0) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: syncState.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        _getSyncColor(syncState.status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${syncState.synced} de ${syncState.totalToSync} elementos sincronizados',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerConfigCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_remote, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Configuración del Servidor',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Base del Servidor',
                hintText: 'https://tu-servidor.com/api',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la URL del servidor';
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'Por favor ingresa una URL válida';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Clave de API',
                hintText: 'Tu clave de API secreta',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu clave de API';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La sincronización se realiza de forma manual por tu seguridad. '
                      'Configura tu propio servidor o backend para habilitar esta función.',
                      style: TextStyle(color: Colors.amber[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOptionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync_alt, color: Colors.green[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Opciones de Sincronización',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Sincronización Automática'),
              subtitle: const Text(
                'Sincronizar automáticamente cada vez que se conecte a WiFi',
              ),
              value: _autoSyncEnabled,
              onChanged: (value) {
                setState(() {
                  _autoSyncEnabled = value;
                });
              },
              secondary: Icon(Icons.wifi, color: Colors.green[600]),
            ),

            const Divider(),

            ListTile(
              leading: Icon(Icons.cloud_upload, color: Colors.blue[600]),
              title: const Text('Solo subir cambios locales'),
              subtitle: const Text('No descargar cambios del servidor'),
              trailing: Radio<String>(
                value: 'upload_only',
                groupValue: 'upload_only', // Por defecto
                onChanged: (value) {
                  // Implementar lógica de selección
                },
              ),
            ),

            ListTile(
              leading: Icon(Icons.sync, color: Colors.purple[600]),
              title: const Text('Sincronización bidireccional'),
              subtitle: const Text('Subir y descargar cambios (avanzado)'),
              trailing: Radio<String>(
                value: 'bidirectional',
                groupValue: 'upload_only',
                onChanged: (value) {
                  // Implementar lógica de selección
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatsCard(BuildContext context) {
    final syncStats = ref.watch(syncStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange[600], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Estadísticas de Sincronización',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            syncStats.when(
              data: (stats) => _buildStatsContent(context, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Text(
                    'Error al cargar estadísticas: $error',
                    style: TextStyle(color: Colors.red[600]),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Map<String, int> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Productos',
                '${stats['pendingProducts']}',
                Icons.inventory,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                'Categorías',
                '${stats['pendingCategories']}',
                Icons.category,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Movimientos',
                '${stats['pendingMovements']}',
                Icons.swap_horiz,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                'Total Pendiente',
                '${stats['totalPending']}',
                Icons.pending,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SyncState syncState) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed:
                syncState.status == SyncStatus.syncing
                    ? null
                    : () => _performSync(),
            icon:
                syncState.status == SyncStatus.syncing
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.sync),
            label: Text(
              syncState.status == SyncStatus.syncing
                  ? 'Sincronizando...'
                  : 'Sincronizar Ahora',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () => _testConnection(),
            icon: const Icon(Icons.wifi_protected_setup),
            label: const Text('Probar Conexión'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _performSync() async {
    if (!_formKey.currentState!.validate()) return;

    final syncService = ref.read(offlineSyncServiceProvider.notifier);
    await syncService.performFullSync();

    // Mostrar resultado
    if (mounted) {
      final currentState = ref.read(offlineSyncServiceProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentState.status == SyncStatus.success
                ? 'Sincronización completada exitosamente'
                : currentState.message ?? 'Error en la sincronización',
          ),
          backgroundColor:
              currentState.status == SyncStatus.success
                  ? Colors.green[600]
                  : Colors.red[600],
        ),
      );
    }
  }

  void _testConnection() {
    // Implementar prueba de conexión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de prueba de conexión próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  IconData _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.cloud_queue;
      case SyncStatus.syncing:
        return Icons.cloud_sync;
      case SyncStatus.success:
        return Icons.cloud_done;
      case SyncStatus.error:
        return Icons.cloud_off;
    }
  }

  Color _getSyncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey[600]!;
      case SyncStatus.syncing:
        return Colors.blue[600]!;
      case SyncStatus.success:
        return Colors.green[600]!;
      case SyncStatus.error:
        return Colors.red[600]!;
    }
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Listo para sincronizar';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.success:
        return 'Sincronización exitosa';
      case SyncStatus.error:
        return 'Error de sincronización';
    }
  }
}
