// main.dart
import 'package:flutter/material.dart';
import 'package:mini_projet/loginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mini_projet/panier.dart';
import 'package:mini_projet/model_service.dart'; // Import the ModelService
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize ModelService before running the app
  final modelService = ModelService();
  await modelService.initializeModel();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        Provider<ModelService>(create: (_) => modelService), // Provide ModelService
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nom de l\'Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
