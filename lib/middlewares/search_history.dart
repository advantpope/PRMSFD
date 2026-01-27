import 'package:hive/hive.dart';
part 'search_history.g.dart';

@HiveType(typeId: 10)
class SearchHistory {
  @HiveField(0)
  final String query;

  @HiveField(1)
  final String filterType; // e.g. "name", "valuation", "latlng"

  @HiveField(2)
  final int count;

  @HiveField(3)
  final DateTime lastUsed;

  SearchHistory({
    required this.query,
    required this.filterType,
    required this.count,
    required this.lastUsed,
  });

  SearchHistory copyWith({int? count, DateTime? lastUsed}) {
    return SearchHistory(
      query: query,
      filterType: filterType,
      count: count ?? this.count,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
