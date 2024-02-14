import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class AudioPlayerManager with ChangeNotifier {
  late AudioPlayer _audioPlayer;

  AudioPlayerManager() {
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  AudioPlayer get audioPlayer => _audioPlayer;
  Duration _pausedPosition = Duration.zero;

  Future<void> _initAudioPlayer() async {
    _audioPlayer.positionStream.listen((position) {
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      notifyListeners();
    });
  }

  Future<void> playPause(String url) async {
    if (_audioPlayer.playing) {
      _pausedPosition = await _audioPlayer.position;
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
        initialPosition: _pausedPosition,
      );
      await _audioPlayer.play();
    }

    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }
}

class MusicPlayerPersistentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var audioPlayerManager = Provider.of<AudioPlayerManager>(context, listen: false);

    return Container(
      color: Colors.black, // Couleur de fond de la barre persistante
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Afficher les informations de lecture actuelles
            StreamBuilder<Duration>(
              stream: audioPlayerManager.audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final duration = audioPlayerManager.audioPlayer.duration ?? Duration.zero;
                final progress = duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

                return Row(
                  children: [
                    Text(
                      formatDuration(position),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      formatDuration(duration),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            ),
            // Ajouter des contrôles de lecture
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 24,),
                  onPressed: () {
                    audioPlayerManager.seek(audioPlayerManager.audioPlayer.position - Duration(seconds: 10));
                  },
                ),
                IconButton(
                  icon: Icon(audioPlayerManager.audioPlayer.playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24,),
                  onPressed: () {
                    audioPlayerManager.playPause('https://futursowax.com/profil_musique/music_file/');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop, color: Colors.white, size: 24,),
                  onPressed: () {
                    audioPlayerManager.stop();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.fast_forward_rounded, color: Colors.white, size: 24,),
                  onPressed: () {
                    audioPlayerManager.seek(audioPlayerManager.audioPlayer.position + Duration(seconds: 10));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
