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
class AdventurerGear {
  final int id;
  final int adventurerId;
  final bool isEquipped;
  final int quantity;
  final String? customName;
  final String? notes;
  final String baseItemName;
  final double? weight;
  final int? price;
  final String? imageUrl;
  final String itemType;
  final String? bodySlot;

  AdventurerGear({
    required this.id,
    required this.adventurerId,
    required this.isEquipped,
    required this.quantity,
    this.customName,
    this.notes,
    required this.baseItemName,
    this.weight,
    this.price,
    this.imageUrl,
    required this.itemType,
    this.bodySlot,
  });

  factory AdventurerGear.fromJson(Map<String, dynamic> json) {
    return AdventurerGear(
      id: json['id'],
      adventurerId: json['adventurer_id'],
      isEquipped: json['is_equipped'] ?? false,
      quantity: json['quantity'] ?? 1,
      customName: json['custom_name'],
      notes: json['notes'],
      baseItemName: json['base_item_name'],
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      price: json['price'],
      imageUrl: json['image_url'],
      itemType: json['item_type'],
      bodySlot: json['body_slot'],
    );
  }
}