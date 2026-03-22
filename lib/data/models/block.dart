import 'package:flutter/material.dart';

class BlockRecord {
  const BlockRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.label,
    required this.iconCodePoint,
    required this.colorHex,
  });

  final int id;
  final String name;
  final String description;
  final String label;
  final int iconCodePoint;
  final String colorHex;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => Color(int.decode(colorHex));

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'label': label,
      'icon_code_point': iconCodePoint,
      'color_hex': colorHex,
    };
  }

  factory BlockRecord.fromMap(Map<String, Object?> map) {
    return BlockRecord(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      label: map['label'] as String,
      iconCodePoint: map['icon_code_point'] as int,
      colorHex: map['color_hex'] as String,
    );
  }
}
