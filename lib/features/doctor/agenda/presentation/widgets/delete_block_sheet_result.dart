import 'package:flutter/foundation.dart';
import 'package:priora/features/doctor/agenda/presentation/widgets/delete_block_sheet.dart'
    show DeleteBlockSheet;

/// Result of user action in [DeleteBlockSheet].
@immutable
class DeleteBlockSheetResult {
  const DeleteBlockSheetResult({required this.success, this.blockId});

  final bool success;
  final String? blockId;
}
