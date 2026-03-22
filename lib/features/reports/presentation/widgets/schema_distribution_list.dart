import 'package:flutter/material.dart';

class SchemaDistributionList extends StatelessWidget {
  const SchemaDistributionList({
    super.key,
    required this.categoryCounts,
    required this.latestSummary,
  });

  final Map<String, int> categoryCounts;
  final String latestSummary;

  @override
  Widget build(BuildContext context) {
    final entries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF191A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2020).withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Data Distribution', style: TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                Text('Generated from local records', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFACABAA))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                _headerRow(),
                for (final entry in entries)
                  _tableRow(
                    title: entry.key,
                    records: entry.value,
                    status: entry.value > 1 ? 'Active' : 'Sparse',
                    accent: _colorFor(entry.key),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF131313),
              border: Border(top: BorderSide(color: const Color(0xFF484848).withValues(alpha: 0.1))),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Text(latestSummary, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFACABAA))),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text('CATEGORY', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFACABAA)))),
          Expanded(child: Text('TYPE', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFACABAA)))),
          Expanded(child: Align(alignment: Alignment.centerRight, child: Text('RECORDS', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFACABAA))))),
          Expanded(child: Padding(padding: EdgeInsets.only(left: 16), child: Text('STATUS', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFACABAA))))),
        ],
      ),
    );
  }

  Widget _tableRow({
    required String title,
    required int records,
    required String status,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: const Color(0xFF484848).withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.folder_special, color: accent, size: 18),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          ),
          const Expanded(
            child: Text('SQLite category bucket', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA))),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('$records', style: const TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.white)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: accent)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(String category) {
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
}
