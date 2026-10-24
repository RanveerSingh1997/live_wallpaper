import '../../models/motivational_short.dart';
import '../../models/smart_filter_config.dart';

/// Pure domain helper that encapsulates feed filtering and recommendation sorting.
class WallpaperFeedFilter {
  const WallpaperFeedFilter._();

  /// Re-orders wallpapers so user's preferred categories appear first.
  static List<MotivationalShort> buildForYouList(
    List<MotivationalShort> all,
    Set<String> preferences,
  ) {
    if (preferences.isEmpty) return all;
    final preferred =
        all.where((s) => preferences.contains(s.category)).toList();
    final others =
        all.where((s) => !preferences.contains(s.category)).toList();
    return [...preferred, ...others];
  }

  /// Filters wallpapers based on active category, preferences, and smart filters.
  static List<MotivationalShort> filterShorts({
    required List<MotivationalShort> allShorts,
    required String category,
    required Set<String> preferences,
    required SmartFilterConfig smartFilter,
  }) {
    List<MotivationalShort> base;
    if (category == 'All') {
      base = allShorts;
    } else if (category == 'For You') {
      base = buildForYouList(allShorts, preferences);
    } else if (category == 'Live Wallpapers') {
      base = allShorts.where((s) => s.isLive).toList();
    } else if (category == 'Static Wallpapers') {
      base = allShorts.where((s) => !s.isLive).toList();
    } else if (category == 'AMOLED True-Black') {
      base = allShorts.where((s) => s.isAmoledCertified).toList();
    } else {
      base = allShorts.where((s) => s.category == category).toList();
    }

    if (smartFilter.hasActiveFilters) {
      base = base.where((s) => smartFilter.matches(s)).toList();
    }
    return base;
  }
}
