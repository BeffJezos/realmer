enum Avatar {
  archimago('Archimago', 'assets/ascii/archimago_ascii.png'),
  avatarOfAir('Avatar of Air', 'assets/ascii/avatar_of_air_ascii.png'),
  avatarOfEarth('Avatar of Earth', 'assets/ascii/avatar_of_earth_ascii.png'),
  avatarOfFire('Avatar of Fire', 'assets/ascii/avatar_of_fire_ascii.png'),
  avatarOfWater('Avatar of Water', 'assets/ascii/avatar_of_water_ascii.png'),
  battlemage('Battlemage', 'assets/ascii/battlemage_ascii.png'),
  deathspeaker('Deathspeaker', 'assets/ascii/deathspeaker_ascii.png'),
  dragonlord('Dragonlord', 'assets/ascii/dragonlord_ascii.png'),
  druid('Druid', 'assets/ascii/druid_ascii.png'),
  elementalist('Elementalist', 'assets/ascii/elementalist_ascii.png'),
  enchantress('Enchantress', 'assets/ascii/enchantress_ascii.png'),
  flamecaller('Flamecaller', 'assets/ascii/flamecaller_ascii.png'),
  geomancer('Geomancer', 'assets/ascii/geomancer_ascii.png'),
  pathfinder('Pathfinder', 'assets/ascii/pathfinder_ascii.png'),
  seer('Seer', 'assets/ascii/seer_ascii.png'),
  sorcerer('Sorcerer', 'assets/ascii/sorcerer_ascii.png'),
  sparkmage('Sparkmage', 'assets/ascii/sparkmage_ascii.png'),
  spellslinger('Spellslinger', 'assets/ascii/spellslinger_ascii.png'),
  templar('Templar', 'assets/ascii/templar_ascii.png'),
  waveshaper('Waveshaper', 'assets/ascii/waveshaper_ascii.png'),
  witch('Witch', 'assets/ascii/witch_ascii.png');

  const Avatar(this.displayName, this.assetPath);

  final String displayName;
  final String assetPath;
}
