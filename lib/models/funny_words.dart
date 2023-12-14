import 'dart:math';

class FunnyWords {
  static List<String> lazyAdjectives = [
    'Drowsy',
    'Sluggo',
    'Snoozy',
    'Lethar',
    'Yawner',
    'Foggy',
    'Weary',
    'Dozy',
    'Dull',
    'Napper',
    'Laggy',
    'Slotho',
    'Blanko',
    'Zonked',
    'Zzzzzz',
    'Hazy',
    'Numby',
    'Drifty',
    'Loafer',
    'Fainto'
  ];

  static List<String> animalNouns = [
    'Cat',
    'Dog',
    'Elephant',
    'Giraffe',
    'Hippo',
    'Kangaroo',
    'Lion',
    'Monkey',
    'Penguin',
    'Raccoon',
    'Tiger',
    'Squirrel',
    'Bear',
    'Panda',
    'Sloth',
    'Koala',
    'Snail',
    'Loris',
    'Dodo',
    'Quokka',
    'Zebra'
  ];
  static String getRandomCombination() {
    final Random random = Random();

    final String randomAdjective =
        lazyAdjectives[random.nextInt(lazyAdjectives.length)];
    final String randomAnimalNoun =
        animalNouns[random.nextInt(animalNouns.length)];

    return '$randomAdjective$randomAnimalNoun';
  }
}
