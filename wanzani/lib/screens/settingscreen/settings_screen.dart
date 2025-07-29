import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wanzani/screens/Home/home_screen.dart';
import 'package:wanzani/screens/notificationscreen/notifications_screen.dart';
import 'package:wanzani/screens/personalinformation/personal_info_screen.dart';
import 'package:wanzani/screens/searchscreen/search_screen.dart';
import 'package:wanzani/screens/auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4;
  Locale? _selectedLocale;

  final List<Widget> screens = [
    const HomeScreen(),
    const SearchScreen(),
    const SizedBox.shrink(),
    const NotificationsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedLocale = context.locale;
      });
    });
  }

  void _onTabTapped(int index) {
    if (index == 2) return;
    setState(() => _currentIndex = index);
    if (index != 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screens[index]),
      );
    }
  }

  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
    setState(() => _selectedLocale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "settings".tr(),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _sectionTitle("account".tr()),
          _settingsTile(
            Icons.person,
            "personal_information".tr(),
            bgColor: Colors.greenAccent.shade100,
            iconColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
          ),
          _settingsTile(
            Icons.lock,
            "privacy_security".tr(),
            bgColor: Colors.green.shade100,
            iconColor: Colors.green,
          ),
          _settingsTile(
            Icons.notifications,
            "notifications".tr(),
            bgColor: Colors.purple.shade100,
            iconColor: Colors.purple,
          ),
          _sectionTitle("preferences".tr()),
          _settingsTile(
            Icons.palette,
            "appearance".tr(),
            bgColor: Colors.pink.shade100,
            iconColor: Colors.pink,
          ),
          _settingsTile(
            Icons.language,
            "language".tr(),
            bgColor: Colors.yellow.shade100,
            iconColor: Colors.orange,
            trailing: DropdownButton<Locale>(
              value: _selectedLocale,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text("English")),
                DropdownMenuItem(value: Locale('fr'), child: Text("French")),
              ],
              onChanged: (locale) {
                if (locale != null) _changeLanguage(locale);
              },
            ),
          ),
          _settingsTile(
            Icons.phone,
            "contact_us".tr(),
            bgColor: Colors.red.shade100,
            iconColor: Colors.red,
          ),
          _sectionTitle("about".tr()),
          _settingsTile(
            Icons.help_outline,
            "help_center".tr(),
            iconColor: Colors.black,
            bgColor: Colors.grey.shade200,
          ),
          _settingsTile(
            Icons.privacy_tip,
            "privacy_policy".tr(),
            iconColor: Colors.black,
            bgColor: Colors.grey.shade200,
          ),
          _settingsTile(
            Icons.description,
            "terms_of_service".tr(),
            iconColor: Colors.black,
            bgColor: Colors.grey.shade200,
          ),
          _settingsTile(
            Icons.bolt,
            "app_version".tr(),
            iconColor: Colors.black,
            bgColor: Colors.grey.shade200,
            trailing: const Text(
              "1.0.0 (build 2023.06.21)",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                "logout".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 80,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, "home".tr(), 0),
                  _buildNavItem(Icons.search, "search".tr(), 1),
                  const SizedBox(width: 60),
                  Stack(
                    children: [
                      _buildNavItem(Icons.notifications, "alerts".tr(), 3),
                      Positioned(
                        right: 10,
                        top: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _onTabTapped(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage: AssetImage('assets/avatar.png'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "profile".tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
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
                decoration: const BoxDecoration(
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
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title, {
    Widget? trailing,
    Color? iconColor,
    Color? bgColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor ?? Colors.grey.shade100,
        child: Icon(icon, color: iconColor ?? Colors.blue),
      ),
      title: Text(title),
      trailing: trailing != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: trailing,
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap ?? () {},
    );
  }
}
