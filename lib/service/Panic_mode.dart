// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';

// class PanicMode extends StatefulWidget {
//   const PanicMode({super.key});

//   @override
//   State<PanicMode> createState() => _PanicModeState();
// }

// class _PanicModeState extends State<PanicMode> {
//   final AudioPlayer player = AudioPlayer();
//   Duration position = Duration.zero;
//   Duration duration = Duration.zero;

//   String formatDuration(Duration d) {
//     final min = d.inMinutes.remainder(60);
//     final sec = d.inSeconds.remainder(60);
//     return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
//   }

//   @override
//   void initState() {
//     super.initState();
//     _setupAudio();
//   }

//   Future<void> _setupAudio() async {
//     final session = await AudioSession.instance;
//     await session
//         .configure(AudioSessionConfiguration.speech()); // or `.music()`

//     try {
//       await player.setAsset('assets/sound_alert.mp3');
//       duration = (await player.duration) ?? Duration.zero;
//       setState(() {}); // Update UI once the duration is known
//     } catch (e) {
//       print("Error loading audio: $e");
//     }

//     // Listen for position updates
//     player.positionStream.listen((p) {
//       setState(() => position = p);
//     });
//   }

//   void handlePlayPause() async {
//     try {
//       if (player.playing) {
//         await player.pause(); // Ensure pause completes before updating UI
//       } else {
//         await player.play(); // Ensure play completes before updating UI
//       }
//       setState(() {}); // Update UI
//     } catch (e) {
//       print("Error playing audio: $e"); // Debugging info
//     }
//   }

//   void handleSeek(double value) {
//     player.seek(Duration(seconds: value.toInt()));
//   }

//   @override
//   void dispose() {
//     player.dispose(); // Prevent memory leaks
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Panic Mode")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(formatDuration(position)),
//             Slider(
//               min: 0.0,
//               max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0,
//               value: position.inSeconds
//                   .toDouble()
//                   .clamp(0.0, duration.inSeconds.toDouble()),
//               onChanged: handleSeek,
//             ),
//             Text(formatDuration(duration)),

//             // Use StreamBuilder for real-time play/pause UI update
//             StreamBuilder<bool>(
//               stream: player.playingStream,
//               builder: (context, snapshot) {
//                 bool isPlaying = snapshot.data ?? false;
//                 return IconButton(
//                   onPressed: handlePlayPause,
//                   icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
