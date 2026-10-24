import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Production-grade obsidian dark fallback widget rendered when an unhandled
/// widget layout exception occurs, avoiding the red/grey screen of death in release builds.
class ProductionCrashFallbackWidget extends StatelessWidget {
  final FlutterErrorDetails? details;
  final VoidCallback? onRetry;

  const ProductionCrashFallbackWidget({
    super.key,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkBackground,
      child: Center(
        child: Padding(
          padding: AppDimensions.paddingAll24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),
              const Text(
                'Something unexpected occurred',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space8),
              const Text(
                'Wallora recovered gracefully. The incident has been recorded in your local diagnostic buffer.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space20),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reload Interface'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.auroraViolet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radius12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space20,
                      vertical: AppDimensions.space12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
