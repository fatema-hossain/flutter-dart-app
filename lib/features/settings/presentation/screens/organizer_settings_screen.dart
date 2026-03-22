import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/file_zen_scope.dart';
import '../../../../data/controllers/file_zen_controller.dart';
import '../../../../data/models/organizer_rules.dart';
import '../widgets/conflict_resolution_settings.dart';
import '../widgets/extension_protocols_card.dart';
import '../widgets/temporal_logic_picker.dart';

class OrganizerSettingsScreen extends StatelessWidget {
  const OrganizerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FileZenScope.of(context);
    final rules = controller.rules;
    if (rules == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E0E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.grid_view, color: Color(0xFFAEC6FF)),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'FileZen',
          style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organizer',
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w300, letterSpacing: -1.0, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These controls now load and save organizer rules through the local database.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Color(0xFFACABAA)),
                ),
                const SizedBox(height: 48),
                ExtensionProtocolsCard(
                  visualAssets: rules.visualAssetsEnabled,
                  documents: rules.documentsEnabled,
                  sourceCode: rules.sourceCodeEnabled,
                  archives: rules.archivesEnabled,
                  onVisualAssetsChanged: (value) => _save(context, controller, rules.copyWith(visualAssetsEnabled: value)),
                  onDocumentsChanged: (value) => _save(context, controller, rules.copyWith(documentsEnabled: value)),
                  onSourceCodeChanged: (value) => _save(context, controller, rules.copyWith(sourceCodeEnabled: value)),
                  onArchivesChanged: (value) => _save(context, controller, rules.copyWith(archivesEnabled: value)),
                ),
                const SizedBox(height: 32),
                TemporalLogicPicker(
                  inactivityDays: rules.inactivityDays,
                  createdFrom: rules.createdFrom,
                  createdTo: rules.createdTo,
                  onInactivityChanged: (value) => _save(context, controller, rules.copyWith(inactivityDays: value), showSnackBar: false),
                ),
                const SizedBox(height: 32),
                ConflictResolutionSettings(
                  appendTimestamps: rules.appendTimestamps,
                  defaultStrategy: rules.defaultStrategy,
                  onAppendTimestampsChanged: (value) => _save(context, controller, rules.copyWith(appendTimestamps: value)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    FileZenController controller,
    OrganizerRules rules, {
    bool showSnackBar = true,
  }) async {
    await controller.updateRules(rules);
    if (showSnackBar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organizer rules saved')),
      );
    }
  }
}
