import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../PagePrincipale.dart';

class DetailNouveaute extends StatefulWidget {
  const DetailNouveaute({super.key});

  @override
  State<DetailNouveaute> createState() => _DetailNouveauteState();
}

class _DetailNouveauteState extends State<DetailNouveaute> {
  String? user_profil;
  String? username;
  int? status;
  bool _session = false;
  void session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_profil = prefs.getString('user_profil');
      print(user_profil);
      username = prefs.getString('username');
      status = prefs.getInt('status');
      _session = true;
    });
  }

  Future<List<Music>> getMusics() async {
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

  Future<void> afficherMusiques() async {
    try {
      List<Music> musicList = await getMusics();

      // Affichez les données dans le widget
      setState(() {
        _musicList = musicList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }

  late List<Music> _musicList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    session();
    afficherMusiques();
    getMusics();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 55, 79, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'StreamIt.',
                  style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: Color.fromRGBO(18, 41, 67, 1),
              child: user_profil == null
                  ? Icon(Icons.person, color: Color.fromRGBO(249, 175, 24, 1))
                  : Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    image: DecorationImage(
                        image: NetworkImage('https://futursowax.com/profil_musique/images/${user_profil}'),
                        fit: BoxFit.cover
                    )
                ),
              ),
            )
          ],
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(249, 175, 24, 1)), // Ajout de cette ligne
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _musicList.length,
              itemBuilder: (context, index) {
                var music = _musicList[index];
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
