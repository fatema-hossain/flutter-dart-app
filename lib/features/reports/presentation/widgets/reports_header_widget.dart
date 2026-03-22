import 'package:flutter/material.dart';

class ReportsHeaderWidget extends StatelessWidget {
  const ReportsHeaderWidget({
    super.key,
    required this.snapshotCount,
    required this.onGenerateReport,
  });

  final int snapshotCount;
  final Future<void> Function() onGenerateReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SYSTEM INSIGHTS',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2.0, color: Color(0xFFACABAA)),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w300, letterSpacing: -1.0, color: Colors.white),
                        children: [
                          TextSpan(text: 'Reports & '),
                          TextSpan(text: 'Archives', style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFFAEC6FF))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$snapshotCount report snapshots stored locally.',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA)),
                    ),
                  ],
                ),
                if (!isWide) const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFAEC6FF), Color(0xFF0C4492)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: ElevatedButton(
                    onPressed: () async => onGenerateReport(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF003D8A), size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Generate Report',
                          style: TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003D8A)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
