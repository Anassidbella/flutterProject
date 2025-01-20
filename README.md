# Mini Projet : Application de Gestion des Vêtements

Cette application Flutter est conçue pour faciliter la gestion des vêtements. Elle permet aux utilisateurs d’ajouter un vêtement en téléchargeant une image, et grâce à un modèle d'apprentissage automatique, l'application prédit la catégorie du vêtement téléchargé.

## Fonctionnalités clés

- **Ajout de vêtements** : Les utilisateurs peuvent ajouter un vêtement en téléchargeant une image.
- **Prédiction de catégorie** : L'application analyse l'image téléchargée et prédit automatiquement la catégorie du vêtement parmi les options disponibles.

## Informations de Connexion

Pour des besoins de test, vous pouvez utiliser les identifiants suivants :

- **Utilisateur 1** :  
  - **Nom d'utilisateur** : test  
  - **Mot de passe** : test

- **Utilisateur 2** :  
  - **Nom d'utilisateur** : user1  
  - **Mot de passe** : user1

## Catégories de Vêtements Supportées

Le modèle de prédiction est entraîné sur les catégories suivantes :
- **Shorts**
- **T-shirts**
- **Hoodies**
- **Jeans**

Lors de l'ajout d’un vêtement, veuillez vous assurer que l'image correspond à l'une de ces catégories pour garantir une prédiction optimale.

---
## Instructions pour Installer et Exécuter l'Application Localement

### Prérequis
1. **Flutter SDK** : Installez Flutter en suivant le [guide officiel](https://docs.flutter.dev/get-started/install).
2. **Git** : Assurez-vous que Git est installé. Téléchargez-le depuis [ce lien](https://git-scm.com/downloads).
3. **IDE** : Installez un éditeur de code comme [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio).
4. **Emulateur ou Appareil Physique** : Configurez un émulateur Android/iOS ou connectez un appareil physique avec le mode débogage USB activé.

---

### Étapes d’Installation

#### 1. **Cloner le Référentiel**
Ouvrez un terminal et exécutez la commande suivante :
```bash
git clone https://github.com/Anassidbella/flutterProject.git
```
Naviguez dans le dossier du projet :
```bash
cd flutterProject
```
2. **Installer les Dépendances**
Installez les paquets nécessaires avec :
```bash
flutter pub get
```
#### 3. **Configurer les Plates-Formes**
Android : Assurez-vous que l'Android SDK est configuré dans Android Studio.
iOS (macOS uniquement) : Installez CocoaPods si ce n'est pas déjà fait :
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

#### 4. **Lancer l’Application**
Vérifiez que votre appareil ou émulateur est détecté :
```bash
flutter devices
```
Lancez l'application :
```bash
flutter run
```


