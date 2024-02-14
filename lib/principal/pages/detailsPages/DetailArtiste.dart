import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream/principal/pages/Recherche.dart';

class DetailArtiste extends StatelessWidget {
  final List<String> dataList = List.generate(5, (index) => 'Artiste $index');
  var artiste;
  DetailArtiste({this.artiste});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(33, 55, 79, 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: size.height/2.2,
            width: buttonWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
              image: DecorationImage(
                image: NetworkImage('https://futursowax.com/profil_musique/images/${artiste.user_profil}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Deuxième partie - Liste verticale
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10.0),
            child: Text(
              'Musiques',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  var data = dataList[index];

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
                              ),
                            ),
                            SizedBox(width: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),),
                                Text('Titre de la musique', style: TextStyle(fontSize: 14, color: Colors.grey[200]),),
                              ],
                            ),
                          ],
                        ),
                        CupertinoButton(child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white,), onPressed: (){}),
                      ],
                    ),
                  );
                },
              )
            ),
          ),
        ],
      ),
    );
  }
}
