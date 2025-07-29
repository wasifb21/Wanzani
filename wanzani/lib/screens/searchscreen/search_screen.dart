import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wanzani/screens/home/home_screen.dart';
import 'package:wanzani/screens/notificationscreen/notifications_screen.dart';
import 'package:wanzani/screens/settingscreen/settings_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  Map<String, int> searchCounts = {};

  List<String> get trendingTags {
    final sorted = searchCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => '#${e.key}').toList();
  }

  void _onSearch(String value) {
    final search = value.trim();
    if (search.isEmpty) return;
    setState(() {
      recentSearches.remove(search);
      recentSearches.insert(0, search);
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10);
      }
      searchCounts[search] = (searchCounts[search] ?? 0) + 1;
    });
    _searchController.clear();
    // Optionally: trigger actual search logic here
  }

  void _deleteSearch(String search) {
    setState(() {
      recentSearches.remove(search);
    });
  }

  void _clearAll() {
    setState(() {
      recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'search'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'search_hint'.tr(),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _onSearch(_searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'recent_searches'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _clearAll,
                  child: Text(
                    "clear_all".tr(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentSearches.isEmpty)
              Text('no recent search',
                  style: const TextStyle(color: Colors.grey)),
            ...recentSearches.map((search) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 20),
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _deleteSearch(search),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(
              "trending".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trendingTags.isEmpty
                  ? [
                      Text('no trending',
                          style: const TextStyle(color: Colors.grey))
                    ]
                  : trendingTags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: const Color(0xFFF1F1F1),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
                color: Colors.white,
              ),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home,
                    label: "home".tr(),
                    isActive: false,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    ),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.search,
                    label: "search".tr(),
                    isActive: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 60),
                  Stack(
                    children: [
                      _buildNavItem(
                        context,
                        icon: Icons.notifications,
                        label: "alerts".tr(),
                        isActive: false,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
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
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
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
                            color: Colors.grey,
                            fontSize: 12,
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

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? Colors.blue : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
