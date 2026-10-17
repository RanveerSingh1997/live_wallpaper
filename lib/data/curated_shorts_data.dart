import 'package:flutter/material.dart';
import '../models/motivational_short.dart';

class CuratedShortsData {
  static const List<String> availablePreferences = [
    'Anime & Gaming',
    'Nature & Scenery',
    'Cyberpunk & Tech',
    'Cars & Speed',
    'Minimal & AMOLED',
    'Motivation & Mindset',
    'Fitness & Grind',
  ];

  static const List<MotivationalShort> shorts = [
    // 1. Anime & Gaming (Flagship: Hajime no Ippo)
    MotivationalShort(
      id: 'ippo_hard_work',
      title: 'Hajime no Ippo: Makunouchi Creed',
      quote: 'Not everyone who works hard is rewarded, but everyone who succeeds has worked hard.',
      author: 'Coach Kamogawa to Ippo Makunouchi',
      category: 'Anime & Gaming',
      videoAssetPath: 'assets/videos/ippo_motivation.mp4',
      accentColor: Color(0xFFFF5722),
      mood: 'Fighter Spirit',
      hasTextByDefault: true,
      tags: 'anime ippo makunouchi boxing fighter gaming fight kamogawa punch knockout',
      alternativeQuotes: [
        'Hard work betrays none. Step into the ring and conquer yourself.',
        'A single punch thrown with all your soul can shatter limitations.',
        'Stand up! The fight is never over until you surrender.',
      ],
    ),

    // 2. Nature & Scenery (Aesthetic Nature Live Wallpaper)
    MotivationalShort(
      id: 'nature_aurora',
      title: 'Cosmic Aurora & Mountain Peak',
      quote: 'Nature does not hurry, yet everything is accomplished.',
      author: 'Lao Tzu',
      category: 'Nature & Scenery',
      videoAssetPath: 'assets/videos/iron_mind.mp4',
      accentColor: Color(0xFF00E676),
      mood: 'Serenity & Calm',
      hasTextByDefault: false,
      tags: 'nature aurora mountains stars night landscape peaceful calm ocean water',
      alternativeQuotes: [
        'Adopt the pace of nature: her secret is patience.',
        'The earth has music for those who listen.',
        'In the midst of movement, keep stillness inside you.',
      ],
    ),

    // 3. Cyberpunk & Tech
    MotivationalShort(
      id: 'silent_ambition',
      title: 'Silent Ambition: Neon Rain',
      quote: 'Work in absolute silence. Let your unstoppable execution make the thunder.',
      author: 'Night Protocol',
      category: 'Cyberpunk & Tech',
      videoAssetPath: 'assets/videos/silent_ambition.mp4',
      accentColor: Color(0xFFD500F9),
      mood: 'Deep Focus',
      hasTextByDefault: true,
      tags: 'cyberpunk tech coding developer neon matrix hacker midnight futuristic',
      alternativeQuotes: [
        'Never announce moves before they trigger checkmate.',
        'While they sleep, you architect. While they celebrate, you execute.',
        'Genius is relentless focus on what truly matters.',
      ],
    ),

    // 4. Cars & Speed (Supercar / Hypercar aesthetic)
    MotivationalShort(
      id: 'supercar_night',
      title: 'Midnight Highway & Twin Turbo',
      quote: 'Speed is nothing without direction.',
      author: 'Apex Velocity',
      category: 'Cars & Speed',
      videoAssetPath: 'assets/videos/comeback_spirit.mp4',
      accentColor: Color(0xFFFF1744),
      mood: 'Adrenaline',
      hasTextByDefault: false,
      tags: 'cars speed supercar hypercar drift highway racing neon asphalt engine turbo',
      alternativeQuotes: [
        'Drive your ambition harder than your fears.',
        'The road to mastery has no speed limits.',
        'Built for the track, born to conquer the night.',
      ],
    ),

    // 5. Minimal & AMOLED (Dark Aesthetic)
    MotivationalShort(
      id: 'minimal_amoled',
      title: 'Obsidian Void & Liquid Motion',
      quote: 'Simplicity is the ultimate sophistication.',
      author: 'Leonardo da Vinci',
      category: 'Minimal & AMOLED',
      videoAssetPath: 'assets/videos/iron_mind.mp4',
      accentColor: Color(0xFF7C4DFF),
      mood: 'Minimalist',
      hasTextByDefault: false,
      tags: 'minimal amoled dark black liquid geometry abstract clean elegance luxury',
      alternativeQuotes: [
        'Silence is where power accumulates.',
        'Less noise, more signal.',
        'Pure form, uncompromised essence.',
      ],
    ),

    // 6. Fitness & Grind
    MotivationalShort(
      id: 'discipline_grind',
      title: '05:00 AM Protocol: Iron Discipline',
      quote: 'Motivation gets you started. Discipline keeps you alive.',
      author: 'Iron Mindset',
      category: 'Fitness & Grind',
      videoAssetPath: 'assets/videos/discipline_grind.mp4',
      accentColor: Color(0xFFFFC107),
      mood: 'Relentless Grind',
      hasTextByDefault: true,
      tags: 'fitness gym workout morning grind discipline sweat bodybuilding cardio',
      alternativeQuotes: [
        'Small daily habits repeated consistently build unbreakable empires.',
        'Suffer the pain of discipline, or suffer the lifelong pain of regret.',
        'Do what must be done, especially when your mind makes excuses.',
      ],
    ),

    // 7. Motivation & Mindset
    MotivationalShort(
      id: 'stoic_wisdom',
      title: 'The Stoic Fortress',
      quote: 'You have power over your mind, not outside events. Realize this, and find strength.',
      author: 'Marcus Aurelius',
      category: 'Motivation & Mindset',
      videoAssetPath: 'assets/videos/discipline_grind.mp4',
      accentColor: Color(0xFF00E5FF),
      mood: 'Stoic Wisdom',
      hasTextByDefault: true,
      tags: 'motivation stoic philosophy wisdom marcus aurelius strength resilience mind focus',
      alternativeQuotes: [
        'The obstacle in your path becomes the path forward.',
        'Waste no more time arguing what a good person should be. Be one.',
        'He who fears difficulty will never do anything worthy of greatness.',
      ],
    ),
  ];

  static List<String> get categories {
    final List<String> list = ['For You', 'All'];
    for (final pref in availablePreferences) {
      if (!list.contains(pref)) {
        list.add(pref);
      }
    }
    return list;
  }
}
