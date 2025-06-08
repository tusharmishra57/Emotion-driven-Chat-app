import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final VoidCallback? onCancel;

  const LoadingScreen({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
    this.onCancel,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple,
              AppTheme.primaryPink,
              AppTheme.primaryBlue,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Loading Icon
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: AnimatedBuilder(
                          animation: _rotationAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value * 2 * 3.14159,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.face_retouching_natural,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Loading Message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    widget.message ?? 'Loading...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Progress Indicator
                if (widget.showProgress) ...[
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: widget.progress != null
                          ? LinearProgressIndicator(
                              value: widget.progress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            )
                          : LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.progress != null)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '${(widget.progress! * 100).round()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 40),

                // Loading Steps/Tips
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLoadingTips(),
                ),

                const SizedBox(height: 60),

                // Cancel Button
                if (widget.onCancel != null)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextButton(
                      onPressed: widget.onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingTips() {
    final tips = [
      '🎨 Creating beautiful Ghibli-style expressions',
      '😊 Analyzing your emotions with AI',
      '💬 Preparing your chat experience',
      '✨ Adding magical touches to your messages',
      '🌟 Almost ready for fun conversations!',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Did you know?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tips[DateTime.now().millisecond % tips.length],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Specific Loading Screens for different scenarios
class EmotionAnalysisLoadingScreen extends LoadingScreen {
  const EmotionAnalysisLoadingScreen({super.key})
      : super(
          message: 'Analyzing your emotion...',
          showProgress: true,
        );
}

class ChatLoadingScreen extends LoadingScreen {
  const ChatLoadingScreen({super.key})
      : super(
          message: 'Loading chat...',
        );
}

class ConnectionLoadingScreen extends LoadingScreen {
  const ConnectionLoadingScreen({super.key})
      : super(
          message: 'Connecting to ChatFun...',
        );
}

class UploadLoadingScreen extends LoadingScreen {
  final double uploadProgress;

  const UploadLoadingScreen({
    super.key,
    required this.uploadProgress,
  }) : super(
          message: 'Uploading emotion...',
          showProgress: true,
          progress: uploadProgress,
        );
}

// Loading Dialog for overlay loading
class LoadingDialog extends StatelessWidget {
  final String message;
  final bool showProgress;
  final double? progress;

  const LoadingDialog({
    super.key,
    required this.message,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryPurple,
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${(progress! * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void showWithProgress(
      BuildContext context, String message, double progress) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        message: message,
        showProgress: true,
        progress: progress,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
