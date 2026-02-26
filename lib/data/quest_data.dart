import '../models/quest.dart';

class QuestData {
  static final List<Quest> dailyQuests = [
    Quest(
      id: "preparations_strength",
      title: "PREPARATIONS FOR STRENGTH",
      description:
          "Push yourself beyond the limits to prepare for the path ahead.",
      reward: Reward(
        exp: 100,
        statBoost: {"strength": 2, "vitality": 1},
      ),
    ),
    Quest(
      id: "agility_training",
      title: "AGILITY TRAINING",
      description:
          "Enhance your reflexes through intense cardio and calisthenics.",
      reward: Reward(
        exp: 100,
        statBoost: {"strength": 1, "agility": 1, "sense": 1},
      ),
    ),
  ];

  static Quest? getQuestById(String id) {
    return dailyQuests.firstWhere((q) => q.id == id,
        orElse: () => dailyQuests.first);
  }
}
