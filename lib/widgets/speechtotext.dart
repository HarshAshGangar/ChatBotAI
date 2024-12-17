import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechState {
  final String text; // Recognized speech text
  final bool isListening; // Whether the app is listening
  final void Function(String)? onSpeechUpdate; // Callback to update external text

  SpeechState({
    this.text = "",
    this.isListening = false,
    this.onSpeechUpdate,
  });

  SpeechState copyWith({
    String? text,
    bool? isListening,
    void Function(String)? onSpeechUpdate,
  }) {
    return SpeechState(
      text: text ?? this.text,
      isListening: isListening ?? this.isListening,
      onSpeechUpdate: onSpeechUpdate ?? this.onSpeechUpdate,
    );
  }
}

class SpeechNotifier extends StateNotifier<SpeechState> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  SpeechNotifier() : super(SpeechState()) {
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => print("Speech Status: $status"),
      onError: (error) => print("Speech Error: $error"),
    );
    if (!available) {
      print("Speech-to-Text not available.");
    }
  }

  void startListening() async {
    if (!_speechToText.isAvailable || state.isListening) return;

    await _speechToText.listen(onResult: (result) {
      final recognizedText = result.recognizedWords;

      // Update state with recognized text
      state = state.copyWith(text: recognizedText);

      // Trigger external callback if set (e.g., to update the TextField)
      if (state.onSpeechUpdate != null) {
        state.onSpeechUpdate!(recognizedText);
      }
    });

    state = state.copyWith(isListening: true);
  }

  void stopListening() async {
    if (!state.isListening) return;

    await _speechToText.stop();
    state = state.copyWith(isListening: false);
  }
}

final speechProvider = StateNotifierProvider<SpeechNotifier, SpeechState>((ref) {
  return SpeechNotifier();
});
