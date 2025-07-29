import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../auth/login_screen.dart';
import '../auth/create_account_screen.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top row: Skip + Language selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'skip'.tr(),
                      style: const TextStyle(color: Colors.lightBlue),
                    ),
                  ),
                  // Language Switch Dropdown
                  DropdownButton<Locale>(
                    value: context.locale,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.language, color: Colors.black),
                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text("English"),
                      ),
                      DropdownMenuItem(
                        value: Locale('fr'),
                        child: Text("Français"),
                      ),
                    ],
                    onChanged: (locale) {
                      if (locale != null) {
                        context.setLocale(locale);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Avatar
              const CircleAvatar(
                radius: 80,
                backgroundColor: Color(0xFFF1F1F1),
                backgroundImage: AssetImage('assets/avatar3.png'),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'get_started'.tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'get_started_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const Spacer(),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(false),
                  _buildIndicator(false),
                  _buildIndicator(true),
                ],
              ),

              const SizedBox(height: 24),

              // Create Account button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: Text('create_account'.tr()),
                ),
              ),

              const SizedBox(height: 12),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('login'.tr()),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.lightBlue : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
