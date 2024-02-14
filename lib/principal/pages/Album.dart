import 'dart:convert';
import 'package:flutter/material.dart';
import 'detailsPages/DetailsAlbum.dart';
import 'package:http/http.dart' as http;

class Album {
  final int album_id;
  final String album_name;
  final String album_picture;
  final String album_added_date;

  Album({
    required this.album_name,
    required this.album_picture,
    required this.album_added_date,
    required this.album_id
  });

  // Factory method pour créer une instance de Music depuis un Map
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        album_name: json['album_name'],
        album_picture: json['album_picture'],
        album_added_date: json['album_added_date'],
        album_id: json['album_id']
    );
  }
}
class Albums extends StatefulWidget {
  const Albums({Key? key}) : super(key: key);

  @override
  State<Albums> createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  Future<List<Album>> getMusics() async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=GetAlbum';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Si la requête a réussi, convertissez la réponse JSON en une liste d'objets Music
        List<dynamic> dataList = json.decode(response.body)['data'];
        print(dataList);
        List<Album> musicList = dataList.map((json) => Album.fromJson(json)).toList();

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
      List<Album> musicList = await getMusics();

      // Affichez les données dans le widget
      setState(() {
        _musicList = musicList;
      });
    } catch (e) {
      // Gérez les erreurs liées à la connexion ou au traitement des données
      print('Erreur : $e');
    }
  }


  late List<Album> _musicList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Appelez votre fonction pour récupérer les données ici
    afficherMusiques();
    getMusics();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30,),
            // Première partie
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 250,
                width: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Pour vous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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
                      Text('Derniers album(s) de vos artistes préféré',style: TextStyle(fontSize: 14,),),
                      SizedBox(height: 100),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Artiste',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          Text('Titre de la musique',style: TextStyle(fontSize: 14,),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),

            // Deuxième partie
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
                        'Album(s) Tendance',
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
                        itemCount: 5, // Nombre d'éléments dans votre liste
                        itemBuilder: (context, index) {
                          // Construction des éléments de la liste
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailAlbum()));
                                  },
                                  child: Container(
                                    height: 250,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15)),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text('Titre $index',
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
                        itemCount: _musicList.length,
                        itemBuilder: (context, index) {
                          var music = _musicList[index];
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailAlbum(albums: music)));
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
                                        image: NetworkImage('https://futursowax.com/profil_musique/cover/${music.album_picture}'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(music.album_name, style: TextStyle(color: Colors.white)),
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
          ],
        ),
      ),
    );
  }
}