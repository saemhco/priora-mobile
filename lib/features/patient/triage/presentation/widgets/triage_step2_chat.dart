import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:priora/features/patient/triage/controller/triage_cubit.dart';
import 'package:priora/features/patient/triage/presentation/widgets/triage_header.dart';

class TriageStep2Chat extends StatefulWidget {
  final TriageState state;
  final String accessToken;

  const TriageStep2Chat({
    super.key,
    required this.state,
    required this.accessToken,
  });

  @override
  State<TriageStep2Chat> createState() => _TriageStep2ChatState();
}

class _TriageStep2ChatState extends State<TriageStep2Chat> {
  late final TriageCubit _cubit;
  final _chatInputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showAttachmentMenu = false;
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _cubit = context.read<TriageCubit>();
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _scrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _sendCurrentMessage(String text) {
    if (text.trim().isEmpty && _selectedImagePath == null) return;

    if (_selectedImagePath != null) {
      _cubit.sendImageMessage(
        widget.accessToken,
        _selectedImagePath!,
        text: text.trim().isEmpty ? null : text.trim(),
      );
      setState(() {
        _selectedImagePath = null;
      });
    } else {
      _cubit.sendMessage(widget.accessToken, text);
    }
    _chatInputController.clear();
  }

  void _updateControllers() {
    final currentIds = widget.state.missingQuestions.map((q) => q['id']?.toString() ?? '').toSet();
    
    _controllers.keys.toList().forEach((id) {
      if (!currentIds.contains(id)) {
        _controllers[id]?.dispose();
        _controllers.remove(id);
      }
    });

    for (var q in widget.state.missingQuestions) {
      final id = q['id']?.toString() ?? '';
      final qType = q['type']?.toString() ?? 'text';
      if (qType != 'choice') {
        final stateVal = widget.state.answers[id] ?? '';
        if (!_controllers.containsKey(id)) {
          _controllers[id] = TextEditingController(text: stateVal);
          _controllers[id]!.addListener(() {
            if (_cubit.state.answers[id] != _controllers[id]!.text) {
              _cubit.updateAnswer(id, _controllers[id]!.text);
            }
          });
        } else {
          if (stateVal.isEmpty && _controllers[id]!.text.isNotEmpty) {
            _controllers[id]!.text = '';
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateControllers();
    _scrollToBottom();

    return Stack(
      children: [
        Column(
          children: [
            // Triage Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: TriageHeader(
                currentStep: 2,
                totalSteps: 2,
                title: 'Motivo de consulta',
              ),
            ),
            const Divider(color: Color(0xFFE2E8F0), height: 1),

            // Chat Messages Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount:
                    widget.state.chatMessages.length + (widget.state.isAnalyzing ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == widget.state.chatMessages.length) {
                    return _buildAnalyzingBubble();
                  }

                  final message = widget.state.chatMessages[index];
                  return Column(
                    crossAxisAlignment: message.isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      _buildMessageBubble(message),
                      if (message.options != null) ...[
                        const SizedBox(height: 12),
                        _buildOptionsCard(message.options!),
                      ],
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),
            ),

            if (_selectedImagePath != null) _buildAttachmentPreview(),

            // Input Bar
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular + button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAttachmentMenu = !_showAttachmentMenu;
                      });
                    },
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _showAttachmentMenu ? Icons.close : Icons.add,
                        color: const Color(0xFF64748B),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Input Field
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: TextField(
                          controller: _chatInputController,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Escribe tu respuesta aquí...',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          onSubmitted: (value) {
                            _sendCurrentMessage(value);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send Button
                  GestureDetector(
                    onTap: () {
                      _sendCurrentMessage(_chatInputController.text);
                    },
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0256C2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_showAttachmentMenu)
          Positioned(left: 16, bottom: 84, child: _buildAttachmentMenu()),
      ],
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_selectedImagePath!),
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImagePath = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Imagen seleccionada',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Se enviará con tu mensaje',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.image_outlined,
                color: Color(0xFF0256C2),
                size: 20,
              ),
              title: const Text(
                'Adjuntar imagen',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              dense: true,
              onTap: () {
                setState(() {
                  _showAttachmentMenu = false;
                });
                _showImageSourceBottomSheet(context);
              },
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ListTile(
              leading: const Icon(
                Icons.insert_drive_file_outlined,
                color: Color(0xFF0256C2),
                size: 20,
              ),
              title: const Text(
                'Adjuntar archivo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              dense: true,
              onTap: () {
                setState(() {
                  _showAttachmentMenu = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selecciona una opción',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF0256C2),
                    ),
                  ),
                  title: const Text(
                    'Cámara',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  subtitle: const Text(
                    'Toma una foto al instante',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF0256C2),
                    ),
                  ),
                  title: const Text(
                    'Galería',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                  subtitle: const Text(
                    'Elige una imagen existente',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(TriageMessage message) {
    return Row(
      mainAxisAlignment: message.isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isUser) ...[
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF0256C2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? const Color(0xFF0E5FD9)
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 16),
                  ),
                  border: Border.all(
                    color: message.isUser
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: message.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.imagePath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(message.imagePath!),
                          height: 150,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (message.text != 'Imagen adjunta')
                        const SizedBox(height: 8),
                    ],
                    if (message.imagePath == null ||
                        message.text != 'Imagen adjunta')
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF22D3EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFEFF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(0xFFCFFAFE), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'La IA está analizando tus síntomas',
                  style: TextStyle(
                    color: Color(0xFF0891B2),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                _buildBlinkingDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkingDots() {
    return const SizedBox(
      width: 16,
      child: Text(
        '...',
        style: TextStyle(
          color: Color(0xFF0891B2),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptionsCard(List<String> options) {
    final hasMissingQuestions = widget.state.missingQuestions.isNotEmpty;

    final bool allAnswered = widget.state.missingQuestions.every((q) {
      final qId = q['id']?.toString() ?? '';
      final ans = widget.state.answers[qId];
      return ans != null && ans.trim().isNotEmpty;
    });

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasMissingQuestions
                ? 'Completa las siguientes preguntas para continuar:'
                : 'Por favor, selecciona o responde lo siguiente:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((option) {
              final Map<String, dynamic>? matchingQuestion =
                  widget.state.missingQuestions.firstWhere(
                (q) => q['question']?.toString().trim() == option.trim(),
                orElse: () => null,
              );

              if (matchingQuestion == null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _cubit.sendMessage(widget.accessToken, option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF64748B),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final String qId = matchingQuestion['id']?.toString() ?? '';
              final String qText = matchingQuestion['question']?.toString() ?? '';
              final String qType = matchingQuestion['type']?.toString() ?? 'text';
              final List<dynamic> qChoices = matchingQuestion['choices'] ?? [];
              final currentAnswer = widget.state.answers[qId] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (qType == 'choice')
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: qChoices.map<Widget>((choice) {
                          final choiceText = choice.toString();
                          final isSelected = currentAnswer == choiceText;

                          return GestureDetector(
                            onTap: () => _cubit.updateAnswer(qId, choiceText),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0E5FD9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                choiceText,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      TextField(
                        controller: _controllers[qId],
                        keyboardType: qType == 'number'
                            ? TextInputType.number
                            : TextInputType.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: qType == 'number'
                              ? 'Ingresa un número...'
                              : 'Escribe tu respuesta aquí...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E5FD9),
                              width: 1.2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (hasMissingQuestions) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: (!allAnswered || widget.state.isAnalyzing)
                    ? null
                    : () => _cubit.submitChatAnswers(widget.accessToken),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0256C2),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: widget.state.isAnalyzing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar respuestas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
