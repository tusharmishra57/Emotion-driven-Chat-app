import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'home_screen.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final String? errorCode;
  final VoidCallback? onRetry;
  final bool showHomeButton;

  const ErrorScreen({
    super.key,
    this.errorMessage,
    this.errorCode,
    this.onRetry,
    this.showHomeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBackground,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon Animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 1),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 60,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Error Title
                Text(
                  'Oops! Something went wrong',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),

                const SizedBox(height: 16),

                // Error Message
                Text(
                  errorMessage ??
                      'We encountered an unexpected error. Don\'t worry, our team has been notified and we\'re working to fix it.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                if (errorCode != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Error Code: $errorCode',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Ghibli-style illustration placeholder
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '😔',
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ghibli-style sad face',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.primaryPurple,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Action Buttons
                Column(
                  children: [
                    if (onRetry != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                            'Try Again',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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

                    if (onRetry != null && showHomeButton)
                      const SizedBox(height: 16),

                    if (showHomeButton)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _goToHome(context),
                          icon: const Icon(Icons.home_rounded),
                          label: Text(
                            'Go to Home',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryPurple,
                            side:
                                const BorderSide(color: AppTheme.primaryPurple),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Report Issue Button
                    TextButton.icon(
                      onPressed: () => _reportIssue(context),
                      icon: const Icon(Icons.bug_report_rounded),
                      label: Text(
                        'Report Issue',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Help Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'If the problem persists, please contact our support team at support@chatfun.com',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _reportIssue(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Report Issue',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us improve ChatFun by reporting this issue:',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Describe what you were doing when this error occurred...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technical Details:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Error: ${errorMessage ?? "Unknown error"}\n'
                    'Code: ${errorCode ?? "N/A"}\n'
                    'Time: ${DateTime.now().toString()}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Issue reported successfully. Thank you!',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'Send Report',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Error Screen for specific error types
class NetworkErrorScreen extends ErrorScreen {
  const NetworkErrorScreen({super.key})
      : super(
          errorMessage:
              'No internet connection. Please check your network settings and try again.',
          errorCode: 'NETWORK_ERROR',
        );
}

class ServerErrorScreen extends ErrorScreen {
  const ServerErrorScreen({super.key})
      : super(
          errorMessage:
              'Our servers are currently experiencing issues. Please try again in a few minutes.',
          errorCode: 'SERVER_ERROR',
        );
}

class NotFoundErrorScreen extends ErrorScreen {
  const NotFoundErrorScreen({super.key})
      : super(
          errorMessage:
              'The page you\'re looking for doesn\'t exist or has been moved.',
          errorCode: 'NOT_FOUND',
          showHomeButton: true,
        );
}

class PermissionErrorScreen extends ErrorScreen {
  const PermissionErrorScreen({super.key})
      : super(
          errorMessage:
              'Camera or microphone permission is required for emotion recognition. Please enable permissions in settings.',
          errorCode: 'PERMISSION_DENIED',
        );
}
