import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/models/motivational_short.dart';

void main() {
  group('MotivationalShort Model Tests', () {
    const testShort = MotivationalShort(
      id: 'test_short_1',
      title: 'Neon Odyssey',
      quote: 'Dare to explore the unknown.',
      author: 'Voyager',
      category: 'Cyberpunk & Tech',
      videoAssetPath: 'assets/videos/test.mp4',
      accentColor: Color(0xFF00E5FF),
      tags: 'cyber, neon, future',
      trueBlackPercentage: 85,
      fileSizeBytes: 3145728, // 3.0 MB
      gradientColors: [Color(0xFF00E5FF), Colors.black],
    );

    test('props and equality work as expected', () {
      const copy = MotivationalShort(
        id: 'test_short_1',
        title: 'Neon Odyssey',
        quote: 'Dare to explore the unknown.',
        author: 'Voyager',
        category: 'Cyberpunk & Tech',
        videoAssetPath: 'assets/videos/test.mp4',
        accentColor: Color(0xFF00E5FF),
        tags: 'cyber, neon, future',
        trueBlackPercentage: 85,
        fileSizeBytes: 3145728,
        gradientColors: [Color(0xFF00E5FF), Colors.black],
      );

      expect(testShort, equals(copy));
      expect(testShort.hashCode, equals(copy.hashCode));
    });

    test('isAmoledCertified returns true when trueBlackPercentage >= 75 or category is Minimal & AMOLED', () {
      expect(testShort.isAmoledCertified, isTrue);

      final nonAmoled = testShort.copyWith(trueBlackPercentage: 40, category: 'Nature');
      expect(nonAmoled.isAmoledCertified, isFalse);

      final minimalCategory = testShort.copyWith(trueBlackPercentage: 30, category: 'Minimal & AMOLED');
      expect(minimalCategory.isAmoledCertified, isTrue);
    });

    test('fileSizeFormatted formats bytes into KB and MB properly', () {
      const kbShort = MotivationalShort(
        id: 'kb_item',
        title: 'Small',
        quote: 'Small item',
        author: 'Author',
        category: 'Nature',
        videoAssetPath: 'path',
        accentColor: Colors.white,
        tags: '',
        fileSizeBytes: 512000, // 500 KB
      );
      expect(kbShort.fileSizeFormatted, '500.0 KB');
      expect(testShort.fileSizeFormatted, '3.0 MB');
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      final json = testShort.toJson();
      expect(json['id'], 'test_short_1');
      expect(json['title'], 'Neon Odyssey');
      expect(json['trueBlackPercentage'], 85);
      expect(json['accentColor'], const Color(0xFF00E5FF).toARGB32());

      final deserialized = MotivationalShort.fromJson(json);
      expect(deserialized.id, testShort.id);
      expect(deserialized.title, testShort.title);
      expect(deserialized.accentColor.toARGB32(), testShort.accentColor.toARGB32());
      expect(deserialized.trueBlackPercentage, testShort.trueBlackPercentage);
      expect(deserialized.isAmoledCertified, isTrue);
    });

    test('copyWith modifies targeted fields while preserving others', () {
      final modified = testShort.copyWith(
        title: 'Updated Title',
        trueBlackPercentage: 92,
      );

      expect(modified.id, testShort.id);
      expect(modified.title, 'Updated Title');
      expect(modified.trueBlackPercentage, 92);
      expect(modified.quote, testShort.quote);
      expect(modified.category, testShort.category);
    });
  });
}
