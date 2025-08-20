import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'player_page.dart';

class ExploreChannelsPage extends StatefulWidget {
  const ExploreChannelsPage({super.key});

  @override
  State<ExploreChannelsPage> createState() => _ExploreChannelsPageState();
}

class _ExploreChannelsPageState extends State<ExploreChannelsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<_ChannelData> _filteredChannels = [];
  late final List<_ChannelData> _allChannels;

  @override
  void initState() {
    super.initState();
    _allChannels = [
      _ChannelData(
          "Sports Central",
          "Sports Network",
          "NBA Finals",
          "Premium",
          "SC",
          "24.5K",
          "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
      _ChannelData("World News 24", "Global Media", "Breaking News", "Free",
          "WN", "18.2K", "https://www.cbsnews.com/live/"),
      _ChannelData(
          "Entertainment Plus",
          "EntMedia Group",
          "Celebrity Showdown",
          "Premium",
          "EP",
          "15.7K",
          "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"),
      _ChannelData(
          "Movie Central",
          "FilmStream",
          "Action Classics",
          "Free",
          "MC",
          "9.8K",
          "https://test-streams.mux.dev/bbb_720p_30fps_128kbit.m3u8"),
      _ChannelData(
          "Kids Zone",
          "KidMedia",
          "Cartoon Adventures",
          "Free",
          "KZ",
          "13.4K",
          "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"),
      _ChannelData("Football Hub", "SportsNet", "Premier League", "Premium",
          "FH", "21.2K", "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"),
      _ChannelData(
          "Cooking Network",
          "FoodMedia",
          "Master Chef Live",
          "Free",
          "CN",
          "14.7K",
          "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8"),
      _ChannelData(
          "Cinema Plus",
          "FilmStream Pro",
          "Sci-Fi Marathon",
          "Premium",
          "CP",
          "10.5K",
          "https://test-streams.mux.dev/bbb_720p_30fps_128kbit.m3u8"),
    ];
    _filteredChannels = List.from(_allChannels);

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredChannels = _allChannels
            .where((channel) => channel.title.toLowerCase().contains(query))
            .toList();
      });
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Text(
                "TV Channels".tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFilterChip("All Channels".tr()),
                _buildFilterChip("Sports".tr()),
                _buildFilterChip("News".tr()),
                _buildFilterChip("Entertainment".tr()),
                _buildFilterChip("Movies".tr()),
                _buildFilterChip("Kids".tr()),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildMostPopularButton(),
            const SizedBox(height: 16),
            ..._filteredChannels
                .map((channel) => _buildChannelCard(context, channel)),
            const SizedBox(height: 24),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Chip(
      backgroundColor: const Color.fromARGB(255, 138, 189, 213),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 153, 205, 229),
        hintText: 'Search channels...'.tr(),
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }

  Widget _buildMostPopularButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
      child: Text("Most Popular".tr(),
          style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildChannelCard(BuildContext context, _ChannelData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 130,
            color: Colors.black45,
            child: Stack(
              children: [
                const Center(
                  child:
                      Icon(Icons.play_circle, color: Colors.white54, size: 50),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("LIVE".tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(data.viewers,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color.fromARGB(255, 158, 207, 230),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("sc  ${data.subtitle}".tr(),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                Text("Airing: ${data.airing}".tr(),
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 14,
                      child: Text(data.initials,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.subscription,
                      style: TextStyle(
                        color: data.subscription == "Free"
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlayerPage(streamUrl: data.streamUrl),
                          ),
                        );
                      },
                      child: Text("Watch Now".tr(),
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

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(6),
          ),
          child:
              Text("${index + 1}", style: const TextStyle(color: Colors.white)),
        );
      })
        ..add(
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text("10", style: TextStyle(color: Colors.white)),
          ),
        ),
    );
  }
}

class _ChannelData {
  final String title;
  final String subtitle;
  final String airing;
  final String subscription;
  final String initials;
  final String viewers;
  final String streamUrl;

  _ChannelData(
    this.title,
    this.subtitle,
    this.airing,
    this.subscription,
    this.initials,
    this.viewers,
    this.streamUrl,
  );
}
