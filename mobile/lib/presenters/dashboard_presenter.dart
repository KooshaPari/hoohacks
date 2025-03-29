import '../controllers/health_data_controller.dart';
import '../models/health_data.dart';

/// Presenter in the MCP pattern - prepares data for the view
class DashboardPresenter {
  final HealthDataController _controller;
  
  DashboardPresenter(this._controller);
  
  /// Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    await _controller.initialize();
    
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 7));
    
    final summary = await _controller.getHealthSummary(startDate, today);
    final recentEntries = await _controller.getJournalEntriesInRange(
      startDate, today
    );
    
    // Sort entries by date, most recent first
    recentEntries.sort((a, b) => DateTime.parse(b.timestamp).compareTo(DateTime.parse(a.timestamp)));
    
    final weeklyNarrative = await _controller.getWeeklyNarrative();
    
    return {
      'summary': summary,
      'recentEntries': recentEntries.take(3).toList(),
      'weeklyNarrative': weeklyNarrative,
    };
  }
  
  /// Format date for display
  String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.month}/${date.day}/${date.year}';
  }
  
  /// Format time for display
  String formatTime(String isoDate) {
    final date = DateTime.parse(isoDate);
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
