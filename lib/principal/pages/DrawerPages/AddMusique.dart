import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../../accueil.dart';

class IntroductionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Introduction Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenue à l\'introduction !'),
            ElevatedButton(
              onPressed: () async {
                // Marquer la page d'introduction comme vue
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('hasSeenIntroduction', true);

                // Naviguer vers la page principale
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}

class DynamicInfo {
  String? mp3FileName;
  String? mp3FilePath;
  bool isPlaying = false;
  String? textInput; // Ajoutez cette ligne
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  // Définissez les choix du menu déroulant
  List<String> dropdownItems = ['Single', 'Album'];

  // Variable pour stocker la sélection actuelle du menu déroulant
  String selectedDropdownValue = 'Single'; // Initialisation avec le premier choix
  String? selectedMp3FileName; // Nom du fichier MP3 sélectionné
  String? selectedMp3FilePath;
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  bool isEditing = true; // ou toute autre valeur initiale selon votre logique
  String? selectedImagePath;
  String? selectedImageName;
  String? duration;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _albumNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      if (selectedMp3FileName != null) {
        _audioPlayer.play(DeviceFileSource(selectedMp3FilePath!));
        print(selectedMp3FilePath);
      }
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Modifiez la fonction _playPause
  Future<void> _playPauses(DynamicInfo dynamicInfo) async {
    if (dynamicInfo.isPlaying) {
      _audioPlayer.pause();
    } else {
      if (dynamicInfo.mp3FilePath != null) {
        _audioPlayer.play(DeviceFileSource(dynamicInfo.mp3FilePath!));
      }
    }

    setState(() {
      dynamicInfo.isPlaying = !dynamicInfo.isPlaying;
    });
  }

  Future<void> insererDonnees(String musicTitle, String singleImage, String fileName) async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=AjouterSingle';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    // Supposons que vous ayez ces données à envoyer
    Map<String, dynamic> data = {
      "music_title": musicTitle,
      "music_status": "0",
      "single_image": singleImage,
      "file_name": fileName,
      "user_id": userId.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        // Affichez la réponse du serveur (success ou message d'erreur)
        print("Réponse du serveur : ${response.body}");
        uploadCover(selectedImagePath!, singleImage);
        uploadSong(selectedMp3FilePath!, fileName);
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
        print("Erreur lors de la requête : ${response.statusCode}");
        showSnackbar("Erreur lors de la requête : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
      showSnackbar("Erreur lors de la requête : $e");
    }
  }

  Future<void> insererAlbums(List<DynamicInfo> dynamicInfos) async {
    const String url = 'https://musique.cipepsud-diwassa.com?route=AjouterAlbum';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');

    try {
      for (var dynamicInfo in dynamicInfos) {
        // Construisez le map data pour chaque élément de dynamicInfos
        Map<String, dynamic> data = {
          "music_title": dynamicInfo.textInput,
          "music_status": "0",
          "album_name": _albumNameController.text,
          "album_picture": selectedImageName,
          "file_name": dynamicInfo.mp3FileName,
          "user_id": userId.toString(),
        };

        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> result = json.decode(response.body);
          // Affichez la réponse du serveur (success ou message d'erreur)
          print("Réponse du serveur : ${response.body}");

          // Appel des fonctions uploadCover et uploadSong pour chaque élément de dynamicInfos
          await uploadSong(dynamicInfo.mp3FilePath!, dynamicInfo.mp3FileName);

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
          print("Erreur lors de la requête : ${response.statusCode}");
          showSnackbar("Erreur lors de la requête : ${response.statusCode}");
        }
      }
      await uploadCover(selectedImagePath!, selectedImageName);
    } catch (e) {
      print("Erreur lors de la requête : $e");
      showSnackbar("Erreur lors de la requête : $e");
    }
  }

// ... le reste de votre code


  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> uploadCover(String imagePath, name) async {
    final String apiUrl = 'https://futursowax.com/profil_musique/uploading_cover.php';

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
  Future<void> uploadSong(String songPath, name) async {
    final String apiUrl = 'https://futursowax.com/profil_musique/uploading_musque.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['filename'] = name;
      request.files.add(await http.MultipartFile('photo', File(songPath).readAsBytes().asStream(),
          File(songPath).lengthSync(), filename: name));
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
  List<DynamicInfo> dynamicInfos = [];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;
    List<Widget> dynamicCenters = dynamicInfos.map((info) => buildDynamicCenter(info)).toList();
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Center(
              child: Container(
                width: buttonWidth / 1.03,
                height: size.width / 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/cover2.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                  child: Container(
                    color: Color.fromRGBO(18, 41, 67, 0.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Center(
              child: Container(
                width: buttonWidth / 1.03,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(33, 55, 79, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedDropdownValue,
                    onChanged: (String? newValue) {
                      // Mise à jour de l'état pour déclencher la reconstruction du widget
                      setState(() {
                        selectedDropdownValue = newValue!;
                      });

                      // Vous pouvez ajouter ici la logique en fonction de la sélection
                    },
                    style: TextStyle(color: Colors.white),
                    items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Color.fromRGBO(249, 175, 24, 1),
                              fontSize: 16
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: Color.fromRGBO(18, 41, 67, 1),
                  ),
                ),
              ),
            ),
            if (selectedDropdownValue == 'Album')
              SizedBox(height: 10,),
            if (selectedDropdownValue == 'Album')
              Center(
              child: Container(
                width: buttonWidth / 1.03,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(33, 55, 79, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _albumNameController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nom de l\'album',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      helperStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            if (selectedDropdownValue == 'Single')
              Center(
              child: Container(
                width: buttonWidth / 1.03,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(33, 55, 79, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _titleController,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Titre de votre musique',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          helperStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedMp3FileName != null
                              ? '$selectedMp3FileName'
                              : 'Choisissez votre musique',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Utilisez file_picker pour sélectionner un fichier MP3
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['mp3'],
                              );

                              if (result != null) {
                                setState(() {
                                  selectedMp3FileName = result.files.first.name;
                                  selectedMp3FilePath = result.files.first.path;
                                  isPlaying = false; // Arrêtez l'audio si un nouveau fichier est sélectionné
                                  _audioPlayer.stop();
                                });
                              }
                            },
                            icon: Icon(Icons.add, color: Color.fromRGBO(249, 175, 24, 1)),
                            label: Text('Ajouter MP3', style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1))),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          if (selectedMp3FileName != null)
                            ElevatedButton.icon(
                              onPressed: _playPause,
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Color.fromRGBO(249, 175, 24, 1),
                              ),
                              label: Text(
                                isPlaying ? 'Pause' : 'Play',
                                style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selectedDropdownValue == 'Single')
              SizedBox(height: 10,),
            if (selectedDropdownValue == 'Album')
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Ajoutez un nouveau centre à la liste des centres dynamiques
                    setState(() {

                      // Ajouter une nouvelle DynamicInfo à la liste
                      dynamicInfos.add(DynamicInfo());

                      // Affichez tous les centres dynamiques
                      List<Widget> dynamicCenters = dynamicInfos.map((info) => buildDynamicCenter(info)).toList();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(buttonWidth, 55),
                    backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Ajouter une musique',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (selectedDropdownValue == 'Album')
              SizedBox(height: 10,),
            if (selectedDropdownValue == 'Album')
              // Affichez tous les centres dynamiques
              Column(children: dynamicCenters),
            Center(
              child: Container(
                width: buttonWidth / 1.03,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(33, 55, 79, 1),
                ),
                child: Center(
                  child: isEditing
                      ? Container(
                    width: buttonWidth / 1.07,
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(18, 41, 67, 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ajouter une image de couverture',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromRGBO(249, 175, 24, 1),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: () async {
                              final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

                              if (pickedFile != null) {
                                setState(() {
                                  selectedImagePath = pickedFile.path;
                                  selectedImageName = path.basename(pickedFile.path);
                                  isEditing = false; // Cela changera l'état pour afficher l'image
                                });
                              }
                              print("Picked file: $selectedImagePath");
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(
                    width: buttonWidth / 1.07,
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(18, 41, 67, 1),
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            child: Image.file(
                              File(selectedImagePath!),
                              width: buttonWidth / 1.07,
                              height: 210,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            top: 0,
                            child: Center(
                              child: Image.file(
                                File(selectedImagePath!),
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            left: MediaQuery.of(context).size.width/1.3,
                            right: 0,
                            bottom: MediaQuery.of(context).size.height/5,
                            top: 0,
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:  Color.fromRGBO(249, 175, 24, 1),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.clear, color: Colors.white,),
                                  onPressed: () async {
                                    print("Editing: $isEditing");
                                    setState(() {
                                      selectedImagePath = null;
                                      selectedImageName = null;
                                      isEditing = true; // Cela changera l'état pour afficher l'image
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDropdownValue == 'Single'){
                    insererDonnees(
                        _titleController.text,
                      selectedImageName!,
                      selectedMp3FileName!
                    );
                  }else{
                    insererAlbums(dynamicInfos);
                  }
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(buttonWidth, 55),
                  backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Téléverser',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
  // Fonction pour construire un centre dynamique
  // Function to build a dynamic center
  Widget buildDynamicCenter(DynamicInfo dynamicInfo) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;

    return Column(
      children: [
        Container(
          width: buttonWidth / 1.03,
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(33, 55, 79, 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      dynamicInfo.textInput = value;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Titre de votre musique',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    helperStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dynamicInfo.mp3FileName != null
                        ? '${dynamicInfo.mp3FileName}'
                        : 'Choisissez votre musique',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['mp3'],
                        );

                        if (result != null) {
                          setState(() {
                            dynamicInfo.mp3FileName = result.files.first.name;
                            dynamicInfo.mp3FilePath = result.files.first.path;
                            dynamicInfo.isPlaying = false;
                            _audioPlayer.stop();
                          });
                        }
                      },
                      icon: Icon(Icons.add, color: Color.fromRGBO(249, 175, 24, 1)),
                      label: Text('Ajouter MP3', style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1))),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    if (dynamicInfo.mp3FileName != null)
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Utilisez la fonction _playPause avec les informations dynamiques
                          _playPauses(dynamicInfo);
                        },
                        icon: Icon(
                          dynamicInfo.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Color.fromRGBO(249, 175, 24, 1),
                        ),
                        label: Text(
                          dynamicInfo.isPlaying ? 'Pause' : 'Play',
                          style: TextStyle(color: Color.fromRGBO(249, 175, 24, 1)),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20,)
      ],
    );
  }
}


class Controller extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App',
      home: FutureBuilder<bool>(
        future: hasSeenIntroduction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              // L'utilisateur a déjà vu la page d'introduction, affichez la page principale.
              return MainPage();
            } else {
              // L'utilisateur n'a pas encore vu la page d'introduction, affichez-la.
              return IntroductionPage();
            }
          } else {
            // Affichez une boîte de chargement ou tout autre indicateur pendant la vérification.
            return Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 190,
                  height: 190,
                  // Adjust width and height according to your logo size
                ),
                SizedBox(height: 30),
                // Loading animation
                SpinKitWave(
                  color: Color.fromRGBO(249, 175, 24, 1), // Change the color as needed
                  size: 40.0, // Adjust the size as needed
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<bool> hasSeenIntroduction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenIntroduction') ?? false;
  }
}