class ReportSnapshot {
  const ReportSnapshot({
    required this.id,
    required this.generatedAt,
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.totalBlocks,
    required this.archivedFiles,
    required this.duplicateConflicts,
  });

  final int id;
  final DateTime generatedAt;
  final int totalFiles;
  final int totalSizeBytes;
  final int totalBlocks;
  final int archivedFiles;
  final int duplicateConflicts;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'generated_at': generatedAt.toIso8601String(),
      'total_files': totalFiles,
      'total_size_bytes': totalSizeBytes,
      'total_blocks': totalBlocks,
      'archived_files': archivedFiles,
      'duplicate_conflicts': duplicateConflicts,
    };
  }

  factory ReportSnapshot.fromMap(Map<String, Object?> map) {
    return ReportSnapshot(
      id: map['id'] as int,
      generatedAt: DateTime.parse(map['generated_at'] as String),
      totalFiles: map['total_files'] as int,
      totalSizeBytes: map['total_size_bytes'] as int,
      totalBlocks: map['total_blocks'] as int,
      archivedFiles: map['archived_files'] as int,
      duplicateConflicts: map['duplicate_conflicts'] as int,
    );
  }
}
