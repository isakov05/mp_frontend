import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  final double? confidence;
  final String? predictedLabel;

  const ChatScreen({
    super.key,
    this.initialMessage,
    this.confidence,
    this.predictedLabel,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  bool historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _loadHistory();

    // If ChatScreen was opened from Prediction page
    if (widget.initialMessage != null) {
      messages.add({"role": "user", "text": widget.initialMessage!});
      _scrollToBottom();

      _sendInitialAI();
    }
  }

  // ====================================
  // 🔹 Load chat history from backend
  // ====================================
  Future<void> _loadHistory() async {
    final history = await ChatService.loadHistory();

    setState(() {
      messages = history
          .map((h) => {
                "role": h["role"],
                "text": h["content"],
              })
          .toList();
      historyLoaded = true;
    });

    _scrollToBottom();
  }

  // ====================================
  // 🔹 Handle first AI message
  // ====================================
  Future<void> _sendInitialAI() async {
    setState(() => isLoading = true);

    final response = await ChatService.sendMessage(
      message: widget.initialMessage!,
      confidence: widget.confidence,
      predictedLabel: widget.predictedLabel,
    );

    _handleAIResponse(response);
  }

  // ====================================
  // 🔹 Handle user message
  // ====================================
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || isLoading) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    final response = await ChatService.sendMessage(message: text);

    _handleAIResponse(response);
  }

  // ====================================
  // 🔹 Add AI reply + system log
  // ====================================
  void _handleAIResponse(Map<String, dynamic> response) {
    final reply = response["reply"] ?? "No response";
    final logged = response["logged"] ?? false;

    setState(() {
      messages.add({"role": "ai", "text": reply});

      if (logged == true) {
        messages.add({
          "role": "system",
          "text": "✔️ Food logged automatically by NutriChat AI!",
        });
      }

      isLoading = false;
    });

    _scrollToBottom();
  }

  // ====================================
  // 🔹 Scroll to bottom helper
  // ====================================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ====================================
  // 🔹 UI Layout
  // ====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NutriChat AI"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: historyLoaded
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isLoading) {
                        return _typingIndicator();
                      }

                      final msg = messages[index];
                      final isUser = msg["role"] == "user";
                      final isSystem = msg["role"] == "system";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.green.shade600
                                : isSystem
                                    ? Colors.orange.shade200
                                    : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg["text"],
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("NutriChat is thinking..."),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: "Ask NutriChat...",
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              backgroundColor: Colors.green,
              radius: 24,
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          )
        ],
      ),
    );
  }
}
