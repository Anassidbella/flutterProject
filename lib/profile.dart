import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mini_projet/loginPage.dart';
import 'model_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart'; // Ensure correct path to model_service.dart

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModelService _modelService = ModelService();
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
  String? _predictedCategory;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _initializeModel();
  }

  // Initialize model
  Future<void> _initializeModel() async {
    setState(() => _isLoading = true);
    await _modelService.initializeModel();
    setState(() => _isLoading = false);
  }

  // Load User Profile Data
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _login = prefs.getString('login');
    if (_login != null) {
      try {
        DocumentSnapshot snapshot = await _firestore.collection('utilisateurs').doc(_login).get();
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

  // Save User Profile Data
  Future<void> _saveUserProfile() async {
    if (_formKey.currentState!.validate()) {
      await _firestore.collection('utilisateurs').doc(_login).update({
        'password': _passwordController.text,
        'birthday': _birthdayController.text,
        'address': _addressController.text,
        'postalCode': int.tryParse(_postalCodeController.text) ?? 0,
        'city': _cityController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile information updated.')));
    }
  }

  // Handle Image Selection and Classification
  Future<void> _pickImageAndClassify() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
      _showAddVetementDialog();
    }
  }

  // Show Dialog for Adding Clothing Item
  void _showAddVetementDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter un Vêtement', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedImage != null) 
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: Image.memory(_selectedImage!, height: 150, fit: BoxFit.cover),
                  ),
                SizedBox(height: 16),
                _buildTextField(_titleController, 'Titre du vêtement'),
                _buildTextField(_sizeController, 'Taille'),
                _buildTextField(_brandController, 'Marque'),
                _buildTextField(_priceController, 'Prix', isNumeric: true),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    hintText: _predictedCategory ?? 'Non classifiée',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                // Call your function to add clothing item
                Navigator.of(context).pop();
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  // Helper for Creating TextFields
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ce champ est obligatoire';
          }
          return null;
        },
      ),
    );
  }

  // Logout and redirect to LoginPage
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('login'); // Clear login data
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage())); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              initialValue: _login,
                              readOnly: true,
                              decoration: InputDecoration(labelText: 'Login', border: OutlineInputBorder()),
                            ),
                            SizedBox(height: 16),
                            _buildTextField(_passwordController, 'Password'),
                            _buildTextField(_birthdayController, 'Anniversaire'),
                            _buildTextField(_addressController, 'Adresse'),
                            _buildTextField(_postalCodeController, 'Code Postal', isNumeric: true),
                            _buildTextField(_cityController, 'Ville'),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _saveUserProfile,
                                  child: Text('Valider'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    textStyle: TextStyle(fontSize: 16),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImageAndClassify,
                      child: Text('Ajouter un vêtement'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 16),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _logout,
                      child: Text('Se Deconnecter'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 16),
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
