import 'package:equatable/equatable.dart';

import '../../domain/entities/activity_log_entry.dart';

class ActivityLogState extends Equatable {
  final List<ActivityLogEntry> entries;
  final String searchQuery;
  final int pageSize;

  const ActivityLogState({
    required this.entries,
    this.searchQuery = '',
    this.pageSize = 50,
  });

  List<ActivityLogEntry> get filteredEntries {
    final query = searchQuery.trim().toLowerCase();
    final filtered = entries.where((e) {
      if (query.isEmpty) return true;
      return e.details.toLowerCase().contains(query) || e.type.label.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (pageSize == -1) return filtered;
    return filtered.take(pageSize).toList();
  }

  int get totalMatchCount {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return entries.length;
    return entries.where((e) => e.details.toLowerCase().contains(query) || e.type.label.toLowerCase().contains(query)).length;
  }

  ActivityLogState copyWith({
    List<ActivityLogEntry>? entries,
    String? searchQuery,
    int? pageSize,
  }) {
    return ActivityLogState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [entries, searchQuery, pageSize];
}
