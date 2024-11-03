import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vetements.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  Future<void> loginUser(BuildContext context) async {
    String login = _loginController.text.trim();
    String password = _passwordController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "Veuillez remplir tous les champs");
      return;
    }

    DocumentReference userDoc = FirebaseFirestore.instance.collection('utilisateurs').doc(login);

    try {
      DocumentSnapshot snapshot = await userDoc.get();
      if (snapshot.exists) {
        var userData = snapshot.data() as Map<String, dynamic>;
        if (userData['password'] == password) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('login', login);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VetementsPage()),
          );
        } else {
          _showErrorDialog(context, "Mot de passe incorrect");
        }
      } else {
        _showErrorDialog(context, "Utilisateur introuvable");
      }
    } catch (e) {
      print("Error: $e");
      _showErrorDialog(context, "Une erreur est survenue. Veuillez réessayer.");
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Vêtements'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Veuillez vous connecter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Identifiant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                loginUser(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Se connecter', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
