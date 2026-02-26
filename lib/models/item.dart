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
      type: _safeItemType(json['type']),
      rarity: _safeItemRarity(json['rarity']),
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

ItemType _safeItemType(dynamic raw) {
  final value = raw?.toString() ?? '';
  for (final type in ItemType.values) {
    if (type.name == value) return type;
  }
  return ItemType.material;
}

ItemRarity _safeItemRarity(dynamic raw) {
  final value = raw?.toString() ?? '';
  for (final rarity in ItemRarity.values) {
    if (rarity.name == value) return rarity;
  }
  return ItemRarity.D;
}
