import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final VoidCallback? onAttachFile;
  final VoidCallback? onVoiceMessage;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.onAttachFile,
    this.onVoiceMessage,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with TickerProviderStateMixin {
  bool _isTyping = false;
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
      
      if (_isTyping) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _sendMessage() {
    if (widget.controller.text.trim().isNotEmpty) {
      widget.onSendMessage(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attach button
            IconButton(
              onPressed: widget.onAttachFile,
              icon: const Icon(Icons.attach_file),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                foregroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isTyping 
                        ? AppTheme.primaryPurple.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    // Emoji button
                    IconButton(
                      onPressed: () {
                        // Add emoji picker functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '😊 Emoji picker coming soon!',
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
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                    ),
                    
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    
                    // Camera button
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '📷 Camera coming soon!',
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
                      icon: const Icon(Icons.camera_alt_outlined),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send/Voice button
            AnimatedBuilder(
              animation: _sendButtonAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _isTyping ? _sendMessage : widget.onVoiceMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isTyping
                            ? [AppTheme.primaryPurple, AppTheme.primaryPink]
                            : [AppTheme.primaryGreen, AppTheme.primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (_isTyping 
                              ? AppTheme.primaryPurple 
                              : AppTheme.primaryGreen).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * _sendButtonAnimation.value),
                      child: Icon(
                        _isTyping ? Icons.send : Icons.mic,
                        color: Colors.white,
                        size: 20,
                      ),
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
}