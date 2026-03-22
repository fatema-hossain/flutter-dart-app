import 'package:flutter/material.dart';

import '../../../../core/state/file_zen_scope.dart';

class DayTabsSelector extends StatelessWidget {
  const DayTabsSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final days = controller.weekdaysForSelectedBlock;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final day in days)
            _buildDayTab(
              label: day,
              isActive: controller.selectedWeekday == day,
              onTap: () => controller.selectWeekday(day),
            ),
        ],
      ),
    );
  }

  Widget _buildDayTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0C4492) : const Color(0xFF191A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFFAEC6FF).withValues(alpha: 0.2)
                : const Color(0xFF484848).withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? const Color(0xFFBDD0FF) : const Color(0xFFACABAA),
          ),
        ),
      ),
    );
  }
}
