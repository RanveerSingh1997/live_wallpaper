import 'package:flutter/material.dart';
import '../models/motivational_short.dart';

class CuratedShortsData {
  static const List<MotivationalShort> shorts = [
    MotivationalShort(
      id: 'ippo_hard_work',
      title: 'Hajime no Ippo: Makunouchi Creed',
      quote: 'Not everyone who works hard is rewarded, but everyone who succeeds has worked hard.',
      author: 'Coach Kamogawa to Ippo Makunouchi',
      category: 'Fighter Spirit',
      videoAssetPath: 'assets/videos/ippo_motivation.mp4',
      accentColor: Color(0xFFFF5722),
      tags: 'hippo maiko ippo makunouchi boxing hard work anime fighter coach kamogawa discipline',
      alternativeQuotes: [
        'Hard work betrays none. Step into the ring and conquer yourself.',
        'A single punch thrown with all your soul can shatter limitations.',
        'Stand up! The fight is never over until you surrender.',
      ],
    ),
    MotivationalShort(
      id: 'discipline_grind',
      title: 'Discipline Over Motivation',
      quote: 'Motivation gets you started. Discipline keeps you alive.',
      author: '05:00 AM Protocol',
      category: 'Discipline',
      videoAssetPath: 'assets/videos/discipline_grind.mp4',
      accentColor: Color(0xFFFFC107),
      tags: 'discipline motivation morning habits grind workout consistency focus',
      alternativeQuotes: [
        'Small daily habits repeated consistently build unbreakable empires.',
        'Suffer the pain of discipline, or suffer the lifelong pain of regret.',
        'Do what must be done, especially when your mind makes excuses.',
      ],
    ),
    MotivationalShort(
      id: 'iron_mind',
      title: 'The Stoic Forge',
      quote: 'You have power over your mind, not outside events. Realize this, and find strength.',
      author: 'Marcus Aurelius',
      category: 'Stoic Wisdom',
      videoAssetPath: 'assets/videos/iron_mind.mp4',
      accentColor: Color(0xFF00E5FF),
      tags: 'stoic marcus aurelius philosophy power mind calm focus meditation strength',
      alternativeQuotes: [
        'The obstacle in your path becomes the path forward.',
        'Waste no more time arguing what a good person should be. Be one.',
        'He who fears difficulty will never do anything worthy of greatness.',
      ],
    ),
    MotivationalShort(
      id: 'silent_ambition',
      title: 'Silent Ambition',
      quote: 'Work in absolute silence. Let your unstoppable execution make the thunder.',
      author: 'Night Protocol',
      category: 'Deep Grind',
      videoAssetPath: 'assets/videos/silent_ambition.mp4',
      accentColor: Color(0xFFD500F9),
      tags: 'coding build startup hacker developer night hustle focus stealth',
      alternativeQuotes: [
        'Never announce moves before they trigger checkmate.',
        'While they sleep, you architect. While they celebrate, you execute.',
        'Genius is relentless focus on what truly matters.',
      ],
    ),
    MotivationalShort(
      id: 'comeback_spirit',
      title: 'Never Stay Down',
      quote: 'It is not about how hard you hit. It is about how hard you can get hit and keep moving forward.',
      author: 'Championship Mindset',
      category: 'Resilience',
      videoAssetPath: 'assets/videos/comeback_spirit.mp4',
      accentColor: Color(0xFFFF1744),
      tags: 'boxing rocky fight comeback resilience never give up grit heart warrior',
      alternativeQuotes: [
        'Every true champion was once a contender who refused to stay down.',
        'Fall seven times. Rise eight times with fire in your eyes.',
        'Scars are simply undeniable proof that you survived the war.',
      ],
    ),
  ];

  static List<String> get categories {
    final Set<String> unique = {'All'};
    for (final short in shorts) {
      unique.add(short.category);
    }
    return unique.toList();
  }
}
