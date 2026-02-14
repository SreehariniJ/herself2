import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/herself_core.dart';

class GeminiChatbotLogic {
  final UserState userState;
  // TODO: Replace with your actual Gemini API Key
  static const String _apiKey = "AIzaSyAeVujLDCXyllamZzlieBEJulsRM8O-b6U";
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiChatbotLogic(this.userState) {
    _initModel();
  }

  void _initModel() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
      generationConfig: GenerationConfig(
        temperature: 0.7, // Creative but helpful
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048, // Keep responses concise for chat
      ),
    );
    _startChat();
  }

  void _startChat() {
    // System instruction to define persona
    final persona =
        """
    You are an AI companion named 'Herself' designed to provide emotional support, empathy, and practical advice.
    The user's name is ${userState.name}.
    Current user state: Mood: ${userState.mood}, Energy: ${userState.energyLevel}/10.
    
    Guidelines:
    1. Be empathetic, warm, and non-judgmental.
    2. Validate the user's feelings first before offering advice.
    3. Keep responses concise (2-3 sentences max usually) as this is a chat interface.
    4. If the user mentions self-harm or suicide, provide immediate resources and encourage professional help gently.
    5. Do not be overly formal. Speak like a caring friend.
    """;

    _chatSession = _model.startChat(history: [Content.text(persona)]);
  }

  Future<String> getResponse(String input) async {
    try {
      final response = await _chatSession?.sendMessage(Content.text(input));
      return response?.text ??
          "I'm strange... I couldn't think of a response. Try again?";
    } catch (e) {
      print("Gemini Error: $e"); // Print to console
      if (e.toString().contains("API_KEY_INVALID")) {
        return "It looks like your API Key is invalid. Please check the code configuration.";
      }
      // Return the actual error for debugging purposes
      return "I'm having trouble connecting. Error: ${e.toString()}";
    }
  }
}
