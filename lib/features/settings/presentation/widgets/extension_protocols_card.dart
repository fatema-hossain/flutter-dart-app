import 'package:flutter/material.dart';

class ExtensionProtocolsCard extends StatelessWidget {
  const ExtensionProtocolsCard({
    super.key,
    required this.visualAssets,
    required this.documents,
    required this.sourceCode,
    required this.archives,
    required this.onVisualAssetsChanged,
    required this.onDocumentsChanged,
    required this.onSourceCodeChanged,
    required this.onArchivesChanged,
  });

  final bool visualAssets;
  final bool documents;
  final bool sourceCode;
  final bool archives;
  final ValueChanged<bool> onVisualAssetsChanged;
  final ValueChanged<bool> onDocumentsChanged;
  final ValueChanged<bool> onSourceCodeChanged;
  final ValueChanged<bool> onArchivesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extension Protocols',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'These toggles are now saved in the local organizer rules table.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA)),
                  ),
                ],
              ),
              Icon(Icons.auto_awesome, color: Color(0xFFAEC6FF), size: 30),
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 380,
                child: _buildItem('Visual Assets', '.jpg, .png, .svg', Icons.image, const Color(0xFFAEC6FF), visualAssets, onVisualAssetsChanged),
              ),
              SizedBox(
                width: 380,
                child: _buildItem('Documents', '.pdf, .docx, .txt', Icons.description, const Color(0xFF8FA0AA), documents, onDocumentsChanged),
              ),
              SizedBox(
                width: 380,
                child: _buildItem('Source Code', '.js, .py, .html, .dart', Icons.terminal, const Color(0xFFE4DFFF), sourceCode, onSourceCodeChanged),
              ),
              SizedBox(
                width: 380,
                child: _buildItem('Archives', '.zip, .rar, .7z', Icons.inventory_2, Colors.white, archives, onArchivesChanged),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String subtitle, IconData icon, Color iconColor, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFACABAA))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF003D8A),
            activeTrackColor: const Color(0xFFAEC6FF),
            inactiveTrackColor: const Color(0xFF252626),
          ),
        ],
      ),
    );
  }
}
