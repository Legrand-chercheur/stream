import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../PagePrincipale.dart';
import '../detailsPages/PlaySong.dart';

class AddPlaylist extends StatefulWidget {
  final Function(Music) onMusicAdded;

  AddPlaylist({required this.onMusicAdded});

  @override
  State<AddPlaylist> createState() => _AddPlaylistState();
}

class _AddPlaylistState extends State<AddPlaylist> {

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


  late List<Music> _musicLists = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    afficherMusique();
    getMusic();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(33, 55, 79, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 55, 79, 1),
        title: Text(
          'Choisir un morceaux.',
          style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(249, 175, 24, 1)), // Ajout de cette ligne
      ),
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
              // Deuxième partie - Liste verticale
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Musiques',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height/1.3,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _musicLists.length,
                  itemBuilder: (context, index) {
                    var music = _musicLists[index];
                    return ListTile(
                      leading: Container(
                        width: 100,
                        height: 150,
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
                        child: Icon(CupertinoIcons.add_circled_solid, color: Colors.white,),
                        onPressed: (){
                          // Appel de la fonction de rappel pour ajouter la musique à la première page
                          widget.onMusicAdded(music);
                          Navigator.pop(context); // Revenir à la première page après l'ajout
                        },
                      ),
                      title: Text(
                        _musicLists[index].musicTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        _musicLists[index].username,
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
