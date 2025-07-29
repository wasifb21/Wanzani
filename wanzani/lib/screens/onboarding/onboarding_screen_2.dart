import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'onboarding_screen3.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen3(),
                        ),
                      );
                    },
                    child: Text(
                      'skip'.tr(),
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                  _buildLanguageDropdown(context),
                ],
              ),

              const SizedBox(height: 40),

              // Avatar
              const CircleAvatar(
                radius: 80,
                backgroundColor: Color(0xFFF1F1F1),
                backgroundImage: AssetImage('assets/avatar2.png'),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'onboard2_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'onboard2_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const Spacer(),

              // Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(false),
                  _buildIndicator(true),
                  _buildIndicator(false),
                ],
              ),

              const SizedBox(height: 24),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen3(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('next'.tr(), style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return DropdownButton<Locale>(
      value: context.locale,
      underline: const SizedBox(),
      icon: const Icon(Icons.language, color: Colors.black),
      onChanged: (Locale? locale) {
        if (locale != null) {
          context.setLocale(locale);
        }
      },
      items: const [
        DropdownMenuItem(value: Locale('en'), child: Text('English')),
        DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
      ],
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
