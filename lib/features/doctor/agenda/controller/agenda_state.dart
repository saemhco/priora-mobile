import 'package:flutter/foundation.dart';

@immutable
class AgendaState {
  const AgendaState();
}

@immutable
class DeleteBlockResult {
  final bool success;
  final String? message;

  const DeleteBlockResult({required this.success, this.message});
}
