import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wanzani/screens/VerificationProcesspage/VerificationFaqScreen.dart';
import 'package:wanzani/screens/auth/login_screen.dart';
import 'package:wanzani/screens/uploadimage/upload_image_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationProcessScreen extends StatefulWidget {
  const VerificationProcessScreen({super.key});

  @override
  State<VerificationProcessScreen> createState() =>
      _VerificationProcessScreenState();
}

class _VerificationProcessScreenState extends State<VerificationProcessScreen> {
  late final String userId;
  final dbRef = FirebaseDatabase.instance.ref();
  Map<String, String?> uploadedImages = {
    'id_card': null,
    'license': null,
    'certificate': null,
  };
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid ?? 'testUser';
    // No need to call _fetchUploadedImages, will use StreamBuilder
    loading = false;
  }

  void _onImageUploaded(String docType, String imageUrl) {
    setState(() {
      uploadedImages[docType] = imageUrl;
    });
  }

  bool get allUploaded =>
      uploadedImages['id_card'] != null &&
      uploadedImages['license'] != null &&
      uploadedImages['certificate'] != null;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: dbRef.child('verifications/$userId').onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.snapshot.value as Map?;
            uploadedImages['id_card'] =
                data != null ? data['id_card'] as String? : null;
            uploadedImages['license'] =
                data != null ? data['license'] as String? : null;
            uploadedImages['certificate'] =
                data != null ? data['certificate'] as String? : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _stepCircle('1'),
                      const SizedBox(width: 12),
                      Text(
                        'verification_process'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'submit_documents'.tr(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VerificationFaqScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'learn_more'.tr(),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _stepCircle('2'),
                      const SizedBox(width: 12),
                      Text(
                        'upload_documents'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _uploadBox(
                    icon: Icons.credit_card,
                    description: 'upload_id_card'.tr(),
                    docType: 'id_card',
                    context: context,
                    imageUrl: uploadedImages['id_card'],
                    onUploaded: (url) => _onImageUploaded('id_card', url),
                    userId: userId,
                  ),
                  const SizedBox(height: 24),
                  _uploadBox(
                    icon: Icons.insert_drive_file,
                    description: 'upload_license'.tr(),
                    docType: 'license',
                    context: context,
                    imageUrl: uploadedImages['license'],
                    onUploaded: (url) => _onImageUploaded('license', url),
                    userId: userId,
                  ),
                  const SizedBox(height: 24),
                  _uploadBox(
                    icon: Icons.article,
                    description: 'upload_certificates'.tr(),
                    docType: 'certificate',
                    context: context,
                    imageUrl: uploadedImages['certificate'],
                    onUploaded: (url) => _onImageUploaded('certificate', url),
                    userId: userId,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _stepCircle('3'),
                      const SizedBox(width: 12),
                      Text(
                        'verification_status'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'pending_verification'.tr(),
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'reviewing_info'.tr(),
                          style: const TextStyle(color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Image.asset('assets/avatar.png', width: 40, height: 40),
                      const SizedBox(width: 12),
                      Text(
                        'your_profile'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Text(
                      'awaiting_verification'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        'after_verification'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'receive_badge'.tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: allUploaded
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            allUploaded ? Colors.blue : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'submit_button'.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _stepCircle(String number) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _uploadBox({
    required IconData icon,
    required String description,
    required String docType,
    required BuildContext context,
    String? imageUrl,
    required Function(String) onUploaded,
    required String userId,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UploadImageScreen(docType: docType, userId: userId),
                ),
              );
              if (result is String && result.isNotEmpty) {
                onUploaded(result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              imageUrl == null ? 'select_file'.tr() : 'uploaded'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
