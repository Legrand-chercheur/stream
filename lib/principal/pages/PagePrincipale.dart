import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'detailsPages/Liste_nouveaute.dart';
import 'detailsPages/PlaySong.dart';

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

class Tendances {
  final int musicId;
  final String musicTitle;
  final int userId;
  final String username;
  final String? image;
  final String fileName;

  Tendances({
    required this.musicId,
    required this.musicTitle,
    required this.userId,
    required this.username,
    this.image,
    required this.fileName,
  });

  // Factory method pour créer une instance de Music depuis un Map
  factory Tendances.fromJson(Map<String, dynamic> json) {
    return Tendances(
      musicId: json['music_id'],
      musicTitle: json['music_title'],
      userId: json['user_id'],
      username: json['username'],
      image: json['image'],
      fileName: json['file_name'],
    );
  }
}

class Principale extends StatefulWidget {
  const Principale({Key? key}) : super(key: key);

  @override
  State<Principale> createState() => _PrincipaleState();
}

class _PrincipaleState extends State<Principale> {

  Future<List<Music>> getMusics() async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=GetMusicInfo';

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
  Future<List<Tendances>> getTendances() async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=Tendances';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(dataList);
        List<Tendances> musicList = dataList.map((json) => Tendances.fromJson(json)).toList();

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
      List<Tendances> tendancesList = await getTendances();

      // Affichez les données dans le widget
      setState(() {
        _musicList = musicList;
        _tendancesList = tendancesList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }

  Future<Map<String, dynamic>?> fetchLastListenedMusic() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    final apiUrl = 'https://musique.cipepsud-diwassa.com?route=getLastListenedMusic&userId=$userId'; // Remplacez ceci par l'URL réel de votre API

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          // Accéder aux données seulement si "success" est vrai
          final Map<String, dynamic> musicData = data['data'];
          String artistName = musicData['artist_name'];
          print('Données de la réponse : $artistName');
          return musicData;
        } else {
          // Aucune donnée à afficher
          print('Aucune donnée disponible.');
        }

      } else {
        print('Erreur de requête : ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
      return null;
    }
  }

  late List<Music> _musicList = [];
  late List<Tendances> _tendancesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Appelez votre fonction pour récupérer les données ici
    afficherMusiques();
    getMusics();
    fetchLastListenedMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Musique Populaire',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 26),
                    Container(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tendancesList.length, // Nombre d'éléments dans votre liste
                        itemBuilder: (context, index) {
                          // Construction des éléments de la liste
                          var tendances = _tendancesList[index];
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
                                        image: NetworkImage('https://futursowax.com/profil_musique/cover/${tendances.image}'),
                                        fit: BoxFit.cover,
                                      ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(tendances.musicTitle,
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Deuxième partie
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: FutureBuilder(
                future: fetchLastListenedMusic(), // Remplacez cette fonction par l'appel à votre fonction getLastListenedMusic
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Affichez un indicateur de chargement pendant le chargement des données
                  } else if (snapshot.hasError) {
                    return Text('Erreur de chargement des données'); // Affichez un message d'erreur en cas d'échec du chargement des données
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Container(); // Affichez un message s'il n'y a pas de données
                  } else {
                    // Affichez vos données dans le conteneur
                    var lastListenedMusic = snapshot.data;
                    return Column(
                      children: [
                        SizedBox(height: 30,),
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width / 1.5,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: NetworkImage('https://futursowax.com/profil_musique/cover/${lastListenedMusic!["image"] ?? ''}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Récemment écouté', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    TextButton(
                                      onPressed: () {
                                        // Action lorsque le bouton est pressé
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                                      ),
                                      child: Text('Voir +', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 110),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lastListenedMusic["artist_name"] ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                    SizedBox(height: 10),
                                    Text(lastListenedMusic["music_title"] ?? '', style: TextStyle(fontSize: 14, color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
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
                          Text(
                            'Dernière Nouveauté',
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
                    SizedBox(height: 10),
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
                              width: 200, // Largeur du conteneur
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
                                    child: Text(
                                      music.musicTitle,
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 1, // Ajustez le nombre de lignes au besoin
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ),
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