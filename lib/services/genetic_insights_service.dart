import 'supabase_service.dart';
import '../models/genetic_insight.dart';

/// Service for managing genetic insights data
class GeneticInsightsService {
  /// Get all genetic insights for a specific user
  static Future<List<GeneticInsight>> getGeneticInsights(String userId) async {
    try {
      print(
        '🔄 GeneticInsightsService: Fetching genetic insights for user: $userId',
      );

      final response = await SupabaseService.client
          .from('genetic_insights')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final insights = List<GeneticInsight>.from(
        response.map((item) => GeneticInsight.fromJson(item)),
      );

      print(
        '✅ GeneticInsightsService: Retrieved ${insights.length} genetic insights',
      );
      return insights;
    } catch (e) {
      print('❌ GeneticInsightsService: Error fetching genetic insights: $e');
      return [];
    }
  }

  /// Get a specific genetic insight by ID
  static Future<GeneticInsight?> getGeneticInsight(String insightId) async {
    try {
      print('🔄 GeneticInsightsService: Fetching genetic insight: $insightId');

      final response = await SupabaseService.client
          .from('genetic_insights')
          .select('*')
          .eq('id', insightId)
          .maybeSingle();

      if (response != null) {
        print(
          '✅ GeneticInsightsService: Retrieved genetic insight: $insightId',
        );
        return GeneticInsight.fromJson(response);
      } else {
        print(
          '⚠️ GeneticInsightsService: Genetic insight not found: $insightId',
        );
        return null;
      }
    } catch (e) {
      print('❌ GeneticInsightsService: Error fetching genetic insight: $e');
      return null;
    }
  }

  /// Create a new genetic insight
  static Future<GeneticInsight?> createGeneticInsight({
    required String userId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metaData,
  }) async {
    try {
      print(
        '🔄 GeneticInsightsService: Creating genetic insight for user: $userId',
      );

      final response = await SupabaseService.client
          .from('genetic_insights')
          .insert({'user_id': userId, 'data': data, 'meta_data': metaData})
          .select()
          .single();

      print(
        '✅ GeneticInsightsService: Created genetic insight for user: $userId',
      );
      return GeneticInsight.fromJson(response);
    } catch (e) {
      print('❌ GeneticInsightsService: Error creating genetic insight: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is Exception) {
        print('❌ Error message: ${e.toString()}');
      }
      return null;
    }
  }

  /// Update an existing genetic insight
  static Future<GeneticInsight?> updateGeneticInsight({
    required String insightId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metaData,
  }) async {
    try {
      print('🔄 GeneticInsightsService: Updating genetic insight: $insightId');

      final updateData = <String, dynamic>{};
      if (data != null) {
        updateData['data'] = data;
      }
      if (metaData != null) {
        updateData['meta_data'] = metaData;
      }

      if (updateData.isEmpty) {
        print(
          '⚠️ GeneticInsightsService: No data to update for insight: $insightId',
        );
        return null;
      }

      final response = await SupabaseService.client
          .from('genetic_insights')
          .update(updateData)
          .eq('id', insightId)
          .select()
          .single();

      print('✅ GeneticInsightsService: Updated genetic insight: $insightId');
      return GeneticInsight.fromJson(response);
    } catch (e) {
      print('❌ GeneticInsightsService: Error updating genetic insight: $e');
      return null;
    }
  }

  /// Delete a genetic insight
  static Future<bool> deleteGeneticInsight(String insightId) async {
    try {
      print('🔄 GeneticInsightsService: Deleting genetic insight: $insightId');

      await SupabaseService.client
          .from('genetic_insights')
          .delete()
          .eq('id', insightId);

      print('✅ GeneticInsightsService: Deleted genetic insight: $insightId');
      return true;
    } catch (e) {
      print('❌ GeneticInsightsService: Error deleting genetic insight: $e');
      return false;
    }
  }

  /// Get the most recent genetic insight for a user
  static Future<GeneticInsight?> getLatestGeneticInsight(String userId) async {
    try {
      print(
        '🔄 GeneticInsightsService: Fetching latest genetic insight for user: $userId',
      );

      final response = await SupabaseService.client
          .from('genetic_insights')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        print(
          '✅ GeneticInsightsService: Retrieved latest genetic insight for user: $userId',
        );
        return GeneticInsight.fromJson(response);
      } else {
        print(
          '⚠️ GeneticInsightsService: No genetic insights found for user: $userId',
        );
        return null;
      }
    } catch (e) {
      print(
        '❌ GeneticInsightsService: Error fetching latest genetic insight: $e',
      );
      return null;
    }
  }

  /// Get genetic insights within a date range
  static Future<List<GeneticInsight>> getGeneticInsightsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print(
        '🔄 GeneticInsightsService: Fetching genetic insights for user: $userId between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}',
      );

      final response = await SupabaseService.client
          .from('genetic_insights')
          .select('*')
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      final insights = List<GeneticInsight>.from(
        response.map((item) => GeneticInsight.fromJson(item)),
      );

      print(
        '✅ GeneticInsightsService: Retrieved ${insights.length} genetic insights in date range',
      );
      return insights;
    } catch (e) {
      print(
        '❌ GeneticInsightsService: Error fetching genetic insights in date range: $e',
      );
      return [];
    }
  }
}
