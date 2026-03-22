import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final List<_ChatMsg> _messages = [
    _ChatMsg(
      text:
          "Hi! I'm PlanGo AI 🇱🇰 Your Sri Lanka travel expert! I can help you plan the perfect itinerary, discover hidden gems, find guesthouses, and answer any question about travelling Sri Lanka. Where shall we start?",
      isAi: true,
    ),
  ];

  final List<String> _quickPrompts = [
    '🗺️ Plan a 7-day itinerary',
    '🏖️ Best beaches in Sri Lanka',
    '🐆 Yala safari tips',
    '🏨 Budget guesthouses',
    '🍛 Sri Lankan food guide',
    '🚂 Scenic train routes',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(text: text.trim(), isAi: false));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMsg(text: _getAiResponse(text), isAi: true));
      });
      _scrollToBottom();
    });
  }

  String _getAiResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('sri lanka') ||
        lower.contains('sigiriya') ||
        lower.contains('colombo')) {
      return "Sri Lanka is incredible! 🇱🇰 I recommend:\n\n• **Sigiriya** – Ancient rock fortress, a must-see\n• **Galle** – Colonial fort city by the sea\n• **Ella** – Scenic hill country & tea plantations\n• **Mirissa** – Beautiful whale watching beach\n\nThe best time to visit the west & south coast is November–April. Would you like a detailed itinerary?";
    } else if (lower.contains('hotel') ||
        lower.contains('stay') ||
        lower.contains('accommodation')) {
      return "Sri Lanka has accommodation for every budget! 🏨\n\n• **Budget**: Guesthouses from \$12/night\n• **Mid-range**: Boutique eco-lodges \$40–100/night\n• **Luxury**: Aman Resorts & Geoffrey Bawa hotels from \$250/night\n\nI can suggest options by region. Which part of Sri Lanka are you heading to?";
    } else if (lower.contains('beach')) {
      return "Sri Lanka has over 1,600km of coastline! 🏖️\n\n• **Mirissa** – Blue whale watching (Nov–Apr)\n• **Unawatuna** – Calm snorkelling waters\n• **Arugam Bay** – World top-10 surf spot\n• **Nilaveli** – Pristine white sand, Pigeon Island\n• **Bentota** – Water sports & luxury resorts\n\nThe south coast is best Nov–Apr; east coast May–Sep.";
    } else if (lower.contains('itinerary') ||
        lower.contains('plan') ||
        lower.contains('trip')) {
      return "I'd love to help plan your trip! 🗺️ Let me know:\n\n1. How many days do you have?\n2. What's your budget range?\n3. What interests you most – nature, culture, beaches, adventure?\n\nI'll create a perfect day-by-day itinerary for you!";
    } else if (lower.contains('food') ||
        lower.contains('eat') ||
        lower.contains('restaurant')) {
      return "Sri Lankan cuisine is sensational! 🍛\n\n• **Rice & Curry** – The national dish; try at a local amma's kitchen\n• **Kottu Roti** – Chopped roti stir-fry, best street food\n• **Hoppers (Appam)** – Crispy bowl-shaped crepes with egg\n• **String Hoppers** – Steamed rice noodle nests\n• **Pol Sambol** – Spicy coconut relish\n\nAverage meal: \$2–5 at a local spot. Want tips for a specific city?";
    } else {
      return "Great question! As your Sri Lanka travel expert, I can help with:\n\n• 🗺️ Destination recommendations within Sri Lanka\n• 📅 Day-by-day itinerary planning\n• 🏨 Guesthouse & hotel suggestions\n• 🍛 Local food & cultural tips\n• 💰 Budget planning in LKR & USD\n• 🚂 Train, bus & tuk-tuk transport tips\n\nWhat would you like to know more about?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  if (_isTyping && i == _messages.length) {
                    return const _TypingIndicator();
                  }
                  return _BubbleWidget(msg: _messages[i]);
                },
              ),
            ),
            _buildQuickPrompts(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12)),
              child:
                  const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PlanGo AI',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Row(
                  children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: AppColors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('Online',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: AppColors.green,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.more_vert,
                color: AppColors.textPrimary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickPrompts.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(_quickPrompts[i]),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(_quickPrompts[i],
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _sendMessage,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask me anything about travel...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: const Icon(Icons.mic_outlined,
                    color: AppColors.grey, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isAi;
  _ChatMsg({required this.text, required this.isAi});
}

class _BubbleWidget extends StatelessWidget {
  final _ChatMsg msg;
  const _BubbleWidget({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            msg.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (msg.isAi) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: msg.isAi ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isAi ? 4 : 18),
                  bottomRight: Radius.circular(msg.isAi ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 6)
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: msg.isAi ? AppColors.textPrimary : Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!msg.isAi) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  3,
                  (i) => AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, __) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(
                                0.3 + (_ctrl.value * 0.7 * (i == 1 ? 1 : 0.6))),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }
} // ai assistant built by amaya
