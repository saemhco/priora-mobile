import 'package:flutter/foundation.dart';

/// Result of the operation to delete an availability block.
@immutable
class DeleteBlockResult {
  const DeleteBlockResult({required this.success, this.message});

  final bool success;
  final String? message;
}
