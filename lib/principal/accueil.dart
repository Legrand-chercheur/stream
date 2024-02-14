import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream/principal/pages/Album.dart';
import 'package:stream/principal/pages/DrawerPages/AddMusique.dart';
import 'package:stream/principal/pages/DrawerPages/Mamusique.dart';
import 'package:stream/principal/pages/DrawerPages/PlaylistePage.dart';
import 'package:stream/principal/pages/DrawerPages/ProfilUsers.dart';
import 'package:stream/principal/pages/ModeArtiste.dart';
import 'package:stream/principal/pages/PagePrincipale.dart';
import 'package:stream/principal/pages/Playlist.dart';
import 'package:stream/principal/pages/Recherche.dart';
import '../login_register/login.dart';

class Accueil extends StatefulWidget {
  const Accueil({Key? key}) : super(key: key);

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _currentIndex = 0;
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
    return Scaffold(
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
      body: _buildPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Color.fromRGBO(18, 41, 67, 1),
        selectedItemColor: Color.fromRGBO(249, 175, 24, 1),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
        ],
      ),
      drawer: _buildSidebar(),
    );
  }

  void Deconnexion() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() async{
      await prefs.remove('userId');
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('status');
      await prefs.remove('user_profil');
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
  Widget _buildSidebar() {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;
    return Drawer(
      child: Container(
        color: Color.fromRGBO(33, 55, 79, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(33, 55, 79, 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: NetworkImage('https://futursowax.com/profil_musique/images/${user_profil}'),
                          fit: BoxFit.cover
                      )
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
                      child: user_profil == null
                          ? Icon(Icons.person, color: Color.fromRGBO(249, 175, 24, 1))
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  image: DecorationImage(
                                      image: NetworkImage('https://futursowax.com/profil_musique/images/${user_profil}'),
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    username ?? 'Nom d\'utilisateur',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            _buildSidebarItem(Icons.settings, 'Paramètre', () {
              // Action lorsque Paramètre est pressé
            }),
            _buildSidebarItem(Icons.person, 'Profil', () {
              // Action lorsque Profil est pressé
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilPage()));
            }),
            _buildSidebarItem(Icons.library_add, 'Créer Playlist', () {
              // Action lorsque Créer Playlist est pressé
              Navigator.push(context, MaterialPageRoute(builder: (context)=> PlaylistPage()));
            }),
            if (status == 1)
              _buildSidebarItem(Icons.add_circle_outline, 'Ajouter Musique', () {
                // Action lorsque Ajouter Musique est pressé
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Controller()));
              }),
            if (status == 1)
              _buildSidebarItem(Icons.library_music, 'Voir ma musique', () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> MaMusique()));
              }),
            _buildSidebarItem(Icons.exit_to_app, 'Déconnexion', () {
              AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  btnCancelText: 'Annuler',
                  btnOkText: 'Se deconnecter',
                  title: 'Deconnexion',
                  desc: 'Etes vous sur de vouloir vous deconnecter?',
                  btnOkColor: Color.fromRGBO(249, 175, 24, 1),
                  btnCancelColor: Colors.red,
                  btnCancelOnPress: () {},
                  btnOkOnPress: Deconnexion,
              ).show();
            }),
            SizedBox(height: 20),
            if (status == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ModeArtiste()));
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(buttonWidth, 55),
                      backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Passer en mode artiste',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildSidebarItem(IconData icon, String title, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onPressed,
    );
  }
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Principale();
      case 1:
      // Remplacez cela par le widget de la page Album
        return Albums();
      case 2:
      // Remplacez cela par le widget de la page Playlist
        return Playslist();
      case 3:
      // Remplacez cela par le widget de la page Recherche
        return Recherche();
      default:
        return Container();
    }
  }
}
