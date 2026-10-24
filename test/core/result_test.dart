import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';

void main() {
  group('Result Pattern Unit Tests', () {
    test('Success outcome properties and when extraction', () {
      const Result<int> result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.errorMessageOrNull, isNull);

      final extracted = result.when(
        success: (data) => 'Value is $data',
        failure: (msg, _, _) => 'Error: $msg',
      );
      expect(extracted, 'Value is 42');

      final mapped = result.map((data) => data * 2);
      expect(mapped.dataOrNull, 84);
    });

    test('Failure outcome properties and error propagation', () {
      final Result<int> result = Failure('Database connection timed out.',
          error: Exception('SocketException'));

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorMessageOrNull, 'Database connection timed out.');

      final extracted = result.when(
        success: (data) => 'Value is $data',
        failure: (msg, error, _) => 'Failed: $msg (type: ${error.runtimeType})',
      );
      expect(extracted, contains('Failed: Database connection timed out.'));

      final mapped = result.map((data) => data * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.errorMessageOrNull, 'Database connection timed out.');
    });
  });
}
