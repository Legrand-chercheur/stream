import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream/login_register/registration.dart';
import 'package:http/http.dart' as http;
import '../principal/accueil.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> loginUser() async {
    setState(() {
      _loading = true;
    });

    // Remplacez cette URL par celle de votre API de connexion
    final apiUrl = 'https://musique.cipepsud-diwassa.com?route=Login';

    // Les données à envoyer au serveur
    final Map<String, dynamic> data = {
      'email': _emailController.text,
      'password': _passwordController.text,
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
        if (result['message'] == 0) {
          // Stockez les informations de l'utilisateur dans les préférences partagées
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('userId', result['user']['user_id']);
          prefs.setString('username', result['user']['username']);
          prefs.setString('email', result['user']['email']);
          //prefs.setString('user_profil', result['user']['user_profil']);
          prefs.setInt('status', result['user']['status']);
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
  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      assert(!user!.isAnonymous);
      assert(await user!.getIdToken() != null);

      final User? currentUser = _auth.currentUser;
      assert(user!.uid == currentUser!.uid);

      print('Google Sign-In success: ${user?.displayName}');

      return user;
    } catch (error) {
      print('Google Sign-In error: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double buttonWidth = size.width;

    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 41, 67, 1),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.contain
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 35,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'De retour?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Connectez vous pour continuer',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'E-mail ou numero de telephone',
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
                    controller: _passwordController,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: 'Mot de passe',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mot de passe oubliez?',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: () {
                    loginUser();
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
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                TextButton(
                  onPressed: () {
                    _handleSignIn();
                  },
                  style: TextButton.styleFrom(
                    fixedSize: Size(buttonWidth, 60),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo google.png', height: 20, width: 20), // Replace 'googleIconPath' with your Google icon asset path
                      SizedBox(width: 10),
                      Text(
                        'Connexion avec Google',
                        style: TextStyle(
                          color: Color.fromRGBO(18, 41, 67, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous n\'avez pas de compte? ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Registration()));
                      },
                      child: Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: Color.fromRGBO(249, 175, 24, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
