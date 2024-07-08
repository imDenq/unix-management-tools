
# Gestion des Utilisateurs - Readme

## Français

### Introduction

Ce projet est un script Bash interactif utilisant Whiptail pour gérer les utilisateurs et les groupes sur un système Unix/Linux. Il permet d'ajouter, supprimer, modifier des utilisateurs, et bien plus encore.

### Prérequis

- Système Unix/Linux
- Bash shell
- Whiptail installé (`sudo apt-get install whiptail`)
- HTOP (`sudo apt-get install htop`)
- IFSTAT (`apt-get install ifstat`)
- Samba pour gestion des utilisateurs Samba (`sudo apt-get install samba`)

### Installation

1. Clonez le dépôt sur votre machine locale :
   ```bash
   git clone <URL_DU_DEPOT>
   ```
2. Rendez le script exécutable :
   ```bash
   cd <NOM_DU_REPERTOIRE>
   chmod +x gestion.sh
   ```

3. (Optionnel)
    ```bash
   cp gestion.sh /bin/usermgt
   ```

### Utilisation

Exécutez le script avec les droits d'administrateur :
```bash
sudo ./gestion.sh
```

Vous pouvez également exécuter le script via cette commande si vous avez suivi l'étape 3. (Optionnel):
```bash
usermgt
```

### Fonctionnalités

- **Ajouter un utilisateur** : Ajoute un nouvel utilisateur avec mot de passe.
- **Supprimer un utilisateur** : Supprime un utilisateur existant et son répertoire personnel.
- **Lister les utilisateurs** : Affiche la liste des utilisateurs humains ou applicatifs.
- **Modifier un utilisateur** : Permet de modifier les groupes ou le mot de passe d'un utilisateur.
- **Lister les groupes** : Affiche la liste de tous les groupes.
- **Tableau de bord** : Affiche un tableau de bord avec des statistiques sur les utilisateurs.
- **Ajouter un utilisateur Samba** : Ajoute un utilisateur Samba existant.
- **Monitoring en temps réel** : Ouvre l'outil `htop` pour le monitoring du système.
- **Configurations Système**: Permet de modifier les certains fichiers de configuration directement depuis l'interface.

### Avertissements

Assurez-vous d'avoir les droits nécessaires pour exécuter ces commandes, car certaines nécessitent des privilèges super-utilisateur.

### Auteur

Tous droits réservés, DenqLLC.

---

## English

### Introduction

This project is an interactive Bash script using Whiptail to manage users and groups on a Unix/Linux system. It allows adding, deleting, modifying users, and more.

### Prerequisites

- Unix/Linux system
- Bash shell
- Whiptail installed (`sudo apt-get install whiptail`)
- HTOP (`sudo apt-get install htop`)
- IFSTAT (`apt-get install ifstat`)
- Samba for managing Samba users (`sudo apt-get install samba`)

### Installation

1. Clone the repository to your local machine:
   ```bash
   git clone <REPO_URL>
   ```
2. Make the script executable:
   ```bash
   cd <DIRECTORY_NAME>
   chmod +x gestion.sh
   ```

3. (Optional)
    ```bash
   cp gestion.sh /bin/usermgt
   ```

### Usage

Run the script with administrator rights:
```bash
sudo ./gestion.sh
```

You can also run the script like this if you followed previos step 3. (Optional):
```bash
usermgt
```

### Features

- **Add a user**: Adds a new user with a password.
- **Delete a user**: Deletes an existing user and their home directory.
- **List users**: Displays the list of human or application users.
- **Modify a user**: Allows modifying the groups or password of a user.
- **List groups**: Displays the list of all groups.
- **Dashboard**: Shows a dashboard with statistics on users.
- **Add a Samba user**: Adds an existing Samba user.
- **Real-time monitoring**: Opens `htop` for system monitoring.
- **Configuration editor**: Permit the user to modify certain system configurations files.

### Warnings

Ensure you have the necessary permissions to execute these commands as some require super-user privileges.

### Author

All rights reserved, DenqLLC.

---

Thank you for using the User Management Tool!
