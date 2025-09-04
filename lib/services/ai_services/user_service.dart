import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';

/// Service for managing user-related operations
class UserService {
  UserService();

  /// Get all users from the database
  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await SupabaseService.fetchUsers();
      if (kDebugMode) {
        print('👥 Retrieved ${users.length} users from database');
      }
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving users: $e');
      }
      rethrow;
    }
  }

  /// Get a user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final users = await SupabaseService.fetchUsers();
      final user = users.where((u) => u.id == userId).firstOrNull;
      if (kDebugMode) {
        print('👤 Retrieved user: ${user?.friendlyName ?? 'Not found'}');
      }
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving user by ID: $e');
      }
      rethrow;
    }
  }

  /// Get a user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final users = await SupabaseService.fetchUsers();
      final user = users.where((u) => u.email == email).firstOrNull;
      if (kDebugMode) {
        print(
          '👤 Retrieved user by email: ${user?.friendlyName ?? 'Not found'}',
        );
      }
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving user by email: $e');
      }
      rethrow;
    }
  }

  /// Validate user selection
  bool isValidUser(UserModel? user) {
    return user != null && user.id.isNotEmpty;
  }

  /// Get user display name
  String getUserDisplayName(UserModel? user) {
    if (user == null) return 'No user selected';
    return user.friendlyName.isNotEmpty ? user.friendlyName : user.email;
  }

  /// Get user summary for AI context
  String getUserSummary(UserModel user) {
    final age = user.dateOfBirth != null
        ? (DateTime.now().year - user.dateOfBirth!.year).toString()
        : 'Unknown';

    return '''
Name: ${user.friendlyName}
Email: ${user.email}
Age: $age
Activity Level: ${user.activityLevel ?? 'Unknown'}
Health Goals: ${user.healthGoals?.join(', ') ?? 'None specified'}
'''
        .trim();
  }
}
