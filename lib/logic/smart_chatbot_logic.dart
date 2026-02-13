import '../core/herself_core.dart';
import 'dart:math';

// -----------------------------------------------------------------------------
// Intent Engine: A sophisticated pattern matcher that mimics LLM understanding
// -----------------------------------------------------------------------------
enum Intent {
  greeting,
  farewell,
  anxiety,
  depression,
  anger,
  stress,
  relationship,
  workSchool,
  selfHarm,
  insomnia,
  loneliness,
  positive,
  gratitude,
  confusion,
  affirmation,
  unknown,
}

class ConversationState {
  Intent? lastIntent;
  String? lastTopic;
  int consecutiveMisunderstandings = 0;
  List<String> discussionPoints = [];

  void addPoint(String point) {
    if (!discussionPoints.contains(point)) {
      discussionPoints.add(point);
      if (discussionPoints.length > 3) discussionPoints.removeAt(0);
    }
  }
}

class SmartChatbotLogic {
  final UserState userState;
  final Random _random = Random();
  final ConversationState _state = ConversationState();

  SmartChatbotLogic(this.userState);

  // ---------------------------------------------------------------------------
  // Core Response Logic
  // ---------------------------------------------------------------------------
  String getResponse(String input) {
    if (input.trim().isEmpty) return "I'm listening.";

    String normalizedInput = input.trim().toLowerCase();
    Intent intent = _classifyIntent(normalizedInput);

    // Crisis Check (Always first)
    if (intent == Intent.selfHarm) {
      return _generateCrisisResponse();
    }

    // Contextual Handling
    String response = "";
    if (intent == Intent.unknown) {
      _state.consecutiveMisunderstandings++;
      response = _handleUnknown(normalizedInput);
    } else {
      _state.consecutiveMisunderstandings = 0;
      _state.lastIntent = intent;
      response = _generateResponseForIntent(intent, normalizedInput);
    }

    return response;
  }

  String getInitialGreeting() {
    String timeOfDay = _getTimeOfDay();
    String greeting = "Good $timeOfDay, ${userState.name}.";

    if (userState.mood == 'sad' || userState.mood == 'stressed') {
      return "$greeting I noticed you're feeling a bit down. I'm here to listen. What's on your mind?";
    } else if (userState.energyLevel < 4) {
      return "$greeting You seem a bit low on energy. Remember to take it easy today. How are you feeling right now?";
    } else {
      return "$greeting How are you feeling at this moment?";
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "morning";
    if (hour < 17) return "afternoon";
    return "evening";
  }

  // ---------------------------------------------------------------------------
  // Intent Classification (The "Brain")
  // ---------------------------------------------------------------------------
  Intent _classifyIntent(String input) {
    // Crisis
    if (_matches(input, [
      "suicide",
      "kill myself",
      "die",
      "end it all",
      "hurt myself",
    ]))
      return Intent.selfHarm;

    // Emotions
    if (_matches(input, [
      "anxious",
      "panic",
      "scared",
      "fear",
      "worried",
      "nervous",
    ]))
      return Intent.anxiety;
    if (_matches(input, [
      "sad",
      "depressed",
      "cry",
      "tears",
      "hopeless",
      "blue",
      "down",
    ]))
      return Intent.depression;
    if (_matches(input, [
      "angry",
      "mad",
      "furious",
      "hate",
      "annoyed",
      "irritated",
    ]))
      return Intent.anger;
    if (_matches(input, ["stress", "overwhelmed", "pressure", "too much"]))
      return Intent.stress;
    if (_matches(input, ["lonely", "alone", "nobody", "isolated"]))
      return Intent.loneliness;
    if (_matches(input, [
      "happy",
      "good",
      "great",
      "excited",
      "wonderful",
      "joy",
    ]))
      return Intent.positive;

    // Topics
    if (_matches(input, [
      "work",
      "job",
      "boss",
      "career",
      "school",
      "exam",
      "test",
      "study",
      "teacher",
    ]))
      return Intent.workSchool;
    if (_matches(input, [
      "friend",
      "boyfriend",
      "girlfriend",
      "partner",
      "wife",
      "husband",
      "mom",
      "dad",
      "parent",
      "family",
      "breakup",
      "fight",
    ]))
      return Intent.relationship;
    if (_matches(input, ["sleep", "tired", "insomnia", "awake", "exhausted"]))
      return Intent.insomnia;

    // Flow
    if (_matches(input, ["hi", "hello", "hey", "greetings"]))
      return Intent.greeting;
    if (_matches(input, ["bye", "goodbye", "see ya", "night"]))
      return Intent.farewell;
    if (_matches(input, ["thank", "thanks", "thx"])) return Intent.gratitude;
    if (_matches(input, ["yes", "yeah", "sure", "okay", "right"]))
      return Intent.affirmation;
    if (_matches(input, ["no", "nope", "nah"]))
      return Intent
          .affirmation; // Simple affirmation of negative is still dialog flow

    return Intent.unknown;
  }

  bool _matches(String input, List<String> keywords) {
    for (var word in keywords) {
      if (input.contains(word)) return true;
    }
    return false;
  }

  // ---------------------------------------------------------------------------
  // Response Generation (The "Voice")
  // ---------------------------------------------------------------------------
  String _generateResponseForIntent(Intent intent, String input) {
    switch (intent) {
      case Intent.anxiety:
        return _pick([
          "I hear how anxious you are. It feels overwhelming right now, doesn't it? Let's take a breath together.",
          "Anxiety can be such a heavy weight. I'm right here with you. What is one small thing you can see in the room?",
          "It's okay to feel scared. You are safe here. Can you tell me what triggered this feeling?",
          "Let's slow things down. Deep breath in... and out. What is the scariest part of this situation for you?",
        ]);

      case Intent.depression:
        return _pick([
          "I'm so sorry you're going through this. It sounds incredibly painful. I'm listening.",
          "It takes a lot of strength to even say that. Be gentle with yourself. Do you want to vent or just be distracted?",
          "I hear the sadness in your words. You don't have to carry it all alone. I'm here.",
          "Sometimes the heaviness is just too much. Have you eaten or had water today, ${userState.name}?",
        ]);

      case Intent.anger:
        return _pick([
          "It sounds like you're really frustrated. That's completely valid.",
          "Anger is often a sign that a boundary was crossed. What feels unfair to you right now?",
          "Let it out. It's better to express it here than keep it inside. What triggered this?",
        ]);

      case Intent.stress:
        return _pick([
          "That sounds like a lot to handle. No wonder you're stressed.",
          "When everything piles up, it's hard to breathe. What is the one thing stressing you the most right now?",
          "Take a moment. You are doing the best you can. Is there anything you can put aside for tomorrow?",
        ]);

      case Intent.relationship:
        _state.addPoint("relationships");
        return _pick([
          "Relationships are so complex. They can bring us the most joy and the most pain. Tell me more.",
          "It sounds like this connection is really on your mind. How does this make you feel about yourself?",
          "Communication is often the hardest part. Do you feel heard by them?",
        ]);

      case Intent.workSchool:
        _state.addPoint("work/school");
        return _pick([
          "The pressure to perform can be exhausting. Remember, your worth is not just your productivity.",
          "That sounds intense. Are you getting any time to rest in between?",
          "Is this a temporary deadline, or has it been like this for a while?",
        ]);

      case Intent.insomnia:
        return _pick([
          "Not being able to sleep is frustrated. Your mind often races when it's quiet. What are you thinking about?",
          "Rest is vital, but sometimes sleep just won't come. Have you tried a body scan meditation?",
          "The night can feel long when you're awake. I'm here to keep you company.",
        ]);

      case Intent.positive:
        return _pick([
          "That makes me so happy to hear! Hold onto this feeling.",
          "Wonderful! It's important to celebrate these good moments. What was the best part?",
          "I love seeing you like this! Positivity looks good on you.",
        ]);

      case Intent.greeting:
        return _pick([
          "Hello there. I'm glad you're here. How can I support you today?",
          "Hi! I'm listening. What's on your mind?",
          "Welcome back. I hope your day is treating you gently.",
        ]);

      case Intent.gratitude:
        return _pick([
          "You're very welcome. I'm honored to support you.",
          "I'm always here for you, anytime.",
          "It's my purpose to be here. Thank you for trusting me.",
        ]);

      case Intent.affirmation:
        return "I'm listening. Please go on.";

      default:
        return "I'm here.";
    }
  }

  String _handleUnknown(String input) {
    // If the user talks about something specific we don't know, try ELIZA-style reflection
    final iAmPattern = RegExp(r'\bi\s+(?:am|feel)\s+(.*)');
    final match = iAmPattern.firstMatch(input);
    if (match != null) {
      String feeling = match.group(1)!.trim().replaceAll(RegExp(r'[.!?,]'), '');
      return "Why do you feel $feeling?";
    }

    if (_state.consecutiveMisunderstandings > 2) {
      return "I might be having trouble understanding the specifics, but I care about how you feel. Could you tell me more about the emotions you're experiencing?";
    }

    return _pick([
      "I see. Tell me more about that.",
      "That sounds significant. How does that make you feel?",
      "I'm listening. Please go on.",
      "What do you think is the root cause of that?",
      "It's interesting you say that. Why do you think that is?",
    ]);
  }

  String _generateCrisisResponse() {
    return """
I am an AI, but I care about your safety. It sounds like you are in significant pain.
Please reach out to a professional or emergency services.
You are not alone.
Would you like me to open your emergency contacts list?
""";
  }

  String _pick(List<String> options) {
    return options[_random.nextInt(options.length)];
  }
}
