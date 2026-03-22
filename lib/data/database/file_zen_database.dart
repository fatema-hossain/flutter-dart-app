import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/block.dart';
import '../models/day_group.dart';
import '../models/file_item.dart';
import '../models/file_metadata.dart';
import '../models/organizer_rules.dart';
import '../models/report_snapshot.dart';

class FileZenDatabase {
  static const _blocksKey = 'file_zen_blocks';
  static const _dayGroupsKey = 'file_zen_day_groups';
  static const _filesKey = 'file_zen_files';
  static const _rulesKey = 'file_zen_rules';
  static const _reportsKey = 'file_zen_reports';
  static const _seededKey = 'file_zen_seeded';

  Database? _database;
  SharedPreferences? _preferences;

  Future<Database> get _sqlite async {
    if (_database != null) {
      return _database!;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'file_zen.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seedSqlite(db);
      },
    );
    return _database!;
  }

  Future<SharedPreferences> get _prefs async {
    if (_preferences != null) {
      return _preferences!;
    }

    _preferences = await SharedPreferences.getInstance();
    if (!(_preferences!.getBool(_seededKey) ?? false)) {
      await _seedPreferences(_preferences!);
    }
    return _preferences!;
  }

  Future<List<BlockRecord>> fetchBlocks() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _blocksKey);
      return rows.map(BlockRecord.fromMap).toList();
    }

    final db = await _sqlite;
    final rows = await db.query('blocks', orderBy: 'id ASC');
    return rows.map(BlockRecord.fromMap).toList();
  }

  Future<List<DayGroup>> fetchDayGroups() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _dayGroupsKey);
      return rows.map(DayGroup.fromMap).toList();
    }

    final db = await _sqlite;
    final rows = await db.query('day_groups', orderBy: 'id ASC');
    return rows.map(DayGroup.fromMap).toList();
  }

  Future<List<FileItemRecord>> fetchFiles() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _filesKey);
      rows.sort((a, b) => (b['modified_at'] as String).compareTo(a['modified_at'] as String));
      return rows.map(FileItemRecord.fromMap).toList();
    }

    final db = await _sqlite;
    final rows = await db.query('file_items', orderBy: 'modified_at DESC');
    return rows.map(FileItemRecord.fromMap).toList();
  }

  Future<OrganizerRules> fetchRules() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final map = _readObject(prefs, _rulesKey);
      return OrganizerRules.fromMap(map);
    }

    final db = await _sqlite;
    final rows = await db.query('organizer_rules', limit: 1);
    return OrganizerRules.fromMap(rows.first);
  }

  Future<List<ReportSnapshot>> fetchReports() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _reportsKey);
      rows.sort((a, b) => (b['generated_at'] as String).compareTo(a['generated_at'] as String));
      return rows.map(ReportSnapshot.fromMap).toList();
    }

    final db = await _sqlite;
    final rows = await db.query('report_snapshots', orderBy: 'generated_at DESC');
    return rows.map(ReportSnapshot.fromMap).toList();
  }

  Future<void> updateRules(OrganizerRules rules) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      await prefs.setString(_rulesKey, jsonEncode(rules.toMap()));
      return;
    }

    final db = await _sqlite;
    await db.update(
      'organizer_rules',
      rules.toMap(),
      where: 'id = ?',
      whereArgs: [rules.id],
    );
  }

  Future<void> upsertFile(FileItemRecord file) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _filesKey);
      final index = rows.indexWhere((row) => row['id'] == file.id);
      final map = file.toMap();
      if (index >= 0) {
        rows[index] = map;
      } else {
        rows.add(map);
      }
      await prefs.setString(_filesKey, jsonEncode(rows));
      return;
    }

    final db = await _sqlite;
    await db.insert(
      'file_items',
      file.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFile(int id) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _filesKey)..removeWhere((row) => row['id'] == id);
      await prefs.setString(_filesKey, jsonEncode(rows));
      return;
    }

    final db = await _sqlite;
    await db.delete('file_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertReport(ReportSnapshot report) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      final rows = _readList(prefs, _reportsKey);
      final nextId = rows.isEmpty
          ? 1
          : rows
                  .map((row) => row['id'] as int)
                  .reduce((value, element) => value > element ? value : element) +
              1;
      final map = report.toMap()..['id'] = nextId;
      rows.add(map);
      await prefs.setString(_reportsKey, jsonEncode(rows));
      return nextId;
    }

    final db = await _sqlite;
    final map = report.toMap()..remove('id');
    return db.insert('report_snapshots', map);
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE blocks(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        label TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE day_groups(
        id INTEGER PRIMARY KEY,
        block_id INTEGER NOT NULL,
        weekday TEXT NOT NULL,
        session_label TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE file_items(
        id INTEGER PRIMARY KEY,
        block_id INTEGER NOT NULL,
        day_group_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        extension TEXT NOT NULL,
        path TEXT NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        shared_with TEXT NOT NULL,
        note TEXT NOT NULL,
        size_bytes INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        modified_at TEXT NOT NULL,
        owner_id INTEGER NOT NULL,
        owner_name TEXT NOT NULL,
        group_id INTEGER NOT NULL,
        group_name TEXT NOT NULL,
        selinux_label TEXT NOT NULL,
        numeric_permissions TEXT NOT NULL,
        rwx_permissions TEXT NOT NULL,
        block_size INTEGER NOT NULL,
        total_blocks INTEGER NOT NULL,
        inode_number INTEGER NOT NULL,
        hard_links INTEGER NOT NULL,
        is_immutable INTEGER NOT NULL,
        is_signed INTEGER NOT NULL,
        is_hidden INTEGER NOT NULL,
        is_journaled INTEGER NOT NULL,
        is_critical_path INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE organizer_rules(
        id INTEGER PRIMARY KEY,
        visual_assets_enabled INTEGER NOT NULL,
        documents_enabled INTEGER NOT NULL,
        source_code_enabled INTEGER NOT NULL,
        archives_enabled INTEGER NOT NULL,
        inactivity_days REAL NOT NULL,
        append_timestamps INTEGER NOT NULL,
        default_strategy TEXT NOT NULL,
        created_from TEXT NOT NULL,
        created_to TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE report_snapshots(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        generated_at TEXT NOT NULL,
        total_files INTEGER NOT NULL,
        total_size_bytes INTEGER NOT NULL,
        total_blocks INTEGER NOT NULL,
        archived_files INTEGER NOT NULL,
        duplicate_conflicts INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedSqlite(Database db) async {
    final seed = _buildSeedData();

    for (final block in seed.blocks) {
      await db.insert('blocks', block.toMap());
    }

    for (final group in seed.dayGroups) {
      await db.insert('day_groups', group.toMap());
    }

    for (final file in seed.files) {
      await db.insert('file_items', file.toMap());
    }

    await db.insert('organizer_rules', seed.rules.toMap());
    await db.insert('report_snapshots', seed.report.toMap());
  }

  Future<void> _seedPreferences(SharedPreferences prefs) async {
    final seed = _buildSeedData();

    await prefs.setString(
      _blocksKey,
      jsonEncode(seed.blocks.map((item) => item.toMap()).toList()),
    );
    await prefs.setString(
      _dayGroupsKey,
      jsonEncode(seed.dayGroups.map((item) => item.toMap()).toList()),
    );
    await prefs.setString(
      _filesKey,
      jsonEncode(seed.files.map((item) => item.toMap()).toList()),
    );
    await prefs.setString(_rulesKey, jsonEncode(seed.rules.toMap()));
    await prefs.setString(_reportsKey, jsonEncode([seed.report.toMap()]));
    await prefs.setBool(_seededKey, true);
  }

  List<Map<String, Object?>> _readList(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return <Map<String, Object?>>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Map<String, Object?>.from(item as Map))
        .toList();
  }

  Map<String, Object?> _readObject(SharedPreferences prefs, String key) {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return <String, Object?>{};
    }
    return Map<String, Object?>.from(jsonDecode(raw) as Map);
  }

  _SeedData _buildSeedData() {
    const blocks = <BlockRecord>[
      BlockRecord(
        id: 1,
        name: 'Primary Archive',
        description: 'Core files for the active semester project and shared team work.',
        label: 'ACTIVE BLOCK',
        iconCodePoint: Icons.auto_awesome_outlined.codePoint,
        colorHex: '0xFFAEC6FF',
      ),
      BlockRecord(
        id: 2,
        name: 'Cloud Assets',
        description: 'Design exports and synced references collected from shared storage.',
        label: 'SYNCED BLOCK',
        iconCodePoint: Icons.cloud_done_outlined.codePoint,
        colorHex: '0xFFE4DFFF',
      ),
      BlockRecord(
        id: 3,
        name: 'Reports Vault',
        description: 'Generated summaries, weekly reports, and archived snapshots.',
        label: 'REPORTING BLOCK',
        iconCodePoint: Icons.insert_chart_outlined.codePoint,
        colorHex: '0xFF8FA0AA',
      ),
    ];

    const dayGroups = <DayGroup>[
      DayGroup(id: 1, blockId: 1, weekday: 'Friday', sessionLabel: 'Morning Session - 09:00'),
      DayGroup(id: 2, blockId: 1, weekday: 'Thursday', sessionLabel: 'Afternoon Session - 14:30'),
      DayGroup(id: 3, blockId: 1, weekday: 'Wednesday', sessionLabel: 'Review Session - 19:00'),
      DayGroup(id: 4, blockId: 2, weekday: 'Friday', sessionLabel: 'Asset Sync - 10:15'),
      DayGroup(id: 5, blockId: 2, weekday: 'Tuesday', sessionLabel: 'Illustration Review - 16:00'),
      DayGroup(id: 6, blockId: 3, weekday: 'Monday', sessionLabel: 'Weekly Summary - 08:00'),
    ];

    final now = DateTime.now();
    final files = <FileItemRecord>[
      FileItemRecord(
        id: 1,
        blockId: 1,
        dayGroupId: 1,
        name: 'Campaign_Brief_V2.pdf',
        extension: '.pdf',
        path: '/Primary Archive/Friday/Campaign_Brief_V2.pdf',
        category: 'Documents',
        status: 'Review',
        sharedWith: 'Shared with 3 people',
        note: 'Needs final approval from supervisor.',
        sizeBytes: 4200000,
        createdAt: now.subtract(const Duration(days: 8)),
        modifiedAt: now.subtract(const Duration(hours: 2)),
        metadata: const FileMetadataRecord(
          ownerId: 1000,
          ownerName: 'teamlead',
          groupId: 1000,
          groupName: 'project',
          seLinuxLabel: 'u:object_r:docs_file:s0',
          numericPermissions: '0644',
          rwxPermissions: '-rw-r--r--',
          blockSize: 4096,
          totalBlocks: 1025,
          inodeNumber: 284556122,
          hardLinks: 1,
          isImmutable: false,
          isSigned: true,
          isHidden: false,
          isJournaled: true,
          isCriticalPath: true,
        ),
      ),
      FileItemRecord(
        id: 2,
        blockId: 1,
        dayGroupId: 1,
        name: 'Hero_Visual_Concept.png',
        extension: '.png',
        path: '/Primary Archive/Friday/Hero_Visual_Concept.png',
        category: 'Visual Assets',
        status: 'Asset',
        sharedWith: 'Private',
        note: 'Draft hero artwork for mobile preview.',
        sizeBytes: 12800000,
        createdAt: now.subtract(const Duration(days: 5)),
        modifiedAt: now.subtract(const Duration(hours: 4)),
        metadata: const FileMetadataRecord(
          ownerId: 1002,
          ownerName: 'designer',
          groupId: 1000,
          groupName: 'project',
          seLinuxLabel: 'u:object_r:media_file:s0',
          numericPermissions: '0644',
          rwxPermissions: '-rw-r--r--',
          blockSize: 4096,
          totalBlocks: 3125,
          inodeNumber: 284556123,
          hardLinks: 1,
          isImmutable: false,
          isSigned: false,
          isHidden: false,
          isJournaled: true,
          isCriticalPath: false,
        ),
      ),
      FileItemRecord(
        id: 3,
        blockId: 1,
        dayGroupId: 2,
        name: 'Budget_Projections_Final.xlsx',
        extension: '.xlsx',
        path: '/Primary Archive/Thursday/Budget_Projections_Final.xlsx',
        category: 'Documents',
        status: 'Priority',
        sharedWith: 'Auto-sync enabled',
        note: 'Contains the cost baseline used in the last meeting.',
        sizeBytes: 1100000,
        createdAt: now.subtract(const Duration(days: 4)),
        modifiedAt: now.subtract(const Duration(minutes: 15)),
        metadata: const FileMetadataRecord(
          ownerId: 1001,
          ownerName: 'analyst',
          groupId: 1000,
          groupName: 'project',
          seLinuxLabel: 'u:object_r:spreadsheet_file:s0',
          numericPermissions: '0664',
          rwxPermissions: '-rw-rw-r--',
          blockSize: 4096,
          totalBlocks: 269,
          inodeNumber: 284556124,
          hardLinks: 1,
          isImmutable: false,
          isSigned: true,
          isHidden: false,
          isJournaled: true,
          isCriticalPath: true,
        ),
      ),
      FileItemRecord(
        id: 4,
        blockId: 2,
        dayGroupId: 4,
        name: 'Landing_Animation.svg',
        extension: '.svg',
        path: '/Cloud Assets/Friday/Landing_Animation.svg',
        category: 'Visual Assets',
        status: 'Synced',
        sharedWith: 'Shared with 2 people',
        note: 'Pulled from Figma export batch.',
        sizeBytes: 530000,
        createdAt: now.subtract(const Duration(days: 2)),
        modifiedAt: now.subtract(const Duration(hours: 5)),
        metadata: const FileMetadataRecord(
          ownerId: 1002,
          ownerName: 'designer',
          groupId: 1010,
          groupName: 'assets',
          seLinuxLabel: 'u:object_r:vector_file:s0',
          numericPermissions: '0644',
          rwxPermissions: '-rw-r--r--',
          blockSize: 4096,
          totalBlocks: 130,
          inodeNumber: 284556125,
          hardLinks: 1,
          isImmutable: false,
          isSigned: true,
          isHidden: false,
          isJournaled: false,
          isCriticalPath: false,
        ),
      ),
      FileItemRecord(
        id: 5,
        blockId: 2,
        dayGroupId: 5,
        name: 'ui_flow_mapper.dart',
        extension: '.dart',
        path: '/Cloud Assets/Tuesday/ui_flow_mapper.dart',
        category: 'Source Code',
        status: 'Source',
        sharedWith: 'Shared with dev team',
        note: 'Prototype widget mapper used for demo builds.',
        sizeBytes: 84000,
        createdAt: now.subtract(const Duration(days: 7)),
        modifiedAt: now.subtract(const Duration(days: 1, hours: 3)),
        metadata: const FileMetadataRecord(
          ownerId: 1003,
          ownerName: 'developer',
          groupId: 1000,
          groupName: 'project',
          seLinuxLabel: 'u:object_r:source_file:s0',
          numericPermissions: '0754',
          rwxPermissions: '-rwxr-xr--',
          blockSize: 4096,
          totalBlocks: 21,
          inodeNumber: 284556126,
          hardLinks: 1,
          isImmutable: false,
          isSigned: false,
          isHidden: false,
          isJournaled: true,
          isCriticalPath: false,
        ),
      ),
      FileItemRecord(
        id: 6,
        blockId: 3,
        dayGroupId: 6,
        name: 'weekly_report_2026_03_22.txt',
        extension: '.txt',
        path: '/Reports Vault/Monday/weekly_report_2026_03_22.txt',
        category: 'Archives',
        status: 'Archived',
        sharedWith: 'Faculty ready',
        note: 'Generated weekly report snapshot.',
        sizeBytes: 18000,
        createdAt: now.subtract(const Duration(days: 1)),
        modifiedAt: now.subtract(const Duration(days: 1)),
        metadata: const FileMetadataRecord(
          ownerId: 1000,
          ownerName: 'teamlead',
          groupId: 1004,
          groupName: 'reports',
          seLinuxLabel: 'u:object_r:report_file:s0',
          numericPermissions: '0640',
          rwxPermissions: '-rw-r-----',
          blockSize: 4096,
          totalBlocks: 5,
          inodeNumber: 284556127,
          hardLinks: 1,
          isImmutable: true,
          isSigned: true,
          isHidden: false,
          isJournaled: true,
          isCriticalPath: false,
        ),
      ),
    ];

    final rules = const OrganizerRules(
      id: 1,
      visualAssetsEnabled: true,
      documentsEnabled: true,
      sourceCodeEnabled: true,
      archivesEnabled: true,
      inactivityDays: 90,
      appendTimestamps: true,
      defaultStrategy: 'Create unique version (v2, v3...)',
      createdFrom: 'Jan 01, 2024',
      createdTo: 'Present',
    );

    final report = ReportSnapshot(
      id: 1,
      generatedAt: now.subtract(const Duration(days: 1)),
      totalFiles: files.length,
      totalSizeBytes: files.fold<int>(0, (sum, file) => sum + file.sizeBytes),
      totalBlocks: blocks.length,
      archivedFiles: files.where((file) => file.status == 'Archived').length,
      duplicateConflicts: 1,
    );

    return _SeedData(
      blocks: blocks,
      dayGroups: dayGroups,
      files: files,
      rules: rules,
      report: report,
    );
  }
}

class _SeedData {
  const _SeedData({
    required this.blocks,
    required this.dayGroups,
    required this.files,
    required this.rules,
    required this.report,
  });

  final List<BlockRecord> blocks;
  final List<DayGroup> dayGroups;
  final List<FileItemRecord> files;
  final OrganizerRules rules;
  final ReportSnapshot report;
}
