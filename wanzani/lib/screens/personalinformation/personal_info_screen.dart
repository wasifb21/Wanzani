// lib/screens/PersonalInfoScreen.dart

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanzani/screens/PaymentMethodScreen/Payment_Method_Screen.dart';
import 'package:wanzani/screens/SubscriptionDetailsScreen/Subscription_Details_Screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final db = FirebaseDatabase.instance.ref();
  User? user;
  Map<String, dynamic>? profile;
  String? photoUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchProfile();
    _listenPhotoUrl();
  }

  void _listenPhotoUrl() {
    if (user == null) return;
    db.child('users/${user!.uid}/photoUrl').onValue.listen((ev) {
      photoUrl = ev.snapshot.value as String?;
      if (mounted) setState(() {});
    });
  }

  Future<void> _fetchProfile() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (doc.exists) {
      profile = doc.data();
      setState(() {});
    }
  }

  Future<void> _pickAndSaveImage({required bool fromCamera}) async {
    final picked = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    final path = picked.path;
    await db.child('users/${user!.uid}/photoUrl').set(path);
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'photoUrl': path,
    }, SetOptions(merge: true));
    await user?.updatePhotoURL(path);
    await user?.reload();
    user = FirebaseAuth.instance.currentUser;
    setState(() => _uploading = false);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('select_from_gallery'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickAndSaveImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text('take_photo'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickAndSaveImage(fromCamera: true);
              },
            ),
            if (photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text('remove_photo'.tr()),
                onTap: () async {
                  Navigator.pop(context);
                  await db.child('users/${user!.uid}/photoUrl').remove();
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({'photoUrl': null}, SetOptions(merge: true));
                  await user?.updatePhotoURL(null);
                  await user?.reload();
                  user = FirebaseAuth.instance.currentUser;
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(
      text: profile?['name'] ?? user?.displayName ?? '',
    );
    final emailController = TextEditingController(
      text: profile?['email'] ?? user?.email ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('edit_profile'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'full_name'.tr()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'email'.tr()),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final newEmail = emailController.text.trim();
              try {
                if (newName.isNotEmpty && newName != user?.displayName) {
                  await user?.updateDisplayName(newName);
                  await db.child('users/${user!.uid}/name').set(newName);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({'name': newName}, SetOptions(merge: true));
                }
                if (newEmail.isNotEmpty && newEmail != user?.email) {
                  await user?.updateEmail(newEmail);
                  await db.child('users/${user!.uid}/email').set(newEmail);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({'email': newEmail}, SetOptions(merge: true));
                }
                await user?.reload();
                user = FirebaseAuth.instance.currentUser;
                await _fetchProfile();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('profile_updated'.tr())));
              } catch (_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('error_updating_profile'.tr())),
                );
              }
            },
            child: Text('update'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = profile?['name'] ?? user?.displayName ?? 'No Name';
    final email = profile?['email'] ?? user?.email ?? '—';
    final phone = profile?['phone'] ?? '—';
    final joined =
        user?.metadata.creationTime?.toLocal().toString().split(' ').first ??
        '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'personal_info'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _showPhotoOptions,
                  child: _uploading ? _loadingAvatar() : _avatar(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'member_since'.tr()}: $joined',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: 300,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                label: Text(
                  'edit_profile'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            _infoRow("email".tr(), email),
            const SizedBox(height: 16),
            _infoRow("phone_number".tr(), phone),
            const SizedBox(height: 16),
            _infoRow("subscription".tr(), "\$9.99/month"),
            const SizedBox(height: 16),
            _infoRow("listening_time".tr(), "143 hours"),
            const SizedBox(height: 16),
            _infoRow("favorite_genre".tr(), "Electronic, Jazz"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubscriptionDetailsScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 17,
                  horizontal: 12,
                ),
              ),
              child: Text(
                "manage_subscription".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
              child: Text(
                "payment_methods".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
              ),
              child: Text(
                "notification_settings".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: 30,
      backgroundImage: (photoUrl != null && File(photoUrl!).existsSync())
          ? FileImage(File(photoUrl!))
          : const AssetImage('assets/avatar.png') as ImageProvider,
    );
  }

  Widget _loadingAvatar() => CircleAvatar(
    radius: 30,
    backgroundColor: Colors.grey.shade200,
    child: const CircularProgressIndicator(),
  );

  Widget _infoRow(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 14, color: Colors.black)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 16)),
    ],
  );
}
