import 'package:equatable/equatable.dart';
import '../models/motivational_short.dart';

abstract class WallpaperIntent extends Equatable {
  const WallpaperIntent();

  @override
  List<Object?> get props => [];
}

/// Intent to load the initial shorts feed, cached quotes, and favorites.
class LoadFeedIntent extends WallpaperIntent {}

/// Intent triggered when user swipes to a new vertical short in the feed.
class ChangeActiveShortIntent extends WallpaperIntent {
  final int index;
  const ChangeActiveShortIntent(this.index);

  @override
  List<Object?> get props => [index];
}

/// Intent to toggle in-app feed preview audio.
class ToggleFeedMuteIntent extends WallpaperIntent {}

/// Intent to favorite or unfavorite a short.
class ToggleFavoriteIntent extends WallpaperIntent {
  final String shortId;
  const ToggleFavoriteIntent(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

/// Intent to filter the shorts feed by category (e.g. All, Fighter, Discipline).
class FilterByCategoryIntent extends WallpaperIntent {
  final String category;
  const FilterByCategoryIntent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Intent to update or customize the quote on a specific short.
class UpdateCustomQuoteIntent extends WallpaperIntent {
  final String shortId;
  final String newQuote;
  const UpdateCustomQuoteIntent({
    required this.shortId,
    required this.newQuote,
  });

  @override
  List<Object?> get props => [shortId, newQuote];
}

/// Intent to reset quote to original default.
class ResetCustomQuoteIntent extends WallpaperIntent {
  final String shortId;
  const ResetCustomQuoteIntent(this.shortId);

  @override
  List<Object?> get props => [shortId];
}

/// Intent to apply the chosen short as a looping live wallpaper.
class ApplyLiveWallpaperIntent extends WallpaperIntent {
  final MotivationalShort short;
  final bool isMuted;

  const ApplyLiveWallpaperIntent({
    required this.short,
    this.isMuted = true,
  });

  @override
  List<Object?> get props => [short, isMuted];
}

/// Intent to share video or invoke native iPad "Use as Wallpaper" share sheet.
class ShareVideoIntent extends WallpaperIntent {
  final MotivationalShort short;
  const ShareVideoIntent(this.short);

  @override
  List<Object?> get props => [short];
}

/// Intent to open the Photos app on iPad/iOS.
class OpenPhotosIntent extends WallpaperIntent {}

/// Intent to check if the wallpaper is currently active on the device.
class CheckWallpaperStatusIntent extends WallpaperIntent {}

/// Intent to clear temporary status messages / snackbars.
class ClearStatusMessageIntent extends WallpaperIntent {}
