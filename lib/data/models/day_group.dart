class DayGroup {
  const DayGroup({
    required this.id,
    required this.blockId,
    required this.weekday,
    required this.sessionLabel,
  });

  final int id;
  final int blockId;
  final String weekday;
  final String sessionLabel;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'block_id': blockId,
      'weekday': weekday,
      'session_label': sessionLabel,
    };
  }

  factory DayGroup.fromMap(Map<String, Object?> map) {
    return DayGroup(
      id: map['id'] as int,
      blockId: map['block_id'] as int,
      weekday: map['weekday'] as String,
      sessionLabel: map['session_label'] as String,
    );
  }
}
