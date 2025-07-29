import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentScreen extends StatefulWidget {
  final String postKey;
  final String postOwnerId;

  const CommentScreen({
    Key? key,
    required this.postKey,
    required this.postOwnerId,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final db = FirebaseDatabase.instance.ref();
  final _controller = TextEditingController();

  Stream<List<Map<String, dynamic>>> get _commentsStream {
    return db.child('postComments/${widget.postKey}').onValue.map((e) {
      final mp = e.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return mp.entries.map((ent) {
        final d = Map<String, dynamic>.from(ent.value as Map);
        d['key'] = ent.key;
        return d;
      }).toList()..sort(
        (a, b) => (a['timestamp'] as int).compareTo(b['timestamp'] as int),
      );
    });
  }

  Future<void> _postComment(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final now = DateTime.now().millisecondsSinceEpoch;

    final profileSnap = await db.child('users/$uid/profile').get();

    String name = user.displayName ?? 'Someone';
    String? photo = user.photoURL;

    if (profileSnap.exists) {
      final userMap = Map<String, dynamic>.from(profileSnap.value as Map);
      name = userMap['name'] ?? name;
      photo = userMap['photoUrl'] ?? photo;
    }

    // 1️⃣ Add comment with profile data
    await db.child('postComments/${widget.postKey}').push().set({
      'fromUserId': uid,
      'fromUserName': name,
      'fromUserPhoto': photo,
      'text': trimmed,
      'timestamp': now,
    });

    // 2️⃣ Increment comment count
    await db.child('posts/${widget.postKey}/commentCount').runTransaction((
      currentData,
    ) {
      int curr = 0;
      final v = currentData;
      if (v is int) {
        curr = v;
      } else if (v is String) {
        curr = int.tryParse(v) ?? 0;
      }
      return Transaction.success(curr + 1);
    });

    // 3️⃣ Notify post owner
    if (widget.postOwnerId != uid) {
      await db.child('notifications').push().set({
        'type': 'comment',
        'fromUserId': uid,
        'fromUserName': name,
        'fromUserPhoto': photo,
        'toUserId': widget.postOwnerId,
        'postId': widget.postKey,
        'commentText': trimmed,
        'timestamp': now,
        'unread': true,
      });
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _commentsStream,
              builder: (c, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final cm = list[i];
                    final name = cm['fromUserName'] ?? 'Someone';
                    final photo = cm['fromUserPhoto'];
                    ImageProvider avatar = const AssetImage(
                      'assets/avatar.png',
                    );
                    if (photo != null && photo.toString().isNotEmpty) {
                      avatar = photo.startsWith('http')
                          ? NetworkImage(photo)
                          : File(photo).existsSync()
                          ? FileImage(File(photo))
                          : avatar;
                    }

                    return ListTile(
                      leading: CircleAvatar(backgroundImage: avatar),
                      title: Text(name),
                      subtitle: Text(cm['text'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _postComment(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
