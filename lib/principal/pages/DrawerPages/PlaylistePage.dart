import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../accueil.dart';
import '../PagePrincipale.dart';
import 'NewPlaylist.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<Music> _musicList = [];
  TextEditingController _playlistTitleController = TextEditingController();

  void addMusicToPlaylist(Music music) {
    setState(() {
      _musicList.add(music);
    });
  }

  void playMusic(Music music) {
    print("Lecture de la musique : ${music.musicTitle}");
  }

  void removeMusicFromPlaylist(Music music) {
    setState(() {
      _musicList.remove(music);
    });
  }

  Future<bool> addPlaylistToServer(String playlistName, List<int> musicIds) async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=createPlaylist'; // Remplacez par votre URL
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'playlist_name': playlistName,
          'userId': userId.toString(),
          'music_ids': musicIds.join(','), // Convertit la liste en une chaîne séparée par des virgules
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erreur : $e');
      return false;
    }
  }

  void savePlaylist() async {
    String playlistName = _playlistTitleController.text;
    List<int> musicIds = _musicList.map((music) => music.musicId).toList();

    if (musicIds.isNotEmpty) {
      bool success = await addPlaylistToServer(playlistName, musicIds);

      if (success) {
        print('Playlist enregistrée avec succès');
        _playlistTitleController.clear();
        setState(() {
          _musicList.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist enregistrée avec succès'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Accueil()),
        );
      } else {
        print('Erreur lors de l\'enregistrement de la playlist');
      }
    } else {
      print('La playlist est vide');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(33, 55, 79, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 55, 79, 1),
        title: Text(
          'Créer une playliste.',
          style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(249, 175, 24, 1)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6.0, right: 6.0),
              child: Container(
                padding: EdgeInsets.only(left: 8, top: 3, bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                ),
                child: TextField(
                  controller: _playlistTitleController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.add_box_outlined),
                    hintText: 'Nom de la playlist',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(
                      color: CupertinoColors.white,
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(249, 175, 24, 1)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPlaylist(onMusicAdded: addMusicToPlaylist),
                    ),
                  );
                },
                child: Text('Ajouter une musique'),
              ),
            ),
            SizedBox(height: 16.0),
            if (_musicList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _musicList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        width: 60,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: NetworkImage('https://futursowax.com/profil_musique/cover/${_musicList[index].image}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: Color.fromRGBO(249, 175, 24, 1)),
                            onPressed: () {
                              playMusic(_musicList[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Color.fromRGBO(249, 175, 24, 1)),
                            onPressed: () {
                              removeMusicFromPlaylist(_musicList[index]);
                            },
                          ),
                        ],
                      ),
                      title: Text(
                        _musicList[index].musicTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        _musicList[index].username,
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(33, 55, 79, 1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(color: CupertinoColors.white),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(249, 175, 24, 1)),
            ),
            onPressed: _musicList.isNotEmpty ? savePlaylist : null,
            child: Text('Enregistrer Playlist'),
          ),
        ),
      ),
    );
  }
}
