import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/zones_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

/// Tela de gestão de zonas (admin)
class ZoneManagementScreen extends StatefulWidget {
  const ZoneManagementScreen({super.key});

  @override
  State<ZoneManagementScreen> createState() => _ZoneManagementScreenState();
}

class _ZoneManagementScreenState extends State<ZoneManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ZonesProvider>().loadZones();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZonesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Zonas'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadZones(),
        child: provider.isLoading
            ? const LoadingWidget()
            : provider.zones.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.map_outlined,
                    title: 'Nenhuma zona',
                    message: 'Crie a primeira zona da comunidade!',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.zones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final zone = provider.zones[index];
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(zone.colorValue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(zone.name),
                          subtitle: Text(zone.description ?? 'Sem descrição'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: zone.active,
                                onChanged: (v) => provider.toggleActive(zone.id, v),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) => _handleAction(v, zone.id),
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'stats',
                                    child: Text('Estatísticas'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Excluir',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Zona'),
      ),
    );
  }

  void _handleAction(String action, String zoneId) {
    switch (action) {
      case 'edit':
        _showEditDialog(zoneId);
        break;
      case 'stats':
        _showStatsDialog(zoneId);
        break;
      case 'delete':
        _confirmDelete(zoneId);
        break;
    }
  }

  void _showCreateDialog() {
    _showZoneDialog(null);
  }

  void _showEditDialog(String zoneId) {
    _showZoneDialog(zoneId);
  }

  void _showZoneDialog(String? zoneId) {
    final provider = context.read<ZonesProvider>();
    final zone = zoneId != null ? provider.getZoneById(zoneId) : null;
    
    final nameController = TextEditingController(text: zone?.name);
    final descController = TextEditingController(text: zone?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(zone == null ? 'Nova Zona' : 'Editar Zona'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (zone == null) {
                await provider.createZone(
                  name: nameController.text,
                  description: descController.text,
                );
              } else {
                await provider.updateZone(zone.id, {
                  'name': nameController.text,
                  'description': descController.text,
                });
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(String zoneId) async {
    final provider = context.read<ZonesProvider>();
    await provider.loadZoneStats(zoneId);
    
    if (!mounted) return;

    final stats = provider.selectedZoneStats;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow('Usuários', stats?['usersCount']?.toString() ?? '0'),
            _StatRow('Projetos', stats?['projectsCount']?.toString() ?? '0'),
            _StatRow('Produtos', stats?['productsCount']?.toString() ?? '0'),
            _StatRow('Serviços', stats?['servicesCount']?.toString() ?? '0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String zoneId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Zona'),
        content: const Text('Deseja realmente excluir esta zona?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ZonesProvider>().deleteZone(zoneId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

