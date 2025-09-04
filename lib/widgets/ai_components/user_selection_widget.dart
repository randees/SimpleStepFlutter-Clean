import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../services/ai_services/user_service.dart';
import '../../services/ai_services/service_locator.dart';
import '../user_management_modal.dart';

/// Composable widget for user selection and management
class UserSelectionWidget extends StatefulWidget {
  final UserModel? selectedUser;
  final ValueChanged<UserModel?> onUserChanged;
  final VoidCallback? onUserManagementPressed;

  const UserSelectionWidget({
    super.key,
    this.selectedUser,
    required this.onUserChanged,
    this.onUserManagementPressed,
  });

  @override
  State<UserSelectionWidget> createState() => _UserSelectionWidgetState();
}

class _UserSelectionWidgetState extends State<UserSelectionWidget> {
  final UserService _userService = ServiceLocator().userService;
  List<UserModel> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });

      if (kDebugMode) {
        print('✅ Loaded ${users.length} users for selection');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading users: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUserManagementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserManagementModal(
        onUserSelected: (UserModel user) {
          widget.onUserChanged(user);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select User Context:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showUserManagementModal,
                  icon: const Icon(Icons.people, size: 18),
                  label: const Text('User Management'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_users.isEmpty && !_isLoading)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'No users available. Please check network connectivity.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              )
            else if (_isLoading)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading users...',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              )
            else
              Text(
                'Found ${_users.length} users available',
                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserModel>(
              value: _users.contains(widget.selectedUser)
                  ? widget.selectedUser
                  : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: _users.isEmpty
                  ? const Text('Loading users...')
                  : const Text('Choose a user for context'),
              items: _users.map((user) {
                return DropdownMenuItem<UserModel>(
                  value: user,
                  child: Text(
                    '${user.friendlyName} (${user.activityLevel ?? 'Unknown'})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: widget.onUserChanged,
            ),
          ],
        ),
      ),
    );
  }
}
