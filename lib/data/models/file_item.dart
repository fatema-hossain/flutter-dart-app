import 'package:flutter/material.dart';

import 'file_metadata.dart';

class FileItemRecord {
  const FileItemRecord({
    required this.id,
    required this.blockId,
    required this.dayGroupId,
    required this.name,
    required this.extension,
    required this.path,
    required this.category,
    required this.status,
    required this.sharedWith,
    required this.note,
    required this.sizeBytes,
    required this.createdAt,
    required this.modifiedAt,
    required this.metadata,
  });

  final int id;
  final int blockId;
  final int dayGroupId;
  final String name;
  final String extension;
  final String path;
  final String category;
  final String status;
  final String sharedWith;
  final String note;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final FileMetadataRecord metadata;

  IconData get icon {
    switch (extension.toLowerCase()) {
      case '.pdf':
      case '.docx':
      case '.txt':
        return Icons.description;
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.svg':
        return Icons.image;
      case '.xlsx':
      case '.csv':
        return Icons.table_chart;
      case '.zip':
      case '.rar':
      case '.7z':
        return Icons.inventory_2;
      case '.dart':
      case '.js':
      case '.py':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color get accentColor {
    switch (category) {
      case 'Visual Assets':
        return const Color(0xFFE4DFFF);
      case 'Source Code':
        return const Color(0xFFAEC6FF);
      case 'Archives':
        return Colors.white;
      default:
        return const Color(0xFF8FA0AA);
    }
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'block_id': blockId,
      'day_group_id': dayGroupId,
      'name': name,
      'extension': extension,
      'path': path,
      'category': category,
      'status': status,
      'shared_with': sharedWith,
      'note': note,
      'size_bytes': sizeBytes,
      'created_at': createdAt.toIso8601String(),
      'modified_at': modifiedAt.toIso8601String(),
      'owner_id': metadata.ownerId,
      'owner_name': metadata.ownerName,
      'group_id': metadata.groupId,
      'group_name': metadata.groupName,
      'selinux_label': metadata.seLinuxLabel,
      'numeric_permissions': metadata.numericPermissions,
      'rwx_permissions': metadata.rwxPermissions,
      'block_size': metadata.blockSize,
      'total_blocks': metadata.totalBlocks,
      'inode_number': metadata.inodeNumber,
      'hard_links': metadata.hardLinks,
      'is_immutable': metadata.isImmutable ? 1 : 0,
      'is_signed': metadata.isSigned ? 1 : 0,
      'is_hidden': metadata.isHidden ? 1 : 0,
      'is_journaled': metadata.isJournaled ? 1 : 0,
      'is_critical_path': metadata.isCriticalPath ? 1 : 0,
    };
  }

  factory FileItemRecord.fromMap(Map<String, Object?> map) {
    return FileItemRecord(
      id: map['id'] as int,
      blockId: map['block_id'] as int,
      dayGroupId: map['day_group_id'] as int,
      name: map['name'] as String,
      extension: map['extension'] as String,
      path: map['path'] as String,
      category: map['category'] as String,
      status: map['status'] as String,
      sharedWith: map['shared_with'] as String,
      note: map['note'] as String,
      sizeBytes: map['size_bytes'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      modifiedAt: DateTime.parse(map['modified_at'] as String),
      metadata: FileMetadataRecord(
        ownerId: map['owner_id'] as int,
        ownerName: map['owner_name'] as String,
        groupId: map['group_id'] as int,
        groupName: map['group_name'] as String,
        seLinuxLabel: map['selinux_label'] as String,
        numericPermissions: map['numeric_permissions'] as String,
        rwxPermissions: map['rwx_permissions'] as String,
        blockSize: map['block_size'] as int,
        totalBlocks: map['total_blocks'] as int,
        inodeNumber: map['inode_number'] as int,
        hardLinks: map['hard_links'] as int,
        isImmutable: (map['is_immutable'] as int) == 1,
        isSigned: (map['is_signed'] as int) == 1,
        isHidden: (map['is_hidden'] as int) == 1,
        isJournaled: (map['is_journaled'] as int) == 1,
        isCriticalPath: (map['is_critical_path'] as int) == 1,
      ),
    );
  }

  FileItemRecord copyWith({
    int? id,
    int? blockId,
    int? dayGroupId,
    String? name,
    String? extension,
    String? path,
    String? category,
    String? status,
    String? sharedWith,
    String? note,
    int? sizeBytes,
    DateTime? createdAt,
    DateTime? modifiedAt,
    FileMetadataRecord? metadata,
  }) {
    return FileItemRecord(
      id: id ?? this.id,
      blockId: blockId ?? this.blockId,
      dayGroupId: dayGroupId ?? this.dayGroupId,
      name: name ?? this.name,
      extension: extension ?? this.extension,
      path: path ?? this.path,
      category: category ?? this.category,
      status: status ?? this.status,
      sharedWith: sharedWith ?? this.sharedWith,
      note: note ?? this.note,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
