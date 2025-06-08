import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  bool _emotionSharingEnabled = true;
  bool _autoSaveEmotions = true;
  bool _faceDetectionEnabled = true;
  double _emotionSensitivity = 0.7;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese'
  ];
  final List<String> _themes = ['Light', 'Dark', 'System'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 16),
            _buildSettingCard([
              _buildSwitchTile(
                'Push Notifications',
                'Receive notifications for new messages',
                Icons.notifications_rounded,
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildSwitchTile(
                'Sound',
                'Play sound for notifications',
                Icons.volume_up_rounded,
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
              ),
              _buildSwitchTile(
                'Vibration',
                'Vibrate for notifications',
                Icons.vibration_rounded,
                _vibrationEnabled,
                (value) => setState(() => _vibrationEnabled = value),
              ),
            ]),

            const SizedBox(height: 30),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 16),
            _buildSettingCard([
              _buildDropdownTile(
                'Theme',
                'Choose your preferred theme',
                Icons.palette_rounded,
                _selectedTheme,
                _themes,
                (value) => setState(() => _selectedTheme = value!),
              ),
              _buildDropdownTile(
                'Language',
                'Select your language',
                Icons.language_rounded,
                _selectedLanguage,
                _languages,
                (value) => setState(() => _selectedLanguage = value!),
              ),
            ]),

            const SizedBox(height: 30),

            // Emotion Recognition Section
            _buildSectionHeader('Emotion Recognition'),
            const SizedBox(height: 16),
            _buildSettingCard([
              _buildSwitchTile(
                'Face Detection',
                'Enable real-time face detection',
                Icons.face_retouching_natural,
                _faceDetectionEnabled,
                (value) => setState(() => _faceDetectionEnabled = value),
              ),
              _buildSwitchTile(
                'Auto-save Emotions',
                'Automatically save detected emotions',
                Icons.save_rounded,
                _autoSaveEmotions,
                (value) => setState(() => _autoSaveEmotions = value),
              ),
              _buildSliderTile(
                'Emotion Sensitivity',
                'Adjust emotion detection sensitivity',
                Icons.tune_rounded,
                _emotionSensitivity,
                (value) => setState(() => _emotionSensitivity = value),
              ),
            ]),

            const SizedBox(height: 30),

            // Privacy Section
            _buildSectionHeader('Privacy & Security'),
            const SizedBox(height: 16),
            _buildSettingCard([
              _buildSwitchTile(
                'Emotion Sharing',
                'Allow sharing emotions with friends',
                Icons.share_rounded,
                _emotionSharingEnabled,
                (value) => setState(() => _emotionSharingEnabled = value),
              ),
              _buildActionTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip_rounded,
                () => _showPrivacyPolicy(),
              ),
              _buildActionTile(
                'Data Management',
                'Manage your data and downloads',
                Icons.storage_rounded,
                () => _showDataManagement(),
              ),
              _buildActionTile(
                'Block List',
                'Manage blocked users',
                Icons.block_rounded,
                () => _showBlockList(),
              ),
            ]),

            const SizedBox(height: 30),

            // Support Section
            _buildSectionHeader('Support & About'),
            const SizedBox(height: 16),
            _buildSettingCard([
              _buildActionTile(
                'Help Center',
                'Get help and support',
                Icons.help_rounded,
                () => _showHelpCenter(),
              ),
              _buildActionTile(
                'Report a Bug',
                'Report issues or bugs',
                Icons.bug_report_rounded,
                () => _reportBug(),
              ),
              _buildActionTile(
                'Rate App',
                'Rate us on the app store',
                Icons.star_rounded,
                () => _rateApp(),
              ),
              _buildActionTile(
                'About',
                'App version and information',
                Icons.info_rounded,
                () => _showAbout(),
              ),
            ]),

            const SizedBox(height: 30),

            // Danger Zone
            _buildSectionHeader('Danger Zone'),
            const SizedBox(height: 16),
            _buildSettingCard([
              _buildActionTile(
                'Clear Cache',
                'Clear app cache and temporary files',
                Icons.cleaning_services_rounded,
                () => _clearCache(),
                isDestructive: false,
              ),
              _buildActionTile(
                'Reset Settings',
                'Reset all settings to default',
                Icons.restore_rounded,
                () => _resetSettings(),
                isDestructive: true,
              ),
              _buildActionTile(
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever_rounded,
                () => _deleteAccount(),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryPurple,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryPurple,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryPurple,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryPurple,
            inactiveColor: AppTheme.primaryPurple.withOpacity(0.3),
            divisions: 10,
            label: '${(value * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryPurple,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDestructive ? Colors.red : Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showPrivacyPolicy() {
    _showInfoDialog('Privacy Policy',
        'Your privacy is important to us. We collect and use your data responsibly to provide the best emotion recognition experience.');
  }

  void _showDataManagement() {
    _showInfoDialog('Data Management',
        'Manage your stored emotions, chat history, and download your data.');
  }

  void _showBlockList() {
    _showInfoDialog('Block List',
        'Currently no blocked users. You can block users from their profile or chat.');
  }

  void _showHelpCenter() {
    _showInfoDialog('Help Center',
        'Need help? Contact us at support@chatfun.com or visit our FAQ section.');
  }

  void _reportBug() {
    _showInfoDialog('Report a Bug',
        'Found a bug? Please describe the issue and we\'ll fix it as soon as possible.');
  }

  void _rateApp() {
    _showInfoDialog('Rate App',
        'Love ChatFun? Please rate us on the app store to help others discover our app!');
  }

  void _showAbout() {
    _showInfoDialog('About ChatFun',
        'ChatFun v1.0.0\n\nAn emotion-driven chat application with Ghibli-style expressions.\n\nDeveloped with ❤️ for authentic digital communication.');
  }

  void _clearCache() {
    _showConfirmDialog(
      'Clear Cache',
      'This will clear all cached data and temporary files. Continue?',
      () {
        _showSuccessMessage('Cache cleared successfully!');
      },
    );
  }

  void _resetSettings() {
    _showConfirmDialog(
      'Reset Settings',
      'This will reset all settings to their default values. Continue?',
      () {
        setState(() {
          _notificationsEnabled = true;
          _soundEnabled = true;
          _vibrationEnabled = true;
          _darkModeEnabled = false;
          _emotionSharingEnabled = true;
          _autoSaveEmotions = true;
          _faceDetectionEnabled = true;
          _emotionSensitivity = 0.7;
          _selectedLanguage = 'English';
          _selectedTheme = 'System';
        });
        _showSuccessMessage('Settings reset to default!');
      },
    );
  }

  void _deleteAccount() {
    _showConfirmDialog(
      'Delete Account',
      'This will permanently delete your account and all data. This action cannot be undone. Continue?',
      () {
        _showSuccessMessage(
            'Account deletion initiated. You will receive a confirmation email.');
      },
      isDestructive: true,
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm,
      {bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.poppins(),
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
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? Colors.red : AppTheme.primaryPurple,
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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
}
