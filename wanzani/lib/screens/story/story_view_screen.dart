import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> media;
  const StoryViewScreen({super.key, required this.media});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  bool _loading = true;
  bool _disposed = false;
  VideoPlayerController? _vc;
  AnimationController? _anim;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_disposed) return;

    _anim?.stop();
    _anim?.dispose();
    _vc?.removeListener(_listener);
    await _vc?.dispose();
    _vc = null;

    setState(() => _loading = true);

    final media = widget.media[_current];
    final url = media['url'] as String;
    final type = media['type'] as String;

    if (type == 'video') {
      try {
        _vc = url.startsWith('http')
            ? VideoPlayerController.network(url)
            : VideoPlayerController.file(File(url));
        await _vc!.initialize();
        if (_disposed) return;

        _vc!
          ..play()
          ..addListener(_listener);

        _startAnimation(_vc!.value.duration);

        setState(() => _loading = false);
      } catch (_) {
        _next();
      }
    } else {
      final file = File(url);
      if (!url.startsWith('http') && !file.existsSync()) {
        _next();
        return;
      }

      _startAnimation(const Duration(seconds: 4));
      setState(() => _loading = false);
    }
  }

  void _startAnimation(Duration duration) {
    _anim = AnimationController(vsync: this, duration: duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    _anim!.forward();
  }

  void _listener() {
    if (_vc != null &&
        _vc!.value.isInitialized &&
        _vc!.value.position >= _vc!.value.duration &&
        !_disposed) {
      _next();
    }
  }

  void _next() {
    if (_disposed) return;
    if (_current < widget.media.length - 1) {
      setState(() => _current++);
      _load();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _vc?.removeListener(_listener);
    _vc?.dispose();
    _anim?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media[_current];
    final type = media['type'] as String;
    final url = media['url'] as String;

    final file = File(url);
    final provider = url.startsWith('http')
        ? NetworkImage(url)
        : FileImage(file) as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _next,
            child: Center(
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : (type == 'video' && _vc != null)
                  ? AspectRatio(
                      aspectRatio: _vc!.value.aspectRatio,
                      child: VideoPlayer(_vc!),
                    )
                  : Image(
                      image: provider,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              children: List.generate(widget.media.length, (index) {
                final isActive = index == _current;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: LinearProgressIndicator(
                      value: index < _current
                          ? 1
                          : index == _current
                          ? _anim?.value ?? 0
                          : 0,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
