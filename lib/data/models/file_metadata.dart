class FileMetadataRecord {
  const FileMetadataRecord({
    required this.ownerId,
    required this.ownerName,
    required this.groupId,
    required this.groupName,
    required this.seLinuxLabel,
    required this.numericPermissions,
    required this.rwxPermissions,
    required this.blockSize,
    required this.totalBlocks,
    required this.inodeNumber,
    required this.hardLinks,
    required this.isImmutable,
    required this.isSigned,
    required this.isHidden,
    required this.isJournaled,
    required this.isCriticalPath,
  });

  final int ownerId;
  final String ownerName;
  final int groupId;
  final String groupName;
  final String seLinuxLabel;
  final String numericPermissions;
  final String rwxPermissions;
  final int blockSize;
  final int totalBlocks;
  final int inodeNumber;
  final int hardLinks;
  final bool isImmutable;
  final bool isSigned;
  final bool isHidden;
  final bool isJournaled;
  final bool isCriticalPath;
}
