import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_wallpaper/core/core.dart';

void main() {
  group('AppLocalizations Unit Tests', () {
    test('English translations match default copy', () {
      final l10n = AppLocalizations(const Locale('en'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'Make every screen yours.');
      expect(l10n.navFeed, 'Feed');
      expect(l10n.navCategories, 'Categories');
      expect(l10n.navDiscover, 'Discover');
      expect(l10n.actionApply, 'Apply');
      expect(l10n.actionApplyLiveMotion, 'Apply Live Motion');
      expect(l10n.titleQuoteStudio, 'QUOTE STUDIO');
      expect(l10n.itemsCount(1), '1 item');
      expect(l10n.itemsCount(5), '5 items');
      expect(l10n.durationSeconds(10), '10s');
      expect(l10n.appliedSuccess('Neo-Tokyo'), '✨ Applied "Neo-Tokyo" successfully!');
    });

    test('Spanish translations provide localized strings', () {
      final l10n = AppLocalizations(const Locale('es'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'Haz que cada pantalla sea tuya.');
      expect(l10n.navCategories, 'Categorías');
      expect(l10n.navFavorites, 'Favoritos');
      expect(l10n.actionApplyLiveMotion, 'Aplicar Movimiento en Vivo');
      expect(l10n.titleQuoteStudio, 'ESTUDIO DE FRASES');
      expect(l10n.itemsCount(2), '2 elementos');
      expect(l10n.durationSeconds(30), '30s');
    });

    test('Japanese translations provide localized strings', () {
      final l10n = AppLocalizations(const Locale('ja'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'すべての画面を、あなたらしく。');
      expect(l10n.navCategories, 'カテゴリー');
      expect(l10n.navFavorites, 'お気に入り');
      expect(l10n.actionApplyLiveMotion, 'ライブモーションを適用');
      expect(l10n.titleQuoteStudio, '引用スタジオ');
      expect(l10n.itemsCount(3), '3 件');
    });

    test('German translations provide localized strings', () {
      final l10n = AppLocalizations(const Locale('de'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'Mach jeden Bildschirm zu deinem.');
      expect(l10n.navCategories, 'Kategorien');
      expect(l10n.actionApplyLiveMotion, 'Live Motion Anwenden');
      expect(l10n.titleQuoteStudio, 'ZITAT-STUDIO');
      expect(l10n.itemsCount(1), '1 Element');
      expect(l10n.itemsCount(4), '4 Elemente');
    });

    test('French translations provide localized strings', () {
      final l10n = AppLocalizations(const Locale('fr'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'Faites de chaque écran le vôtre.');
      expect(l10n.navCategories, 'Catégories');
      expect(l10n.navFavorites, 'Favoris');
      expect(l10n.actionApplyLiveMotion, 'Appliquer le Mouvement en Direct');
      expect(l10n.titleQuoteStudio, 'STUDIO DE CITATIONS');
      expect(l10n.itemsCount(1), '1 élément');
      expect(l10n.itemsCount(4), '4 éléments');
      expect(l10n.durationSeconds(25), '25s');
    });

    test('Hindi translations provide localized strings', () {
      final l10n = AppLocalizations(const Locale('hi'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'हर स्क्रीन को अपना बनाएं।');
      expect(l10n.navCategories, 'श्रेणियां');
      expect(l10n.navFavorites, 'पसंदीदा');
      expect(l10n.actionApplyLiveMotion, 'लाइव मोशन लागू करें');
      expect(l10n.titleQuoteStudio, 'कोट स्टूडियो');
      expect(l10n.itemsCount(3), '3 आइटम');
      expect(l10n.durationSeconds(15), '15 से.');
    });

    test('Unsupported locale falls back gracefully to English', () {
      final l10n = AppLocalizations(const Locale('it'));

      expect(l10n.appName, 'Wallora');
      expect(l10n.appTagline, 'Make every screen yours.');
      expect(l10n.navFeed, 'Feed');
    });

    test('AppLocalizationsDelegate handles supported and unsupported locales', () async {
      const delegate = AppLocalizationsDelegate();

      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isTrue);
      expect(delegate.isSupported(const Locale('ja')), isTrue);
      expect(delegate.isSupported(const Locale('de')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isTrue);
      expect(delegate.isSupported(const Locale('hi')), isTrue);
      expect(delegate.isSupported(const Locale('it')), isFalse);
      expect(delegate.shouldReload(delegate), isFalse);

      final loaded = await delegate.load(const Locale('es'));
      expect(loaded.navFeed, 'Feed');
      expect(loaded.navFavorites, 'Favoritos');
    });
  });

  group('AppLocalizations Widget Context Tests', () {
    testWidgets('AppLocalizations.of(context) retrieves translations in widget tree',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF000000),
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          pageRouteBuilder: <T>(settings, builder) =>
              PageRouteBuilder<T>(settings: settings, pageBuilder: (ctx, _, _) => builder(ctx)),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Text(l10n.appTagline),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Haz que cada pantalla sea tuya.'), findsOneWidget);
    });
  });
}
