/*
3.5e Database Companion
Copyright (C) 2026 Daniel Bender

-----------------------------------------------------------------------
AI DISCLOSURE: 
This file was developed with the assistance of Gemini Code Assist. 
AI-generated logic and boilerplate have been reviewed, refined, and 
verified by the human author for accuracy and project integration.
-----------------------------------------------------------------------

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
*/
sealed class Item {
  final int id;
  final String name;
  final String itemType;
  final int? price;
  final double? weight;
  final String? bookName;
  final String? bodySlot;
  final String? description;
  final String? imageUrl;
  final int? baseItemId;
  final int? page;
  final int? enhancementBonus;
  final List<int>? enchantmentIds;

  const Item({
    required this.id,
    required this.name,
    required this.itemType,
    this.price,
    this.weight,
    this.bookName,
    this.bodySlot,
    this.description,
    this.imageUrl,
    this.baseItemId,
    this.page,
    this.enhancementBonus,
    this.enchantmentIds,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json['item_type'] as String? ?? 'gear';
    switch (type.toLowerCase()) {
      case 'weapon':
        return WeaponItem.fromJson(json);
      case 'armor':
        return ArmorItem.fromJson(json);
      case 'consumable':
        return ConsumableItem.fromJson(json);
      case 'wondrous':
        return WondrousItem.fromJson(json);
      case 'ring':
        return RingItem.fromJson(json);
      case 'rod':
        return RodItem.fromJson(json);
      case 'staff':
        return StaffItem.fromJson(json);
      case 'wand':
        return WandItem.fromJson(json);
      case 'potion':
        return PotionItem.fromJson(json);
      case 'scroll':
        return ScrollItem.fromJson(json);
      case 'gear':
      default:
        return GearItem.fromJson(json);
    }
  }
}

class WeaponItem extends Item {
  final String? damage;
  final int? criticalRange;
  final int? criticalMultiplier;
  final int? range;
  final String? handedness;
  final String? weaponType;
  final String? weaponCategory;

  const WeaponItem({
    required super.id,
    required super.name,
    required super.itemType,
    super.price,
    super.weight,
    super.bookName,
    super.bodySlot,
    super.description,
    super.imageUrl,
    super.baseItemId,
    super.page,
    super.enhancementBonus,
    super.enchantmentIds,
    this.damage,
    this.criticalRange,
    this.criticalMultiplier,
    this.range,
    this.handedness,
    this.weaponType,
    this.weaponCategory,
  });

  factory WeaponItem.fromJson(Map<String, dynamic> json) {
    return WeaponItem(
      id: json['id'],
      name: json['name'],
      itemType: json['item_type'],
      price: json['price'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      bookName: json['book_name'],
      bodySlot: json['body_slot'],
      description: json['description'],
      imageUrl: json['image_url'],
      baseItemId: json['base_item_id'],
      page: json['page'],
      enhancementBonus: json['enhancement_bonus'],
      enchantmentIds: (json['enchantment_ids'] as List?)?.cast<int>(),
      damage: json['damage'],
      criticalRange: json['crit_range'],
      criticalMultiplier: json['crit_damage'],
      range: json['range'],
      handedness: json['handedness'],
      weaponType: json['weapon_type'],
      weaponCategory: json['weapon_category'],
    );
  }
}

class ArmorItem extends Item {
  final int? acBonus;
  final int? maxDexBonus;
  final int? armorCheckPenalty;
  final int? speedThirty;
  final int? speedTwenty;
  final String? armorCategory;
  final int? arcaneSpellFailure;

  const ArmorItem({
    required super.id,
    required super.name,
    required super.itemType,
    super.price,
    super.weight,
    super.bookName,
    super.bodySlot,
    super.description,
    super.imageUrl,
    super.baseItemId,
    super.page,
    super.enhancementBonus,
    super.enchantmentIds,
    this.acBonus,
    this.maxDexBonus,
    this.armorCheckPenalty,
    this.speedThirty,
    this.speedTwenty,
    this.armorCategory,
    this.arcaneSpellFailure,
  });

  factory ArmorItem.fromJson(Map<String, dynamic> json) {
    return ArmorItem(
      id: json['id'],
      name: json['name'],
      itemType: json['item_type'],
      price: json['price'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      bookName: json['book_name'],
      bodySlot: json['body_slot'],
      description: json['description'],
      imageUrl: json['image_url'],
      baseItemId: json['base_item_id'],
      page: json['page'],
      enhancementBonus: json['enhancement_bonus'],
      enchantmentIds: (json['enchantment_ids'] as List?)?.cast<int>(),
      acBonus: json['ac_bonus'],
      maxDexBonus: json['max_dex_bonus'],
      armorCheckPenalty: json['armor_check_penalty'],
      speedThirty: json['speed_thirty'],
      speedTwenty: json['speed_twenty'],
      armorCategory: json['armor_category'],
      arcaneSpellFailure: json['arcane_spell_failure'],
    );
  }
}

class ConsumableItem extends Item {
  const ConsumableItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory ConsumableItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, ConsumableItem.new);
}

class WondrousItem extends Item {
  const WondrousItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory WondrousItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, WondrousItem.new);
}

class RingItem extends Item {
  const RingItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory RingItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, RingItem.new);
}

class RodItem extends Item {
  const RodItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory RodItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, RodItem.new);
}

class StaffItem extends Item {
  const StaffItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory StaffItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, StaffItem.new);
}

class WandItem extends Item {
  const WandItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory WandItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, WandItem.new);
}

class PotionItem extends Item {
  const PotionItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory PotionItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, PotionItem.new);
}

class ScrollItem extends Item {
  const ScrollItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory ScrollItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, ScrollItem.new);
}

class GearItem extends Item {
  const GearItem({required super.id, required super.name, required super.itemType, super.price, super.weight, super.bookName, super.bodySlot, super.description, super.imageUrl, super.baseItemId, super.page, super.enhancementBonus, super.enchantmentIds});
  factory GearItem.fromJson(Map<String, dynamic> json) => _genericFromJson(json, GearItem.new);
}

T _genericFromJson<T extends Item>(
  Map<String, dynamic> json,
  T Function({
    required int id,
    required String name,
    required String itemType,
    int? price,
    double? weight,
    String? bookName,
    String? bodySlot,
    String? description,
    String? imageUrl,
    int? baseItemId,
    int? page,
    int? enhancementBonus,
    List<int>? enchantmentIds,
  }) constructor,
) {
  return constructor(
    id: json['id'],
    name: json['name'],
    itemType: json['item_type'],
    price: json['price'],
    weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    bookName: json['book_name'],
    bodySlot: json['body_slot'],
    description: json['description'],
    imageUrl: json['image_url'],
    baseItemId: json['base_item_id'],
    page: json['page'],
    enhancementBonus: json['enhancement_bonus'],
    enchantmentIds: (json['enchantment_ids'] as List?)?.cast<int>(),
  );
}