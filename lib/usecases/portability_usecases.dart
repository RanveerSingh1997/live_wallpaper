import 'package:equatable/equatable.dart';
import '../core/core.dart';
import '../models/wallora_backup_bundle.dart';
import '../repositories/data_portability_repository.dart';
import 'usecase.dart';

/// Use case that generates a complete backup archive of the user's customizations.
class CreateBackupBundleUseCase implements UseCase<WalloraBackupBundle, NoParams> {
  final DataPortabilityRepository portabilityRepository;

  CreateBackupBundleUseCase({required this.portabilityRepository});

  @override
  Future<Result<WalloraBackupBundle>> call(NoParams params) async {
    try {
      final bundle = await portabilityRepository.createBackupBundle();
      return Success(bundle);
    } catch (e, stack) {
      return Failure('Failed to create backup bundle: $e',
          error: e, stackTrace: stack);
    }
  }
}

/// Parameters for restoring a backup bundle with optional merge.
class RestoreBackupParams extends Equatable {
  final WalloraBackupBundle bundle;
  final bool mergeWithExisting;

  const RestoreBackupParams({
    required this.bundle,
    this.mergeWithExisting = false,
  });

  @override
  List<Object?> get props => [bundle, mergeWithExisting];
}

/// Use case that restores settings, playlists, and customizations from a backup bundle.
class RestoreBackupBundleUseCase implements UseCase<bool, RestoreBackupParams> {
  final DataPortabilityRepository portabilityRepository;

  RestoreBackupBundleUseCase({required this.portabilityRepository});

  @override
  Future<Result<bool>> call(RestoreBackupParams params) async {
    try {
      final success = await portabilityRepository.restoreBackupBundle(
        params.bundle,
        mergeWithExisting: params.mergeWithExisting,
      );
      if (!success) {
        return const Failure('Failed to restore backup bundle.');
      }
      return const Success(true);
    } catch (e, stack) {
      return Failure('Exception restoring backup bundle: $e',
          error: e, stackTrace: stack);
    }
  }
}
