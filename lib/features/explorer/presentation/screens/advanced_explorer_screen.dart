import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/state/file_zen_scope.dart';
import '../../../../data/models/file_item.dart';
import '../../../organizer/presentation/screens/metadata_visualizer_bottom_sheet.dart';

class AdvancedExplorerScreen extends StatelessWidget {
  const AdvancedExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final files = controller.explorerFiles;
    final sizeFormatter = NumberFormat.compact();

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Advanced Explorer',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse project records, search indexed filenames, and inspect metadata stored in the local database.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Color(0xFFACABAA),
                  ),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 900;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _ExplorerSidebar(
                              selectedBlockId: controller.selectedExplorerBlockId,
                              totalFiles: controller.files.length,
                              totalSizeLabel: '${sizeFormatter.format(controller.totalSizeBytes)}B',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: _ExplorerPane(files: files),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _ExplorerSidebar(
                          selectedBlockId: controller.selectedExplorerBlockId,
                          totalFiles: controller.files.length,
                          totalSizeLabel: '${sizeFormatter.format(controller.totalSizeBytes)}B',
                        ),
                        const SizedBox(height: 24),
                        _ExplorerPane(files: files),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: const Color(0xFFAEC6FF),
        foregroundColor: const Color(0xFF003D8A),
        icon: const Icon(Icons.create_new_folder),
        label: const Text('New File'),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final controller = FileZenScope.of(context);
    final nameController = TextEditingController();
    String extension = '.txt';
    String category = 'Documents';
    int blockId = controller.selectedExplorerBlockId ?? controller.blocks.first.id;
    int dayGroupId = controller.dayGroups.firstWhere((group) => group.blockId == blockId).id;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191A1A),
          title: const Text('Create a file record', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              final blockGroups = controller.dayGroups.where((group) => group.blockId == blockId).toList();
              if (!blockGroups.any((group) => group.id == dayGroupId)) {
                dayGroupId = blockGroups.first.id;
              }
              return SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Base name'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: blockId,
                      dropdownColor: const Color(0xFF191A1A),
                      decoration: const InputDecoration(labelText: 'Block'),
                      items: controller.blocks
                          .map((block) => DropdownMenuItem<int>(
                                value: block.id,
                                child: Text(block.name),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => blockId = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: dayGroupId,
                      dropdownColor: const Color(0xFF191A1A),
                      decoration: const InputDecoration(labelText: 'Day group'),
                      items: blockGroups
                          .map((group) => DropdownMenuItem<int>(
                                value: group.id,
                                child: Text('${group.weekday} - ${group.sessionLabel}'),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => dayGroupId = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: extension,
                      dropdownColor: const Color(0xFF191A1A),
                      decoration: const InputDecoration(labelText: 'Extension'),
                      items: const ['.txt', '.pdf', '.png', '.dart', '.xlsx']
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setState(() => extension = value!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: const Color(0xFF191A1A),
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const ['Documents', 'Visual Assets', 'Source Code', 'Archives']
                          .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setState(() => category = value!),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                await controller.createFile(
                  blockId: blockId,
                  dayGroupId: dayGroupId,
                  name: nameController.text.trim(),
                  extension: extension,
                  category: category,
                );
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _ExplorerSidebar extends StatelessWidget {
  const _ExplorerSidebar({
    required this.selectedBlockId,
    required this.totalFiles,
    required this.totalSizeLabel,
  });

  final int? selectedBlockId;
  final int totalFiles;
  final String totalSizeLabel;

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Directory Blocks',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalFiles files indexed across $totalSizeLabel of tracked data.',
            style: const TextStyle(color: Color(0xFFACABAA)),
          ),
          const SizedBox(height: 24),
          _BlockTile(
            isSelected: selectedBlockId == null,
            icon: Icons.folder_copy_outlined,
            color: const Color(0xFF8FA0AA),
            title: 'All Blocks',
            subtitle: 'Search every stored record',
            onTap: () => controller.selectExplorerBlock(null),
          ),
          const SizedBox(height: 12),
          for (final block in controller.blocks) ...[
            _BlockTile(
              isSelected: selectedBlockId == block.id,
              icon: block.icon,
              color: block.color,
              title: block.name,
              subtitle: block.description,
              onTap: () => controller.selectExplorerBlock(block.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ExplorerPane extends StatelessWidget {
  const _ExplorerPane({required this.files});

  final List<FileItemRecord> files;

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF191A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: controller.setExplorerQuery,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by filename, category, or path',
              hintStyle: const TextStyle(color: Color(0xFF767575)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFACABAA)),
              filled: true,
              fillColor: const Color(0xFF0E0E0E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (files.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No files match this filter yet.',
                style: TextStyle(color: Color(0xFFACABAA)),
              ),
            )
          else
            Column(
              children: [
                for (final file in files) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: file.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(file.icon, color: file.accentColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                file.path,
                                style: const TextStyle(color: Color(0xFFACABAA)),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _pill(file.category, file.accentColor),
                                  _pill(file.status, const Color(0xFF8FA0AA)),
                                  Text(
                                    'Modified ${dateFormat.format(file.modifiedAt)}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF767575)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: const Color(0xFF252626),
                          onSelected: (value) async {
                            if (value == 'open') {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => MetadataVisualizerBottomSheet(file: file),
                              );
                              return;
                            }

                            if (value == 'rename') {
                              await _showRenameDialog(context, file);
                              return;
                            }

                            if (value == 'delete') {
                              await controller.deleteFile(file.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'open', child: Text('Open metadata')),
                            PopupMenuItem(value: 'rename', child: Text('Rename')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  static Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, FileItemRecord file) async {
    final controller = FileZenScope.of(context);
    final input = TextEditingController(text: file.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191A1A),
          title: const Text('Rename file', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: input,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'File name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.renameFile(file, input.text);
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    required this.isSelected,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.14) : const Color(0xFF191A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.35) : const Color(0xFF484848).withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFACABAA)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
