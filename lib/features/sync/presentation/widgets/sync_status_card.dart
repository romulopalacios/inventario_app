import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/offline_sync_service.dart';

class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(offlineSyncServiceProvider);
    final syncStats = ref.watch(syncStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getSyncIcon(syncState.status),
                      color: _getSyncColor(syncState.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estado de Sincronización',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    // Botón de configuración
                    IconButton(
                      onPressed: () => context.go('/sync-settings'),
                      icon: const Icon(Icons.settings),
                      tooltip: 'Configurar sincronización',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Botón de sincronización
                    if (syncState.status != SyncStatus.syncing)
                      IconButton(
                        onPressed: () => _performSync(ref),
                        icon: const Icon(Icons.sync),
                        tooltip: 'Sincronizar ahora',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[700],
                        ),
                      )
                    else
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estado actual
            _buildCurrentStatus(context, syncState),

            const SizedBox(height: 12),

            // Estadísticas de elementos pendientes
            syncStats.when(
              data: (stats) => _buildSyncStats(context, stats),
              loading:
                  () => const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Calculando elementos pendientes...'),
                    ],
                  ),
              error:
                  (error, stackTrace) => Text(
                    'Error al calcular estadísticas',
                    style: TextStyle(color: Colors.red[600]),
                  ),
            ),

            // Progreso de sincronización
            if (syncState.status == SyncStatus.syncing &&
                syncState.totalToSync > 0)
              _buildSyncProgress(context, syncState),

            // Última sincronización
            if (syncState.lastSyncTime != null)
              _buildLastSyncInfo(context, syncState.lastSyncTime!),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(BuildContext context, SyncState syncState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSyncColor(syncState.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSyncColor(syncState.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getSyncIcon(syncState.status),
            color: _getSyncColor(syncState.status),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSyncStatusText(syncState.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getSyncColor(syncState.status),
                  ),
                ),
                if (syncState.message != null)
                  Text(
                    syncState.message!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStats(BuildContext context, Map<String, int> stats) {
    final totalPending = stats['totalPending'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              totalPending > 0 ? Icons.cloud_upload : Icons.cloud_done,
              color: totalPending > 0 ? Colors.orange[600] : Colors.green[600],
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              totalPending > 0
                  ? '$totalPending elementos pendientes de sincronización'
                  : 'Todos los elementos están sincronizados',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    totalPending > 0 ? Colors.orange[600] : Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        if (totalPending > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatChip(
                context,
                'Productos: ${stats['pendingProducts']}',
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                'Categorías: ${stats['pendingCategories']}',
                Colors.purple,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                'Movimientos: ${stats['pendingMovements']}',
                Colors.green,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSyncProgress(BuildContext context, SyncState syncState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: syncState.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${syncState.synced}/${syncState.totalToSync}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(syncState.progress * 100).toInt()}% completado',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLastSyncInfo(BuildContext context, DateTime lastSync) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'Hace unos segundos';
    } else if (difference.inHours < 1) {
      timeAgo = 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inDays < 1) {
      timeAgo = 'Hace ${difference.inHours} horas';
    } else {
      timeAgo = 'Hace ${difference.inDays} días';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.grey[500], size: 14),
          const SizedBox(width: 6),
          Text(
            'Última sincronización: $timeAgo (${formatter.format(lastSync)})',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _performSync(WidgetRef ref) async {
    final syncService = ref.read(offlineSyncServiceProvider.notifier);
    await syncService.performFullSync();

    // Invalidar estadísticas para refrescarlas
    ref.invalidate(syncStatsProvider);
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
