import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:wanzani/screens/chatscreen/chat_screen.dart';
import 'package:wanzani/screens/commentscreen/comment_screen.dart';
import 'package:wanzani/screens/story/story_view_screen.dart';
import 'package:wanzani/screens/searchscreen/search_screen.dart';
import 'package:wanzani/screens/live/live_stream_page.dart';
import 'package:wanzani/screens/market/market_screen.dart';
import 'package:wanzani/screens/notificationscreen/notifications_screen.dart';
import 'package:wanzani/screens/settingscreen/settings_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final user = FirebaseAuth.instance.currentUser!;
  final db = FirebaseDatabase.instance.ref();
  Set<String> following = {};
  String? _postLocation;
  bool _showLocationField = false;
  final TextEditingController _locationController = TextEditingController();
  String? selectedLocation;
  bool showLocationField = false;
  final List<String> staticLocations = [
    'New York',
    'London',
    'Paris',
    'Tokyo',
    'Dubai',
    'Berlin',
    'Sydney',
    'Cairo',
    'Mumbai',
    'Los Angeles',
    'Toronto',
    'Moscow',
    'Cape Town',
    'Singapore',
    'Istanbul',
  ];
  // Add controller for text post
  final TextEditingController _textPostController = TextEditingController();
  bool _isPostingText = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    db.child('following/$uid').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      setState(() {
        following = data == null ? {} : Set<String>.from(data.keys);
      });
    });
  }

  Stream<List<Map<String, dynamic>>> get _storiesStream =>
      db.child('stories').onValue.map((e) {
        final raw = e.snapshot.value as Map<dynamic, dynamic>? ?? {};
        final cutoff = DateTime.now()
            .subtract(const Duration(hours: 24))
            .toIso8601String();

        return raw.entries
            .map((st) {
              final items = (st.value as Map)
                  .entries
                  .map((it) => Map<String, dynamic>.from(it.value))
                  // Only include stories created in the last 24h
                  .where((m) {
                final createdAt = m['createdAt'] as String?;
                if (createdAt == null) return false;
                return createdAt.compareTo(cutoff) >= 0;
              }).where((m) {
                final u = m['url'] as String?;
                if (u == null || u.isEmpty) return false;
                if (!u.startsWith('http') && !File(u).existsSync())
                  return false;
                return true;
              }).toList()
                ..sort(
                  (a, b) => DateTime.parse(
                    a['createdAt'],
                  ).compareTo(DateTime.parse(b['createdAt'])),
                );
              if (items.isEmpty) return null;
              final latest = items.last;
              return {
                'userId': st.key,
                'userName': latest['userName'],
                'userPhoto': latest['userPhoto'],
                'media': items,
              };
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      });

  Stream<List<Map<String, dynamic>>> get _postsStream =>
      db.child('posts').onValue.map((e) {
        final raw = e.snapshot.value as Map<dynamic, dynamic>? ?? {};
        return raw.entries
            .map(
              (ent) => Map<String, dynamic>.from(ent.value)..['key'] = ent.key,
            )
            .toList()
          ..sort(
            (a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int),
          );
      });

  Future<void> _onYourStoryTap() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await db.child('stories/$uid').push().set({
      'url': picked.path,
      'type': 'photo',
      'createdAt': DateTime.now().toIso8601String(),
      'userName': user.displayName ?? '',
      'userPhoto': user.photoURL ?? '',
    });
  }

  Future<void> _createPost(bool isVideo) async {
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    TextEditingController captionCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isVideo ? 'post_video'.tr() : 'post_photo'.tr()),
        content: TextField(
          controller: captionCtrl,
          decoration: InputDecoration(hintText: 'write_caption'.tr()),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await db.child('posts').push().set({
                'userId': uid,
                'userName': user.displayName ?? '',
                'userPhoto': user.photoURL ?? '',
                'mediaUrl': pickedFile.path,
                'mediaType': isVideo ? 'video' : 'photo',
                'caption': captionCtrl.text.trim(),
                'location': selectedLocation ?? '',
                'likes': 0,
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              });
              setState(() {
                selectedLocation = null;
                _locationController.clear();
              });
            },
            child: Text('post'.tr()),
          ),
        ],
      ),
    );
  }

  void _openStory(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoryViewScreen(media: data['media'])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: _buildTopBar(),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'photo',
            onPressed: () => _createPost(false),
            child: Icon(Icons.photo),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'video',
            onPressed: () => _createPost(true),
            child: Icon(Icons.videocam),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTabBar(),
              SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: _buildStoriesSection(),
              ),
              SizedBox(height: 8),
              _buildCreatePostRow(),
              Divider(height: 1),
              _buildPostsSection(scrollable: false),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCreatePostRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                StreamBuilder<DatabaseEvent>(
                  stream: db.child('users/$uid/photoUrl').onValue,
                  builder: (c, s) {
                    final p = s.data?.snapshot.value as String?;
                    final img = (p != null && File(p).existsSync())
                        ? FileImage(File(p))
                        : const AssetImage('assets/avatar2.png')
                            as ImageProvider;
                    return CircleAvatar(radius: 18, backgroundImage: img);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textPostController,
                    decoration: InputDecoration(
                      hintText: 'Whats on your mind?',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _isPostingText
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.send, color: Colors.blue),
                              onPressed: _textPostController.text.trim().isEmpty
                                  ? null
                                  : () async {
                                      setState(() => _isPostingText = true);
                                      final text =
                                          _textPostController.text.trim();
                                      await db.child('posts').push().set({
                                        'userId': uid,
                                        'userName': user.displayName ?? '',
                                        'userPhoto': user.photoURL ?? '',
                                        'mediaUrl': '',
                                        'mediaType': 'text',
                                        'caption': text,
                                        'location': selectedLocation ?? '',
                                        'likes': 0,
                                        'createdAt': DateTime.now()
                                            .millisecondsSinceEpoch,
                                      });
                                      _textPostController.clear();
                                      setState(() => _isPostingText = false);
                                    },
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _createPost(false),
                  icon: Icon(Icons.photo, color: Colors.grey[700], size: 20),
                  label:
                      Text('Photo', style: TextStyle(color: Colors.grey[700])),
                ),
                TextButton.icon(
                  onPressed: () => _createPost(true),
                  icon: Icon(Icons.videocam, color: Colors.grey[700], size: 20),
                  label:
                      Text('Video', style: TextStyle(color: Colors.grey[700])),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      showLocationField = !showLocationField;
                    });
                  },
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                  label: Text(
                    selectedLocation ?? 'Location',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            if (showLocationField)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Type or select a location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: staticLocations
                            .where((loc) =>
                                _locationController.text.isEmpty ||
                                loc.toLowerCase().contains(
                                    _locationController.text.toLowerCase()))
                            .map((loc) => ActionChip(
                                  label: Text(loc),
                                  onPressed: () {
                                    setState(() {
                                      selectedLocation = loc;
                                      _locationController.text = loc;
                                      showLocationField = false;
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedLocation =
                                    _locationController.text.trim();
                                showLocationField = false;
                              });
                            },
                            child: const Text('Set Location'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedLocation = null;
                                _locationController.clear();
                                showLocationField = false;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _storiesStream,
      builder: (c, snap) {
        if (!snap.hasData) return Center(child: CircularProgressIndicator());
        final list = List<Map<String, dynamic>>.from(snap.data!);
        int idx = list.indexWhere((e) => e['userId'] == uid);
        Map<String, dynamic>? mine;
        if (idx != -1) mine = list.removeAt(idx);

        final items = <Widget>[
          _storyItem(
            photo: user.photoURL ?? '',
            name: 'Your Story',
            isOwn: true,
            hasStory: mine != null,
            mediaData: mine,
          ),
          ...list.map(
            (s) => _storyItem(
              photo: s['userPhoto'] ?? '',
              name: s['userName'] ?? '',
              isOwn: false,
              hasStory: true,
              mediaData: s,
            ),
          ),
        ];
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12),
          children: items,
        );
      },
    );
  }

  Widget _storyItem({
    required String photo,
    required String name,
    required bool isOwn,
    required bool hasStory,
    Map<String, dynamic>? mediaData,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isOwn) {
                if (hasStory &&
                    mediaData != null &&
                    (mediaData['media'] as List).isNotEmpty) {
                  _openStory(mediaData);
                } else {
                  _onYourStoryTap();
                }
              } else if (mediaData != null &&
                  (mediaData['media'] as List).isNotEmpty) {
                _openStory(mediaData);
              }
            },
            child: _storyCircle(photo: photo, isOwn: isOwn, hasStory: hasStory),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: 64,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyCircle({
    required String photo,
    required bool isOwn,
    required bool hasStory,
  }) {
    final provider = photo.startsWith('http')
        ? NetworkImage(photo)
        : FileImage(File(photo)) as ImageProvider;

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(3),
          decoration: hasStory
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.red, Colors.amber]),
                )
              : BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
          child: CircleAvatar(radius: 30, backgroundImage: provider),
        ),
        if (isOwn)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _onYourStoryTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                padding: EdgeInsets.all(4),
                child: Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostsSection({bool scrollable = true}) =>
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: _postsStream,
        builder: (ctx, snap) {
          if (!snap.hasData) return Center(child: CircularProgressIndicator());
          final posts = snap.data!;
          List<Map<String, dynamic>> filteredPosts = posts;
          if (_tabController.index == 1) {
            // Following tab: only show posts from followed users
            filteredPosts =
                posts.where((p) => following.contains(p['userId'])).toList();
          }
          if (scrollable) {
            return ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (_, i) => PostCard(
                data: filteredPosts[i],
                showFollow: filteredPosts[i]['userId'] != uid,
                isFollowing: following.contains(filteredPosts[i]['userId']),
                onFollow: (userId, follow) async {
                  final ref = db.child('following/$uid/$userId');
                  if (follow) {
                    await ref.set(true);
                  } else {
                    await ref.remove();
                  }
                },
              ),
            );
          } else {
            return ListView.builder(
              itemCount: filteredPosts.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => PostCard(
                data: filteredPosts[i],
                showFollow: filteredPosts[i]['userId'] != uid,
                isFollowing: following.contains(filteredPosts[i]['userId']),
                onFollow: (userId, follow) async {
                  final ref = db.child('following/$uid/$userId');
                  if (follow) {
                    await ref.set(true);
                  } else {
                    await ref.remove();
                  }
                },
              ),
            );
          }
        },
      );

  Widget _buildBottomNav() {
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              color: Colors.white,
            ),
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'home'.tr(),
                  isActive: true,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.search,
                  label: 'search'.tr(),
                  isActive: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SearchScreen()),
                  ),
                ),
                SizedBox(width: 60),
                Stack(
                  children: [
                    _buildNavItem(
                      icon: Icons.notifications,
                      label: 'alerts'.tr(),
                      isActive: false,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsScreen(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'profile'.tr(),
                  isActive: false,
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? Colors.blue : Colors.grey;
    final isProfile = icon == Icons.person;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isProfile
                ? CircleAvatar(
                    radius: 14,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  )
                : Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 40, 16, 12), // further increased top padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 24), // made logo smaller
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.group, size: 26), // MSN-like two-person icon
                  onPressed: () {}, // TODO: Add MSN action if needed
                ),
                SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.search, size: 28),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SearchScreen()),
                  ),
                ),
                SizedBox(width: 8),
                // Removed chat icon from top bar
              ],
            ),
          ],
        ),
      );

  Widget _buildTabBar() => TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'for_you'.tr()),
          Tab(text: 'following'.tr()),
          Tab(text: 'TV & Radio'.tr()),
        ],
        onTap: (i) {
          if (i == 2)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LiveStreamPage()),
            ).then((_) => _tabController.index = 0);
          else
            _tabController.index = i;
        },
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        indicatorWeight: 3,
      );
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool showFollow;
  final bool isFollowing;
  final void Function(String userId, bool follow)? onFollow;
  const PostCard(
      {super.key,
      required this.data,
      this.showFollow = false,
      this.isFollowing = false,
      this.onFollow});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _vc;
  late AnimationController _anim;
  late Animation<double> _scaleAnim;
  bool _showHeart = false;
  bool _isLiked = false;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  DatabaseReference likeRef() {
    final key = widget.data['key'] as String;
    return FirebaseDatabase.instance.ref('posts/$key/likedBy/$uid');
  }

  DatabaseReference postRef() {
    final key = widget.data['key'] as String;
    return FirebaseDatabase.instance.ref('posts/$key');
  }

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.8,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    if (widget.data['mediaType'] == 'video') {
      _vc = VideoPlayerController.file(File(widget.data['mediaUrl']))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }

    likeRef().onValue.listen((e) {
      if (mounted) setState(() => _isLiked = e.snapshot.exists);
    });
  }

  @override
  void dispose() {
    _vc?.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _updateLikes(int delta) {
    postRef().child('likes').runTransaction((currentData) {
      int currentLikes = 0;
      if (currentData is int) {
        currentLikes = currentData;
      } else if (currentData is String) {
        currentLikes = int.tryParse(currentData) ?? 0;
      }
      return Transaction.success(currentLikes + delta);
    });
  }

  Future<void> _logLikeNotification() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;
    if (uid == null) return; // no signed-in user

    final postOwnerId = widget.data['userId'] as String?;
    if (postOwnerId == null || postOwnerId == uid) return; // nothing to notify

    // Fetch current user's profile (which contains name/photo override)
    final profileSnap =
        await FirebaseDatabase.instance.ref('users/$uid/profile').get();

    String name = currentUser?.displayName ?? 'Someone';
    String? photo = currentUser?.photoURL;

    if (profileSnap.exists) {
      final userMap = Map<String, dynamic>.from(profileSnap.value as Map);
      name = userMap['name'] ?? name;
      photo = userMap['photoUrl'] ?? photo;
    }

    await FirebaseDatabase.instance.ref('notifications').push().set({
      'type': 'like',
      'fromUserId': uid,
      'fromUserName': name,
      'fromUserPhoto': photo,
      'toUserId': postOwnerId,
      'postId': widget.data['key'],
      'timestamp': now,
      'unread': true,
    });
  }

  void _onDoubleTap() {
    if (!_isLiked) {
      likeRef().set(true);
      _updateLikes(1);
      _logLikeNotification();
      _anim.forward().then((_) => _anim.reverse());
      setState(() => _showHeart = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showHeart = false);
      });
    }
  }

  void _toggleLike() {
    if (_isLiked) {
      likeRef().remove();
      _updateLikes(-1);
    } else {
      likeRef().set(true);
      _updateLikes(1);
      _logLikeNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isVideo = d['mediaType'] == 'video';
    final postUserId = d['userId'] as String?;

    DateTime createdAt;
    final ca = d['createdAt'];
    if (ca is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(ca);
    } else {
      createdAt = DateTime.tryParse(ca.toString()) ?? DateTime.now();
    }
    final subtitleText = '${timeago.format(createdAt)} • Public';

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DataSnapshot>(
                  future: FirebaseDatabase.instance
                      .ref('users/${d['userId']}/profile')
                      .get(),
                  builder: (ctx, snap) {
                    String photoUrl = d['userPhoto'] ?? '';
                    String displayName = d['userName'] ?? 'User';

                    if (snap.hasData && snap.data!.exists) {
                      final u = Map<String, dynamic>.from(
                        snap.data!.value as Map,
                      );
                      photoUrl = u['photoUrl'] ?? photoUrl;
                      displayName = u['name'] ?? displayName;
                      d['userPhoto'] = photoUrl;
                      d['userName'] = displayName;
                    }

                    ImageProvider imageProvider;
                    if (photoUrl.startsWith('http')) {
                      imageProvider = NetworkImage(photoUrl);
                    } else if (photoUrl.isNotEmpty &&
                        File(photoUrl).existsSync()) {
                      imageProvider = FileImage(File(photoUrl));
                    } else {
                      imageProvider = const AssetImage('assets/avatar2.png');
                    }

                    return ListTile(
                      leading: CircleAvatar(backgroundImage: imageProvider),
                      title: Text(displayName),
                      subtitle: Text(subtitleText),
                      trailing: widget.showFollow &&
                              postUserId != null &&
                              widget.onFollow != null
                          ? ElevatedButton(
                              onPressed: () => widget.onFollow!(
                                  postUserId, !widget.isFollowing),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.isFollowing
                                    ? Colors.grey[300]
                                    : Colors.blue,
                                foregroundColor: widget.isFollowing
                                    ? Colors.black
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                  widget.isFollowing ? 'Following' : 'Follow'),
                            )
                          : null,
                    );
                  },
                ),
                if ((d['caption'] as String?)?.isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(d['caption']),
                  ),
                if ((d['location'] as String?)?.isNotEmpty ?? false)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.blue, size: 18),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            d['location'],
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                if (isVideo && _vc?.value.isInitialized == true)
                  AspectRatio(
                    aspectRatio: _vc!.value.aspectRatio,
                    child: VideoPlayer(_vc!),
                  )
                else if (d['mediaType'] == 'photo' &&
                    File(d['mediaUrl']).existsSync())
                  Image.file(
                    File(d['mediaUrl']),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else if (d['mediaType'] == 'photo' || d['mediaType'] == 'video')
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Colors.grey[700],
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${d['likes'] ?? 0}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommentScreen(
                                postKey: d['key'] as String,
                                postOwnerId: d['userId'] as String,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.comment_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${d['commentCount'] ?? 0}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.share_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text('Share', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showHeart)
            ScaleTransition(
              scale: _scaleAnim,
              child: const Icon(Icons.favorite, color: Colors.red, size: 100),
            ),
        ],
      ),
    );
  }
}
