import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PanicScreen extends StatefulWidget {
  const PanicScreen({super.key});

  @override
  _PanicScreenState createState() => _PanicScreenState();
}

class _PanicScreenState extends State<PanicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playAudio() async {
    try {
      Source audioSource = AssetSource('panic.mp3');
      await _audioPlayer.setSourceAsset('panic.mp3');
      await _audioPlayer.play(
        audioSource,
        volume: 1.0,
        balance: 0.0,
        position: Duration.zero,
        mode: PlayerMode.mediaPlayer,
      );
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isPlaying ? null : playAudio,
              child: const Text('Play Audio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPlaying ? pauseAudio : null,
              child: const Text('Pause'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: stopAudio,
              child: const Text('Stop'),
            ),
            const SizedBox(height: 20),
            Text(
              isPlaying ? 'Audio is playing' : 'Audio is stopped',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
