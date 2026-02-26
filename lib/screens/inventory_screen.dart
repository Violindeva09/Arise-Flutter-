import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_provider.dart';
import '../models/item.dart';
import '../config/ui_config.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);
    final workoutType = system.stats.preferredWorkoutType;
    final items = system.inventory;

    // Show currently selected item details or fall back to first item
    final selectedItem =
        (_selectedSlot != null && _selectedSlot! < items.length)
            ? items[_selectedSlot!]
            : (items.isNotEmpty ? items.first : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildSpecializationTag(workoutType),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 36, // Standard 6x6 Grid
                  itemBuilder: (context, index) {
                    final item = index < items.length ? items[index] : null;
                    return _buildSlot(index, item);
                  },
                ),
              ),
              if (selectedItem != null) _buildItemDetail(selectedItem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AriseUI.ornament(),
        const SizedBox(width: 12),
        const Text("03 INVENTORY", style: AriseUI.heading),
      ],
    );
  }

  Widget _buildSpecializationTag(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: AriseUI.glassHUD().copyWith(
        border: Border.all(color: AriseUI.primary.withOpacity(0.3)),
        color: AriseUI.primary.withOpacity(0.05),
      ),
      child: Text("SPECIALIZATION: $type",
          style: const TextStyle(
              color: AriseUI.primary,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    );
  }

  Widget _buildSlot(int index, Item? item) {
    bool isSelected = _selectedSlot == index ||
        (_selectedSlot == null && index == 0 && item != null);

    return GestureDetector(
      onTap: () {
        if (item != null) {
          setState(() => _selectedSlot = index);
        }
      },
      child: Container(
        decoration: AriseUI.glassHUD().copyWith(
          color: item == null
              ? Colors.black.withOpacity(0.3)
              : AriseUI.primary.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? AriseUI.primary
                : (item == null
                    ? Colors.white.withOpacity(0.05)
                    : AriseUI.primary.withOpacity(0.2)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AriseUI.primary.withOpacity(0.3), blurRadius: 8)
                ]
              : null,
        ),
        child: item == null
            ? null
            : Center(
                child: Icon(_getItemIcon(item.type),
                    color: AriseUI.primary, size: 20),
              ),
      ),
    );
  }

  Widget _buildItemDetail(Item item) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: AriseUI.glassHUD(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AriseUI.primary.withOpacity(0.5)),
              color: Colors.black,
            ),
            child:
                Icon(_getItemIcon(item.type), color: AriseUI.primary, size: 40),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      color: AriseUI.secondary.withOpacity(0.2),
                      child: Text("RANK ${item.rarity.name}",
                          style: const TextStyle(
                              color: AriseUI.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.description,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        height: 1.5,
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
                Text("USABLE BY: ${item.id.split('_')[0].toUpperCase()}",
                    style: TextStyle(
                        color: AriseUI.primary.withOpacity(0.5),
                        fontSize: 7,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.weapon:
        return Icons.bolt;
      case ItemType.armor:
        return Icons.shield;
      case ItemType.accessory:
        return Icons.fitness_center;
      case ItemType.consumable:
        return Icons.local_pharmacy_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
