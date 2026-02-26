enum ItemRarity { D, C, B, A, S }

enum ItemType { weapon, armor, accessory, consumable, material }

class Item {
  final String id; // Changed to String for better ID management
  final String name;
  final ItemType type;
  final ItemRarity rarity;
  final String description;
  final Map<String, int> statBoost;

  const Item({
    required this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.description,
    this.statBoost = const {},
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      type: ItemType.values.byName(json['type']),
      rarity: ItemRarity.values.byName(json['rarity']),
      description: json['description'] ?? json['desc'] ?? "",
      statBoost: Map<String, int>.from(json['statBoost'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'rarity': rarity.name,
      'description': description,
      'statBoost': statBoost,
    };
  }
}
