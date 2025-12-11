import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';

/// Tela de gestão de usuários (admin)
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserProvider>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadUsers(),
        child: provider.isLoading
            ? const LoadingWidget()
            : provider.users.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'Nenhum usuário',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Helpers.getColorFromString(user.email),
                            child: Text(
                              Helpers.getInitials(user.name),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getRoleColor(user.role),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleAction(value, user.id),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit_role',
                                child: Text('Alterar Cargo'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Remover',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return AppColors.error;
      case 'gestor':
        return AppColors.warning;
      case 'suporte':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  void _handleAction(String action, String userId) {
    switch (action) {
      case 'edit_role':
        _showRoleDialog(userId);
        break;
      case 'delete':
        _confirmDelete(userId);
        break;
    }
  }

  void _showRoleDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Cargo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Usuário'),
              onTap: () => _updateRole(userId, 'USER'),
            ),
            ListTile(
              title: const Text('Gestor'),
              onTap: () => _updateRole(userId, 'gestor'),
            ),
            ListTile(
              title: const Text('Suporte'),
              onTap: () => _updateRole(userId, 'suporte'),
            ),
            ListTile(
              title: const Text('Admin'),
              onTap: () => _updateRole(userId, 'admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRole(String userId, String role) async {
    Navigator.pop(context);
    await context.read<UserProvider>().updateUserRole(userId, role);
  }

  void _confirmDelete(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Usuário'),
        content: const Text('Deseja realmente remover este usuário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserProvider>().deleteUser(userId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

