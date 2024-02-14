import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../accueil.dart';

class ModeArtiste extends StatefulWidget {
  const ModeArtiste({Key? key}) : super(key: key);

  @override
  State<ModeArtiste> createState() => _ModeArtisteState();
}

class _ModeArtisteState extends State<ModeArtiste> {
  bool _loading = false;


  Future<void> DevenirArtiste() async {
    setState(() {
      _loading = true;
    });

    // Remplacez cette URL par celle de votre API de connexion
    final apiUrl = 'https://musique.cipepsud-diwassa.com?route=GoToArtsite';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    print(userId);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({ 'userId': userId}),
      );

      if (response.statusCode == 200) {
        // Succès de la requête
        final Map<String, dynamic> result = json.decode(response.body);

        // Traitez la réponse en fonction de votre API
        print(result);
        if (result['message'] == 'Vous etes desormais un artiste') {
          // Stockez les informations de l'utilisateur dans les préférences partagées
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('status', 1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
            ),
          );
          // Naviguez vers la page suivante (par exemple, votre tableau de bord)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Accueil()),
          );
        } else {
          // Affichez une snackbar avec le message d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']),
            ),
          );
        }
      } else {
        // Échec de la requête
        print('Échec de la requête HTTP avec le code : ${response.statusCode}');
      }
    } catch (error) {
      // Erreur lors de la requête
      print('Erreur lors de la requête HTTP : $error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;

    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: Stack(
        children: [
          // Image en arrière-plan avec filtre
          Positioned.fill(
            child: Image.asset(
              'assets/cover1.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Color.fromRGBO(18, 41, 67, 0.5), // Teinte de couleur
              ),
            ),
          ),
          // Contenu au premier plan
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/logofranck_Plan de travail 1.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'StreamIt.',
                  style: TextStyle(
                    color: Color.fromRGBO(249, 175, 24, 1),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Devenir un artiste', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 10),
                      Text('Sur notre plateforme nous offrons aux artistes émergents une chance de briller et de partager leur musique avec le monde. Si vous êtes passionné par la musique et que vous rêvez de faire entendre vos créations au plus grand nombre, vous êtes au bon endroit.', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                      Text('NB: Les frais d\'inscrition s\'élève à la somme de 500Fcfa.', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      DevenirArtiste();
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(buttonWidth, 60),
                      backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      'Devenir artiste',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
