import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/state/file_zen_scope.dart';
import '../widgets/reports_header_widget.dart';
import '../widgets/schema_distribution_list.dart';
import '../widgets/storage_metrics_cards.dart';

class DatabaseReportsScreen extends StatelessWidget {
  const DatabaseReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final latest = controller.reports.isEmpty ? null : controller.reports.first;
    final sizeLabel = NumberFormat.compact().format(controller.totalSizeBytes);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 120),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReportsHeaderWidget(
                        snapshotCount: controller.reports.length,
                        onGenerateReport: () async {
                          await controller.generateReport();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Report snapshot generated')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 48),
                      StorageMetricsCards(
                        totalFiles: controller.files.length,
                        totalBlocks: controller.blocks.length,
                        archivedFiles: controller.archivedFilesCount,
                        totalSizeLabel: sizeLabel,
                      ),
                      const SizedBox(height: 48),
                      SchemaDistributionList(
                        categoryCounts: controller.categoryCounts,
                        latestSummary: latest == null
                            ? 'No report snapshot generated yet.'
                            : 'Latest snapshot saved ${DateFormat('dd MMM yyyy, hh:mm a').format(latest.generatedAt)} with ${latest.totalFiles} files and ${latest.archivedFiles} archived records.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
