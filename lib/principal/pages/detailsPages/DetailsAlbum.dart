import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PlaySong.dart';

class DetailAlbums {
  final int album_id;
  final String album_name;
  final int music_id;
  final String image;
  final String? album_added_date;
  final String musicTitle;
  final String fileName;
  final String username;
  final int user_id;

  DetailAlbums( {
    required this.album_id,
    required this.album_name,
    required this.music_id,
    required this.image,
    this.album_added_date,
    required this.musicTitle,
    required this.fileName,
    required this.user_id,
    required this.username,
  });

  // Factory method pour créer une instance de Music depuis un Map
  factory DetailAlbums.fromJson(Map<String, dynamic> json) {
    return DetailAlbums(
      album_id: json['album_id'],
      album_name: json['album_name'],
      music_id: json['music_id'],
      image: json['album_picture'],
      album_added_date: json['album_added_date'],
      musicTitle: json['music_title'],
      fileName: json['file_name'],
      user_id: json['user_id'],
      username: json['username'],
    );
  }
}

class DetailAlbum extends StatefulWidget {
  var albums;
  DetailAlbum({this.albums});

  @override
  State<DetailAlbum> createState() => _DetailAlbumState();
}

class _DetailAlbumState extends State<DetailAlbum> {

  int? userId;
  Future<List<DetailAlbums>> getMusics() async {
    String albumName = widget.albums.album_name;
    String url = 'https://musique.cipepsud-diwassa.com?route=GetAlbumInfo&album_name=$albumName';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(dataList);
        List<DetailAlbums> musicList = dataList.map((json) => DetailAlbums.fromJson(json)).toList();

        return musicList;
      } else {
        // Si la requête a échoué, lancez une exception
        throw Exception('Erreur lors de la requête : ${response.statusCode}');
      }
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      throw Exception('Erreur : $e');
    }
  }

  Future<void> afficherMusiques() async {
    try {
      List<DetailAlbums> musicList = await getMusics();

      // Affichez les données dans le widget
      setState(() {
        _musicList = musicList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }

  void session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }


  late List<DetailAlbums> _musicList = [];
  bool hasLiked = false;
  late AudioPlayer _audioPlayer;
  bool isCurrentlyPlaying = false; // Nouvelle variable d'état
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _audioPlayer = AudioPlayer();
    // Appelez votre fonction pour récupérer les données ici
    afficherMusiques();
    getMusics();
    checkIfUserLiked();
  }

  Future<void> EcouteurPlay() async {
    // Ajoutez l'écouteur à playbackEventStream ici
    _audioPlayer.playbackEventStream.listen((event) {
      // Vérifiez si la musique est en cours de lecture
      bool isCurrentlyPlaying = event.processingState == ProcessingState.completed ||
          event.processingState == ProcessingState.buffering ||
          event.processingState == ProcessingState.ready;

      // Mettez à jour la variable d'état seulement si nécessaire
      if (isCurrentlyPlaying != isCurrentlyPlaying) {
        setState(() {
          isCurrentlyPlaying = isCurrentlyPlaying;
        });
      }
    });
  }

  Future<void> playAlbum() async {
    // Vérifier si la liste de musique est vide
    if (_musicList.isEmpty) {
      return;
    }

    // Vider la liste de lecture existante
    await _audioPlayer.stop();
    await _audioPlayer.dispose();

    // Initialiser un nouveau lecteur audio
    _audioPlayer = AudioPlayer();

    // Ajouter chaque piste à la liste de lecture
    var items = _musicList.map((music) {
      return AudioSource.uri(
        Uri.parse('https://futursowax.com/profil_musique/music_file/${music.fileName}'),
        tag: music.musicTitle, // Tag peut être utilisé pour identifier chaque piste
      );
    }).toList();

    // Définir la liste de lecture avec les pistes
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: items,
        useLazyPreparation: false, // Précharge toutes les pistes immédiatement
      ),
    );

    // Lancer la lecture de la première piste
    await _audioPlayer.play();

    // Mettre à jour l'état pour refléter le nouveau statut de lecture
    setState(() {
      isCurrentlyPlaying = true;
    });
  }


  Future<void> checkIfUserLiked() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    final response = await http.post(
      Uri.parse('https://musique.cipepsud-diwassa.com?route=hasLiked'),
      body: jsonEncode({'userId': userId.toString(), 'albumId': widget.albums.album_id.toString()}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      print(data);
      print(widget.albums.album_id.toString());
      setState(() {
        hasLiked = data['hasLiked'];
      });
    } else {
      // Gérer les erreurs de requête
      print('Erreur de requête : ${response.statusCode}');
    }
  }

  Future<void> addLike() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    final response = await http.post(
      Uri.parse('https://musique.cipepsud-diwassa.com?route=addLike'),
      body: jsonEncode({'userId': userId.toString(), 'albumId': widget.albums.album_id.toString()}),
    );

    if (response.statusCode == 200) {
      // Mettre à jour l'état pour refléter le nouveau statut de like
      setState(() {
        hasLiked = true;
      });
      print(response.body);
    } else {
      // Gérer les erreurs de requête
      print('Erreur de requête : ${response.statusCode}');
    }
  }

  Future<void> removeLike() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    final response = await http.post(
      Uri.parse('https://musique.cipepsud-diwassa.com?route=removeLike'),
      body: jsonEncode({'userId': userId.toString(), 'albumId': widget.albums.album_id.toString()}),
    );

    if (response.statusCode == 200) {
      // Mettre à jour l'état pour refléter le nouveau statut de like
      setState(() {
        hasLiked = false;
      });
      print(response.body);
    } else {
      // Gérer les erreurs de requête
      print('Erreur de requête : ${response.statusCode}');
    }
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;
    EcouteurPlay();
    return Scaffold(
      backgroundColor: Color.fromRGBO(33, 55, 79, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: size.height / 2.1,
            width: buttonWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage('https://futursowax.com/profil_musique/cover/${widget.albums.album_picture}'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Padding(
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
                            icon: Icon(Icons.arrow_left_rounded, color: Color.fromRGBO(249, 175, 24, 1), size: 30,),
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
                            icon: Icon(hasLiked ? Icons.favorite : Icons.favorite_border, color: Color.fromRGBO(249, 175, 24, 1),),
                            onPressed: () async {
                              if (hasLiked) {
                                removeLike();
                              } else {
                                addLike();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16.0,
                  bottom: 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.albums.album_name,
                        style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 130,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color.fromRGBO(249, 175, 24, 1),
                            ),
                            child: IconButton(
                              icon: Row(
                                children: [
                                  Icon(Icons.play_arrow, color: Colors.white),
                                  Text('Lire L\'album', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              onPressed: () async {
                                playAlbum();
                              },
                            ),
                          ),
                          SizedBox(width: 10), // Ajout d'un espace entre les deux conteneurs
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add, color: Colors.grey[500]),
                              onPressed: () async {

                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _musicList.length,
                itemBuilder: (context, index) {
                  var music = _musicList[index];
                  bool isCurrentlyPlaying = _audioPlayer.playing && _audioPlayer.currentIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage('https://futursowax.com/profil_musique/cover/${music.image}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: isCurrentlyPlaying
                                  ? Icon(Icons.play_arrow, color: Colors.orange)
                                  : null,
                            ),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(music.username,style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),),
                                Text(music.musicTitle,style: TextStyle(fontSize: 14, color: Colors.grey[200]),),
                              ],
                            ),
                          ],
                        ),
                        CupertinoButton(child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,), onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>PlayMusic(musique: music)));
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
