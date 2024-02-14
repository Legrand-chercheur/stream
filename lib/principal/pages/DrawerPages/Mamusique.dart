import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../detailsPages/Liste_nouveaute.dart';
import '../detailsPages/PlaySong.dart';

class Music {
  final int musicId;
  final String musicTitle;
  final int userId;
  final String username;
  final String? image;
  final String fileName;

  Music({
    required this.musicId,
    required this.musicTitle,
    required this.userId,
    required this.username,
    this.image,
    required this.fileName,
  });

  // Factory method pour créer une instance de Music depuis un Map
  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      musicId: json['music_id'],
      musicTitle: json['music_title'],
      userId: json['user_id'],
      username: json['username'],
      image: json['image'],
      fileName: json['file_name'],
    );
  }
}

class Single {
  final int musicId;
  final String musicTitle;
  final int userId;
  final String username;
  final String? image;
  final String fileName;

  Single({
    required this.musicId,
    required this.musicTitle,
    required this.userId,
    required this.username,
    this.image,
    required this.fileName,
  });

  // Factory method pour créer une instance de Music depuis un Map
  factory Single.fromJson(Map<String, dynamic> json) {
    return Single(
      musicId: json['music_id'],
      musicTitle: json['music_title'],
      userId: json['user_id'],
      username: json['username'],
      image: json['image'],
      fileName: json['file_name'],
    );
  }
}
class MaMusique extends StatefulWidget {
  const MaMusique({Key? key}) : super(key: key);

  @override
  State<MaMusique> createState() => _MaMusiqueState();
}

class _MaMusiqueState extends State<MaMusique> {

  Future<List<Music>> getMusics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    String url = 'https://musique.cipepsud-diwassa.com?route=GetAlbumByArtist&artiseId=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(dataList);
        List<Music> musicList = dataList.map((json) => Music.fromJson(json)).toList();

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

  Future<List<Single>> getSingle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    String url = 'https://musique.cipepsud-diwassa.com?route=GetArtistSingleInfo&artiseId=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(dataList);
        List<Single> musicList = dataList.map((json) => Single.fromJson(json)).toList();

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
      List<Music> musicList = await getMusics();
      List<Single> singleList = await getSingle();

      // Affichez les données dans le widget
      setState(() {
        _musicList = musicList;
        _singleList = singleList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }


  late List<Music> _musicList = [];
  late List<Single> _singleList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Appelez votre fonction pour récupérer les données ici
    afficherMusiques();
    getSingle();
    getMusics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 55, 79, 1),
        title: Text(
          'Ma musique.',
          style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(249, 175, 24, 1)), // Ajout de cette ligne
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Première partie
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                color: Color.fromRGBO(33, 55, 79, 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if(_singleList.length > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mes Singles',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailNouveaute()));
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                                ),
                                child: Text('Voir +',
                                    style: TextStyle(color: Colors.white)),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 26),
                    if(_singleList.length > 0)
                      Container(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _singleList.length, // Nombre d'éléments dans votre liste
                          itemBuilder: (context, index) {
                            // Construction des éléments de la liste
                            var single = _singleList[index];
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 250,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                        image: NetworkImage('https://futursowax.com/profil_musique/cover/${single.image}'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(single.musicTitle,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    if(_singleList.length <= 0)
                      Container(
                        height: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/lose.png'),
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                            Text('Aucun Single pour le moment...',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
            SizedBox(height: 30,),
            // Troisième partie
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Color.fromRGBO(33, 55, 79, 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(_musicList.length > 0)
                            Text(
                              'Mes Albums',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          if(_musicList.length > 0)
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailNouveaute()));
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                              ),
                              child: Text('Voir +',
                                  style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    if(_musicList.length > 0)
                      Container(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _musicList.length,
                          itemBuilder: (context, index) {
                            var music = _musicList[index];
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PlayMusic(musique: music)));
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 250,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          image: NetworkImage('https://futursowax.com/profil_musique/cover/${music.image}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(music.musicTitle, style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if(_musicList.length <= 0)
                      Container(
                        height: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/lose.png'),
                                    fit: BoxFit.cover
                                )
                              ),
                            ),
                            Text('Aucun Album pour le moment...',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}