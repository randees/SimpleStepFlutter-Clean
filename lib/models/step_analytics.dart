class StepAnalytics {
  final int totalSteps;
  final int averageSteps;
  final MostActiveDay mostActiveDay;
  final LeastActiveDay leastActiveDay;
  final Map<String, int> weeklyPattern;
  final List<DailyStepData> dailyData;
  final DateTime analysisStartDate;
  final DateTime analysisEndDate;

  StepAnalytics({
    required this.totalSteps,
    required this.averageSteps,
    required this.mostActiveDay,
    required this.leastActiveDay,
    required this.weeklyPattern,
    required this.dailyData,
    required this.analysisStartDate,
    required this.analysisEndDate,
  });

  factory StepAnalytics.fromJson(Map<String, dynamic> json) {
    return StepAnalytics(
      totalSteps: json['totalSteps'] as int,
      averageSteps: json['averageSteps'] as int,
      mostActiveDay: MostActiveDay.fromJson(
        json['mostActiveDay'] as Map<String, dynamic>,
      ),
      leastActiveDay: LeastActiveDay.fromJson(
        json['leastActiveDay'] as Map<String, dynamic>,
      ),
      weeklyPattern: Map<String, int>.from(json['weeklyPattern'] as Map),
      dailyData: (json['dailyData'] as List)
          .map((item) => DailyStepData.fromJson(item as Map<String, dynamic>))
          .toList(),
      analysisStartDate: DateTime.parse(json['analysisStartDate'] as String),
      analysisEndDate: DateTime.parse(json['analysisEndDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'averageSteps': averageSteps,
      'mostActiveDay': mostActiveDay.toJson(),
      'leastActiveDay': leastActiveDay.toJson(),
      'weeklyPattern': weeklyPattern,
      'dailyData': dailyData.map((item) => item.toJson()).toList(),
      'analysisStartDate': analysisStartDate.toIso8601String(),
      'analysisEndDate': analysisEndDate.toIso8601String(),
    };
  }

  String getFormattedSummary() {
    return '''
📊 **Step Analysis Summary (${analysisStartDate.toString().substring(0, 10)} to ${analysisEndDate.toString().substring(0, 10)})**

📈 **Overall Statistics:**
• Total Steps: ${totalSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}
• Average Daily Steps: ${averageSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}
• Analysis Period: ${dailyData.length} days

🏆 **Most Active Day:** ${mostActiveDay.date} with ${mostActiveDay.steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps

😴 **Least Active Day:** ${leastActiveDay.date} with ${leastActiveDay.steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps

📅 **Weekly Activity Pattern:**
${_getWeeklyPatternFormatted()}
    ''';
  }

  String _getWeeklyPatternFormatted() {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days
        .map((day) {
          final steps = weeklyPattern[day] ?? 0;
          return '• $day: ${steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps (average)';
        })
        .join('\n');
  }
}

class MostActiveDay {
  final String date;
  final int steps;

  MostActiveDay({required this.date, required this.steps});

  factory MostActiveDay.fromJson(Map<String, dynamic> json) {
    return MostActiveDay(
      date: json['date'] as String,
      steps: json['steps'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'steps': steps};
  }
}

class LeastActiveDay {
  final String date;
  final int steps;

  LeastActiveDay({required this.date, required this.steps});

  factory LeastActiveDay.fromJson(Map<String, dynamic> json) {
    return LeastActiveDay(
      date: json['date'] as String,
      steps: json['steps'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'steps': steps};
  }
}

class DailyStepData {
  final String date;
  final int steps;

  DailyStepData({required this.date, required this.steps});

  factory DailyStepData.fromJson(Map<String, dynamic> json) {
    return DailyStepData(
      date: json['date'] as String,
      steps: json['steps'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'steps': steps};
  }
}

class ActivityPatterns {
  final String mostActiveWeekday;
  final String leastActiveWeekday;
  final int mostActiveWeekdayAverage;
  final int leastActiveWeekdayAverage;
  final StepAnalytics stepAnalytics;

  ActivityPatterns({
    required this.mostActiveWeekday,
    required this.leastActiveWeekday,
    required this.mostActiveWeekdayAverage,
    required this.leastActiveWeekdayAverage,
    required this.stepAnalytics,
  });

  String getFormattedPatterns() {
    return '''
🎯 **30-Day Activity Pattern Analysis**

📊 **Weekly Patterns:**
• Most Active Day of Week: $mostActiveWeekday (${mostActiveWeekdayAverage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} avg steps)
• Least Active Day of Week: $leastActiveWeekday (${leastActiveWeekdayAverage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} avg steps)

🏅 **30-Day Highlights:**
• Highest Step Day: ${stepAnalytics.mostActiveDay.date} (${stepAnalytics.mostActiveDay.steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps)
• Lowest Step Day: ${stepAnalytics.leastActiveDay.date} (${stepAnalytics.leastActiveDay.steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps)
• Daily Average: ${stepAnalytics.averageSteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps
    ''';
  }
}
