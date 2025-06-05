import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/message.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String chatAvatar;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.userName,
    this.chatAvatar = '',
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
    _loadSampleMessages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSampleMessages() {
    // Sample messages for demonstration
    final sampleMessages = [
      Message(
        id: '1',
        text: 'Hey! How are you doing? 😊',
        senderId: 'other',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isMe: false,
      ),
      Message(
        id: '2',
        text: 'I\'m doing great! Just working on some Flutter projects 🚀',
        senderId: 'me',
        timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
        isMe: true,
      ),
      Message(
        id: '3',
        text: 'That sounds awesome! Flutter is so much fun to work with',
        senderId: 'other',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isMe: false,
      ),
      Message(
        id: '4',
        text: 'Absolutely! The hot reload feature is a game changer 🔥',
        senderId: 'me',
        timestamp: DateTime.now().subtract(const Duration(minutes: 23)),
        isMe: true,
      ),
      Message(
        id: '5',
        text: 'Have you tried the new Material 3 design system?',
        senderId: 'other',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isMe: false,
      ),
      Message(
        id: '6',
        text: 'Yes! It looks amazing. The color schemes are so vibrant 🎨',
        senderId: 'me',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        isMe: true,
      ),
    ];

    setState(() {
      _messages.addAll(sampleMessages);
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      senderId: 'me',
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate response after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _simulateResponse();
    });
  }

  void _simulateResponse() {
    final responses = [
      'That\'s interesting! 🤔',
      'I totally agree! 👍',
      'Haha, that\'s funny! 😄',
      'Tell me more about that!',
      'Sounds great! 🎉',
      'I see what you mean 💭',
      'That\'s awesome! ⭐',
    ];

    final randomResponse =
        responses[DateTime.now().millisecond % responses.length];

    final responseMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: randomResponse,
      senderId: 'other',
      timestamp: DateTime.now(),
      isMe: false,
    );

    setState(() {
      _messages.add(responseMessage);
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return MessageBubble(
                      message: message,
                      showAvatar: _shouldShowAvatar(index),
                      showTimestamp: _shouldShowTimestamp(index),
                    );
                  },
                ),
              ),
            ),

            // Chat Input
            ChatInput(
              controller: _messageController,
              onSendMessage: _sendMessage,
              onAttachFile: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '📎 File attachment coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.primaryBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              onVoiceMessage: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '🎤 Voice messages coming soon!',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primaryPurple,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios),
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isOnline ? AppTheme.primaryGreen : Colors.grey,
                width: 2,
              ),
            ),
            child: widget.chatAvatar.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      widget.chatAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    ),
                  )
                : _buildDefaultAvatar(),
          ),

          const SizedBox(width: 12),

          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isOnline ? 'Online' : 'Last seen recently',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '📞 Voice call coming soon!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppTheme.primaryBlue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          icon: const Icon(Icons.call),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            foregroundColor: AppTheme.primaryBlue,
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '📹 Video call coming soon!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppTheme.primaryPink,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          icon: const Icon(Icons.videocam),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
            foregroundColor: AppTheme.primaryPink,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '⚙️ $value coming soon!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppTheme.primaryOrange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'View Profile',
              child: Text('View Profile'),
            ),
            const PopupMenuItem(
              value: 'Media & Files',
              child: Text('Media & Files'),
            ),
            const PopupMenuItem(
              value: 'Search',
              child: Text('Search'),
            ),
            const PopupMenuItem(
              value: 'Mute',
              child: Text('Mute'),
            ),
            const PopupMenuItem(
              value: 'Block',
              child: Text('Block'),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      color: Colors.white,
      size: 24,
    );
  }

  bool _shouldShowAvatar(int index) {
    if (index == _messages.length - 1) return true;

    final currentMessage = _messages[index];
    final nextMessage = _messages[index + 1];

    return currentMessage.isMe != nextMessage.isMe;
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];

    final timeDifference = currentMessage.timestamp
        .difference(previousMessage.timestamp)
        .inMinutes;

    return timeDifference > 5;
  }
}
