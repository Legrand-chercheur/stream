import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PagePrincipale.dart';
import 'detailsPages/DetailArtiste.dart';
import 'detailsPages/PlaySong.dart';

class Artiste {
  final int user_id;
  final String username;
  final String user_profil;

  Artiste({
    required this.user_id,
    required this.username,
    required this.user_profil
  });

  // Factory method pour créer une instance de Music depuis un Map
  factory Artiste.fromJson(Map<String, dynamic> json) {
    return Artiste(
      user_id: json['user_id'],
      username: json['username'],
      user_profil: json['user_profil'],
    );
  }
}

class Recherche extends StatefulWidget {
  const Recherche({super.key});

  @override
  State<Recherche> createState() => _RechercheState();
}

class _RechercheState extends State<Recherche> {

  Future<List<Music>> getMusic() async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=AllGetMusicInfo';

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

  Future<void> afficherMusique() async {
    try {
      List<Music> musicList = await getMusic();

      // Affichez les données dans le widget
      setState(() {
        _musicLists = musicList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }

  Future<List<Artiste>> getMusics() async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=ListArtises';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(response.body);
        List<Artiste> musicList = dataList.map((json) => Artiste.fromJson(json)).toList();

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
      List<Artiste> musicList = await getMusics();

      // Affichez les données dans le widget
      setState(() {
        _musicList = musicList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }

  late List<Artiste> _musicList = [];


  late List<Music> _musicLists = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    afficherMusiques();
    afficherMusique();
    getMusics();
    getMusic();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(33, 55, 79, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zone de recherche
              Center(
                child: Text(
                  'Recherche',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Rechercher...',
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Première partie - Liste horizontale d'artistes
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Artistes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 26),
              Container(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _musicList.length,
                  itemBuilder: (context, index) {
                    var artiste = _musicList[index];
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailArtiste(artiste:artiste)));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage('https://futursowax.com/profil_musique/images/${artiste.user_profil}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(artiste.username, style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Deuxième partie - Liste verticale
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Musiques',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _musicLists.map((music) {
                  return ListTile(
                    leading: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage('https://futursowax.com/profil_musique/cover/${music.image}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    trailing: CupertinoButton(
                      child: Icon(CupertinoIcons.play_fill, color: Colors.white,),
                      onPressed: (){

                      },
                    ),
                    title: Text(
                      music.musicTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      music.username,
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
