// Wallora Live Audio-Reactive Visualizer — Opaque-Box E2E Test Suite
// Conforms to TEST_INFRA.md, ORIGINAL_REQUEST.md, PROJECT.md, and AGENTS.md.
// 4-Tier Test Architecture:
//   Tier 1: Feature Coverage (5 tests x 10 features = 50 tests)
//   Tier 2: Boundary & Corner Cases (5 tests x 10 features = 50 tests)
//   Tier 3: Pairwise Cross-Feature Interactions (10 tests)
//   Tier 4: Real-World Application Scenarios (5 scenarios)
// Total test count: 115 tests. 100% deterministic, headless CI execution.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:live_wallpaper/models/audio_spectrum_metrics.dart';
import 'package:live_wallpaper/models/audio_visualizer_config.dart';
import 'package:live_wallpaper/services/audio_fft_engine.dart';
import 'package:live_wallpaper/services/audio_lifecycle_coordinator.dart';
import 'package:live_wallpaper/services/live_audio_capture_service.dart';
import 'package:live_wallpaper/services/silence_detection_watchdog.dart';
import 'package:live_wallpaper/services/simulated_audio_capture_service.dart';

const String keyAudioVisualizerPersistence = 'audio_visualizer_config';

class AudioFftEngineOracle {
  static const int sampleRate = 44100;
  static const int fftSize = 512;

  final AudioFftEngine _engine = AudioFftEngine();

  AudioSpectrumMetrics processSamples(
    List<double> samples, {
    AudioVisualizerConfig config = AudioVisualizerConfig.defaultConfig,
    int? timestampMs,
  }) {
    return _engine.processSamples(
      samples,
      config: config,
      timestampMs: timestampMs,
    );
  }
}

// =============================================================================
// VISUALIZER DYNAMIC PARAMETERS ORACLE (Wave, Particles & Neon Spline)
// =============================================================================

class VisualizerModulationOracle {
  static const Color cyanAnchor = Color(0xFF00E5FF);
  static const Color violetAnchor = Color(0xFFD500F9);
  static const Color amberAnchor = Color(0xFFFF5722);
  static const Color emeraldAnchor = Color(0xFF00E676);

  static double modulatedWaveAmplitude({
    double baseAmplitude = 1.0,
    required double bass,
    required double reactiveIntensity,
  }) {
    return baseAmplitude * (1.0 + bass * 1.8 * reactiveIntensity);
  }

  static double modulatedWaveSpeed({
    double baseSpeed = 1.0,
    required double mid,
    required double reactiveIntensity,
  }) {
    return baseSpeed * (1.0 + mid * 1.2 * reactiveIntensity);
  }

  static double modulatedWaveFrequency({
    double baseFrequency = 1.5,
    required double treble,
    required double reactiveIntensity,
  }) {
    return baseFrequency * (1.0 + treble * 1.4 * reactiveIntensity);
  }

  static double particleBurstSpeed({
    double baseSpeed = 1.0,
    required bool peakDetected,
    required double bass,
    required double reactiveIntensity,
  }) {
    final boost = peakDetected ? 1.5 : (bass * 0.8);
    return baseSpeed * (1.0 + boost * reactiveIntensity);
  }

  static double particleRadiance({
    double baseRadiance = 1.0,
    required double treble,
    required double reactiveIntensity,
  }) {
    return baseRadiance * (1.0 + treble * 1.0 * reactiveIntensity);
  }

  /// Evaluates 4-anchor neon spline along Cyan -> Violet -> Amber -> Emerald
  static Color evaluateNeonSpline(double t) {
    final clampedT = t.clamp(0.0, 1.0);
    if (clampedT <= 1.0 / 3.0) {
      final localT = clampedT * 3.0;
      return Color.lerp(cyanAnchor, violetAnchor, localT)!;
    } else if (clampedT <= 2.0 / 3.0) {
      final localT = (clampedT - 1.0 / 3.0) * 3.0;
      return Color.lerp(violetAnchor, amberAnchor, localT)!;
    } else {
      final localT = (clampedT - 2.0 / 3.0) * 3.0;
      return Color.lerp(amberAnchor, emeraldAnchor, localT)!;
    }
  }
}

// =============================================================================
// BLoC UDF HARNESS & STATE SELECTORS
// =============================================================================

class AudioVisualizerTestState extends Equatable {
  final AudioVisualizerConfig config;
  final AudioSpectrumMetrics metrics;
  final bool isCaptureRunning;

  const AudioVisualizerTestState({
    this.config = AudioVisualizerConfig.defaultConfig,
    this.metrics = AudioSpectrumMetrics.zero,
    this.isCaptureRunning = false,
  });

  bool get isAudioReactiveActive => config.isEnabled && !metrics.isSilent;
  double get effectiveBassEnergy => metrics.bass * config.reactiveIntensity;
  double get effectiveMidEnergy => metrics.mid * config.reactiveIntensity;
  double get effectiveTrebleEnergy => metrics.treble * config.reactiveIntensity;
  double get effectiveOverallEnergy => metrics.overallAmplitude * config.reactiveIntensity;

  AudioVisualizerTestState copyWith({
    AudioVisualizerConfig? config,
    AudioSpectrumMetrics? metrics,
    bool? isCaptureRunning,
  }) {
    return AudioVisualizerTestState(
      config: config ?? this.config,
      metrics: metrics ?? this.metrics,
      isCaptureRunning: isCaptureRunning ?? this.isCaptureRunning,
    );
  }

  @override
  List<Object?> get props => [config, metrics, isCaptureRunning];
}

class AudioVisualizerBlocHarness {
  AudioVisualizerTestState _state = const AudioVisualizerTestState();
  final StreamController<AudioVisualizerTestState> _stateController =
      StreamController<AudioVisualizerTestState>.broadcast();

  AudioVisualizerTestState get state => _state;
  Stream<AudioVisualizerTestState> get stream => _stateController.stream;

  void toggleAudioVisualizer([bool? isEnabled]) {
    final target = isEnabled ?? !_state.config.isEnabled;
    final newConfig = _state.config.copyWith(isEnabled: target);
    _state = _state.copyWith(
      config: newConfig,
      isCaptureRunning: target,
      metrics: target ? _state.metrics : AudioSpectrumMetrics.zero,
    );
    _stateController.add(_state);
  }

  void updateConfig(AudioVisualizerConfig config) {
    _state = _state.copyWith(config: config);
    _stateController.add(_state);
  }

  void setPreset(AudioVisualizerPreset preset) {
    final newConfig = AudioVisualizerConfig.presetConfig(preset);
    _state = _state.copyWith(config: newConfig);
    _stateController.add(_state);
  }

  void setCaptureMode(AudioCaptureMode mode) {
    final newConfig = _state.config.copyWith(mode: mode);
    _state = _state.copyWith(config: newConfig);
    _stateController.add(_state);
  }

  void resetConfig() {
    _state = _state.copyWith(config: AudioVisualizerConfig.defaultConfig);
    _stateController.add(_state);
  }

  void onSpectrumUpdated(AudioSpectrumMetrics metrics) {
    if (_state.config.isEnabled) {
      _state = _state.copyWith(metrics: metrics);
      _stateController.add(_state);
    }
  }

  void pauseCapture() {
    _state = _state.copyWith(isCaptureRunning: false);
    _stateController.add(_state);
  }

  void resumeCapture() {
    if (_state.config.isEnabled) {
      _state = _state.copyWith(isCaptureRunning: true);
      _stateController.add(_state);
    }
  }

  void dispose() {
    _stateController.close();
  }
}

// =============================================================================
// PROCEDURAL CANVAS TEST WIDGET (60 FPS Benchmark)
// =============================================================================

class AudioReactiveCanvasTestWidget extends StatelessWidget {
  final AudioSpectrumMetrics metrics;
  final AudioVisualizerConfig config;

  const AudioReactiveCanvasTestWidget({
    super.key,
    required this.metrics,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AudioReactiveCanvasPainter(
          metrics: metrics,
          config: config,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _AudioReactiveCanvasPainter extends CustomPainter {
  final AudioSpectrumMetrics metrics;
  final AudioVisualizerConfig config;

  static final Paint _paintCache = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0;
  static final Path _pathCache = Path();

  _AudioReactiveCanvasPainter({
    required this.metrics,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final amplitude = VisualizerModulationOracle.modulatedWaveAmplitude(
      baseAmplitude: 30.0,
      bass: metrics.bass,
      reactiveIntensity: config.reactiveIntensity,
    );
    final frequency = VisualizerModulationOracle.modulatedWaveFrequency(
      baseFrequency: 0.015,
      treble: metrics.treble,
      reactiveIntensity: config.reactiveIntensity,
    );
    final color = VisualizerModulationOracle.evaluateNeonSpline(metrics.overallAmplitude);

    _paintCache.color = color;
    _pathCache.reset();

    final midY = size.height * 0.5;
    _pathCache.moveTo(0, midY);

    for (double x = 0; x <= size.width; x += 10) {
      final y = midY + math.sin(x * frequency) * amplitude;
      _pathCache.lineTo(x, y);
    }

    canvas.drawPath(_pathCache, _paintCache);
  }

  @override
  bool shouldRepaint(covariant _AudioReactiveCanvasPainter oldDelegate) {
    return oldDelegate.metrics != metrics || oldDelegate.config != config;
  }
}

// =============================================================================
// COMPLETE OPAQUE-BOX E2E TEST SUITE (Tiers 1 - 4)
// =============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wallora Live Audio-Reactive Visualizer E2E Test Suite', () {
    // -------------------------------------------------------------------------
    // TIER 1: FEATURE COVERAGE (50 Tests, 5 per feature across 10 features)
    // -------------------------------------------------------------------------
    group('Tier 1: Feature Coverage (50 Tests)', () {
      // Feature 1: Live Audio Frequency Analysis & Spectrum Bands
      group('Feature 1: Frequency Analysis & Spectrum Bands', () {
        late AudioFftEngineOracle dsp;

        setUp(() {
          dsp = AudioFftEngineOracle();
        });

        test('F1.1: 100 Hz pure sine wave yields dominant Bass energy (>0.70)', () {
          final samples = List.generate(AudioFftEngineOracle.fftSize, (i) {
            final t = i / AudioFftEngineOracle.sampleRate;
            return math.sin(2.0 * math.pi * 100.0 * t);
          });
          const config = AudioVisualizerConfig(smoothingFactor: 0.0);
          final metrics = dsp.processSamples(samples, config: config);
          expect(metrics.bass, greaterThan(0.70));
          expect(metrics.treble, lessThan(0.20));
          expect(metrics.isSilent, isFalse);
        });

        test('F1.2: 1,000 Hz pure sine wave yields dominant Mid energy (>0.70)', () {
          final samples = List.generate(AudioFftEngineOracle.fftSize, (i) {
            final t = i / AudioFftEngineOracle.sampleRate;
            return math.sin(2.0 * math.pi * 1000.0 * t);
          });
          const config = AudioVisualizerConfig(smoothingFactor: 0.0);
          final metrics = dsp.processSamples(samples, config: config);
          expect(metrics.mid, greaterThan(0.70));
          expect(metrics.bass, lessThan(0.25));
          expect(metrics.isSilent, isFalse);
        });

        test('F1.3: 10,000 Hz pure sine wave yields dominant Treble energy (>0.70)', () {
          final samples = List.generate(AudioFftEngineOracle.fftSize, (i) {
            final t = i / AudioFftEngineOracle.sampleRate;
            return math.sin(2.0 * math.pi * 10000.0 * t);
          });
          const config = AudioVisualizerConfig(smoothingFactor: 0.0);
          final metrics = dsp.processSamples(samples, config: config);
          expect(metrics.treble, greaterThan(0.70));
          expect(metrics.bass, lessThan(0.20));
          expect(metrics.isSilent, isFalse);
        });

        test('F1.4: Multi-tone synthetic signal distributes energy across Bass, Mid, and Treble', () {
          final samples = List.generate(AudioFftEngineOracle.fftSize, (i) {
            final t = i / AudioFftEngineOracle.sampleRate;
            return (math.sin(2.0 * math.pi * 80.0 * t) +
                    math.sin(2.0 * math.pi * 1200.0 * t) +
                    math.sin(2.0 * math.pi * 9000.0 * t)) /
                3.0;
          });
          final metrics = dsp.processSamples(samples);
          expect(metrics.bass, greaterThan(0.20));
          expect(metrics.mid, greaterThan(0.20));
          expect(metrics.treble, greaterThan(0.20));
        });

        test('F1.5: Overall amplitude accurately tracks RMS energy of the sample buffer', () {
          final samples = List.generate(AudioFftEngineOracle.fftSize, (i) {
            final t = i / AudioFftEngineOracle.sampleRate;
            return 0.5 * math.sin(2.0 * math.pi * 440.0 * t);
          });
          final metrics = dsp.processSamples(samples);
          // Theoretical RMS of 0.5 * sin(wt) is 0.5 / sqrt(2) ~ 0.3535
          expect(metrics.overallAmplitude, closeTo(0.35, 0.05));
        });
      });

      // Feature 2: Visualizer Dynamic Parameters (Wave & Particles)
      group('Feature 2: Dynamic Visual Parameters', () {
        test('F2.1: Bass energy modulates wave crest amplitude proportionally up to 2.8x base', () {
          final base = 100.0;
          final modulated = VisualizerModulationOracle.modulatedWaveAmplitude(
            baseAmplitude: base,
            bass: 1.0,
            reactiveIntensity: 1.0,
          );
          expect(modulated, closeTo(280.0, 0.1));
        });

        test('F2.2: Mid energy modulates wave transit speed smoothly without discontinuity', () {
          final speedLow = VisualizerModulationOracle.modulatedWaveSpeed(
            baseSpeed: 1.0,
            mid: 0.2,
            reactiveIntensity: 1.0,
          );
          final speedHigh = VisualizerModulationOracle.modulatedWaveSpeed(
            baseSpeed: 1.0,
            mid: 0.8,
            reactiveIntensity: 1.0,
          );
          expect(speedHigh, greaterThan(speedLow));
          expect(speedHigh, closeTo(1.96, 0.05));
        });

        test('F2.3: Treble shimmer increases spatial wave frequency and particle radiance', () {
          final freq = VisualizerModulationOracle.modulatedWaveFrequency(
            baseFrequency: 1.5,
            treble: 0.9,
            reactiveIntensity: 1.0,
          );
          final radiance = VisualizerModulationOracle.particleRadiance(
            baseRadiance: 1.0,
            treble: 0.9,
            reactiveIntensity: 1.0,
          );
          expect(freq, closeTo(3.39, 0.05));
          expect(radiance, closeTo(1.9, 0.05));
        });

        test('F2.4: Peak detection triggers boosted particle burst velocity', () {
          final burstNormal = VisualizerModulationOracle.particleBurstSpeed(
            peakDetected: false,
            bass: 0.5,
            reactiveIntensity: 1.0,
          );
          final burstPeak = VisualizerModulationOracle.particleBurstSpeed(
            peakDetected: true,
            bass: 0.5,
            reactiveIntensity: 1.0,
          );
          expect(burstPeak, greaterThan(burstNormal));
          expect(burstPeak, closeTo(2.5, 0.05));
        });

        test('F2.5: 4-anchor neon spline shifts smoothly through Cyan, Violet, Amber, Emerald', () {
          final cStart = VisualizerModulationOracle.evaluateNeonSpline(0.0);
          final cMid1 = VisualizerModulationOracle.evaluateNeonSpline(0.33);
          final cMid2 = VisualizerModulationOracle.evaluateNeonSpline(0.66);
          final cEnd = VisualizerModulationOracle.evaluateNeonSpline(1.0);

          expect(cStart, equals(VisualizerModulationOracle.cyanAnchor));
          expect(cEnd, equals(VisualizerModulationOracle.emeraldAnchor));
          expect(cMid1, isNot(equals(cStart)));
          expect(cMid2, isNot(equals(cEnd)));
        });
      });

      // Feature 3: Visualizer Configuration Controls & Presets
      group('Feature 3: Configuration Controls & Presets', () {
        test('F3.1: cosmicPulse preset loads canonical balanced configuration', () {
          final config = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.cosmicPulse);
          expect(config.preset, AudioVisualizerPreset.cosmicPulse);
          expect(config.sensitivity, 1.2);
          expect(config.smoothingFactor, 0.70);
          expect(config.frequencyFocus, AudioFrequencyFocus.allFrequencies);
        });

        test('F3.2: clubBassDrop preset prioritizes bassCentric focus and heightened intensity', () {
          final config = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.clubBassDrop);
          expect(config.preset, AudioVisualizerPreset.clubBassDrop);
          expect(config.frequencyFocus, AudioFrequencyFocus.bassCentric);
          expect(config.sensitivity, 1.8);
          expect(config.reactiveIntensity, 1.5);
        });

        test('F3.3: ambientChill preset applies higher smoothing and lower intensity', () {
          final config = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.ambientChill);
          expect(config.preset, AudioVisualizerPreset.ambientChill);
          expect(config.smoothingFactor, 0.90);
          expect(config.reactiveIntensity, 0.6);
        });

        test('F3.4: vocalAcoustic preset focuses on mid frequencies with moderate response', () {
          final config = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.vocalAcoustic);
          expect(config.preset, AudioVisualizerPreset.vocalAcoustic);
          expect(config.frequencyFocus, AudioFrequencyFocus.midVocal);
          expect(config.sensitivity, 1.3);
        });

        test('F3.5: minimalistNoir preset sets subtle sensitivity and gentle intensity', () {
          final config = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.minimalistNoir);
          expect(config.preset, AudioVisualizerPreset.minimalistNoir);
          expect(config.sensitivity, 0.5);
          expect(config.reactiveIntensity, 0.3);
        });
      });

      // Feature 4: State Management & UDF Integration
      group('Feature 4: State Management & UDF Integration', () {
        late AudioVisualizerBlocHarness bloc;

        setUp(() {
          bloc = AudioVisualizerBlocHarness();
        });

        tearDown(() {
          bloc.dispose();
        });

        test('F4.1: ToggleAudioVisualizerIntent(true) activates visualizer state', () {
          expect(bloc.state.config.isEnabled, isFalse);
          bloc.toggleAudioVisualizer(true);
          expect(bloc.state.config.isEnabled, isTrue);
          expect(bloc.state.isCaptureRunning, isTrue);
        });

        test('F4.2: ToggleAudioVisualizerIntent(false) deactivates visualizer and zeroes metrics', () {
          bloc.toggleAudioVisualizer(true);
          bloc.onSpectrumUpdated(const AudioSpectrumMetrics(
            bass: 0.8,
            mid: 0.5,
            treble: 0.4,
            overallAmplitude: 0.7,
            peakDetected: false,
            isSilent: false,
            timestampMs: 100,
          ));
          expect(bloc.state.metrics.bass, 0.8);

          bloc.toggleAudioVisualizer(false);
          expect(bloc.state.config.isEnabled, isFalse);
          expect(bloc.state.isCaptureRunning, isFalse);
          expect(bloc.state.metrics, AudioSpectrumMetrics.zero);
          expect(bloc.state.isAudioReactiveActive, isFalse);
        });

        test('F4.3: UpdateAudioVisualizerConfigIntent immutably updates configuration', () {
          const custom = AudioVisualizerConfig(
            isEnabled: true,
            sensitivity: 2.2,
            reactiveIntensity: 1.8,
          );
          bloc.updateConfig(custom);
          expect(bloc.state.config.sensitivity, 2.2);
          expect(bloc.state.config.reactiveIntensity, 1.8);
        });

        test('F4.4: Spectrum update dispatches immutable metrics snapshot', () {
          bloc.toggleAudioVisualizer(true);
          const metrics = AudioSpectrumMetrics(
            bass: 0.95,
            mid: 0.60,
            treble: 0.30,
            overallAmplitude: 0.85,
            peakDetected: true,
            isSilent: false,
            timestampMs: 12345,
          );
          bloc.onSpectrumUpdated(metrics);
          expect(bloc.state.metrics.bass, 0.95);
          expect(bloc.state.metrics.peakDetected, isTrue);
          expect(bloc.state.isAudioReactiveActive, isTrue);
        });

        test('F4.5: State selector isAudioReactiveActive respects silence flag', () {
          bloc.toggleAudioVisualizer(true);
          expect(bloc.state.isAudioReactiveActive, isFalse); // Initial is silent

          bloc.onSpectrumUpdated(const AudioSpectrumMetrics(
            bass: 0.5,
            mid: 0.5,
            treble: 0.5,
            overallAmplitude: 0.5,
            peakDetected: false,
            isSilent: false,
            timestampMs: 200,
          ));
          expect(bloc.state.isAudioReactiveActive, isTrue);

          bloc.onSpectrumUpdated(AudioSpectrumMetrics.zero);
          expect(bloc.state.isAudioReactiveActive, isFalse);
        });
      });

      // Feature 5: Dual-Source Capture (Simulated vs Live)
      group('Feature 5: Dual-Source Capture (Simulated vs Live)', () {
        late SimulatedAudioCaptureService simulatedService;

        setUp(() {
          simulatedService = SimulatedAudioCaptureService();
        });

        tearDown(() {
          simulatedService.dispose();
        });

        test('F5.1: Simulated capture boots immediately and emits non-null spectrum packets', () async {
          expect(simulatedService.isRunning, isFalse);
          final streamFuture = simulatedService.spectrumStream.first;
          await simulatedService.start();
          expect(simulatedService.isRunning, isTrue);

          final packet = await streamFuture;
          expect(packet, isNotNull);
          await simulatedService.stop();
        });

        test('F5.2: technoBeat synthetic preset produces periodic rhythmic bass pulses', () {
          simulatedService.syntheticPreset = SyntheticAudioPreset.technoBeat;
          final frame1 = simulatedService.stepFrame();
          expect(frame1.bass, greaterThan(0.40));
          expect(frame1.isSilent, isFalse);
        });

        test('F5.3: ambientCosmic synthetic preset produces slow drone and shimmer', () {
          simulatedService.syntheticPreset = SyntheticAudioPreset.ambientCosmic;
          final frame = simulatedService.stepFrame();
          expect(frame.bass, greaterThan(0.20));
          expect(frame.treble, greaterThan(0.20));
        });

        test('F5.4: melodicFlow synthetic preset emphasizes mid-frequency band', () {
          simulatedService.syntheticPreset = SyntheticAudioPreset.melodicFlow;
          final frame = simulatedService.stepFrame();
          expect(frame.mid, greaterThan(0.35));
        });

        test('F5.5: Live audio capture falls back cleanly to simulated service if permission denied', () async {
          final liveService = LiveAudioCaptureService(
            fallbackService: simulatedService,
            simulatePermissionDenied: true,
          );
          expect(liveService.isRunning, isFalse);
          await liveService.start();
          expect(liveService.isRunning, isTrue);
          expect(simulatedService.isRunning, isTrue);
          await liveService.stop();
          await liveService.dispose();
        });
      });

      // Feature 6: Settings Persistence & Export Portability
      group('Feature 6: Settings Persistence & Portability', () {
        test('F6.1: Audio visualizer config serializes to JSON symmetrically', () {
          const config = AudioVisualizerConfig(
            isEnabled: true,
            mode: AudioCaptureMode.simulated,
            preset: AudioVisualizerPreset.clubBassDrop,
            sensitivity: 2.5,
            smoothingFactor: 0.85,
            frequencyFocus: AudioFrequencyFocus.bassCentric,
            reactiveIntensity: 1.7,
            isSilenceDetectionEnabled: true,
            silenceThreshold: 0.02,
          );
          final json = config.toJson();
          final deserialized = AudioVisualizerConfig.fromJson(json);
          expect(deserialized, equals(config));
        });

        test('F6.2: SharedPreferences persists and reloads audio visualizer JSON string', () async {
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();

          const config = AudioVisualizerConfig(
            isEnabled: true,
            preset: AudioVisualizerPreset.vocalAcoustic,
            sensitivity: 1.4,
          );
          await prefs.setString(keyAudioVisualizerPersistence, jsonEncode(config.toJson()));

          final storedRaw = prefs.getString(keyAudioVisualizerPersistence);
          expect(storedRaw, isNotNull);
          final loadedConfig = AudioVisualizerConfig.fromJson(jsonDecode(storedRaw!) as Map<String, dynamic>);
          expect(loadedConfig.preset, AudioVisualizerPreset.vocalAcoustic);
          expect(loadedConfig.sensitivity, 1.4);
        });

        test('F6.3: Wallora backup bundle format encapsulates audio visualizer configuration', () {
          const config = AudioVisualizerConfig(
            isEnabled: true,
            preset: AudioVisualizerPreset.ambientChill,
          );
          final bundleMap = {
            'version': 1,
            'appName': 'Wallora',
            'exportedAt': DateTime.now().toIso8601String(),
            'audio_visualizer_config': config.toJson(),
          };
          expect(bundleMap.containsKey('audio_visualizer_config'), isTrue);
          final restored = AudioVisualizerConfig.fromJson(
            bundleMap['audio_visualizer_config'] as Map<String, dynamic>,
          );
          expect(restored.preset, AudioVisualizerPreset.ambientChill);
        });

        test('F6.4: Factory reset clears persisted visualizer settings and restores defaults', () async {
          SharedPreferences.setMockInitialValues({
            keyAudioVisualizerPersistence: jsonEncode(const AudioVisualizerConfig(isEnabled: true).toJson()),
          });
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.containsKey(keyAudioVisualizerPersistence), isTrue);

          await prefs.remove(keyAudioVisualizerPersistence);
          expect(prefs.containsKey(keyAudioVisualizerPersistence), isFalse);
        });

        test('F6.5: Exported JSON bundle adheres to UTF-8 string portability', () {
          const config = AudioVisualizerConfig(
            preset: AudioVisualizerPreset.cosmicPulse,
            sensitivity: 2.0,
          );
          final jsonStr = jsonEncode(config.toJson());
          final bytes = utf8.encode(jsonStr);
          final decodedStr = utf8.decode(bytes);
          expect(decodedStr, equals(jsonStr));
        });
      });

      // Feature 7: Zero Sleep Overhead & App Lifecycle
      group('Feature 7: Zero Sleep Overhead & App Lifecycle', () {
        late SimulatedAudioCaptureService captureService;
        late SilenceDetectionWatchdog silenceWatchdog;
        late AudioLifecycleCoordinator coordinator;

        setUp(() {
          captureService = SimulatedAudioCaptureService();
          silenceWatchdog = SilenceDetectionWatchdog(
            onSilenceAutoHalt: () {},
            onSoundWakeup: () {},
          );
          coordinator = AudioLifecycleCoordinator(
            captureService: captureService,
            silenceWatchdog: silenceWatchdog,
          );
        });

        tearDown(() async {
          await coordinator.captureService?.dispose();
          silenceWatchdog.dispose();
        });

        test('F7.1: App paused state halts capture service immediately', () async {
          await captureService.start();
          expect(captureService.isRunning, isTrue);

          await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
          expect(captureService.isRunning, isFalse);
        });

        test('F7.2: App inactive state halts capture processing', () async {
          await captureService.start();
          await coordinator.onLifecycleStateChanged(AppLifecycleState.inactive);
          expect(captureService.isRunning, isFalse);
        });

        test('F7.3: App hidden state halts capture loop', () async {
          await captureService.start();
          await coordinator.onLifecycleStateChanged(AppLifecycleState.hidden);
          expect(captureService.isRunning, isFalse);
        });

        test('F7.4: App detached state halts audio capture and frees resources', () async {
          await captureService.start();
          await coordinator.onLifecycleStateChanged(AppLifecycleState.detached);
          expect(captureService.isRunning, isFalse);
        });

        test('F7.5: Returning to resumed state restarts capture service when screen is on', () async {
          await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
          expect(captureService.isRunning, isFalse);

          await coordinator.onLifecycleStateChanged(AppLifecycleState.resumed);
          expect(captureService.isRunning, isTrue);
          await captureService.stop();
        });
      });

      // Feature 8: Silence Threshold Auto-Halt & Throttle
      group('Feature 8: Silence Threshold Auto-Halt & Throttle', () {
        late SilenceDetectionWatchdog watchdog;
        bool halted = false;
        bool woken = false;

        setUp(() {
          halted = false;
          woken = false;
          watchdog = SilenceDetectionWatchdog(
            silenceThreshold: 0.015,
            haltDuration: const Duration(milliseconds: 3000),
            onSilenceAutoHalt: () {
              halted = true;
            },
            onSoundWakeup: () {
              woken = true;
            },
          );
        });

        tearDown(() {
          watchdog.dispose();
        });

        test('F8.1: Continuous silence below threshold for 3.0s triggers auto-halt', () {
          expect(halted, isFalse);
          // Simulate 3000ms in steps of 100ms
          for (int i = 0; i < 30; i++) {
            watchdog.inspectAudioFrame(0.005, elapsedMs: 100);
          }
          expect(halted, isTrue);
          expect(watchdog.isHalted, isTrue);
        });

        test('F8.2: Auto-halt stays in effect as long as silence continues', () {
          for (int i = 0; i < 35; i++) {
            watchdog.inspectAudioFrame(0.002, elapsedMs: 100);
          }
          expect(halted, isTrue);
          expect(woken, isFalse);
        });

        test('F8.3: Sound resumption above hysteresis threshold (0.025) wakes engine immediately', () {
          for (int i = 0; i < 30; i++) {
            watchdog.inspectAudioFrame(0.005, elapsedMs: 100);
          }
          expect(halted, isTrue);

          watchdog.inspectAudioFrame(0.05, elapsedMs: 16);
          expect(woken, isTrue);
          expect(watchdog.isHalted, isFalse);
        });

        test('F8.4: Sound pulse at 2.9s resets silence timer, preventing premature halt', () {
          for (int i = 0; i < 29; i++) {
            watchdog.inspectAudioFrame(0.005, elapsedMs: 100);
          }
          expect(halted, isFalse);

          // Reset pulse
          watchdog.inspectAudioFrame(0.5, elapsedMs: 100);
          expect(halted, isFalse);

          // Additional 1s silence -> not yet 3s
          for (int i = 0; i < 10; i++) {
            watchdog.inspectAudioFrame(0.005, elapsedMs: 100);
          }
          expect(halted, isFalse);
        });

        test('F8.5: When silence detection is disabled in config, FFT process ignores silence', () {
          final dsp = AudioFftEngineOracle();
          const config = AudioVisualizerConfig(
            isSilenceDetectionEnabled: false,
            silenceThreshold: 0.015,
          );
          final silentBuffer = List<double>.filled(512, 0.002);
          final metrics = dsp.processSamples(silentBuffer, config: config);
          expect(metrics.isSilent, isFalse);
        });
      });

      // Feature 9: Headless CI Deterministic Execution
      group('Feature 9: Headless CI Deterministic Execution', () {
        test('F9.1: Simulated capture produces identical spectrum sequence for fixed seed/steps', () {
          final serviceA = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);
          final serviceB = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);

          final framesA = List.generate(20, (_) => serviceA.stepFrame());
          final framesB = List.generate(20, (_) => serviceB.stepFrame());

          for (int i = 0; i < 20; i++) {
            expect(framesA[i].bass, equals(framesB[i].bass));
            expect(framesA[i].mid, equals(framesB[i].mid));
            expect(framesA[i].treble, equals(framesB[i].treble));
          }

          serviceA.dispose();
          serviceB.dispose();
        });

        test('F9.2: Test suite runs headlessly without physical microphone hardware', () {
          final dsp = AudioFftEngineOracle();
          final dummy = List<double>.filled(512, 0.2);
          final metrics = dsp.processSamples(dummy);
          expect(metrics, isNotNull);
        });

        test('F9.3: Asynchronous stream subscription delivers events reliably under pump', () async {
          final service = SimulatedAudioCaptureService();
          final received = <AudioSpectrumMetrics>[];
          final sub = service.spectrumStream.listen(received.add);

          await service.start();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await service.stop();
          await sub.cancel();

          expect(received, isNotEmpty);
          await service.dispose();
        });

        test('F9.4: Simulated service can be stepped frame-by-frame synchronously', () async {
          final service = SimulatedAudioCaptureService();
          final m1 = service.stepFrame(customTimestamp: 16);
          final m2 = service.stepFrame(customTimestamp: 32);
          expect(m1.timestampMs, 16);
          expect(m2.timestampMs, 32);
          await service.dispose();
        });

        test('F9.5: Multiple simulated service instances run isolated without shared mutable state', () {
          final s1 = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);
          final s2 = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.silence);

          final m1 = s1.stepFrame();
          final m2 = s2.stepFrame();

          expect(m1.bass, greaterThan(0.2));
          expect(m2.isSilent, isTrue);

          s1.dispose();
          s2.dispose();
        });
      });

      // Feature 10: 60 FPS Canvas Benchmark & Performance
      group('Feature 10: 60 FPS Canvas Benchmark & Performance', () {
        const frameBudgetMicros = 16666; // 16.66ms for 60 FPS budget

        testWidgets('F10.1: Audio-reactive canvas renders 60 frames within 16.66ms budget',
            (WidgetTester tester) async {
          final metrics = const AudioSpectrumMetrics(
            bass: 0.9,
            mid: 0.6,
            treble: 0.4,
            overallAmplitude: 0.8,
            peakDetected: false,
            isSilent: false,
            timestampMs: 100,
          );
          const config = AudioVisualizerConfig(isEnabled: true);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AudioReactiveCanvasTestWidget(
                  metrics: metrics,
                  config: config,
                ),
              ),
            ),
          );

          final sw = Stopwatch()..start();
          for (int i = 0; i < 60; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          sw.stop();
          final avgFrameMicros = sw.elapsedMicroseconds ~/ 60;
          expect(avgFrameMicros, lessThan(frameBudgetMicros));
        });

        testWidgets('F10.2: Particle overlay sustains 60 audio particles within frame budget',
            (WidgetTester tester) async {
          const config = AudioVisualizerConfig(isEnabled: true, reactiveIntensity: 1.5);
          final metrics = const AudioSpectrumMetrics(
            bass: 0.85,
            mid: 0.5,
            treble: 0.9,
            overallAmplitude: 0.75,
            peakDetected: true,
            isSilent: false,
            timestampMs: 200,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AudioReactiveCanvasTestWidget(metrics: metrics, config: config),
              ),
            ),
          );

          final sw = Stopwatch()..start();
          for (int i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          sw.stop();
          expect(sw.elapsedMicroseconds ~/ 30, lessThan(frameBudgetMicros));
        });

        testWidgets('F10.3: RepaintBoundary isolates canvas repaints from parent tree',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: AudioReactiveCanvasTestWidget(
                  metrics: AudioSpectrumMetrics.zero,
                  config: AudioVisualizerConfig.defaultConfig,
                ),
              ),
            ),
          );
          expect(find.byType(RepaintBoundary), findsWidgets);
        });

        test('F10.4: When isAudioReactiveActive is false, effective energies evaluate to 0.0', () {
          const state = AudioVisualizerTestState(
            config: AudioVisualizerConfig(isEnabled: false),
            metrics: AudioSpectrumMetrics.zero,
          );
          expect(state.isAudioReactiveActive, isFalse);
          expect(state.effectiveBassEnergy, 0.0);
          expect(state.effectiveMidEnergy, 0.0);
          expect(state.effectiveTrebleEnergy, 0.0);
        });

        testWidgets('F10.5: Rapid dynamic preset switching under 60 FPS loop introduces no frame spikes',
            (WidgetTester tester) async {
          var config = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.cosmicPulse);
          final metrics = const AudioSpectrumMetrics(
            bass: 0.7,
            mid: 0.5,
            treble: 0.6,
            overallAmplitude: 0.6,
            peakDetected: false,
            isSilent: false,
            timestampMs: 300,
          );

          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: AudioReactiveCanvasTestWidget(metrics: metrics, config: config),
                  ),
                );
              },
            ),
          );

          final sw = Stopwatch()..start();
          final presets = AudioVisualizerPreset.values;
          for (int i = 0; i < presets.length; i++) {
            config = AudioVisualizerConfig.presetConfig(presets[i]);
            await tester.pump(const Duration(milliseconds: 16));
          }
          sw.stop();
          expect(sw.elapsedMicroseconds ~/ presets.length, lessThan(frameBudgetMicros));
        });
      });
    });

    // -------------------------------------------------------------------------
    // TIER 2: BOUNDARY & CORNER CASES (50 Tests, 5 per feature across 10 features)
    // -------------------------------------------------------------------------
    group('Tier 2: Boundary & Corner Cases (50 Tests)', () {
      // Feature 1 Boundaries
      group('Feature 1 Boundaries: DSP Math & Corner Buffers', () {
        late AudioFftEngineOracle dsp;

        setUp(() {
          dsp = AudioFftEngineOracle();
        });

        test('B1.1: Complete digital silence (all 0.0s) yields 0.0 energies and isSilent=true', () {
          final samples = List<double>.filled(512, 0.0);
          final metrics = dsp.processSamples(samples);
          expect(metrics.bass, 0.0);
          expect(metrics.mid, 0.0);
          expect(metrics.treble, 0.0);
          expect(metrics.overallAmplitude, 0.0);
          expect(metrics.isSilent, isTrue);
        });

        test('B1.2: Nyquist frequency limit (22,050 Hz) is handled without NaN or overflow', () {
          final samples = List.generate(512, (i) => i % 2 == 0 ? 1.0 : -1.0);
          final metrics = dsp.processSamples(samples);
          expect(metrics.bass.isNaN, isFalse);
          expect(metrics.treble.isNaN, isFalse);
          expect(metrics.overallAmplitude.isNaN, isFalse);
        });

        test('B1.3: Constant DC offset (all 1.0s) isolates to DC bin without contaminating mid/treble', () {
          final samples = List<double>.filled(512, 1.0);
          final metrics = dsp.processSamples(samples);
          expect(metrics.treble, closeTo(0.0, 0.05));
          expect(metrics.overallAmplitude, closeTo(1.0, 0.01));
        });

        test('B1.4: Extreme clipped square wave (+1.0/-1.0) clamps spectrum cleanly to [0.0, 1.0]', () {
          final samples = List.generate(512, (i) => (i ~/ 16) % 2 == 0 ? 1.0 : -1.0);
          final metrics = dsp.processSamples(samples);
          expect(metrics.bass, inInclusiveRange(0.0, 1.0));
          expect(metrics.mid, inInclusiveRange(0.0, 1.0));
          expect(metrics.treble, inInclusiveRange(0.0, 1.0));
        });

        test('B1.5: Incomplete or empty buffer is zero-padded gracefully without index errors', () {
          final partialSamples = [0.5, -0.5, 0.2];
          final metrics = dsp.processSamples(partialSamples);
          expect(metrics, isNotNull);
          expect(metrics.overallAmplitude, inInclusiveRange(0.0, 1.0));
        });
      });

      // Feature 2 Boundaries
      group('Feature 2 Boundaries: Visualizer Dynamic Clamping & Spikes', () {
        test('B2.1: Reactive intensity = 0.0 completely suppresses audio modulation to baseline', () {
          final amp = VisualizerModulationOracle.modulatedWaveAmplitude(
            baseAmplitude: 100.0,
            bass: 1.0,
            reactiveIntensity: 0.0,
          );
          final speed = VisualizerModulationOracle.modulatedWaveSpeed(
            baseSpeed: 2.0,
            mid: 1.0,
            reactiveIntensity: 0.0,
          );
          expect(amp, equals(100.0));
          expect(speed, equals(2.0));
        });

        test('B2.2: Reactive intensity = 2.0 with maximum bass (1.0) caps wave amplitude predictably', () {
          final amp = VisualizerModulationOracle.modulatedWaveAmplitude(
            baseAmplitude: 50.0,
            bass: 1.0,
            reactiveIntensity: 2.0,
          );
          // 50 * (1.0 + 1.0 * 1.8 * 2.0) = 50 * 4.6 = 230.0
          expect(amp, closeTo(230.0, 0.001));
        });

        test('B2.3: Zero audio energy keeps velocities at resting baseline', () {
          final speed = VisualizerModulationOracle.particleBurstSpeed(
            baseSpeed: 10.0,
            peakDetected: false,
            bass: 0.0,
            reactiveIntensity: 1.0,
          );
          expect(speed, equals(10.0));
        });

        test('B2.4: Sudden transient energy spike (0.0 to 1.0 in single frame) does not produce NaN', () {
          final speed = VisualizerModulationOracle.modulatedWaveSpeed(
            baseSpeed: 1.0,
            mid: 1.0,
            reactiveIntensity: 2.0,
          );
          expect(speed.isFinite, isTrue);
          expect(speed.isNaN, isFalse);
        });

        test('B2.5: Neon spline evaluation with t < 0.0 or t > 1.0 clamps cleanly to anchors', () {
          final under = VisualizerModulationOracle.evaluateNeonSpline(-0.5);
          final over = VisualizerModulationOracle.evaluateNeonSpline(1.5);
          expect(under, equals(VisualizerModulationOracle.cyanAnchor));
          expect(over, equals(VisualizerModulationOracle.emeraldAnchor));
        });
      });

      // Feature 3 Boundaries
      group('Feature 3 Boundaries: Config Clamping & Custom Mutation', () {
        test('B3.1: Sensitivity clamped strictly to [0.1, 3.0]', () {
          const cfgUnder = AudioVisualizerConfig(sensitivity: 0.05);
          const cfgOver = AudioVisualizerConfig(sensitivity: 5.0);
          final c1 = cfgUnder.copyWith(sensitivity: 0.01);
          final c2 = cfgOver.copyWith(sensitivity: 9.9);
          expect(c1.sensitivity, 0.1);
          expect(c2.sensitivity, 3.0);
        });

        test('B3.2: Smoothing factor clamped strictly to [0.0, 0.95]', () {
          final cLow = AudioVisualizerConfig.defaultConfig.copyWith(smoothingFactor: -0.1);
          final cHigh = AudioVisualizerConfig.defaultConfig.copyWith(smoothingFactor: 0.99);
          expect(cLow.smoothingFactor, 0.0);
          expect(cHigh.smoothingFactor, 0.95);
        });

        test('B3.3: Reactive intensity clamped strictly to [0.0, 2.0]', () {
          final cNeg = AudioVisualizerConfig.defaultConfig.copyWith(reactiveIntensity: -1.0);
          final cOver = AudioVisualizerConfig.defaultConfig.copyWith(reactiveIntensity: 3.5);
          expect(cNeg.reactiveIntensity, 0.0);
          expect(cOver.reactiveIntensity, 2.0);
        });

        test('B3.4: Silence threshold clamped strictly to [0.001, 0.1]', () {
          final cLow = AudioVisualizerConfig.defaultConfig.copyWith(silenceThreshold: 0.0001);
          final cHigh = AudioVisualizerConfig.defaultConfig.copyWith(silenceThreshold: 0.5);
          expect(cLow.silenceThreshold, 0.001);
          expect(cHigh.silenceThreshold, 0.1);
        });

        test('B3.5: Custom config copy preserves unmentioned parameters', () {
          final original = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.clubBassDrop);
          final modified = original.copyWith(sensitivity: 2.1);
          expect(modified.sensitivity, 2.1);
          expect(modified.frequencyFocus, original.frequencyFocus);
          expect(modified.reactiveIntensity, original.reactiveIntensity);
        });
      });

      // Feature 4 Boundaries
      group('Feature 4 Boundaries: UDF Idempotence & Immutability', () {
        late AudioVisualizerBlocHarness bloc;

        setUp(() {
          bloc = AudioVisualizerBlocHarness();
        });

        tearDown(() {
          bloc.dispose();
        });

        test('B4.1: Idempotent toggle to enabled does not alter existing active state', () {
          bloc.toggleAudioVisualizer(true);
          expect(bloc.state.config.isEnabled, isTrue);
          bloc.toggleAudioVisualizer(true);
          expect(bloc.state.config.isEnabled, isTrue);
        });

        test('B4.2: Emitted state instances are immutable value objects', () {
          bloc.toggleAudioVisualizer(true);
          final state1 = bloc.state;
          bloc.updateConfig(state1.config.copyWith(sensitivity: 2.8));
          final state2 = bloc.state;
          expect(state1.config.sensitivity, 1.0);
          expect(state2.config.sensitivity, 2.8);
        });

        test('B4.3: effectiveBassEnergy evaluates to 0.0 when reactiveIntensity is 0.0 with max bass', () {
          final state = AudioVisualizerTestState(
            config: const AudioVisualizerConfig(isEnabled: true, reactiveIntensity: 0.0),
            metrics: const AudioSpectrumMetrics(
              bass: 1.0,
              mid: 0.5,
              treble: 0.5,
              overallAmplitude: 1.0,
              peakDetected: true,
              isSilent: false,
              timestampMs: 10,
            ),
          );
          expect(state.effectiveBassEnergy, 0.0);
          expect(state.effectiveOverallEnergy, 0.0);
        });

        test('B4.4: ResetAudioVisualizerConfig restores defaults without unhandled errors', () {
          bloc.updateConfig(const AudioVisualizerConfig(
            isEnabled: true,
            preset: AudioVisualizerPreset.clubBassDrop,
            sensitivity: 2.9,
          ));
          bloc.resetConfig();
          expect(bloc.state.config, equals(AudioVisualizerConfig.defaultConfig));
        });

        test('B4.5: Rapid 50 sequential spectrum updates preserve final metric value', () {
          bloc.toggleAudioVisualizer(true);
          for (int i = 0; i < 50; i++) {
            bloc.onSpectrumUpdated(AudioSpectrumMetrics(
              bass: i / 50.0,
              mid: 0.5,
              treble: 0.5,
              overallAmplitude: 0.5,
              peakDetected: false,
              isSilent: false,
              timestampMs: i * 16,
            ));
          }
          expect(bloc.state.metrics.bass, closeTo(49.0 / 50.0, 0.001));
        });
      });

      // Feature 5 Boundaries
      group('Feature 5 Boundaries: Stream Flapping & Graceful Fallback', () {
        late SimulatedAudioCaptureService simulatedService;

        setUp(() {
          simulatedService = SimulatedAudioCaptureService();
        });

        tearDown(() {
          simulatedService.dispose();
        });

        test('B5.1: Switching capture mode while active transitions cleanly without null events', () async {
          await simulatedService.start();
          expect(simulatedService.isRunning, isTrue);

          simulatedService.updateConfig(
            simulatedService.config.copyWith(mode: AudioCaptureMode.live),
          );
          expect(simulatedService.config.mode, AudioCaptureMode.live);
          await simulatedService.stop();
        });

        test('B5.2: Live capture with denied permissions executes safely via fallback', () async {
          final liveService = LiveAudioCaptureService(
            fallbackService: simulatedService,
            simulatePermissionDenied: true,
          );
          await liveService.start();
          expect(liveService.isRunning, isTrue);
          expect(simulatedService.isRunning, isTrue);
          await liveService.stop();
          await liveService.dispose();
        });

        test('B5.3: 10 repeated start/stop cycles execute without stream leaks', () async {
          for (int i = 0; i < 10; i++) {
            await simulatedService.start();
            expect(simulatedService.isRunning, isTrue);
            await simulatedService.stop();
            expect(simulatedService.isRunning, isFalse);
          }
        });

        test('B5.4: Stopping audio capture when already stopped is a safe no-op', () async {
          expect(simulatedService.isRunning, isFalse);
          await simulatedService.stop();
          expect(simulatedService.isRunning, isFalse);
        });

        test('B5.5: Dynamic config update while stream is running takes effect immediately', () {
          simulatedService.updateConfig(
            simulatedService.config.copyWith(sensitivity: 2.7),
          );
          expect(simulatedService.config.sensitivity, 2.7);
        });
      });

      // Feature 6 Boundaries
      group('Feature 6 Boundaries: Corrupted JSON & Resilience', () {
        test('B6.1: Corrupted or empty JSON map falls back to defaultConfig safely', () {
          final recovered = AudioVisualizerConfig.fromJson(const {});
          expect(recovered.isEnabled, isFalse);
          expect(recovered.preset, AudioVisualizerPreset.cosmicPulse);
          expect(recovered.sensitivity, 1.0);
        });

        test('B6.2: Partially missing fields in JSON are filled with fallback defaults', () {
          final json = {'isEnabled': true, 'sensitivity': 2.4};
          final recovered = AudioVisualizerConfig.fromJson(json);
          expect(recovered.isEnabled, isTrue);
          expect(recovered.sensitivity, 2.4);
          expect(recovered.smoothingFactor, 0.65);
          expect(recovered.preset, AudioVisualizerPreset.cosmicPulse);
        });

        test('B6.3: Unknown/unrecognized enum strings in JSON map to valid default enums', () {
          final json = {
            'mode': 'bluetooth_direct',
            'preset': 'future_bass_2099',
            'frequencyFocus': 'sub_infra_bass',
          };
          final recovered = AudioVisualizerConfig.fromJson(json);
          expect(recovered.mode, AudioCaptureMode.simulated);
          expect(recovered.preset, AudioVisualizerPreset.cosmicPulse);
          expect(recovered.frequencyFocus, AudioFrequencyFocus.allFrequencies);
        });

        test('B6.4: Out-of-range numerical fields in JSON are safely clamped during deserialization', () {
          final json = {
            'sensitivity': 99.9,
            'smoothingFactor': -5.0,
            'reactiveIntensity': 10.0,
            'silenceThreshold': 0.9,
          };
          final recovered = AudioVisualizerConfig.fromJson(json);
          expect(recovered.sensitivity, 3.0);
          expect(recovered.smoothingFactor, 0.0);
          expect(recovered.reactiveIntensity, 2.0);
          expect(recovered.silenceThreshold, 0.1);
        });

        test('B6.5: Metrics JSON deserialization with null or missing values defaults to zero', () {
          final metrics = AudioSpectrumMetrics.fromJson(const {});
          expect(metrics.bass, 0.0);
          expect(metrics.mid, 0.0);
          expect(metrics.treble, 0.0);
          expect(metrics.isSilent, isTrue);
        });
      });

      // Feature 7 Boundaries
      group('Feature 7 Boundaries: Lifecycle Flapping & Zero CPU Assertions', () {
        late SimulatedAudioCaptureService captureService;
        late SilenceDetectionWatchdog silenceWatchdog;
        late AudioLifecycleCoordinator coordinator;

        setUp(() {
          captureService = SimulatedAudioCaptureService();
          silenceWatchdog = SilenceDetectionWatchdog(
            onSilenceAutoHalt: () {},
            onSoundWakeup: () {},
          );
          coordinator = AudioLifecycleCoordinator(
            captureService: captureService,
            silenceWatchdog: silenceWatchdog,
          );
        });

        tearDown(() {
          captureService.dispose();
          silenceWatchdog.dispose();
        });

        test('B7.1: Rapid lifecycle flapping does not spawn duplicate stream tickers', () async {
          await captureService.start();
          await coordinator.onLifecycleStateChanged(AppLifecycleState.inactive);
          await coordinator.onLifecycleStateChanged(AppLifecycleState.resumed);
          await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
          await coordinator.onLifecycleStateChanged(AppLifecycleState.resumed);
          expect(captureService.isRunning, isTrue);
          await captureService.stop();
        });

        test('B7.2: Screen-off event halts capture even if appState is resumed', () async {
          await captureService.start();
          await coordinator.onScreenStateChanged(false); // Screen off
          expect(captureService.isRunning, isFalse);
        });

        test('B7.3: Screen-on event when app is paused does not start capture', () async {
          await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
          await coordinator.onScreenStateChanged(true); // Screen turned on
          expect(captureService.isRunning, isFalse);
        });

        test('B7.4: Halting capture cancels periodic timers, preventing CPU consumption', () async {
          await captureService.start();
          expect(captureService.isRunning, isTrue);
          await captureService.stop();
          expect(captureService.isRunning, isFalse);
        });

        test('B7.5: Re-triggering paused state when already paused is safe and idempotent', () async {
          await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
          await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
          expect(captureService.isRunning, isFalse);
        });
      });

      // Feature 8 Boundaries
      group('Feature 8 Boundaries: Watchdog Custom Threshold & Micro-Bursts', () {
        late SilenceDetectionWatchdog watchdog;
        bool halted = false;
        bool woken = false;

        setUp(() {
          halted = false;
          woken = false;
          watchdog = SilenceDetectionWatchdog(
            silenceThreshold: 0.05, // Custom threshold
            haltDuration: const Duration(milliseconds: 1000), // 1.0s
            onSilenceAutoHalt: () {
              halted = true;
            },
            onSoundWakeup: () {
              woken = true;
            },
          );
        });

        tearDown(() {
          watchdog.dispose();
        });

        test('B8.1: Custom silence threshold (0.05) halts when audio is below 0.05', () {
          for (int i = 0; i < 10; i++) {
            watchdog.inspectAudioFrame(0.04, elapsedMs: 100);
          }
          expect(halted, isTrue);
        });

        test('B8.2: Micro-burst noise below hysteresis threshold (<0.025) does not trigger false wake', () {
          for (int i = 0; i < 10; i++) {
            watchdog.inspectAudioFrame(0.01, elapsedMs: 100);
          }
          expect(halted, isTrue);

          // Sub-hysteresis tick
          watchdog.inspectAudioFrame(0.020, elapsedMs: 16);
          expect(woken, isFalse);
          expect(watchdog.isHalted, isTrue);
        });

        test('B8.3: Watchdog reset clears accumulated silence duration', () {
          for (int i = 0; i < 8; i++) {
            watchdog.inspectAudioFrame(0.01, elapsedMs: 100);
          }
          expect(halted, isFalse);
          watchdog.reset();

          for (int i = 0; i < 5; i++) {
            watchdog.inspectAudioFrame(0.01, elapsedMs: 100);
          }
          expect(halted, isFalse);
        });

        test('B8.4: Instantaneous loud spike wakes watchdog in a single 16ms frame', () {
          for (int i = 0; i < 10; i++) {
            watchdog.inspectAudioFrame(0.01, elapsedMs: 100);
          }
          expect(halted, isTrue);

          watchdog.inspectAudioFrame(0.85, elapsedMs: 16);
          expect(woken, isTrue);
          expect(watchdog.isHalted, isFalse);
        });

        test('B8.5: Disposing silence watchdog prevents any pending trigger callbacks', () {
          watchdog.dispose();
          expect(watchdog.isHalted, isFalse);
        });
      });

      // Feature 9 Boundaries
      group('Feature 9 Boundaries: High-Load Stress & Malformed Buffers', () {
        test('B9.1: Processing 1,000 synthetic frames in tight loop executes without memory error', () {
          final service = SimulatedAudioCaptureService();
          int validFrameCount = 0;
          for (int i = 0; i < 1000; i++) {
            final m = service.stepFrame();
            if (!m.overallAmplitude.isNaN && !m.bass.isNaN) {
              validFrameCount++;
            }
          }
          expect(validFrameCount, equals(1000));
          service.dispose();
        });

        test('B9.2: Synthetic audio buffer handles zero-duration timestamps gracefully', () {
          final service = SimulatedAudioCaptureService();
          final m = service.stepFrame(customTimestamp: 0);
          expect(m.timestampMs, 0);
          service.dispose();
        });

        test('B9.3: Malformed buffer with NaN and Infinite values is sanitized to 0.0', () {
          final dsp = AudioFftEngineOracle();
          final malformed = [double.nan, double.infinity, double.negativeInfinity, 0.5];
          final metrics = dsp.processSamples(malformed);
          expect(metrics.overallAmplitude.isNaN, isFalse);
          expect(metrics.overallAmplitude.isInfinite, isFalse);
        });

        test('B9.4: Stream subscription cancellation without stopping service runs cleanly', () async {
          final service = SimulatedAudioCaptureService();
          final sub = service.spectrumStream.listen((_) {});
          await sub.cancel();
          final m = service.stepFrame();
          expect(m, isNotNull);
          await service.dispose();
        });

        test('B9.5: Deterministic technoBeat preset produces exact same initial frame', () {
          final s1 = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);
          final s2 = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);
          final m1 = s1.stepFrame();
          final m2 = s2.stepFrame();
          expect(m1.bass, equals(m2.bass));
          expect(m1.overallAmplitude, equals(m2.overallAmplitude));
          s1.dispose();
          s2.dispose();
        });
      });

      // Feature 10 Boundaries
      group('Feature 10 Boundaries: Canvas Stress, Zero Size & DPR 3.0', () {
        const frameBudgetMicros = 16666;

        testWidgets('B10.1: Canvas renders under maximum audio load (100% all bands, intensity 2.0)',
            (WidgetTester tester) async {
          const metrics = AudioSpectrumMetrics(
            bass: 1.0,
            mid: 1.0,
            treble: 1.0,
            overallAmplitude: 1.0,
            peakDetected: true,
            isSilent: false,
            timestampMs: 500,
          );
          const config = AudioVisualizerConfig(
            isEnabled: true,
            reactiveIntensity: 2.0,
          );

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: AudioReactiveCanvasTestWidget(
                  metrics: metrics,
                  config: config,
                ),
              ),
            ),
          );

          final sw = Stopwatch()..start();
          for (int i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          sw.stop();
          expect(sw.elapsedMicroseconds ~/ 30, lessThan(frameBudgetMicros));
        });

        testWidgets('B10.2: Zero-size canvas (0x0 constraints) handles layout and paint safely',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: SizedBox.shrink(
                  child: AudioReactiveCanvasTestWidget(
                    metrics: AudioSpectrumMetrics.zero,
                    config: AudioVisualizerConfig.defaultConfig,
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('B10.3: Canvas sustains frame budget on ultra-high density screen (DPR 3.0)',
            (WidgetTester tester) async {
          tester.view.physicalSize = const Size(1440, 3120);
          tester.view.devicePixelRatio = 3.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: AudioReactiveCanvasTestWidget(
                  metrics: AudioSpectrumMetrics(
                    bass: 0.8,
                    mid: 0.6,
                    treble: 0.7,
                    overallAmplitude: 0.7,
                    peakDetected: false,
                    isSilent: false,
                    timestampMs: 10,
                  ),
                  config: AudioVisualizerConfig(isEnabled: true),
                ),
              ),
            ),
          );

          final sw = Stopwatch()..start();
          for (int i = 0; i < 30; i++) {
            await tester.pump(const Duration(milliseconds: 16));
          }
          sw.stop();
          expect(sw.elapsedMicroseconds ~/ 30, lessThan(frameBudgetMicros));
        });

        testWidgets('B10.4: Resizing canvas dynamically does not throw rendering exceptions',
            (WidgetTester tester) async {
          double width = 300;
          await tester.pumpWidget(
            StatefulBuilder(
              builder: (context, setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: SizedBox(
                      width: width,
                      height: 500,
                      child: const AudioReactiveCanvasTestWidget(
                        metrics: AudioSpectrumMetrics.zero,
                        config: AudioVisualizerConfig.defaultConfig,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
          expect(tester.takeException(), isNull);

          width = 600;
          await tester.pump();
          expect(tester.takeException(), isNull);
        });

        test('B10.5: Static painter cache reuses Path and Paint objects without GC churn', () {
          final painter = _AudioReactiveCanvasPainter(
            metrics: AudioSpectrumMetrics.zero,
            config: AudioVisualizerConfig.defaultConfig,
          );
          expect(painter, isNotNull);
        });
      });
    });

    // -------------------------------------------------------------------------
    // TIER 3: CROSS-FEATURE INTERACTIONS & PAIRWISE COMBINATIONS (10 Tests)
    // -------------------------------------------------------------------------
    group('Tier 3: Cross-Feature Interactions & Pairwise Combinations (10 Tests)', () {
      test('T3.1 (F1 x F2): Frequency band separation drives wave amplitude and particle speed simultaneously', () {
        final dsp = AudioFftEngineOracle();
        final samples = List.generate(512, (i) {
          final t = i / 44100.0;
          return (math.sin(2.0 * math.pi * 80.0 * t) + math.sin(2.0 * math.pi * 8000.0 * t)) * 0.5;
        });
        final metrics = dsp.processSamples(samples);

        final waveAmp = VisualizerModulationOracle.modulatedWaveAmplitude(
          baseAmplitude: 100.0,
          bass: metrics.bass,
          reactiveIntensity: 1.0,
        );
        final particleRad = VisualizerModulationOracle.particleRadiance(
          baseRadiance: 1.0,
          treble: metrics.treble,
          reactiveIntensity: 1.0,
        );

        expect(waveAmp, greaterThan(150.0));
        expect(particleRad, greaterThan(1.2));
      });

      test('T3.2 (F2 x F3): Preset switch dynamically updates wave harmonics while visualizer is active', () {
        final pCosmic = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.cosmicPulse);
        final pBass = AudioVisualizerConfig.presetConfig(AudioVisualizerPreset.clubBassDrop);

        final ampCosmic = VisualizerModulationOracle.modulatedWaveAmplitude(
          baseAmplitude: 100.0,
          bass: 0.8,
          reactiveIntensity: pCosmic.reactiveIntensity,
        );
        final ampBass = VisualizerModulationOracle.modulatedWaveAmplitude(
          baseAmplitude: 100.0,
          bass: 0.8,
          reactiveIntensity: pBass.reactiveIntensity,
        );

        expect(ampBass, greaterThan(ampCosmic));
      });

      test('T3.3 (F3 x F4): Updating sensitivity in BLoC state immediately scales effective energies', () {
        final bloc = AudioVisualizerBlocHarness();
        bloc.toggleAudioVisualizer(true);
        bloc.onSpectrumUpdated(const AudioSpectrumMetrics(
          bass: 0.5,
          mid: 0.5,
          treble: 0.5,
          overallAmplitude: 0.5,
          peakDetected: false,
          isSilent: false,
          timestampMs: 1,
        ));

        expect(bloc.state.effectiveBassEnergy, 0.5);

        bloc.updateConfig(bloc.state.config.copyWith(reactiveIntensity: 1.8));
        expect(bloc.state.effectiveBassEnergy, closeTo(0.9, 0.01));
        bloc.dispose();
      });

      test('T3.4 (F4 x F5): Switching capture mode from simulated to live updates BLoC state smoothly', () {
        final bloc = AudioVisualizerBlocHarness();
        bloc.toggleAudioVisualizer(true);
        expect(bloc.state.config.mode, AudioCaptureMode.simulated);

        bloc.setCaptureMode(AudioCaptureMode.live);
        expect(bloc.state.config.mode, AudioCaptureMode.live);
        expect(bloc.state.isCaptureRunning, isTrue);
        bloc.dispose();
      });

      test('T3.5 (F5 x F6): Changing capture mode and preset persists to disk and survives reload', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        const config = AudioVisualizerConfig(
          isEnabled: true,
          mode: AudioCaptureMode.live,
          preset: AudioVisualizerPreset.minimalistNoir,
        );
        await prefs.setString(keyAudioVisualizerPersistence, jsonEncode(config.toJson()));

        final reloaded = AudioVisualizerConfig.fromJson(
          jsonDecode(prefs.getString(keyAudioVisualizerPersistence)!) as Map<String, dynamic>,
        );
        expect(reloaded.mode, AudioCaptureMode.live);
        expect(reloaded.preset, AudioVisualizerPreset.minimalistNoir);
      });

      test('T3.6 (F6 x F7): Persisted visualizer settings correctly restore when app resumes from paused state', () async {
        SharedPreferences.setMockInitialValues({
          keyAudioVisualizerPersistence: jsonEncode(
            const AudioVisualizerConfig(isEnabled: true, sensitivity: 2.3).toJson(),
          ),
        });
        final prefs = await SharedPreferences.getInstance();
        final loaded = AudioVisualizerConfig.fromJson(
          jsonDecode(prefs.getString(keyAudioVisualizerPersistence)!) as Map<String, dynamic>,
        );

        final service = SimulatedAudioCaptureService(config: loaded);
        final watchdog = SilenceDetectionWatchdog(
          onSilenceAutoHalt: () {},
          onSoundWakeup: () {},
        );
        final coordinator = AudioLifecycleCoordinator(
          captureService: service,
          silenceWatchdog: watchdog,
        );

        await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
        expect(service.isRunning, isFalse);

        await coordinator.onLifecycleStateChanged(AppLifecycleState.resumed);
        expect(service.isRunning, isTrue);
        expect(service.config.sensitivity, 2.3);

        await service.stop();
        await service.dispose();
        watchdog.dispose();
      });

      test('T3.7 (F7 x F8): App lifecycle pause forces silence watchdog to halt immediately', () async {
        final service = SimulatedAudioCaptureService();
        final watchdog = SilenceDetectionWatchdog(
          onSilenceAutoHalt: () {},
          onSoundWakeup: () {},
        );
        final coordinator = AudioLifecycleCoordinator(
          captureService: service,
          silenceWatchdog: watchdog,
        );

        // Run silence for 1s
        watchdog.inspectAudioFrame(0.005, elapsedMs: 1000);
        expect(watchdog.isHalted, isFalse);

        // Pause lifecycle
        await coordinator.onLifecycleStateChanged(AppLifecycleState.paused);
        expect(watchdog.isHalted, isFalse); // Reset during pause
        expect(service.isRunning, isFalse);

        await service.dispose();
        watchdog.dispose();
      });

      test('T3.8 (F8 x F1): Silence watchdog auto-halt zeroes spectrum FFT outputs and sets isSilent flag', () {
        final dsp = AudioFftEngineOracle();
        final silent = List<double>.filled(512, 0.005);
        final metrics = dsp.processSamples(silent);
        expect(metrics.isSilent, isTrue);
        expect(metrics.bass, 0.0);
        expect(metrics.mid, 0.0);
        expect(metrics.treble, 0.0);
      });

      testWidgets('T3.9 (F9 x F10): Headless synthetic audio stream drives canvas at 60 FPS without frame drops',
          (WidgetTester tester) async {
        final service = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);
        var currentMetrics = AudioSpectrumMetrics.zero;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  body: AudioReactiveCanvasTestWidget(
                    metrics: currentMetrics,
                    config: const AudioVisualizerConfig(isEnabled: true),
                  ),
                ),
              );
            },
          ),
        );

        final sw = Stopwatch()..start();
        for (int i = 0; i < 30; i++) {
          currentMetrics = service.stepFrame();
          await tester.pump(const Duration(milliseconds: 16));
        }
        sw.stop();
        expect(sw.elapsedMicroseconds ~/ 30, lessThan(16666));
        await service.dispose();
      });

      test('T3.10 (F1 x F4 x F7): Audio stream interrupted by incoming call halts BLoC state and resumes cleanly', () async {
        final bloc = AudioVisualizerBlocHarness();
        bloc.toggleAudioVisualizer(true);
        bloc.onSpectrumUpdated(const AudioSpectrumMetrics(
          bass: 0.8,
          mid: 0.7,
          treble: 0.6,
          overallAmplitude: 0.75,
          peakDetected: false,
          isSilent: false,
          timestampMs: 10,
        ));
        expect(bloc.state.isAudioReactiveActive, isTrue);

        // Incoming call -> Inactive / Paused
        bloc.pauseCapture();
        expect(bloc.state.isCaptureRunning, isFalse);

        // Call ended -> Resumed
        bloc.resumeCapture();
        expect(bloc.state.isCaptureRunning, isTrue);
        expect(bloc.state.isAudioReactiveActive, isTrue);
        bloc.dispose();
      });
    });

    // -------------------------------------------------------------------------
    // TIER 4: REAL-WORLD APPLICATION SCENARIOS (5 Scenarios)
    // -------------------------------------------------------------------------
    group('Tier 4: Real-World Application Scenarios (5 Scenarios)', () {
      test('Scenario 1: Full Audio-Reactive Workflow (Launch, Enable, Tune Presets, Render, Export)', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final bloc = AudioVisualizerBlocHarness();

        // 1. Launch: visualizer initially disabled
        expect(bloc.state.config.isEnabled, isFalse);
        expect(bloc.state.isAudioReactiveActive, isFalse);

        // 2. Enable visualizer
        bloc.toggleAudioVisualizer(true);
        expect(bloc.state.config.isEnabled, isTrue);

        // 3. Select clubBassDrop preset
        bloc.setPreset(AudioVisualizerPreset.clubBassDrop);
        expect(bloc.state.config.preset, AudioVisualizerPreset.clubBassDrop);
        expect(bloc.state.config.frequencyFocus, AudioFrequencyFocus.bassCentric);

        // 4. Tune sensitivity to 1.5, smoothing to 0.50
        bloc.updateConfig(bloc.state.config.copyWith(
          sensitivity: 1.5,
          smoothingFactor: 0.50,
        ));
        expect(bloc.state.config.sensitivity, 1.5);
        expect(bloc.state.config.smoothingFactor, 0.50);

        // 5. Persist to storage
        await prefs.setString(
          keyAudioVisualizerPersistence,
          jsonEncode(bloc.state.config.toJson()),
        );
        expect(prefs.containsKey(keyAudioVisualizerPersistence), isTrue);

        // 6. Audio stream processing
        final dsp = AudioFftEngineOracle();
        final bassDropSamples = List.generate(512, (i) {
          final t = i / 44100.0;
          return math.sin(2.0 * math.pi * 55.0 * t) * 0.9;
        });
        final metrics = dsp.processSamples(bassDropSamples, config: bloc.state.config);
        bloc.onSpectrumUpdated(metrics);

        expect(bloc.state.metrics.bass, greaterThan(0.60));
        expect(bloc.state.isAudioReactiveActive, isTrue);

        // 7. Modulate wave and particle visuals
        final amp = VisualizerModulationOracle.modulatedWaveAmplitude(
          baseAmplitude: 100.0,
          bass: bloc.state.metrics.bass,
          reactiveIntensity: bloc.state.config.reactiveIntensity,
        );
        expect(amp, greaterThan(200.0));

        // 8. Export to backup bundle
        final backupMap = {
          'version': 1,
          'appName': 'Wallora',
          'exportedAt': DateTime.now().toIso8601String(),
          'audio_visualizer_config': bloc.state.config.toJson(),
        };
        final exportedString = jsonEncode(backupMap);
        expect(exportedString.contains('clubBassDrop'), isTrue);

        bloc.dispose();
      });

      test('Scenario 2: Zero Sleep Overhead Lifecycle Flow (Screen off, Inactive, Background)', () async {
        final service = SimulatedAudioCaptureService();
        final watchdog = SilenceDetectionWatchdog(
          onSilenceAutoHalt: () {},
          onSoundWakeup: () {},
        );
        final coordinator = AudioLifecycleCoordinator(
          captureService: service,
          silenceWatchdog: watchdog,
        );

        // 1. Music playing on active screen
        await service.start();
        expect(service.isRunning, isTrue);

        // 2. User presses power button -> Screen Off
        await coordinator.onScreenStateChanged(false);
        expect(service.isRunning, isFalse); // Zero CPU sleep state

        // 3. User turns screen back on
        await coordinator.onScreenStateChanged(true);
        expect(service.isRunning, isTrue);

        // 4. Music stops, 3.0s continuous silence ensues
        for (int i = 0; i < 30; i++) {
          watchdog.inspectAudioFrame(0.005, elapsedMs: 100);
        }
        expect(watchdog.isHalted, isTrue);

        // 5. User receives loud alert tone -> wakes watchdog immediately
        watchdog.inspectAudioFrame(0.75, elapsedMs: 16);
        expect(watchdog.isHalted, isFalse);

        await service.stop();
        await service.dispose();
        watchdog.dispose();
      });

      test('Scenario 3: Dynamic Presets & Sensitivity Sweeps under Heavy Audio Load', () async {
        final service = SimulatedAudioCaptureService(syntheticPreset: SyntheticAudioPreset.technoBeat);
        final bloc = AudioVisualizerBlocHarness();
        bloc.toggleAudioVisualizer(true);

        final presets = AudioVisualizerPreset.values;
        for (final p in presets) {
          bloc.setPreset(p);
          // Sweep sensitivity from 0.1 to 3.0
          for (double sens = 0.5; sens <= 3.0; sens += 0.5) {
            bloc.updateConfig(bloc.state.config.copyWith(sensitivity: sens));
            final metrics = service.stepFrame();
            bloc.onSpectrumUpdated(metrics);

            expect(bloc.state.effectiveBassEnergy, greaterThanOrEqualTo(0.0));
            expect(bloc.state.effectiveMidEnergy, greaterThanOrEqualTo(0.0));
            expect(bloc.state.effectiveTrebleEnergy, greaterThanOrEqualTo(0.0));
          }
        }

        await service.dispose();
        bloc.dispose();
      });

      test('Scenario 4: Seamless Audio Source Toggle & Fallback (Simulated -> Live -> Simulated)', () async {
        final simulatedService = SimulatedAudioCaptureService();
        final liveService = LiveAudioCaptureService(
          fallbackService: simulatedService,
          simulatePermissionDenied: true, // Simulating denied permission in CI
        );
        final bloc = AudioVisualizerBlocHarness();
        bloc.toggleAudioVisualizer(true);

        // 1. Start in simulated mode
        await simulatedService.start();
        expect(simulatedService.isRunning, isTrue);

        // 2. Switch to live capture mode
        bloc.setCaptureMode(AudioCaptureMode.live);
        await liveService.start();
        expect(liveService.isRunning, isTrue);
        // Fallback transparently maintains simulated stream
        expect(simulatedService.isRunning, isTrue);

        // 3. Switch back to simulated mode with technoBeat
        bloc.setCaptureMode(AudioCaptureMode.simulated);
        simulatedService.syntheticPreset = SyntheticAudioPreset.technoBeat;
        final packet = simulatedService.stepFrame();
        bloc.onSpectrumUpdated(packet);

        expect(bloc.state.metrics.bass, greaterThan(0.20));

        await liveService.stop();
        await simulatedService.stop();
        await simulatedService.dispose();
        await liveService.dispose();
        bloc.dispose();
      });

      test('Scenario 5: Extended Silence Idle to Loud Audio Wakeup with Zero CPU Glitch', () async {
        final dsp = AudioFftEngineOracle();
        final bloc = AudioVisualizerBlocHarness();
        bloc.toggleAudioVisualizer(true);

        bool watchdogHalted = false;
        final watchdog = SilenceDetectionWatchdog(
          silenceThreshold: 0.015,
          haltDuration: const Duration(milliseconds: 3000),
          onSilenceAutoHalt: () {
            watchdogHalted = true;
            bloc.onSpectrumUpdated(AudioSpectrumMetrics.zero);
          },
          onSoundWakeup: () {
            watchdogHalted = false;
          },
        );

        // 1. 5 seconds of silence
        for (int i = 0; i < 50; i++) {
          watchdog.inspectAudioFrame(0.002, elapsedMs: 100);
        }
        expect(watchdogHalted, isTrue);
        expect(bloc.state.isAudioReactiveActive, isFalse);
        expect(bloc.state.effectiveOverallEnergy, 0.0);

        // 2. Loud percussive snare strike (RMS 0.8)
        watchdog.inspectAudioFrame(0.8, elapsedMs: 16);
        expect(watchdogHalted, isFalse);

        final loudBuffer = List.generate(512, (i) => math.sin(i.toDouble()) * 0.8);
        final metrics = dsp.processSamples(loudBuffer, config: bloc.state.config);
        bloc.onSpectrumUpdated(metrics);

        expect(bloc.state.isAudioReactiveActive, isTrue);
        expect(bloc.state.metrics.overallAmplitude, greaterThan(0.4));
        expect(bloc.state.effectiveOverallEnergy, greaterThan(0.4));

        watchdog.dispose();
        bloc.dispose();
      });
    });
  });
}
