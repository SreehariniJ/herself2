import '../core/herself_core.dart';
import 'dart:math';

class ChatbotLogic {
  final UserState userState;
  final Random _random = Random();

  // Basic Context Memory
  String _lastTopic = "";
  int _consecutiveQuestions = 0;
  final List<String> _conversationHistory = [];

  ChatbotLogic(this.userState);

  String getInitialGreeting() {
    String greeting = "Hi ${userState.name}, I'm here for you.";

    if (userState.mood == 'sad' || userState.mood == 'stressed') {
      greeting +=
          " I noticed you're feeling a bit down (${userState.mood}). Would you like to talk about what's heavily on your mind?";
    } else if (userState.energyLevel < 4) {
      greeting +=
          " You seem a bit low on energy today. Remember to be gentle with yourself.";
    } else {
      greeting += " How are you feeling right now?";
    }
    return greeting;
  }

  String getResponse(String input) {
    if (input.trim().isEmpty) return "I'm listening.";

    _conversationHistory.add("User: $input");
    String lowerInput = input.toLowerCase();
    String response = "";

    // 1. Check for specific highly emotional keywords (Crisis / High Priority)
    if (_isCrisis(lowerInput)) {
      return "I'm really concerned to hear you say that. Please remember you're not alone. If you're in immediate danger, please reach out to emergency services or a trusted contact immediately. Would you like me to show you your emergency contacts?";
    }

    // 2. Identify Intent & Topic
    String? emotionalResponse = _handleEmotions(lowerInput);
    if (emotionalResponse != null) {
      response = emotionalResponse;
    } else {
      // 3. Handle General Conversation / Reflection
      response = _handleGeneralConversation(lowerInput);
    }

    _conversationHistory.add("Bot: $response");
    return response;
  }

  bool _isCrisis(String input) {
    return input.contains("suicide") ||
        input.contains("kill myself") ||
        input.contains("hurt myself") ||
        input.contains("end it all");
  }

  String? _handleEmotions(String input) {
    // Sadness / Depression
    if (input.contains('sad') ||
        input.contains('depressed') ||
        input.contains('unhappy') ||
        input.contains('crying') ||
        input.contains('lonely')) {
      _lastTopic = "sadness";
      return _getRandomResponse([
        "I'm so sorry you're going through this. It sounds really heavy. Do you want to share what made you feel this way?",
        "It's completely okay to feel sad. Sometimes letting it out is the best thing we can do. I'm here to listen.",
        "I hear you. Loneliness and sadness can feel overwhelming. I'm right here with you. What specific thought is bothering you the most?",
        "Sending you a warm metaphorical hug. Would you like to try a distraction, or do you prefer to vent?",
      ]);
    }

    // Anxiety / Stress
    if (input.contains('anxious') ||
        input.contains('worried') ||
        input.contains('nervous') ||
        input.contains('panic') ||
        input.contains('stress')) {
      _lastTopic = "anxiety";
      return _getRandomResponse([
        "I can hear the anxiety in your words. Let's take a moment. Have you tried grounding yourself? Name 5 things you can see right now.",
        "Anxiety is tough, but it will pass. You are safe here. Take a deep breath with me... Inhale... and Exhale...",
        "It's understandable to feel stressed. Is there one small thing we can tackle together, or do you just need to unleash your thoughts?",
        "I'm listening. Sometimes writing it down helps lower the noise in our heads. Tell me everything.",
      ]);
    }

    // Anger / Frustration
    if (input.contains('angry') ||
        input.contains('mad') ||
        input.contains('furious') ||
        input.contains('hate') ||
        input.contains('annoyed')) {
      _lastTopic = "anger";
      return _getRandomResponse([
        "It sounds like you're really frustrated. That's a valid feeling. What triggered this anger provided you're comfortable sharing?",
        "Anger is a powerful emotion. It often tells us something isn't right. What feels unfair to you right now?",
        "I'm here. Let it all out. It's better out than in. What happened?",
      ]);
    }

    // Happiness / Positive
    if (input.contains('happy') ||
        input.contains('good') ||
        input.contains('great') ||
        input.contains('excited') ||
        input.contains('wonderful')) {
      _lastTopic = "happiness";
      return _getRandomResponse([
        "That makes me so happy to hear! It's great to see you in high spirits. What was the highlight of your day?",
        "Yay! I love that for you. Hold onto this feeling. What are you most grateful for right now?",
        "Wonderful! Positive energy is contagious. Keep shining!",
      ]);
    }

    // Tiredness
    if (input.contains('tired') ||
        input.contains('exhausted') ||
        input.contains('sleepy') ||
        input.contains('drained')) {
      _lastTopic = "tiredness";
      return _getRandomResponse([
        "It sounds like you've been carrying a lot lately. Rest is not a reward, it's a necessity. Can you take a short break?",
        "I hear you. Physical and emotional exhaustion are real. Have you been sleeping okay lately?",
        "Please be gentle with yourself. If you can, finding a quiet moment to just close your eyes might help.",
      ]);
    }

    return null;
  }

  String _handleGeneralConversation(String input) {
    // Topic: Relationships
    if (input.contains('friend') ||
        input.contains('partner') ||
        input.contains('family') ||
        input.contains('parent') ||
        input.contains('mom') ||
        input.contains('dad')) {
      return "Relationships can be complex. How are things going with them specifically?";
    }

    // Topic: Work/School
    if (input.contains('work') ||
        input.contains('job') ||
        input.contains('school') ||
        input.contains('study') ||
        input.contains('boss') ||
        input.contains('teacher')) {
      return "Work and school often bring a mix of challenge and stress. Is there a specific situation there that's on your mind?";
    }

    // Action: Joke
    if (input.contains('joke') || input.contains('funny')) {
      return _getRandomResponse([
        "Why don't scientists trust atoms? Because they make up everything!",
        "What do you call a fake noodle? An impasta!",
        "Why did the scarecrow win an award? Because he was outstanding in his field!",
        "What do you call a bear with no teeth? A gummy bear!",
      ]);
    }

    // Action: Thanks
    if (input.contains('thank')) {
      return "You're very welcome. I appreciate you trusting me with your thoughts.";
    }

    // Action: Greeting
    if (input.contains('hi') ||
        input.contains('hello') ||
        input.contains('hey')) {
      return "Hello again! I'm here. What's on your mind?";
    }

    // ELIZA-style Reflection (The "Humanizing" Part)
    // Reflect "I am X" -> "Why do you think you are X?"
    final iAmPattern = RegExp(
      r'\bi\s+(?:am|feel)\s+(.*)',
      caseSensitive: false,
    );
    final match = iAmPattern.firstMatch(input);
    if (match != null && match.groupCount >= 1) {
      String feelingOrState = match.group(1)!.trim();
      // Remove punctuation
      feelingOrState = feelingOrState.replaceAll(RegExp(r'[.!?,]'), '');

      // Filter out weird long captures
      if (feelingOrState.split(' ').length < 8) {
        return _getReflectiveResponse(feelingOrState);
      }
    }

    // Fallback: Open-ended questions to encourage depth
    return _getRandomResponse([
      "I see. Tell me more about that.",
      "That sounds significant. How does that make you feel?",
      "I'm listening. Please go on.",
      "What do you think is the root cause of that?",
      "It's interesting you say that. Why do you think that is?",
      "I understand. What would be the ideal outcome for you?",
    ]);
  }

  String _getReflectiveResponse(String capturedText) {
    List<String> templates = [
      "Why do you feel $capturedText?",
      "How long have you been feeling $capturedText?",
      "It sounds like being $capturedText is really affecting you right now.",
      "Do you often feel $capturedText?",
      "Thank you for sharing that you feel $capturedText. It helps me understand.",
    ];
    return templates[_random.nextInt(templates.length)];
  }

  String _getRandomResponse(List<String> options) {
    return options[_random.nextInt(options.length)];
  }
}
