import 'package:flutter/material.dart';

class TemporalLogicPicker extends StatelessWidget {
  const TemporalLogicPicker({
    super.key,
    required this.inactivityDays,
    required this.createdFrom,
    required this.createdTo,
    required this.onInactivityChanged,
  });

  final double inactivityDays;
  final String createdFrom;
  final String createdTo;
  final ValueChanged<double> onInactivityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF191A1A),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Color(0xFFAEC6FF), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temporal Logic',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Age and inactivity preferences are now loaded from saved organizer rules.',
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA)),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            children: [
              _buildCreationWindow(),
              _buildInactivitySlider(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreationWindow() {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CREATION WINDOW',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFAEC6FF)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dateBox(createdFrom, Icons.calendar_today)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 20, color: Color(0xFFACABAA)),
              ),
              Expanded(child: _dateBox(createdTo, Icons.event)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInactivitySlider(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INACTIVITY THRESHOLD',
            style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: Color(0xFFAEC6FF)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFAEC6FF),
                    inactiveTrackColor: const Color(0xFF2E3E45),
                    thumbColor: const Color(0xFFAEC6FF),
                    overlayColor: const Color(0xFFAEC6FF).withValues(alpha: 0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: inactivityDays,
                    min: 0,
                    max: 365,
                    divisions: 365,
                    onChanged: onInactivityChanged,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2020),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${inactivityDays.toInt()} Days',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFAEC6FF)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF484848).withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white)),
          Icon(icon, size: 16, color: const Color(0xFFACABAA)),
        ],
      ),
    );
  }
}
