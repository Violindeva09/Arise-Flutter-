import '../models/item.dart';
import '../models/player_stats.dart';

class ResolvedPlayerStats {
  final PlayerStats base;
  final int strength;
  final int agility;
  final int vitality;
  final int sense;
  final int intelligence;
  final int maxHp;
  final int maxMp;

  const ResolvedPlayerStats({
    required this.base,
    required this.strength,
    required this.agility,
    required this.vitality,
    required this.sense,
    required this.intelligence,
    required this.maxHp,
    required this.maxMp,
  });
}

class StatResolver {
  static const List<String> _supportedStats = [
    'strength',
    'agility',
    'vitality',
    'sense',
    'intelligence',
  ];

  static Map<String, int> aggregateEquipmentBonuses(Iterable<Item> items) {
    final totals = {for (final stat in _supportedStats) stat: 0};
    for (final item in items) {
      for (final entry in item.statBoost.entries) {
        if (totals.containsKey(entry.key)) {
          totals[entry.key] = totals[entry.key]! + entry.value;
        }
      }
    }
    return totals;
  }

  static ResolvedPlayerStats resolve({
    required PlayerStats baseStats,
    required Iterable<Item> equippedItems,
    int temporaryStrengthBuff = 0,
    int temporaryAgilityBuff = 0,
    int temporaryVitalityBuff = 0,
    int temporarySenseBuff = 0,
    int temporaryIntelligenceBuff = 0,
  }) {
    final equipmentBonuses = aggregateEquipmentBonuses(equippedItems);

    final strength =
        baseStats.strength + equipmentBonuses['strength']! + temporaryStrengthBuff;
    final agility =
        baseStats.agility + equipmentBonuses['agility']! + temporaryAgilityBuff;
    final vitality =
        baseStats.vitality + equipmentBonuses['vitality']! + temporaryVitalityBuff;
    final sense = baseStats.sense + equipmentBonuses['sense']! + temporarySenseBuff;
    final intelligence = baseStats.intelligence +
        equipmentBonuses['intelligence']! +
        temporaryIntelligenceBuff;

    final maxHp = 100 + (vitality * 10);
    final maxMp = 10 + (intelligence * 5) + (sense * 2);

    return ResolvedPlayerStats(
      base: baseStats,
      strength: strength,
      agility: agility,
      vitality: vitality,
      sense: sense,
      intelligence: intelligence,
      maxHp: maxHp,
      maxMp: maxMp,
    );
  }
}
