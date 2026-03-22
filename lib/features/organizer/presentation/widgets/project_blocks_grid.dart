import 'package:flutter/material.dart';

import '../../../../core/state/file_zen_scope.dart';

class ProjectBlocksGrid extends StatelessWidget {
  const ProjectBlocksGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final selectedBlock = controller.selectedBlock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        const Text(
          'Project Blocks',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 56,
            fontWeight: FontWeight.w300,
            letterSpacing: -1.0,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Blocks are now stored records. Tap a block to filter the timeline by that category.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: Color(0xFFACABAA),
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final block in controller.blocks)
              InkWell(
                onTap: () => controller.selectBlock(block.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  width: 380,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: selectedBlock?.id == block.id ? block.color.withValues(alpha: 0.1) : const Color(0xFF131313),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedBlock?.id == block.id
                          ? block.color.withValues(alpha: 0.35)
                          : const Color(0xFF484848).withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            block.label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              color: block.color,
                            ),
                          ),
                          Icon(block.icon, color: block.color),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        block.name,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        block.description,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFFACABAA),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final day in controller.dayGroups.where((group) => group.blockId == block.id))
                            _buildDayPreview(
                              day.weekday.substring(0, 3).toUpperCase(),
                              controller.files.where((file) => file.dayGroupId == day.id).length.toString().padLeft(2, '0'),
                              controller.selectedWeekday == day.weekday && selectedBlock?.id == block.id,
                              block.color,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayPreview(String day, String number, bool isActive, Color accent) {
    return Container(
      width: 68,
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFF191A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? accent.withValues(alpha: 0.35) : Colors.transparent,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? accent : const Color(0xFFACABAA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isActive ? accent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
