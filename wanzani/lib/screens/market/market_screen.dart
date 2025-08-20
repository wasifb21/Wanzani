import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final dbRef = FirebaseDatabase.instance.ref('stations');
  List<Map<String, dynamic>> stations = [];
  bool loading = true;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _hasAudio = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      print('Firebase snapshot value: $data');
      if (data is Map) {
        final loaded = data.entries.map((e) {
          final value = Map<String, dynamic>.from(e.value as Map);
          return {...value, 'id': e.key};
        }).toList();
        setState(() {
          stations = loaded;
          loading = false;
          print('Loaded stations: $stations');
        });
      } else {
        setState(() {
          stations = [];
          loading = false;
          print('No stations found in Firebase.');
        });
      }
    });
    _player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _hasAudio = state.processingState != ProcessingState.idle;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (stations.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No stations found in Firebase.',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final testStation = {
                    "name": "Synthwave FM",
                    "description":
                        "The ultimate station for retro electronic vibes.",
                    "imageUrl":
                        "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg",
                    "streamUrl":
                        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
                    "badge": "FREE",
                    "views": "4.2M",
                    "location": "New York, USA",
                    "isLive": true
                  };
                  await dbRef.child("featured_station").set(testStation);
                },
                child: const Text("Add Test Station to Firebase (Admin Only)"),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Discover",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Featured Station Card (dynamic)
            if (stations.isNotEmpty) _buildFeaturedCard(stations.first),
            if (stations.isEmpty) _buildFeaturedCard(null),
            const SizedBox(height: 32),
            // Popular Genres (static)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Popular Genres",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text("View All", style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _genreBox("Pop", Colors.pink),
                _genreBox("Rock", Colors.blue),
                _genreBox("Jazz", Colors.green),
                _genreBox("Hip Hop", Colors.orange),
                _genreBox("Electronic", Colors.red),
                _genreBox("Classical", Colors.purple),
              ],
            ),
            const SizedBox(height: 32),
            // Popular Radio Channels (static)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Popular Radio Channels",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text("View All", style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 16),
            _buildRadioChannelCard("600 x 300", "FREE", Colors.green),
            const SizedBox(height: 16),
            _buildRadioChannelCard("600 x 301", "PREMIUM", Colors.purple),
            // --- Trending Section Start ---
            const SizedBox(height: 32),
            Text(
              "Trending",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Today"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("This Week"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("This Month"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Top Trending Radio Station Card (dynamic if available)
            if (stations.isNotEmpty) _buildTrendingStationCard(stations.first),
            if (stations.isEmpty) _buildTrendingStationCard(null),
            const SizedBox(height: 24),
            // Trending by Genre (static)
            const SizedBox(height: 16),
            Text(
              "Trending by Genre",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Container(
                      height: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[700],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "500 x 250\nHip Hop\n15 stations",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Container(
                      height: 120,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[700],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "500 x 250\nElectronic\n22 stations",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // --- Trending Section End ---
            // Trending Radio Shows (static)
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Trending Radio Shows",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text("View All", style: TextStyle(color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrendingRadioShowCard(
              "Morning Buzz",
              "Wake up with the latest hits",
              "FREE",
              Colors.green,
              "Daily • 6-9AM",
              "2.4M views",
            ),
            const SizedBox(height: 16),
            _buildTrendingRadioShowCard(
              "Late Night Vibes",
              "Chill music for night owls",
              "PREMIUM",
              Colors.purple,
              "Daily • 10PM-2AM",
              "1.8M views",
            ),
          ],
        ),
      ),
      floatingActionButton: _hasAudio
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () async {
                if (_isPlaying) {
                  await _player.pause();
                } else {
                  await _player.play();
                }
              },
              child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic>? station) {
    print('Building featured card. Station: $station');
    if (station == null) {
      // fallback to static
      return _staticFeaturedCard();
    }
    final imageUrl = station['imageUrl'] ?? '';
    final name = station['name'] ?? station['title'] ?? '';
    final description = station['description'] ?? '';
    final streamUrl = station['streamUrl'] ?? station['audioUrl'] ?? '';
    final badge = station['badge'] ?? 'FREE';
    final views = station['views'] ?? '4.2M';
    final isLive = station['isLive'] ?? true;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 151, 159, 159),
            Color.fromARGB(255, 84, 83, 86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                print('Image error: $error');
                return Icon(Icons.error, color: Colors.red);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Featured Station",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () async {
                  print('Trying to play: ' + streamUrl);
                  if (streamUrl != '') {
                    try {
                      if (_currentUrl != streamUrl) {
                        await _player.setUrl(streamUrl);
                        _currentUrl = streamUrl;
                      }
                      if (_isPlaying) {
                        await _player.pause();
                      } else {
                        await _player.play();
                      }
                      print('Audio loaded, playing...');
                    } catch (e) {
                      print('Audio error: $e');
                    }
                  } else {
                    print('No stream URL found');
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.25,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.remove_red_eye,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text("$views Views",
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(width: 12),
                Icon(Icons.circle,
                    color: isLive ? Colors.greenAccent : Colors.grey, size: 10),
                const SizedBox(width: 4),
                Text(isLive ? "Now Playing" : "Offline",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    print('Trying to play: ' + streamUrl);
                    if (streamUrl != '') {
                      try {
                        if (_currentUrl != streamUrl) {
                          await _player.setUrl(streamUrl);
                          _currentUrl = streamUrl;
                        }
                        if (_isPlaying) {
                          await _player.pause();
                        } else {
                          await _player.play();
                        }
                        print('Audio loaded, playing...');
                      } catch (e) {
                        print('Audio error: $e');
                      }
                    } else {
                      print('No stream URL found');
                    }
                  },
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? "Pause" : "Play Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  label: const Text("Add to Favorites"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _staticFeaturedCard() {
    // Your original static card code here (copy from your previous version)
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 151, 159, 159),
            Color.fromARGB(255, 84, 83, 86),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                "400 x 400",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Featured Station",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Synthwave FM",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "The ultimate station for retro\nelectronic vibes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "200 × 200",
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "FREE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.25,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.remove_red_eye, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("4.2M Views", style: TextStyle(color: Colors.white70)),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                SizedBox(width: 4),
                Text("Now Playing", style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  label: const Text("Add to Favorites"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _genreBox(String title, Color color) {
    return Container(
      width: 140,
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  static Widget _buildRadioChannelCard(
    String label,
    String badge,
    Color badgeColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.favorite_border, color: Colors.white),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingStationCard(Map<String, dynamic>? station) {
    if (station == null) {
      // fallback to static
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "600 × 350",
                    style: TextStyle(fontSize: 24, color: Colors.black45),
                  ),
                ),
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Chip(
                    label: Text("LIVE"),
                    backgroundColor: Colors.red,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Chip(
                        label: Text("#1 Trending"),
                        backgroundColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Chip(
                        label: Text("FREE"),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Groove Lounge Radio",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text("Funk, Soul & Disco Classics"),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.remove_red_eye, size: 14),
                      SizedBox(width: 4),
                      Text("5.2M views"),
                      SizedBox(width: 12),
                      Icon(Icons.location_pin, size: 14),
                      SizedBox(width: 4),
                      Text("New York, USA"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.music_note, size: 16),
                          SizedBox(width: 4),
                          Text("Now Playing"),
                        ],
                      ),
                      Icon(Icons.play_circle_fill, color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: station['imageUrl'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Positioned(
                top: 8,
                left: 8,
                child: Chip(
                  label: Text("LIVE"),
                  backgroundColor: Colors.red,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    const Chip(
                      label: Text("#1 Trending"),
                      backgroundColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(station['badge'] ?? ''),
                      backgroundColor: (station['badge'] ?? '') == 'FREE'
                          ? Colors.green
                          : Colors.purple,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(station['description'] ?? ''),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye, size: 14),
                    const SizedBox(width: 4),
                    Text("${station['views'] ?? ''} views"),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_pin, size: 14),
                    const SizedBox(width: 4),
                    Text(station['location'] ?? ''),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.music_note, size: 16),
                        SizedBox(width: 4),
                        Text("Now Playing"),
                      ],
                    ),
                    const Icon(Icons.play_circle_fill, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTrendingRadioShowCard(
    String title,
    String subtitle,
    String badge,
    Color badgeColor,
    String timing,
    String views,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Text(
              "200 × 200",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timing,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
