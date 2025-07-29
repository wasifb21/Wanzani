import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wanzani/screens/live/player_page.dart';

class FeaturedChannelsPage extends StatefulWidget {
  const FeaturedChannelsPage({super.key});

  @override
  State<FeaturedChannelsPage> createState() => _FeaturedChannelsPageState();
}

class _FeaturedChannelsPageState extends State<FeaturedChannelsPage> {
  List<Map<String, dynamic>> _channels = [
    {
      'id': '1',
      'title': 'Sports Channel',
      'subtitle': 'Best Channel',
      'label': 'C1',
      'avatarColor': Colors.blue,
      'viewers': '1234',
      'tag': 'Free',
      'streamUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    },
    {
      'id': '2',
      'title': 'News Channel',
      'subtitle': 'Another Channel',
      'label': 'C2',
      'avatarColor': Colors.red,
      'viewers': '5678',
      'tag': 'Premium',
      'streamUrl':
          'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8',
    },
    {
      'id': '3',
      'title': 'Music Channel',
      'subtitle': 'Fun Channel',
      'label': 'C3',
      'avatarColor': Colors.green,
      'viewers': '4321',
      'tag': 'Free',
      'streamUrl':
          'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
    },
  ];
  List<Map<String, dynamic>> _filteredChannels = [];
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredChannels = List.from(_channels);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChannels = _channels.where((channel) {
        final title = (channel['title'] ?? '').toLowerCase();
        final label = (channel['label'] ?? '').toLowerCase();
        final subtitle = (channel['subtitle'] ?? '').toLowerCase();
        return title.contains(query) ||
            label.contains(query) ||
            subtitle.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      body: SafeArea(
        child: _filteredChannels.isEmpty
            ? const Center(
                child: Text("No channels found",
                    style: TextStyle(color: Colors.white)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: _isSearching
                            ? TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                              )
                            : Text(
                                'Featured Channels'.tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isSearching ? Icons.close : Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isSearching) {
                              _searchController.clear();
                              _filteredChannels = _channels;
                            }
                            _isSearching = !_isSearching;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._filteredChannels
                      .map((channel) => _buildChannelCard(context, channel))
                      .toList(),
                ],
              ),
      ),
    );
  }

  Widget _buildChannelCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 130,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                    child: Icon(Icons.play_circle,
                        size: 50, color: Colors.black54)),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('LIVE'.tr(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        data['viewers'] ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'] ?? '',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(data['subtitle'] ?? '',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: data['avatarColor'],
                      radius: 14,
                      child: Text(
                        (data['label'] ?? '').substring(0, 2),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(data['label'] ?? '',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    Text(
                      data['tag'] ?? '',
                      style: TextStyle(
                        color: (data['tag'] == 'Free')
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (data['tag'] == 'Free') ? Colors.teal : Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlayerPage(streamUrl: data['streamUrl']),
                          ),
                        );
                      },
                      child: Text("Watch".tr(),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
