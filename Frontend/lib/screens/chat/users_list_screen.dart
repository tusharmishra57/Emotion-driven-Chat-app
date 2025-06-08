import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';

  final List<User> _allUsers = [
    User(
      id: '1',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      avatar: '👩‍🦰',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
      bio: 'Love sharing emotions! 😊',
      mutualFriends: 5,
      recentEmotion: '😊',
    ),
    User(
      id: '2',
      name: 'Bob Smith',
      email: 'bob@example.com',
      avatar: '👨‍🦱',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
      bio: 'Ghibli art enthusiast 🎨',
      mutualFriends: 3,
      recentEmotion: '🎨',
    ),
    User(
      id: '3',
      name: 'Carol Davis',
      email: 'carol@example.com',
      avatar: '👩‍🦳',
      isOnline: true,
      lastSeen: DateTime.now(),
      bio: 'Always happy to chat! 💬',
      mutualFriends: 8,
      recentEmotion: '💬',
    ),
    User(
      id: '4',
      name: 'David Wilson',
      email: 'david@example.com',
      avatar: '👨‍🦲',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      bio: 'Emotion recognition expert',
      mutualFriends: 2,
      recentEmotion: '🤔',
    ),
    User(
      id: '5',
      name: 'Emma Brown',
      email: 'emma@example.com',
      avatar: '👩‍🦱',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      bio: 'Creative soul ✨',
      mutualFriends: 12,
      recentEmotion: '✨',
    ),
  ];

  final List<User> _friends = [];
  final List<User> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeUsers();
  }

  void _initializeUsers() {
    // Simulate friends and suggestions
    _friends.addAll(_allUsers.take(3));
    _suggestions.addAll(_allUsers.skip(3));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<User> get _filteredUsers {
    final currentTab = _tabController.index;
    List<User> users;

    switch (currentTab) {
      case 0:
        users = _allUsers;
        break;
      case 1:
        users = _friends;
        break;
      case 2:
        users = _suggestions;
        break;
      default:
        users = _allUsers;
    }

    if (_searchQuery.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.bio.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPurple,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            color: AppTheme.primaryPurple,
            onPressed: _showAddFriendDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryPurple,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          onTap: (index) {
            setState(() {});
          },
          tabs: const [
            Tab(text: 'All Users'),
            Tab(text: 'Friends'),
            Tab(text: 'Suggestions'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Users List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList(_filteredUsers),
                _buildUsersList(_filteredUsers),
                _buildUsersList(_filteredUsers),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInviteFriendsDialog,
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(
          Icons.share_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUsersList(List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty ? 'No users found' : 'No users available',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Try a different search term',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: user.isOnline
                              ? AppTheme.primaryGreen
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.avatar,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    if (user.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            user.recentEmotion,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.bio,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            user.isOnline
                                ? Icons.circle
                                : Icons.access_time_rounded,
                            size: 12,
                            color: user.isOnline
                                ? AppTheme.primaryGreen
                                : Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isOnline
                                ? 'Online'
                                : _formatLastSeen(user.lastSeen),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (user.mutualFriends > 0) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.people_rounded,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.mutualFriends} mutual',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startChat(user),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: Text(
                      'Chat',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryPurple,
                      side: const BorderSide(color: AppTheme.primaryPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addFriend(user),
                    icon: Icon(
                      _friends.contains(user)
                          ? Icons.person_remove_rounded
                          : Icons.person_add_rounded,
                    ),
                    label: Text(
                      _friends.contains(user) ? 'Remove' : 'Add Friend',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _friends.contains(user)
                          ? Colors.red
                          : AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _startChat(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: 'chat_${user.id}',
          userName: user.name,
        ),
      ),
    );
  }

  void _addFriend(User user) {
    setState(() {
      if (_friends.contains(user)) {
        _friends.remove(user);
        if (!_suggestions.contains(user)) {
          _suggestions.add(user);
        }
      } else {
        _friends.add(user);
        _suggestions.remove(user);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _friends.contains(user)
              ? '${user.name} added to friends!'
              : '${user.name} removed from friends',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _friends.contains(user)
            ? AppTheme.primaryGreen
            : AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add Friend',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email or Username',
                hintText: 'Enter email or username',
                prefixIcon: Icon(Icons.person_search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You can also share your profile to invite friends!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
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
                    'Friend request sent!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
            ),
            child: Text(
              'Send Request',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteFriendsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Invite Friends',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.share_rounded,
                    size: 48,
                    color: AppTheme.primaryPurple,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share ChatFun with your friends!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite them to experience emotion-driven conversations with Ghibli-style expressions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                    'Invitation shared successfully!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
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
}

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final bool isOnline;
  final DateTime lastSeen;
  final String bio;
  final int mutualFriends;
  final String recentEmotion;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.isOnline,
    required this.lastSeen,
    required this.bio,
    required this.mutualFriends,
    required this.recentEmotion,
  });
}
