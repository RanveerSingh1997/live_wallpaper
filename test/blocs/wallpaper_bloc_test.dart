import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/blocs/wallpaper_bloc.dart';
import 'package:live_wallpaper/blocs/wallpaper_intent.dart';
import 'package:live_wallpaper/blocs/wallpaper_state.dart';
import 'package:live_wallpaper/repositories/wallpaper_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WallpaperRepository repository;
  late WallpaperBloc bloc;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'favorite_short_ids': ['ippo_hard_work'],
      'custom_quote_ippo_hard_work': 'Custom test quote for Ippo',
    });
    final prefs = await SharedPreferences.getInstance();
    repository = WallpaperRepository(prefs: prefs);
    bloc = WallpaperBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('WallpaperBloc - Intent-Driven Tests', () {
    test('initial state has default idle values', () {
      expect(bloc.state.allShorts, isEmpty);
      expect(bloc.state.filteredShorts, isEmpty);
      expect(bloc.state.activeIndex, 0);
      expect(bloc.state.actionStatus, WallpaperActionStatus.idle);
      expect(bloc.state.isFeedMuted, true);
    });

    test('LoadFeedIntent loads shorts catalog, favorites and custom quotes', () async {
      bloc.add(LoadFeedIntent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<WallpaperState>(
            (s) => s.actionStatus == WallpaperActionStatus.loading,
          ),
          predicate<WallpaperState>((s) {
            final hasIppo = s.allShorts.any((x) => x.id == 'ippo_hard_work');
            final isFav = s.favoriteIds.contains('ippo_hard_work');
            final hasCustomQuote =
                s.customizedQuotes['ippo_hard_work'] == 'Custom test quote for Ippo';

            return s.actionStatus == WallpaperActionStatus.idle &&
                s.allShorts.isNotEmpty &&
                s.filteredShorts.length == s.allShorts.length &&
                hasIppo &&
                isFav &&
                hasCustomQuote;
          }),
        ]),
      );
    });

    test('ChangeActiveShortIntent updates activeIndex within bounds', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const ChangeActiveShortIntent(2));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.activeIndex == 2)),
      );
    });

    test('ToggleFeedMuteIntent toggles between mute and unmute', () async {
      expect(bloc.state.isFeedMuted, true);

      bloc.add(ToggleFeedMuteIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.isFeedMuted == false)),
      );

      bloc.add(ToggleFeedMuteIntent());
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) => s.isFeedMuted == true)),
      );
    });

    test('FilterByCategoryIntent filters shorts list properly', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const FilterByCategoryIntent('Fighter Spirit'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.selectedCategory == 'Fighter Spirit' &&
              s.filteredShorts.every((x) => x.category == 'Fighter Spirit') &&
              s.filteredShorts.isNotEmpty;
        })),
      );

      bloc.add(const FilterByCategoryIntent('All'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) {
          return s.selectedCategory == 'All' &&
              s.filteredShorts.length == s.allShorts.length;
        })),
      );
    });

    test('ToggleFavoriteIntent adds and removes short from favorites', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      // Toggle off ippo_hard_work (was initial favorite)
      bloc.add(const ToggleFavoriteIntent('ippo_hard_work'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => !s.favoriteIds.contains('ippo_hard_work'))),
      );

      // Toggle back on
      bloc.add(const ToggleFavoriteIntent('ippo_hard_work'));
      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>(
            (s) => s.favoriteIds.contains('ippo_hard_work'))),
      );
    });

    test('UpdateCustomQuoteIntent and ResetCustomQuoteIntent work properly', () async {
      bloc.add(LoadFeedIntent());
      await bloc.stream.firstWhere((s) => s.allShorts.isNotEmpty);

      bloc.add(const UpdateCustomQuoteIntent(
        shortId: 'discipline_grind',
        newQuote: 'Pain is temporary, pride is forever.',
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            s.customizedQuotes['discipline_grind'] ==
            'Pain is temporary, pride is forever.')),
      );

      bloc.add(const ResetCustomQuoteIntent('discipline_grind'));

      await expectLater(
        bloc.stream,
        emits(predicate<WallpaperState>((s) =>
            !s.customizedQuotes.containsKey('discipline_grind'))),
      );
    });
  });
}
