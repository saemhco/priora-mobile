/// Mensaje del chat de triaje.
class TriageMessage {
  TriageMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.options,
    this.imagePath,
  });

  final String text;
  final bool isUser;
  final String time;
  final List<String>? options;
  final String? imagePath;
}
