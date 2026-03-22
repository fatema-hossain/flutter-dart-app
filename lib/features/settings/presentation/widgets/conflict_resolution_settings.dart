import 'package:flutter/material.dart';

class ConflictResolutionSettings extends StatelessWidget {
  const ConflictResolutionSettings({
    super.key,
    required this.appendTimestamps,
    required this.defaultStrategy,
    required this.onAppendTimestampsChanged,
  });

  final bool appendTimestamps;
  final String defaultStrategy;
  final ValueChanged<bool> onAppendTimestampsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF191A1A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFAEC6FF), Color(0xFF0C4492)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.gavel, color: Color(0xFF003D8A)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conflict Resolution',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Duplicate handling preferences are now persisted and reused across report generation.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA)),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.history, color: Color(0xFFE4DFFF)),
                              SizedBox(width: 12),
                              Text(
                                'Append timestamps to duplicates',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                              ),
                            ],
                          ),
                          Switch(
                            value: appendTimestamps,
                            onChanged: onAppendTimestampsChanged,
                            activeThumbColor: const Color(0xFF003D8A),
                            activeTrackColor: const Color(0xFFAEC6FF),
                            inactiveTrackColor: const Color(0xFF252626),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: const Color(0xFF484848).withValues(alpha: 0.1))),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Default Resolution Strategy',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFACABAA)),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2020),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    defaultStrategy,
                                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
                                  ),
                                  const Icon(Icons.check_circle, color: Color(0xFFAEC6FF), size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
