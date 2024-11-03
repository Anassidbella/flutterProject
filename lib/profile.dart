import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_projet/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // State Variables
  String? _login;
  bool _isLoading = true;
  Uint8List? _selectedImage;
  List<String>? _predictedCategory;
  Interpreter? _interpreter;
  static const String _modelPath = "model_unquant.tflite";
  static const String _labelPath = "assets/labels.txt";
  static const int _imageSize = 224;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializeModel();
  }

  // Load model and labels
  Future<void> _initializeModel() async {
    setState(() => _isLoading = true);
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      print("Model loaded successfully");
      await _loadCategoryLabels();
    } catch (e, stackTrace) {
      print("Error loading model: $e");
      print("Stack trace: $stackTrace");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadCategoryLabels() async {
    try {
      final labelData = await rootBundle.loadString(_labelPath);
      _predictedCategory = labelData.split('\n');
    } catch (e) {
      print("Error loading category labels: $e");
    }
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _login = prefs.getString('login');
    if (_login != null) {
      try {
        DocumentSnapshot snapshot =
            await _firestore.collection('utilisateurs').doc(_login).get();
        if (snapshot.exists) {
          var userData = snapshot.data() as Map<String, dynamic>;
          _passwordController.text = userData['password'] ?? '';
          _birthdayController.text = userData['birthday'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _postalCodeController.text = userData['postalCode']?.toString() ?? '';
          _cityController.text = userData['city'] ?? '';
        }
      } catch (e) {
        print("Error loading user profile: $e");
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore.collection('utilisateurs').doc(_login).update({
          'password': _passwordController.text,
          'birthday': _birthdayController.text,
          'address': _addressController.text,
          'postalCode': int.tryParse(_postalCodeController.text),
          'city': _cityController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profil mis à jour avec succès !'),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de la mise à jour : $e'),
        ));
      }
    }
  }

  Future<void> _pickImageAndClassify() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
      _classifyImage(imageBytes);
      _showAddVetementDialog();
    }
  }

  Future<void> _classifyImage(Uint8List imageBytes) async {
    if (_interpreter == null) return;

    img.Image? decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return;

    final input = _preprocessImage(decodedImage);
    final output = List.filled(1 * 4, 0.0).reshape([1, 4]);

    _interpreter!.run(input, output);

    final outputList = output[0] as List<double>;
    int predictedIndex =
        outputList.indexOf(outputList.reduce((a, b) => a > b ? a : b));
    setState(() {
      String fullCategory = _predictedCategory![predictedIndex];
      _predictedCategory = [fullCategory.split(' ').sublist(1).join(' ')];
    });
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    img.Image resizedImage =
        img.copyResize(image, width: _imageSize, height: _imageSize);
    return [
      List.generate(
        _imageSize,
        (y) => List.generate(
          _imageSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              (img.getRed(pixel) / 255.0),
              (img.getGreen(pixel) / 255.0),
              (img.getBlue(pixel) / 255.0),
            ];
          },
        ),
      ),
    ];
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  void _showAddVetementDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Ajouter un Vêtement',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: Image.memory(_selectedImage!,
                        height: 150, fit: BoxFit.cover),
                  ),
                _buildTextField(_titleController, 'Titre du vêtement'),
                _buildTextField(_sizeController, 'Taille'),
                _buildTextField(_brandController, 'Marque'),
                _buildTextField(_priceController, 'Prix', isNumeric: true),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    hintText: _predictedCategory?.isNotEmpty == true
                        ? _predictedCategory![0]
                        : 'Non classifiée',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                await _addVetement();
                Navigator.of(context).pop();
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addVetement() async {
    if (_titleController.text.isNotEmpty &&
        _sizeController.text.isNotEmpty &&
        _brandController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _predictedCategory?.isNotEmpty == true) {
      try {
        await _firestore.collection('vetements').add({
          'title': _titleController.text,
          'size': _sizeController.text,
          'brand': _brandController.text,
          'price': double.tryParse(_priceController.text),
          'categorie': _predictedCategory![0],
          'image': await _uploadImage(),
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Vêtement ajouté avec succès !'),
        ));
        _titleController.clear();
        _sizeController.clear();
        _brandController.clear();
        _priceController.clear();
      } catch (e) {
        print("Error adding vetement: $e");
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('vetements/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putData(_selectedImage!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          TextButton(
            onPressed: _updateUserProfile,
            child: Text(
              'Valider',
              style: TextStyle(
                color: Colors
                    .black, // Ensures the text is visible against the AppBar color
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _login,
                      readOnly: true,
                      decoration: InputDecoration(
                          labelText: 'Login', border: OutlineInputBorder()),
                    ),
                    _buildTextField(_passwordController, 'Mot de passe',
                        obscureText: true),
                    _buildTextField(_birthdayController, 'Date de naissance'),
                    _buildTextField(_addressController, 'Adresse'),
                    _buildTextField(_postalCodeController, 'Code postal',
                        isNumeric: true),
                    _buildTextField(_cityController, 'Ville'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _logout,
                      child: Text('Se déconnecter'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImageAndClassify,
                      icon: Icon(Icons.add_a_photo),
                      label: Text('Ajouter un vêtement'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
