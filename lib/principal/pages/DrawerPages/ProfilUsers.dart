import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../../accueil.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? user_profil;
  TextEditingController _pseudoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  bool isEditing = true; // ou toute autre valeur initiale selon votre logique
  String? selectedImagePath;
  String? selectedImageName;
  bool _loading = false;
  bool _session = false;

  void session() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_profil = prefs.getString('user_profil');
      print(user_profil);
      _pseudoController.text = prefs.getString('username')!;
      _emailController.text = prefs.getString('email')!;
      _session = true;
    });
  }

  Future<void> profilEdit() async {
    setState(() {
      _loading = true;
    });

    // Remplacez cette URL par celle de votre API de connexion
    final apiUrl = 'https://musique.cipepsud-diwassa.com?route=EditProfil';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    // Les données à envoyer au serveur
    final Map<String, dynamic> data = {
      'userId': userId.toString(),
      'newUsername': _pseudoController.text,
      'newEmail': _emailController.text,
      'newUserProfile': selectedImageName ?? selectedImageName
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Succès de la requête
        final Map<String, dynamic> result = json.decode(response.body);

        // Traitez la réponse en fonction de votre API
        print(result);
        if (result['message'] == 'Profil mis à jour avec succès') {
          if (selectedImagePath != null) {
            await uploadPhoto(selectedImagePath!, selectedImageName);
          }
          // Stockez les informations de l'utilisateur dans les préférences partagées
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {
            prefs.setString('username', _pseudoController.text);
            prefs.setString('email', _emailController.text);
            prefs.setString('user_profil', selectedImageName!);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
            ),
          );
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
  Future<void> uploadPhoto(String imagePath, name) async {
    final String apiUrl = 'https://futursowax.com/profil_musique/uploading.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['filename'] = name;
      request.files.add(await http.MultipartFile('photo', File(imagePath).readAsBytes().asStream(),
          File(imagePath).lengthSync(), filename: name));
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Photo uploaded successfully');
        print(await response.stream.bytesToString());
      } else {
        print('Error uploading photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    session();
  }
  @override
  Widget build(BuildContext context) {
    if (_session == false) {
      session();
    }
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 55, 79, 1),
        title: Text(
          'Profil.',
          style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
        ),
        iconTheme: IconThemeData(color: Color.fromRGBO(249, 175, 24, 1)), // Ajout de cette ligne
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromRGBO(18, 41, 67, 1),
          child: Stack(
            children: [
              // Premier Container (1/4 de la hauteur de l'écran)
              Container(
                height: MediaQuery.of(context).size.height,
                color: Color.fromRGBO(18, 41, 67, 1),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height/2.5,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'E-mail',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            helperStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _pseudoController,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Pseudo',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _telController,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tel',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                      ElevatedButton(
                        onPressed: () {
                          profilEdit();
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
                          'Met à jour le profil',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 4,
                color: Color.fromRGBO(33, 55, 79, 1),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.height/2,
                top: 0,
                child: Container(
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromRGBO(18, 41, 67, 1),
                      ),
                      child: Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white
                          ),
                          child: isEditing
                              ? selectedImagePath != null
                              ? Container(
                                child: Image.file(
                                    File(selectedImagePath!),
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                              )
                              : user_profil == null
                              ? Icon(Icons.person, color: Color.fromRGBO(249, 175, 24, 1))
                              : Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: NetworkImage('https://futursowax.com/profil_musique/images/${user_profil}'),
                                          fit: BoxFit.cover
                                      )
                                  ),
                                )
                              :Container(),

                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width/3,
                right: 0,
                bottom: MediaQuery.of(context).size.height/2.3,
                top: 100,
                child: Center(
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color:  Color.fromRGBO(249, 175, 24, 1),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        print("Editing: $isEditing");
                        if (isEditing) {
                          // Utilisez image_picker pour sélectionner une image depuis les fichiers
                          final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

                          if (pickedFile != null) {
                            // Mettez à jour l'état avec le chemin du fichier sélectionné
                            setState(() {
                              selectedImagePath = pickedFile.path;
                              selectedImageName = path.basename(pickedFile.path);
                            });
                          }
                          print("Picked file: $selectedImagePath");
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

