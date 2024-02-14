import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class OTPConfirmation extends StatefulWidget {
  var email, username, password, codeOtp;
  OTPConfirmation({ this.password, this.email, this.username, this.codeOtp});

  @override
  State<OTPConfirmation> createState() => _OTPConfirmationState();
}

class _OTPConfirmationState extends State<OTPConfirmation> {
  List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());
  List<TextEditingController> _controllers = List.generate(5, (index) => TextEditingController());
  bool isLoading = false;
  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    final String apiUrl = 'https://musique.cipepsud-diwassa.com?route=Register'; // Remplacez cela par votre URL PHP

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // Si la requête a réussi, renvoyer les données sous forme de carte
        return json.decode(response.body);
      } else {
        // Si la requête a échoué, renvoyer une erreur
        throw Exception('Failed to register user');
      }
    } catch (e) {
      // En cas d'erreur, renvoyer une carte d'erreur
      return {'error': 'Error communicating with the server: $e'};
    }
  }

  Future<void> _handleRegisterButtonPress() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> userData = {
      'username': widget.username,
      'email': widget.email,
      'password': widget.password
    };
    print(userData);
    try {
      Map<String, dynamic> result = await registerUser(userData);

      if (result.containsKey('error')) {
        print('Error: ${result}');
        // Handle the error as needed
      } else {
        print('Message: ${result['message']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
        // Handle the success as needed
      }
    } finally {
      // Reset the button state after API call
      setState(() {
        isLoading = false;
      });
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
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/logo.png'),
                          fit: BoxFit.contain
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Confirmation OTP',
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
                    'Entrez le code de confirmation pour continuer',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color.fromRGBO(249, 175, 24, 1), width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 4) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.length == 0 && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 30,),
                ElevatedButton(
                  onPressed: () {
                    // Vérifier si le code OTP saisi est correct
                    String enteredOTP = _controllers.map((controller) => controller.text).join();
                    if (enteredOTP == widget.codeOtp) {
                      // Le code OTP est correct, lancer la fonction d'enregistrement
                      _handleRegisterButtonPress();
                    } else {
                      // Le code OTP est incorrect, afficher un message d'erreur (vous pouvez personnaliser cela selon vos besoins)
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Code incorrect"),
                            content: Text("Veuillez saisir le code correctement."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(buttonWidth, 60),
                    backgroundColor: Color.fromRGBO(249, 175, 24, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    'Confirmer l\'inscription',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
