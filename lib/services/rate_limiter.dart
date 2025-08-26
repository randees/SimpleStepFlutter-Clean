/// Rate limiter for OpenAI API calls to prevent abuse
class RateLimiter {
  static final Map<String, List<DateTime>> _userRequests = {};
  static const int maxRequestsPerMinute = 10;
  static const int maxRequestsPerHour = 50;

  /// Check if user can make a request
  static bool canMakeRequest(String userId) {
    final now = DateTime.now();
    final userRequests = _userRequests[userId] ?? [];

    // Remove requests older than 1 hour
    userRequests.removeWhere((time) => now.difference(time).inHours >= 1);

    // Remove requests older than 1 minute for minute check
    final recentRequests = userRequests
        .where((time) => now.difference(time).inMinutes < 1)
        .toList();

    // Check limits
    if (recentRequests.length >= maxRequestsPerMinute) {
      return false;
    }

    if (userRequests.length >= maxRequestsPerHour) {
      return false;
    }

    // Add current request
    userRequests.add(now);
    _userRequests[userId] = userRequests;

    return true;
  }

  /// Get time until next request is allowed
  static Duration? getWaitTime(String userId) {
    final now = DateTime.now();
    final userRequests = _userRequests[userId] ?? [];

    final recentRequests = userRequests
        .where((time) => now.difference(time).inMinutes < 1)
        .toList();

    if (recentRequests.length >= maxRequestsPerMinute) {
      final oldestRecent = recentRequests.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      return Duration(minutes: 1) - now.difference(oldestRecent);
    }

    return null;
  }
}
