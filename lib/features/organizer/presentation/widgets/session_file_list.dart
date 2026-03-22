import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/state/file_zen_scope.dart';
import '../../../../data/models/file_item.dart';
import '../screens/metadata_visualizer_bottom_sheet.dart';

class SessionFileList extends StatelessWidget {
  const SessionFileList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final files = controller.timelineFiles;

    if (files.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No files are stored for this block/day combination yet.',
          style: TextStyle(color: Color(0xFFACABAA)),
        ),
      );
    }

    final grouped = <String, List<FileItemRecord>>{};
    for (final file in files) {
      grouped.putIfAbsent(controller.sessionLabelForFile(file), () => []).add(file);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          _buildSessionHeader(entry.key),
          const SizedBox(height: 8),
          for (final file in entry.value) ...[
            _buildFileItem(context: context, file: file),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSessionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: Color(0xFFE4DFFF),
        ),
      ),
    );
  }

  Widget _buildFileItem({
    required BuildContext context,
    required FileItemRecord file,
  }) {
    final size = NumberFormat.compact().format(file.sizeBytes);
    final relativeDate = DateFormat('dd MMM, hh:mm a').format(file.modifiedAt);

    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MetadataVisualizerBottomSheet(file: file),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF191A1A),
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last modified $relativeDate • ${size}B',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFFACABAA),
                    ),
                  ),
                ],
              ),
            ),
            if (file.sharedWith.isNotEmpty) ...[
              Text(
                file.sharedWith,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFF767575),
                ),
              ),
              const SizedBox(width: 24),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: file.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                file.status,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: file.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.more_vert, color: Color(0xFFACABAA)),
          ],
        ),
      ),
    );
  }
}
