import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Cross-platform utility that safely encapsulates platform queries.
///
/// Prevents runtime crashes on Flutter Web where accessing `Platform.is*`
/// throws `Unsupported operation: Platform._operatingSystem`.
abstract final class AppPlatform {
  /// Whether the application is running in a Web browser.
  static bool get isWeb => kIsWeb;

  /// Whether the operating system is Android (and not Web).
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Whether the operating system is iOS (and not Web).
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Whether the operating system is macOS (and not Web).
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Whether the operating system is Windows (and not Web).
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Whether the operating system is Linux (and not Web).
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Whether the operating system is Fuchsia (and not Web).
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
}
