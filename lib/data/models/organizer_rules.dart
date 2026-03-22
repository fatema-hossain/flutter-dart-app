class OrganizerRules {
  const OrganizerRules({
    required this.id,
    required this.visualAssetsEnabled,
    required this.documentsEnabled,
    required this.sourceCodeEnabled,
    required this.archivesEnabled,
    required this.inactivityDays,
    required this.appendTimestamps,
    required this.defaultStrategy,
    required this.createdFrom,
    required this.createdTo,
  });

  final int id;
  final bool visualAssetsEnabled;
  final bool documentsEnabled;
  final bool sourceCodeEnabled;
  final bool archivesEnabled;
  final double inactivityDays;
  final bool appendTimestamps;
  final String defaultStrategy;
  final String createdFrom;
  final String createdTo;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'visual_assets_enabled': visualAssetsEnabled ? 1 : 0,
      'documents_enabled': documentsEnabled ? 1 : 0,
      'source_code_enabled': sourceCodeEnabled ? 1 : 0,
      'archives_enabled': archivesEnabled ? 1 : 0,
      'inactivity_days': inactivityDays,
      'append_timestamps': appendTimestamps ? 1 : 0,
      'default_strategy': defaultStrategy,
      'created_from': createdFrom,
      'created_to': createdTo,
    };
  }

  factory OrganizerRules.fromMap(Map<String, Object?> map) {
    return OrganizerRules(
      id: map['id'] as int,
      visualAssetsEnabled: (map['visual_assets_enabled'] as int) == 1,
      documentsEnabled: (map['documents_enabled'] as int) == 1,
      sourceCodeEnabled: (map['source_code_enabled'] as int) == 1,
      archivesEnabled: (map['archives_enabled'] as int) == 1,
      inactivityDays: (map['inactivity_days'] as num).toDouble(),
      appendTimestamps: (map['append_timestamps'] as int) == 1,
      defaultStrategy: map['default_strategy'] as String,
      createdFrom: map['created_from'] as String,
      createdTo: map['created_to'] as String,
    );
  }

  OrganizerRules copyWith({
    bool? visualAssetsEnabled,
    bool? documentsEnabled,
    bool? sourceCodeEnabled,
    bool? archivesEnabled,
    double? inactivityDays,
    bool? appendTimestamps,
    String? defaultStrategy,
    String? createdFrom,
    String? createdTo,
  }) {
    return OrganizerRules(
      id: id,
      visualAssetsEnabled: visualAssetsEnabled ?? this.visualAssetsEnabled,
      documentsEnabled: documentsEnabled ?? this.documentsEnabled,
      sourceCodeEnabled: sourceCodeEnabled ?? this.sourceCodeEnabled,
      archivesEnabled: archivesEnabled ?? this.archivesEnabled,
      inactivityDays: inactivityDays ?? this.inactivityDays,
      appendTimestamps: appendTimestamps ?? this.appendTimestamps,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      createdFrom: createdFrom ?? this.createdFrom,
      createdTo: createdTo ?? this.createdTo,
    );
  }
}
