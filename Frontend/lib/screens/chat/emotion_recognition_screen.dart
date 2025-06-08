import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class EmotionRecognitionScreen extends StatefulWidget {
  const EmotionRecognitionScreen({super.key});

  @override
  State<EmotionRecognitionScreen> createState() =>
      _EmotionRecognitionScreenState();
}

class _EmotionRecognitionScreenState extends State<EmotionRecognitionScreen>
    with TickerProviderStateMixin {
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  bool _showResult = false;
  String _detectedEmotion = '';
  String _ghibliArt = '';

  late AnimationController _pulseController;
  late AnimationController _resultController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  final List<EmotionResult> _emotionHistory = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emotion Recognition',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPurple,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppTheme.primaryPurple,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: AppTheme.primaryPurple,
            onPressed: _showEmotionHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Camera Preview Area
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _buildCameraPreview(),
            ),

            const SizedBox(height: 30),

            // Capture Button
            if (!_showResult) _buildCaptureButton(),

            // Result Display
            if (_showResult) _buildResultDisplay(),

            const SizedBox(height: 30),

            // Instructions
            if (!_isCapturing && !_isAnalyzing && !_showResult)
              _buildInstructions(),

            // Action Buttons
            if (_showResult) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isCapturing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryPurple,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.face_retouching_natural,
                      size: 50,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Capturing your expression...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_isAnalyzing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              'Analyzing emotion...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Creating Ghibli-style artwork',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Camera Preview',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Position your face in the frame',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryPink],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: _captureEmotion,
          child: const Center(
            child: Icon(
              Icons.camera_alt_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Emotion Detected!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Ghibli Art Preview
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _ghibliArt,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _detectedEmotion,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Ghibli-style expression created!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primaryPurple,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'How it works',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '1. Position your face in the camera frame\n'
            '2. Tap the capture button\n'
            '3. Our AI will detect your emotion\n'
            '4. Get a beautiful Ghibli-style expression\n'
            '5. Share it with friends!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _captureAnother,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
              side: const BorderSide(color: AppTheme.primaryPurple),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareEmotion,
            icon: const Icon(Icons.share_rounded),
            label: Text(
              'Share',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _captureEmotion() async {
    setState(() {
      _isCapturing = true;
      _showResult = false;
    });

    _pulseController.repeat(reverse: true);

    // Simulate capture delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isCapturing = false;
      _isAnalyzing = true;
    });

    _pulseController.stop();

    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 3));

    // Mock emotion detection result
    final emotions = [
      'Happy',
      'Sad',
      'Surprised',
      'Angry',
      'Neutral',
      'Excited'
    ];
    final ghibliArts = ['😊', '😢', '😮', '😡', '😐', '🤩'];
    final randomIndex = DateTime.now().millisecond % emotions.length;

    setState(() {
      _isAnalyzing = false;
      _showResult = true;
      _detectedEmotion = emotions[randomIndex];
      _ghibliArt = ghibliArts[randomIndex];
    });

    // Add to history
    _emotionHistory.insert(
        0,
        EmotionResult(
          emotion: _detectedEmotion,
          ghibliArt: _ghibliArt,
          timestamp: DateTime.now(),
        ));

    _resultController.forward();
  }

  void _captureAnother() {
    setState(() {
      _showResult = false;
    });
    _resultController.reset();
  }

  void _shareEmotion() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Share Emotion?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Text(
                  _ghibliArt,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share your $_detectedEmotion expression with friends?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmShare();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'Share',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Emotion shared successfully! 🎉',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showEmotionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Emotion History',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _emotionHistory.length,
                  itemBuilder: (context, index) {
                    final emotion = _emotionHistory[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            emotion.ghibliArt,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        emotion.emotion,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _formatTimestamp(emotion.timestamp),
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () {
                          // Share this emotion
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class EmotionResult {
  final String emotion;
  final String ghibliArt;
  final DateTime timestamp;

  EmotionResult({
    required this.emotion,
    required this.ghibliArt,
    required this.timestamp,
  });
}
