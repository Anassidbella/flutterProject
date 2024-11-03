import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'panier.dart'; // Import your CartProvider

class DetailPage extends StatelessWidget {
  final dynamic vetement;

  const DetailPage({Key? key, required this.vetement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vetement['title'] ?? 'Détail du vêtement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with shadow and rounded corners
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 2,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vetement['image'] ?? '',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              
              // Title
              Text(
                vetement['title'] ?? 'Titre non disponible',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Divider(thickness: 1.5, color: Colors.grey[300], height: 30),

              // Details
              buildDetailRow('Catégorie', vetement['categorie'] ?? 'Inconnue'),
              buildDetailRow('Taille', vetement['size'] ?? 'Inconnue'),
              buildDetailRow('Marque', vetement['brand'] ?? 'Inconnue'),
              buildDetailRow(
                'Prix',
                '${vetement['price'] ?? 'N/A'} €',
                valueStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 35),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    label: Text('Retour', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                    label: Text('Ajouter au panier', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final item = PanierItem(
                        image: vetement['image'],
                        title: vetement['title'],
                        size: vetement['size'],
                        price: vetement['price'],
                      );
                      Provider.of<CartProvider>(context, listen: false).addItem(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${vetement['title']} ajouté au panier'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label :',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
