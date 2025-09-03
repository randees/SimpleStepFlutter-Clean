import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class UserManagementModal extends StatefulWidget {
  final Function(UserModel)? onUserSelected;

  const UserManagementModal({Key? key, this.onUserSelected}) : super(key: key);

  @override
  State<UserManagementModal> createState() => _UserManagementModalState();
}

class _UserManagementModalState extends State<UserManagementModal> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  UserModel? _selectedUser;
  bool _isSearching = false;
  String _searchQuery = '';

  // Status message state
  String? _statusMessage;
  bool _isStatusError = false;
  bool _showStatus = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      _searchQuery = query;
      // Clear status when starting new search
      _hideStatus();
      // Check for special asterisk functionality
      if (query == '***') {
        _performTopTenSearch();
      } else if (query.length >= 3) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults.clear();
          _selectedUser = null;
        });
      }
    }
  }

  void _showStatusMessage(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
      _isStatusError = isError;
      _showStatus = true;
    });

    // Only auto-hide success messages, errors require manual dismissal
    if (!isError) {
      Future.delayed(Duration(seconds: 4), () {
        if (mounted) {
          _hideStatus();
        }
      });
    }
  }

  void _hideStatus() {
    setState(() {
      _showStatus = false;
      _statusMessage = null;
      _isStatusError = false;
    });
  }

  Future<void> _performTopTenSearch() async {
    setState(() {
      _isSearching = true;
    });

    try {
      final users = await SupabaseService.fetchUsers();
      setState(() {
        _searchResults = users.take(10).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      _showStatusMessage('Error fetching top 10 users: $e', isError: true);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 3) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final allUsers = await SupabaseService.fetchUsers();
      final filteredUsers = allUsers.where((user) {
        final searchLower = query.toLowerCase();
        return user.friendlyName.toLowerCase().contains(searchLower) ||
            user.email.toLowerCase().contains(searchLower) ||
            user.id.toLowerCase().contains(searchLower);
      }).toList();

      setState(() {
        _searchResults = filteredUsers;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });

      _showStatusMessage('Error searching users: $e', isError: true);
    }
  }

  void _selectUser(UserModel user) {
    setState(() {
      _selectedUser = user;
    });
    // Don't call onUserSelected here anymore - modal stays open
    // User can close manually or use a separate "Select" button
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showStatusMessage('$label copied to clipboard');
  }

  /// Export user data to JSON file
  Future<void> _exportUserData(UserModel user) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting user data...'),
            ],
          ),
        ),
      );

      // Export data
      final exportData = await SupabaseService.exportUserData(user.id);

      // Close loading dialog
      Navigator.of(context).pop();

      // Convert to JSON
      final jsonString = JsonEncoder.withIndent('  ').convert(exportData);

      // Create and download file
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'user_data_${user.friendlyName}_${DateTime.now().millisecondsSinceEpoch}.json',
        )
        ..click();

      html.Url.revokeObjectUrl(url);

      // Show success message
      _showStatusMessage('User data exported successfully');
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();

      // Show error message
      _showStatusMessage('Error exporting user data: $e', isError: true);
    }
  }

  /// Import user data from JSON file
  Future<void> _importUserData() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Importing user data...'),
              ],
            ),
          ),
        );

        // Read and parse JSON
        final bytes = result.files.single.bytes!;
        final jsonString = utf8.decode(bytes);
        final importData = jsonDecode(jsonString) as Map<String, dynamic>;

        // Import data
        await SupabaseService.importUserData(importData);

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        _showStatusMessage('User data imported successfully');

        // Refresh search results if there's a current search
        if (_searchQuery.isNotEmpty) {
          if (_searchQuery == '***') {
            _performTopTenSearch();
          } else {
            _performSearch(_searchQuery);
          }
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      _showStatusMessage('Error importing user data: $e', isError: true);
    }
  }

  /// Delete user and all their data with confirmation
  Future<void> _deleteUser(UserModel user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this user and ALL their data?',
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User to be deleted:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Name: ${user.friendlyName}'),
                  Text('Email: ${user.email}'),
                  Text('ID: ${user.id}'),
                  SizedBox(height: 8),
                  Text(
                    '⚠️ This action cannot be undone!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Deleting user and all data...'),
              ],
            ),
          ),
        );

        // Delete user and data
        await SupabaseService.deleteUserAndData(user.id);

        // Close loading dialog
        Navigator.of(context).pop();

        // Clear selected user if it was the deleted one
        if (_selectedUser?.id == user.id) {
          setState(() {
            _selectedUser = null;
          });
        }

        // Refresh search results
        if (_searchQuery.isNotEmpty) {
          if (_searchQuery == '***') {
            _performTopTenSearch();
          } else {
            _performSearch(_searchQuery);
          }
        }

        // Show success message
        _showStatusMessage(
          'User "${user.friendlyName}" and all data deleted successfully',
        );
      } catch (e) {
        // Close loading dialog if still open
        Navigator.of(context).pop();

        // Show error message
        _showStatusMessage('Error deleting user: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9, // 90% height
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          vertical:
              MediaQuery.of(context).size.height *
              0.05, // 5% margin top and bottom
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(
            20,
          ), // Changed to all corners since it's centered
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.people, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'User Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Status Banner (shown when there's a status message)
            if (_showStatus && _statusMessage != null)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isStatusError
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isStatusError
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isStatusError ? Icons.error : Icons.check_circle,
                      color: _isStatusError ? Colors.red : Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _isStatusError
                              ? Colors.red[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Show copy button only for error messages
                    if (_isStatusError)
                      IconButton(
                        onPressed: () =>
                            _copyToClipboard(_statusMessage!, 'Error message'),
                        icon: Icon(Icons.copy, size: 18),
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: 24,
                          height: 24,
                        ),
                        tooltip: 'Copy error message',
                      ),
                    IconButton(
                      onPressed: _hideStatus,
                      icon: Icon(Icons.close, size: 18),
                      color: _isStatusError ? Colors.red : Colors.green,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ),

            // Search Section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Search Users',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _importUserData,
                        icon: Icon(Icons.upload, size: 16),
                        label: Text('Import'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'Type 3+ characters to search, or *** for top 10 users',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? Container(
                              width: 20,
                              height: 20,
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults.clear();
                                  _selectedUser = null;
                                });
                              },
                              icon: Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      // Handled by listener
                    },
                  ),
                  if (_searchQuery.isNotEmpty &&
                      _searchQuery.length < 3 &&
                      _searchQuery != '***')
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Type ${3 - _searchQuery.length} more character(s) to search, or *** for top 10',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                      ),
                    ),
                ],
              ),
            ),

            // Selected User Details (show below search)
            if (_selectedUser != null) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Selected User',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onUserSelected != null) {
                              widget.onUserSelected!(_selectedUser!);
                            }
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.check, size: 16),
                          label: Text('Select'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size(0, 36),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportUserData(_selectedUser!),
                            icon: Icon(Icons.download, size: 16),
                            label: Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _deleteUser(_selectedUser!),
                            icon: Icon(Icons.delete, size: 16),
                            label: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Name',
                      _selectedUser!.friendlyName,
                      Icons.person,
                      copyable: true,
                    ),
                    _buildDetailRow(
                      context,
                      'Email',
                      _selectedUser!.email,
                      Icons.email,
                      copyable: true,
                    ),
                    _buildDetailRow(
                      context,
                      'UUID',
                      _selectedUser!.id,
                      Icons.fingerprint,
                      copyable: true,
                    ),
                    if (_selectedUser!.activityLevel != null)
                      _buildDetailRow(
                        context,
                        'Activity Level',
                        _selectedUser!.activityLevel!,
                        Icons.fitness_center,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Search Results (hide when user is selected)
            if (_searchResults.isNotEmpty && _selectedUser == null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search Results (${_searchResults.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];

                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            user.friendlyName.isNotEmpty
                                ? user.friendlyName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(user.friendlyName),
                        subtitle: Text(user.email),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _selectUser(user),
                      ),
                    );
                  },
                ),
              ),
            ] else if (_searchQuery.length >= 3 &&
                !_isSearching &&
                _selectedUser == null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        'Try a different search term',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                SelectableText(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              onPressed: () => _copyToClipboard(value, label),
              icon: Icon(Icons.copy, size: 16),
              tooltip: 'Copy $label',
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints.tightFor(width: 24, height: 24),
            ),
        ],
      ),
    );
  }
}
