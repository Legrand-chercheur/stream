import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stream/principal/pages/PagePrincipale.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerManager {
  late AudioPlayer _audioPlayer;

  AudioPlayerManager() {
    _audioPlayer = AudioPlayer();
  }

  AudioPlayer get audioPlayer => _audioPlayer;
  Duration _pausedPosition = Duration.zero;

  Future<void> playPause(String url) async {
    if (_audioPlayer.playing) {
      // Sauvegarder la position actuelle avant de mettre en pause
      _pausedPosition = await _audioPlayer.position;
      await _audioPlayer.pause();
    } else {
      // Utiliser la position sauvegardée lors de la reprise de la lecture
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)),
          initialPosition: _pausedPosition);
      await _audioPlayer.play();
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    // Remettre la position de lecture à zéro
    await _audioPlayer.seek(Duration.zero);
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }
}


class PlayMusic extends StatefulWidget {
  var musique;
  PlayMusic({this.musique});

  @override
  State<PlayMusic> createState() => _PlayMusicState();
}

class _PlayMusicState extends State<PlayMusic> {
  late AudioPlayerManager _audioPlayerManager;

  @override
  void initState() {
    super.initState();
    print(widget.musique.fileName);
    _audioPlayerManager = AudioPlayerManager();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: size.height/1.6,
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: NetworkImage('https://futursowax.com/profil_musique/cover/${widget.musique.image}'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(
                    color: Color.fromRGBO(18, 41, 67, 0.5), // Teinte de couleur
                    child: Padding(
                      padding: const EdgeInsets.all(35.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color:  Colors.white,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color.fromRGBO(249, 175, 24, 1),),
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color:  Colors.white,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.menu, color: Color.fromRGBO(249, 175, 24, 1),),
                                onPressed: () async {

                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: 100,
                  right: 100,
                  bottom: 100,
                  top: 100,
                  child: Container(
                    height: size.height/4,
                    width: buttonWidth/4,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage('https://futursowax.com/profil_musique/cover/${widget.musique.image}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
              )
            ],
          ),
          Container(
            height: size.height/2.7,
            width: buttonWidth,
            decoration: BoxDecoration(
              color:  Color.fromRGBO(18, 41, 67, 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.musique.musicTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.musique.username,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  StreamBuilder<Duration>(
                    stream: _audioPlayerManager.audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final duration = _audioPlayerManager.audioPlayer.duration ?? Duration.zero;
                      final progress = duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

                      return Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(249, 175, 24, 1)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formatDuration(position),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formatDuration(duration),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.fast_rewind_rounded, color: Colors.white, size: 40,),
                        onPressed: () {
                          _audioPlayerManager.seek(_audioPlayerManager.audioPlayer.position - Duration(seconds: 10));
                        },
                      ),
                      IconButton(
                        icon: Icon(_audioPlayerManager.audioPlayer.playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40,),
                        onPressed: () {
                          setState(() {
                            _audioPlayerManager.playPause('https://futursowax.com/profil_musique/music_file/${widget.musique.fileName}');
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.stop, color: Colors.white, size: 40,),
                        onPressed: () {
                          setState(() {
                            _audioPlayerManager.stop();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_forward_rounded, color: Colors.white, size: 40,),
                        onPressed: () {
                          _audioPlayerManager.seek(_audioPlayerManager.audioPlayer.position + Duration(seconds: 10));
                        },
                      ),
                    ],
                  ),
                  // Barre de progression du volume
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.volume_down_rounded,color: Colors.white,),
                      Container(
                        width: buttonWidth/1.25,
                        child: Slider(
                          value: _audioPlayerManager.audioPlayer.volume,
                          min: 0,
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey[500],
                          max: 1.0,
                          onChanged: (value) {
                            setState(() {
                              _audioPlayerManager.audioPlayer.setVolume(value);
                            });
                          },
                        ),
                      ),
                      Icon(Icons.volume_up_rounded,color: Colors.white,),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
