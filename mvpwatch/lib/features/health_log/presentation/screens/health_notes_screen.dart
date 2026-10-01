import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/app_colors.dart';
import '../bloc/health_log_bloc.dart';

class HealthNotesScreen extends StatefulWidget {
  const HealthNotesScreen({super.key});

  @override
  State<HealthNotesScreen> createState() => _HealthNotesScreenState();
}

class _HealthNotesScreenState extends State<HealthNotesScreen> {
  final TextEditingController _noteController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
            _noteController.text = _lastWords;
          }),
        );
      }
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _submitNote() {
    final note = _noteController.text.trim();
    if (note.isNotEmpty) {
      context.read<HealthLogBloc>().add(AddHealthNoteEvent(note));
      _noteController.clear();
      setState(() => _lastWords = '');
      // Unfocus keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'How are you feeling today?',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: CircleAvatar(
                        backgroundColor: _isListening ? AppColors.error : AppColors.surface,
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _submitNote,
                      child: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notes List
          Expanded(
            child: BlocBuilder<HealthLogBloc, HealthLogState>(
              builder: (context, state) {
                if (state is HealthLogLoading && state is! HealthLogLoaded) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                if (state is HealthLogLoaded) {
                  final notes = state.notes;
                  if (notes.isEmpty) {
                    return Center(
                      child: Text(
                        'No health notes yet.\nTap the mic or type to add one.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Dismissible(
                        key: Key(note.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          context.read<HealthLogBloc>().add(DeleteHealthNoteEvent(note.id));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.note,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('MMM dd, yyyy • hh:mm a').format(note.timestamp),
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
