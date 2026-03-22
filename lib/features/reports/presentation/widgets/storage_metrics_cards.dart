import 'package:flutter/material.dart';

class StorageMetricsCards extends StatelessWidget {
  const StorageMetricsCards({
    super.key,
    required this.totalFiles,
    required this.totalBlocks,
    required this.archivedFiles,
    required this.totalSizeLabel,
  });

  final int totalFiles;
  final int totalBlocks;
  final int archivedFiles;
  final String totalSizeLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final infoColumn = Column(
          children: [
            Expanded(child: _buildInfoCard(Icons.folder_zip, const Color(0xFF8FA0AA), '$totalFiles', 'Total Objects Indexed')),
            const SizedBox(height: 16),
            Expanded(child: _buildInfoCard(Icons.verified_user, const Color(0xFFE4DFFF), '$archivedFiles', 'Archived Files')),
          ],
        );

        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _buildLiveStatusCard()),
              const SizedBox(width: 16),
              Expanded(child: infoColumn),
            ],
          );
        }

        return Column(
          children: [
            _buildLiveStatusCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoCard(Icons.folder_zip, const Color(0xFF8FA0AA), '$totalFiles', 'Total Objects Indexed')),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoCard(Icons.verified_user, const Color(0xFFE4DFFF), '$totalBlocks', 'Tracked Blocks')),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLiveStatusCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF191A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.storage, color: Color(0xFFAEC6FF), size: 36),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2020),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DATABASE LIVE',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.0, color: Color(0xFFACABAA)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalSizeLabel,
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text('tracked', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Calculated from persisted file records', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, Color iconColor, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFACABAA)),
          ),
        ],
      ),
    );
  }
}
