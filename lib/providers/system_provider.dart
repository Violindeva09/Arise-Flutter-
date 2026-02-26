import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import '../models/item.dart';
import '../models/skill.dart';
import '../models/equipment_slot.dart';
import '../data/penalty_data.dart';
import '../data/inventory_data.dart';
import '../services/equipment_service.dart';
import '../services/game_logic.dart';
import '../services/persistence_service.dart';

class SystemProvider with ChangeNotifier {
  PlayerStats _stats = PlayerStats(
    level: 1,
    rank: "E",
    exp: 0,
    strength: 5,
    agility: 5,
    sense: 5,
    vitality: 5,
    intelligence: 5,
    statPoints: 0,
  );

  String _playerName = "Hunter";
  String _email = "";
  bool _isPenaltyActive = false;
  List<Item> _inventory = [];

  PlayerStats get stats => _stats;
  PlayerStats get computedStats => EquipmentService.applyAllBonuses(_stats, _inventory);
  String get playerName => _playerName;
  String get email => _email;
  List<Item> get inventory => _inventory;
  bool get isPenaltyActive => _isPenaltyActive;

  Item? get equippedWeapon => _equippedFor(EquipmentSlot.weapon);
  Item? get equippedArmor => _equippedFor(EquipmentSlot.armor);
  Item? get equippedAccessory => _equippedFor(EquipmentSlot.accessory);

  Penalty? get currentPenalty =>
      _isPenaltyActive ? PenaltyData.getCurrentPenalty() : null;


  Item? _equippedFor(EquipmentSlot slot) {
    for (final item in _inventory) {
      if (item.slot == slot && item.isEquipped) return item;
    }
    return null;
  }


  int get maxHp => GameLogic.getMaxHp(computedStats.vitality);
  int get maxMp => GameLogic.getMaxMp(computedStats.intelligence, computedStats.sense);
  double get expProgress => GameLogic.getExpProgress(_stats.exp, _stats.level);

  final List<Map<String, dynamic>> _questHistory = [];
  List<Map<String, dynamic>> get questHistory => _questHistory;

  Future<void> init(String name, String email) async {
    _playerName = name;
    _email = email;
    final savedState = await PersistenceService.loadPlayerState(name);
    if (savedState != null) {
      _stats = savedState.stats;
    }
    _updateInventory();
    if (savedState != null) {
      _restoreEquippedItems(savedState.equippedItemIds);
    }
    notifyListeners();
  }

  void _restoreEquippedItems(List<String> equippedItemIds) {
    for (final id in equippedItemIds) {
      final matches = _inventory.where((item) => item.id == id);
      if (matches.isEmpty) continue;
      EquipmentService.toggleEquip(matches.first, _inventory);
      matches.first.isEquipped = true;
    }
  }

  void _updateInventory() {
    _inventory = InventoryData.getItemsForType(_stats.preferredWorkoutType);
  }

  void setWorkoutType(String type) {
    _stats = _stats.copyWith(preferredWorkoutType: type);
    _updateInventory();
    _saveAndNotify();
  }

  bool equipOrUnequip(Item item) {
    final changed = EquipmentService.toggleEquip(item, _inventory);
    if (changed) _saveAndNotify();
    return changed;
  }

  void awakenPlayer() {
    _stats = _stats.copyWith(isPlayerAwakened: true);
    _saveAndNotify();
  }

  void setHunterClass(String newClass) {
    _stats = _stats.copyWith(hunterClass: newClass);
    _saveAndNotify();
  }

  void addRewards(Map<String, int> gains, {String? questName}) {
    final oldStats = _stats;
    _stats = GameLogic.addQuestRewards(_stats, gains);

    if (questName != null) {
      _addToHistory(
        questName: questName,
        status: "COMPLETED",
        xp: gains["exp"] ?? 0,
      );
    }

    _checkClassPromotion();
    _checkSkillUnlocks(oldStats);
    _saveAndNotify();
  }

  void _checkClassPromotion() {
    if (_stats.level >= GameLogic.CLASS_CHANGE_LEVEL &&
        _stats.hunterClass == "NONE") {
      String eligibleClass = GameLogic.determineEligibleClass(_stats);
      setHunterClass(eligibleClass);
    }
  }

  void _checkSkillUnlocks(PlayerStats oldStats) {}

  void activatePenalty() {
    _isPenaltyActive = true;
    notifyListeners();
  }

  void resolvePenalty() {
    _isPenaltyActive = false;
    _stats = GameLogic.calculateLevelUp(_stats.copyWith(
      exp: GameLogic.getExpRequired(_stats.level),
    )).copyWith(exp: 0);

    _addToHistory(
      questName: "PENALTY ESCAPED",
      status: "COMPLETED",
      xp: "SECRET LEVEL UP",
    );

    _saveAndNotify();
  }

  void _saveAndNotify() {
    PersistenceService.savePlayerState(
      _playerName,
      stats: _stats,
      equippedItemIds: _inventory.where((item) => item.isEquipped).map((item) => item.id).toList(),
    );
    notifyListeners();
  }

  void _addToHistory(
      {required String questName,
      required String status,
      required dynamic xp}) {
    final entry = {
      'date': DateTime.now().toString().split(' ')[0],
      'quest': questName,
      'status': status,
      'xp': xp is int ? (xp > 0 ? "+$xp" : xp.toString()) : xp.toString(),
    };
    _questHistory.insert(0, entry);
    if (_questHistory.length > 50) _questHistory.removeLast();
  }

  void assignStatPoint(String stat) {
    if (_stats.statPoints > 0) {
      _stats = _stats.copyWith(
        strength: stat == 'strength' ? _stats.strength + 1 : _stats.strength,
        agility: stat == 'agility' ? _stats.agility + 1 : _stats.agility,
        vitality: stat == 'vitality' ? _stats.vitality + 1 : _stats.vitality,
        sense: stat == 'sense' ? _stats.sense + 1 : _stats.sense,
        intelligence: stat == 'intelligence'
            ? _stats.intelligence + 1
            : _stats.intelligence,
        statPoints: _stats.statPoints - 1,
      );
      _saveAndNotify();
    }
  }

  bool isSkillUnlocked(Skill skill) {
    return GameLogic.isSkillUnlocked(_stats, skill);
  }
}
