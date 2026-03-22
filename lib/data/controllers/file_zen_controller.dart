import 'dart:math';

import 'package:flutter/material.dart';

import '../database/file_zen_database.dart';
import '../models/block.dart';
import '../models/day_group.dart';
import '../models/file_item.dart';
import '../models/file_metadata.dart';
import '../models/organizer_rules.dart';
import '../models/report_snapshot.dart';

class FileZenController extends ChangeNotifier {
  FileZenController(this._database);

  final FileZenDatabase _database;

  bool _isLoading = true;
  String? _error;
  List<BlockRecord> _blocks = const [];
  List<DayGroup> _dayGroups = const [];
  List<FileItemRecord> _files = const [];
  List<ReportSnapshot> _reports = const [];
  OrganizerRules? _rules;
  int? _selectedBlockId;
  String? _selectedWeekday;
  String _explorerQuery = '';
  int? _selectedExplorerBlockId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BlockRecord> get blocks => _blocks;
  List<DayGroup> get dayGroups => _dayGroups;
  List<FileItemRecord> get files => _files;
  List<ReportSnapshot> get reports => _reports;
  OrganizerRules? get rules => _rules;
  int? get selectedBlockId => _selectedBlockId;
  String? get selectedWeekday => _selectedWeekday;
  String get explorerQuery => _explorerQuery;
  int? get selectedExplorerBlockId => _selectedExplorerBlockId;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _blocks = await _database.fetchBlocks();
      _dayGroups = await _database.fetchDayGroups();
      _files = await _database.fetchFiles();
      _rules = await _database.fetchRules();
      _reports = await _database.fetchReports();

      _selectedBlockId ??= _blocks.isNotEmpty ? _blocks.first.id : null;
      _selectedExplorerBlockId ??= _selectedBlockId;
      final initialDays = weekdaysForSelectedBlock;
      _selectedWeekday ??= initialDays.isNotEmpty ? initialDays.first : null;
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BlockRecord? get selectedBlock {
    final id = _selectedBlockId;
    if (id == null) {
      return null;
    }
    return _blocks.where((block) => block.id == id).firstOrNull;
  }

  List<FileItemRecord> get filesForSelectedBlock {
    final id = _selectedBlockId;
    if (id == null) {
      return _files;
    }
    return _files.where((file) => file.blockId == id).toList();
  }

  List<String> get weekdaysForSelectedBlock {
    final days = filesForSelectedBlock.map(dayLabelForFile).toSet().toList()..sort(_weekdaySort);
    return days;
  }

  List<FileItemRecord> get timelineFiles {
    var entries = filesForSelectedBlock;
    if (_selectedWeekday != null) {
      entries = entries.where((file) => dayLabelForFile(file) == _selectedWeekday).toList();
    }
    entries.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return entries;
  }

  List<FileItemRecord> get explorerFiles {
    var entries = _files;
    if (_selectedExplorerBlockId != null) {
      entries = entries.where((file) => file.blockId == _selectedExplorerBlockId).toList();
    }

    final query = _explorerQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return entries;
    }

    return entries.where((file) {
      return file.name.toLowerCase().contains(query) ||
          file.category.toLowerCase().contains(query) ||
          file.path.toLowerCase().contains(query);
    }).toList();
  }

  int get totalSizeBytes => _files.fold<int>(0, (sum, file) => sum + file.sizeBytes);

  int get archivedFilesCount => _files.where((file) => file.status == 'Archived').length;

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final file in _files) {
      counts.update(file.category, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  Future<void> updateRules(OrganizerRules updatedRules) async {
    _rules = updatedRules;
    await _database.updateRules(updatedRules);
    notifyListeners();
  }

  void selectBlock(int blockId) {
    _selectedBlockId = blockId;
    _selectedExplorerBlockId = blockId;
    final days = weekdaysForSelectedBlock;
    _selectedWeekday = days.isNotEmpty ? days.first : null;
    notifyListeners();
  }

  void selectWeekday(String weekday) {
    _selectedWeekday = weekday;
    notifyListeners();
  }

  void setExplorerQuery(String query) {
    _explorerQuery = query;
    notifyListeners();
  }

  void selectExplorerBlock(int? blockId) {
    _selectedExplorerBlockId = blockId;
    notifyListeners();
  }

  Future<void> renameFile(FileItemRecord file, String newName) async {
    final cleanName = newName.trim();
    if (cleanName.isEmpty) {
      return;
    }

    final renamed = file.copyWith(
      name: cleanName,
      path: '${file.path.split('/').take(file.path.split('/').length - 1).join('/')}/$cleanName',
      modifiedAt: DateTime.now(),
    );
    await _database.upsertFile(renamed);
    await _refreshFiles();
  }

  Future<void> createFile({
    required int blockId,
    required int dayGroupId,
    required String name,
    required String extension,
    required String category,
  }) async {
    final now = DateTime.now();
    final nextId = _files.isEmpty ? 1 : _files.map((file) => file.id).reduce(max) + 1;
    final file = FileItemRecord(
      id: nextId,
      blockId: blockId,
      dayGroupId: dayGroupId,
      name: '$name$extension',
      extension: extension,
      path: '/${blockName(blockId)}/${dayGroupById(dayGroupId)?.weekday ?? 'Unsorted'}/$name$extension',
      category: category,
      status: 'New',
      sharedWith: 'Local record',
      note: 'Created from Explorer screen.',
      sizeBytes: 64 * 1024,
      createdAt: now,
      modifiedAt: now,
      metadata: FileMetadataRecord(
        ownerId: 1000,
        ownerName: 'current_user',
        groupId: 1000,
        groupName: 'project',
        seLinuxLabel: 'u:object_r:user_file:s0',
        numericPermissions: '0644',
        rwxPermissions: '-rw-r--r--',
        blockSize: 4096,
        totalBlocks: 16,
        inodeNumber: Random().nextInt(800000000),
        hardLinks: 1,
        isImmutable: false,
        isSigned: false,
        isHidden: false,
        isJournaled: true,
        isCriticalPath: false,
      ),
    );
    await _database.upsertFile(file);
    await _refreshFiles();
  }

  Future<void> deleteFile(int id) async {
    await _database.deleteFile(id);
    await _refreshFiles();
  }

  Future<void> generateReport() async {
    final snapshot = ReportSnapshot(
      id: 0,
      generatedAt: DateTime.now(),
      totalFiles: _files.length,
      totalSizeBytes: totalSizeBytes,
      totalBlocks: _blocks.length,
      archivedFiles: archivedFilesCount,
      duplicateConflicts: _files.length - _files.map((file) => file.name).toSet().length,
    );
    await _database.insertReport(snapshot);
    _reports = await _database.fetchReports();
    notifyListeners();
  }

  String dayLabelForFile(FileItemRecord file) {
    return dayGroupById(file.dayGroupId)?.weekday ?? 'Unsorted';
  }

  String sessionLabelForFile(FileItemRecord file) {
    return dayGroupById(file.dayGroupId)?.sessionLabel ?? 'Session';
  }

  DayGroup? dayGroupById(int id) => _dayGroups.where((group) => group.id == id).firstOrNull;

  String blockName(int id) => _blocks.where((block) => block.id == id).firstOrNull?.name ?? 'Unknown';

  Future<void> _refreshFiles() async {
    _files = await _database.fetchFiles();
    notifyListeners();
  }

  int _weekdaySort(String a, String b) {
    const order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return order.indexOf(a).compareTo(order.indexOf(b));
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
