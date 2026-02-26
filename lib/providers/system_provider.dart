import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import '../models/item.dart';
import '../models/skill.dart';
import '../data/penalty_data.dart';
import '../data/inventory_data.dart';
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

  // Getters
  PlayerStats get stats => _stats;
  String get playerName => _playerName;
  String get email => _email;
  List<Item> get inventory => _inventory;
  bool get isPenaltyActive => _isPenaltyActive;
  Penalty? get currentPenalty =>
      _isPenaltyActive ? PenaltyData.getCurrentPenalty() : null;

  // Architect's Formulas - Delegated to logic layer
  int get maxHp => GameLogic.getMaxHp(_stats.vitality);
  int get maxMp => GameLogic.getMaxMp(_stats.intelligence, _stats.sense);
  double get expProgress => GameLogic.getExpProgress(_stats.exp, _stats.level);

  // History Tracking
  final List<Map<String, dynamic>> _questHistory = [];
  List<Map<String, dynamic>> get questHistory => _questHistory;

  Future<void> init(String name, String email) async {
    _playerName = name;
    _email = email;
    final savedStats = await PersistenceService.loadPlayerStats(name);
    if (savedStats != null) {
      _stats = savedStats;
    }
    _updateInventory();
    notifyListeners();
  }

  void _updateInventory() {
    _inventory = InventoryData.getItemsForType(_stats.preferredWorkoutType);
  }

  void setWorkoutType(String type) {
    _stats = _stats.copyWith(preferredWorkoutType: type);
    _updateInventory();
    _saveAndNotify();
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

  void _checkSkillUnlocks(PlayerStats oldStats) {
    // In a real app, we'd compare which skills changed from locked to unlocked
    // and trigger an event/notification.
    // This is a placeholder for the Event Trigger.
  }

  void activatePenalty() {
    _isPenaltyActive = true;
    notifyListeners();
  }

  void resolvePenalty() {
    _isPenaltyActive = false;
    // Penalties grant a level up but reset EXP
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
    PersistenceService.savePlayerStats(_playerName, _stats);
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
