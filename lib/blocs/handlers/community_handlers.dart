import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/motivational_short.dart';
import '../../models/wallora_screen_blueprint.dart';
import '../../repositories/wallpaper_repository.dart';
import '../wallpaper_intent.dart';
import '../wallpaper_state.dart';

mixin CommunityHandlers on Bloc<WallpaperIntent, WallpaperState> {
  WallpaperFacadeRepository get repository;

  Future<void> onApplyScreenBlueprint(
    ApplyScreenBlueprintIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final blueprint = event.blueprint;
    MotivationalShort? targetShort;
    for (final s in state.allShorts) {
      if (s.id == blueprint.wallpaper.id) {
        targetShort = s;
        break;
      }
    }
    targetShort ??= state.currentShort ??
        (state.allShorts.isNotEmpty ? state.allShorts.first : null);

    // 1. Save quote customization if specified
    Map<String, String> updatedQuotes = state.customizedQuotes;
    if (targetShort != null && blueprint.customQuote.isNotEmpty) {
      await repository.saveCustomQuote(targetShort.id, blueprint.customQuote);
      updatedQuotes = Map<String, String>.from(state.customizedQuotes)
        ..[targetShort.id] = blueprint.customQuote;
    }

    // 2. Persist studio configurations
    await repository.saveAuraPaletteConfig(blueprint.auraConfig);
    await repository.saveParticleEffectConfig(blueprint.particleConfig);
    await repository.saveParallaxEffectConfig(blueprint.parallaxConfig);
    await repository.saveAuroraSynthesizerConfig(blueprint.auroraConfig);

    // 3. Apply live or static wallpaper
    if (targetShort != null) {
      if (targetShort.isLive) {
        await repository.applyAsLiveWallpaper(
          short: targetShort,
          isMuted: state.isFeedMuted,
        );
      } else {
        await repository.applyStaticWallpaper(
          short: targetShort,
          targetScreen: 'both',
          customQuote: blueprint.customQuote,
          effectConfig: state.getEffectiveEffects(targetShort.id),
        );
      }
    }

    int? newIndex;
    if (targetShort != null) {
      final idx = state.filteredShorts.indexOf(targetShort);
      if (idx != -1) newIndex = idx;
    }

    emit(state.copyWith(
      activeWallpaperId: targetShort?.id ?? state.activeWallpaperId,
      isLiveWallpaperActiveOnDevice:
          targetShort?.isLive == true ? true : state.isLiveWallpaperActiveOnDevice,
      activeIndex: newIndex ?? state.activeIndex,
      customizedQuotes: updatedQuotes,
      auraConfig: blueprint.auraConfig,
      particleConfig: blueprint.particleConfig,
      parallaxConfig: blueprint.parallaxConfig,
      auroraSynthesizerConfig: blueprint.auroraConfig,
      actionStatus: WallpaperActionStatus.appliedSuccess,
      message: '✨ Applied "${blueprint.title}" Aesthetic Blueprint!',
    ));
  }

  Future<void> onPublishCurrentSetup(
    PublishCurrentSetupIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final current = state.currentShort;
    if (current == null) {
      emit(state.copyWith(
          errorMessage:
              'Cannot publish blueprint: No active wallpaper selected.'));
      return;
    }

    final blueprint = WalloraScreenBlueprint(
      id: 'blueprint_user_${DateTime.now().millisecondsSinceEpoch}',
      title: event.title.trim().isEmpty
          ? '${current.title} Setup'
          : event.title.trim(),
      creatorName: event.creatorName.trim().isEmpty
          ? 'Wallora Creator'
          : event.creatorName.trim(),
      description: event.description.trim().isEmpty
          ? 'Complete screen aesthetic curated with Wallora.'
          : event.description.trim(),
      wallpaper: current,
      customQuote: state.customizedQuotes[current.id] ?? current.quote,
      auraConfig: state.auraConfig,
      particleConfig: state.particleConfig,
      parallaxConfig: state.parallaxConfig,
      auroraConfig: state.auroraSynthesizerConfig,
      tags:
          event.tags.isNotEmpty ? event.tags : [current.category, 'Community'],
      likesCount: 1,
      clonesCount: 0,
      createdAt: DateTime.now(),
    );

    await repository.savePublishedBlueprint(blueprint);
    final updatedList = repository.getCommunityBlueprints();
    emit(state.copyWith(
      communityBlueprints: updatedList,
      message: '🎉 "${blueprint.title}" published to Community Showcase!',
    ));
  }

  Future<void> onToggleBlueprintLike(
    ToggleBlueprintLikeIntent event,
    Emitter<WallpaperState> emit,
  ) async {
    final updatedLikedIds =
        await repository.toggleBlueprintLike(event.blueprintId);
    final isLiked = updatedLikedIds.contains(event.blueprintId);

    final updatedBlueprints = state.communityBlueprints.map((bp) {
      if (bp.id == event.blueprintId) {
        return bp.copyWith(
          likesCount: isLiked
              ? bp.likesCount + 1
              : (bp.likesCount > 0 ? bp.likesCount - 1 : 0),
        );
      }
      return bp;
    }).toList();

    emit(state.copyWith(
      likedBlueprintIds: updatedLikedIds,
      communityBlueprints: updatedBlueprints,
      message: isLiked ? 'Blueprint liked! ❤️' : 'Blueprint unliked.',
    ));
  }

  void onFilterCommunityBlueprints(
    FilterCommunityBlueprintsIntent event,
    Emitter<WallpaperState> emit,
  ) {
    emit(state.copyWith(communityTagFilter: event.tagQuery));
  }
}
