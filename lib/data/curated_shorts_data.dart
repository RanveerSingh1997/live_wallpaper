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
    // 1. Anime & Gaming (Flagship: Hajime no Ippo) - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF2E0800), Color(0xFFFF5722), Color(0xFF000000)],
      tags: 'anime ippo makunouchi boxing fighter gaming fight kamogawa punch knockout live',
      alternativeQuotes: [
        'Hard work betrays none. Step into the ring and conquer yourself.',
        'A single punch thrown with all your soul can shatter limitations.',
        'Stand up! The fight is never over until you surrender.',
      ],
    ),

    // 2. Nature & Scenery (Aesthetic Nature Live Wallpaper) - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF002914), Color(0xFF00E676), Color(0xFF05050A)],
      tags: 'nature aurora mountains stars night landscape peaceful calm ocean water live',
      alternativeQuotes: [
        'Adopt the pace of nature: her secret is patience.',
        'The earth has music for those who listen.',
        'In the midst of movement, keep stillness inside you.',
      ],
    ),

    // 3. Cyberpunk & Tech - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF1E002B), Color(0xFFD500F9), Color(0xFF050510)],
      tags: 'cyberpunk tech coding developer neon matrix hacker midnight futuristic live',
      alternativeQuotes: [
        'Never announce moves before they trigger checkmate.',
        'While they sleep, you architect. While they celebrate, you execute.',
        'Genius is relentless focus on what truly matters.',
      ],
    ),

    // 4. Cars & Speed (Supercar / Hypercar aesthetic) - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF2E0007), Color(0xFFFF1744), Color(0xFF050505)],
      tags: 'cars speed supercar hypercar drift highway racing neon asphalt engine turbo live',
      alternativeQuotes: [
        'Drive your ambition harder than your fears.',
        'The road to mastery has no speed limits.',
        'Built for the track, born to conquer the night.',
      ],
    ),

    // 5. Minimal & AMOLED (Dark Aesthetic) - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF100028), Color(0xFF7C4DFF), Color(0xFF000000)],
      tags: 'minimal amoled dark black liquid geometry abstract clean elegance luxury live',
      alternativeQuotes: [
        'Silence is where power accumulates.',
        'Less noise, more signal.',
        'Pure form, uncompromised essence.',
      ],
    ),

    // 6. Fitness & Grind - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF2B2000), Color(0xFFFFC107), Color(0xFF080808)],
      tags: 'fitness gym workout morning grind discipline sweat bodybuilding cardio live',
      alternativeQuotes: [
        'Small daily habits repeated consistently build unbreakable empires.',
        'Suffer the pain of discipline, or suffer the lifelong pain of regret.',
        'Do what must be done, especially when your mind makes excuses.',
      ],
    ),

    // 7. Motivation & Mindset - LIVE
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
      isLive: true,
      resolution: '1080x1920 (FHD 60fps)',
      fileSizeBytes: 2848208,
      durationSeconds: 15,
      gradientColors: [Color(0xFF00282E), Color(0xFF00E5FF), Color(0xFF050B0D)],
      tags: 'motivation stoic philosophy wisdom marcus aurelius strength resilience mind focus live',
      alternativeQuotes: [
        'The obstacle in your path becomes the path forward.',
        'Waste no more time arguing what a good person should be. Be one.',
        'He who fears difficulty will never do anything worthy of greatness.',
      ],
    ),

    // 8. Minimal & AMOLED - STATIC
    MotivationalShort(
      id: 'static_amoled_nebula',
      title: 'Obsidian Nebula & Deep Space',
      quote: 'Look up at the stars and not down at your feet.',
      author: 'Stephen Hawking',
      category: 'Minimal & AMOLED',
      videoAssetPath: 'assets/videos/iron_mind.mp4',
      accentColor: Color(0xFFB388FF),
      mood: 'Deep Space',
      hasTextByDefault: false,
      isLive: false,
      resolution: '2160x3840 (4K UHD)',
      fileSizeBytes: 1420500,
      durationSeconds: 0,
      gradientColors: [Color(0xFF050014), Color(0xFF311B92), Color(0xFF000000)],
      tags: 'static amoled dark space nebula stars cosmic minimal 4k wallpaper',
      alternativeQuotes: [
        'In the infinity of the void, craft your own constellation.',
        'Darkness is the canvas upon which stars shine brightest.',
      ],
    ),

    // 9. Nature & Scenery - STATIC
    MotivationalShort(
      id: 'static_nature_solitude',
      title: 'Alpine Solitude & Misty Ridge',
      quote: 'The mountains are calling and I must go.',
      author: 'John Muir',
      category: 'Nature & Scenery',
      videoAssetPath: 'assets/videos/comeback_spirit.mp4',
      accentColor: Color(0xFF69F0AE),
      mood: 'Tranquil Peak',
      hasTextByDefault: false,
      isLive: false,
      resolution: '2160x3840 (4K UHD)',
      fileSizeBytes: 1840200,
      durationSeconds: 0,
      gradientColors: [Color(0xFF001F12), Color(0xFF004D40), Color(0xFF04130E)],
      tags: 'static nature mountains alpine fog mist evergreen calm peaceful 4k wallpaper',
      alternativeQuotes: [
        'He who climbs highest sees furthest.',
        'Peace is found on the quiet ridges.',
      ],
    ),

    // 10. Cars & Speed - STATIC
    MotivationalShort(
      id: 'static_speed_apex',
      title: 'Apex Velocity: Carbon & Crimson',
      quote: 'To achieve greatness, take risks that make your heartbeat race.',
      author: 'Enzo Ferrari',
      category: 'Cars & Speed',
      videoAssetPath: 'assets/videos/silent_ambition.mp4',
      accentColor: Color(0xFFFF5252),
      mood: 'Pure Adrenaline',
      hasTextByDefault: false,
      isLive: false,
      resolution: '2160x3840 (4K UHD)',
      fileSizeBytes: 1650800,
      durationSeconds: 0,
      gradientColors: [Color(0xFF280003), Color(0xFFB71C1C), Color(0xFF0A0203)],
      tags: 'static cars supercar racing track carbon fiber red speed 4k wallpaper',
      alternativeQuotes: [
        'Speed is a feeling, perfection is an obsession.',
        'Brake late, accelerate earlier.',
      ],
    ),

    // 11. Motivation & Mindset - STATIC
    MotivationalShort(
      id: 'static_stoic_citadel',
      title: 'The Inner Citadel: Granite & Gold',
      quote: 'Very little is needed to make a happy life; it is all within yourself.',
      author: 'Marcus Aurelius',
      category: 'Motivation & Mindset',
      videoAssetPath: 'assets/videos/ippo_motivation.mp4',
      accentColor: Color(0xFFFFD700),
      mood: 'Inner Strength',
      hasTextByDefault: true,
      isLive: false,
      resolution: '2160x3840 (4K UHD)',
      fileSizeBytes: 1320100,
      durationSeconds: 0,
      gradientColors: [Color(0xFF211700), Color(0xFFFF8F00), Color(0xFF0A0802)],
      tags: 'static motivation stoic citadel gold quote typography inspiring 4k wallpaper',
      alternativeQuotes: [
        'Stand firm like a rock against which the waves continually break.',
        'You have power over your thoughts. Master them.',
      ],
    ),
  ];

  static List<String> get categories {
    final Set<String> set = {'All', 'For You', 'Live Wallpapers', 'Static Wallpapers'};
    for (final short in shorts) {
      set.add(short.category);
    }
    return set.toList();
  }
}
