import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AudioLocal.dart';
import 'package:http/http.dart' as http;

class PlayListe {

  final int playlist_id;
  final String playlist_name;
  final int user_id;

  PlayListe (this.playlist_id, this.playlist_name, this.user_id);

  factory PlayListe.fromJson(Map<String, dynamic> json) {
    return PlayListe(json['playlist_id'], json['playlist_name'], json['user_id']);
  }

}

class Playslist extends StatefulWidget {
  const Playslist({Key? key}) : super(key: key);

  @override
  State<Playslist> createState() => _PlayslistState();
}

class _PlayslistState extends State<Playslist> {

  Future<List<PlayListe>> getPlaylist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    String url = 'https://musique.cipepsud-diwassa.com?route=getPlaylist&userId=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(dataList);
        List<PlayListe> musicList = dataList.map((json) => PlayListe.fromJson(json)).toList();

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
      List<PlayListe> playList = await getPlaylist();

      // Affichez les données dans le widget
      setState(() {
        _playList = playList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }

  late List<PlayListe> _playList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    afficherMusiques();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Troisième partie
            Container(
              decoration: BoxDecoration(
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
                            'Mes playlists',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              // Action lorsque le bouton est pressé
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
                        itemCount: _playList.length, // Nombre d'éléments dans votre liste
                        itemBuilder: (context, index) {
                          // Construction des éléments de la liste
                          var playliste = _playList[index];
                          return GestureDetector(
                            onTap: (){

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
                                        color:  Color.fromRGBO(18, 41, 67, 1),
                                        borderRadius: BorderRadius.circular(15)),
                                    child: Center(child: Image.asset('assets/logofranck_Plan de travail 1.png', width: 100, height: 150,)),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(playliste.playlist_name,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30,),
            // Quatrième partie
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 250,
                width: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: AssetImage('assets/cover3.jpeg'),
                        fit: BoxFit.cover
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ma liste locale', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
                          TextButton(
                            onPressed: () {
                              // Action lorsque le bouton est pressé
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyAudioListScreen()));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                            ),
                            child: Text('Voir +',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      SizedBox(height: 120),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Liste locale',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),),
                          Text('Ecouter la musique de votre mobile',style: TextStyle(fontSize: 14, color: Colors.grey[200]),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}