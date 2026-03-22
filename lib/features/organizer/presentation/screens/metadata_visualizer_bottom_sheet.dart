import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/file_item.dart';
import '../widgets/fs_attributes_grid.dart';
import '../widgets/security_context_card.dart';
import '../widgets/storage_geometry_card.dart';
import '../widgets/unix_permissions_widget.dart';

class MetadataVisualizerBottomSheet extends StatelessWidget {
  const MetadataVisualizerBottomSheet({
    required this.file,
    super.key,
  });

  final FileItemRecord file;

  @override
  Widget build(BuildContext context) {
    final metadata = file.metadata;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF484848),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Explorer', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA))),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFFACABAA)),
                      Expanded(
                        child: Text(
                          file.path,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${file.category} • Last modified ${DateFormat('dd MMM yyyy, hh:mm a').format(file.modifiedAt)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFFACABAA),
                    ),
                  ),
                  const SizedBox(height: 48),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final leftColumn = Column(
                        children: [
                          _buildPrimaryStorageCard(),
                          const SizedBox(height: 24),
                          UnixPermissionsWidget(
                            numericPerms: metadata.numericPermissions,
                            rwxString: metadata.rwxPermissions,
                            uR: metadata.rwxPermissions[1] == 'r',
                            uW: metadata.rwxPermissions[2] == 'w',
                            uX: metadata.rwxPermissions[3] == 'x',
                            gR: metadata.rwxPermissions[4] == 'r',
                            gW: metadata.rwxPermissions[5] == 'w',
                            gX: metadata.rwxPermissions[6] == 'x',
                            oR: metadata.rwxPermissions[7] == 'r',
                            oW: metadata.rwxPermissions[8] == 'w',
                            oX: metadata.rwxPermissions[9] == 'x',
                          ),
                        ],
                      );

                      final rightColumn = Column(
                        children: [
                          SecurityContextCard(
                            ownerId: metadata.ownerId,
                            ownerName: metadata.ownerName,
                            groupId: metadata.groupId,
                            groupName: metadata.groupName,
                            seLinuxLabel: metadata.seLinuxLabel,
                          ),
                          const SizedBox(height: 24),
                          StorageGeometryCard(
                            blockSize: metadata.blockSize,
                            totalBlocks: metadata.totalBlocks,
                          ),
                          const SizedBox(height: 24),
                          FsAttributesGrid(
                            isImmutable: metadata.isImmutable,
                            isSigned: metadata.isSigned,
                            isHidden: metadata.isHidden,
                            isJournaled: metadata.isJournaled,
                            isCriticalPath: metadata.isCriticalPath,
                            inodeNumber: metadata.inodeNumber,
                            hardLinks: metadata.hardLinks,
                          ),
                        ],
                      );

                      if (constraints.maxWidth > 800) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: leftColumn),
                            const SizedBox(width: 24),
                            Expanded(child: rightColumn),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          leftColumn,
                          const SizedBox(height: 24),
                          rightColumn,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStorageCard() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(file.icon, color: file.accentColor, size: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('FORMAT', style: TextStyle(fontFamily: 'Inter', fontSize: 12, letterSpacing: 2.0, color: Color(0xFFACABAA))),
                  const SizedBox(height: 4),
                  Text(
                    file.extension.toUpperCase().replaceAll('.', ''),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: file.accentColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                (file.sizeBytes / (1024 * 1024)).toStringAsFixed(1),
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 72, fontWeight: FontWeight.w200, color: Colors.white, height: 1.0),
              ),
              const SizedBox(width: 8),
              const Text('MB', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, color: Color(0xFFACABAA))),
            ],
          ),
          const SizedBox(height: 8),
          Text(file.note, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFACABAA))),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Storage Efficiency', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              Text(file.sharedWith, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFACABAA))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2E3E45),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (file.sizeBytes / 15000000).clamp(0.08, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [file.accentColor, const Color(0xFF0C4492)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
