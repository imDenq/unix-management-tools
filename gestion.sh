#!/bin/bash

##################################
#                                #
#  All rights reserved, DenqLLC  #
#                                #
##################################

# Temporary file to store manually added files
temp_config_file_list="/tmp/config_file_list"

# Fonction pour afficher le menu principal
show_menu() {
    choice=$(whiptail --title "Outils de Gestion" --menu "Choisissez une option:" 15 50 9 \
        "1" "Ajouter un utilisateur" \
        "2" "Supprimer un utilisateur" \
        "3" "Lister les utilisateurs" \
        "4" "Modifier un utilisateur" \
        "5" "Lister les groupes" \
        "6" "Tableau de bord" \
        "7" "Monitoring en temps réel" \
        "8" "Configurations" \
        "9" "Quitter" 3>&1 1>&2 2>&3)
    echo $choice
}

# Fonction pour ajouter un utilisateur avec sous-menu
add_user() {
    add_user_choice=$(whiptail --title "Ajouter un utilisateur" --menu "Choisissez une option:" 15 50 2 \
        "1" "Ajouter un utilisateur standard" \
        "2" "Ajouter un utilisateur Samba" 3>&1 1>&2 2>&3)
    
    case $add_user_choice in
        1)
            username=$(whiptail --inputbox "Entrez le nom d'utilisateur:" 8 40 3>&1 1>&2 2>&3)
    
            if id "$username" &>/dev/null; then
                whiptail --msgbox "Erreur: L'utilisateur '$username' existe déjà." 8 40
            else
                password=$(whiptail --passwordbox "Entrez le mot de passe pour l'utilisateur:" 8 40 3>&1 1>&2 2>&3)
                password2=$(whiptail --passwordbox "Confirmez le mot de passe:" 8 40 3>&1 1>&2 2>&3)

                if [ "$password" != "$password2" ]; then
                    whiptail --msgbox "Les mots de passe ne correspondent pas. Veuillez réessayer." 8 40
                    return
                fi

                encrypted_password=$(openssl passwd -1 "$password")
                sudo useradd -m -p "$encrypted_password" -s /bin/bash "$username"
                if [ $? -eq 0 ]; then
                    whiptail --msgbox "Utilisateur '$username' ajouté avec succès." 8 40
                else
                    whiptail --msgbox "Erreur lors de l'ajout de l'utilisateur '$username'." 8 40
                fi
            fi
            ;;
        2)
            add_samba_user
            ;;
        *)
            whiptail --msgbox "Option invalide. Veuillez choisir 1 ou 2." 8 40
            ;;
    esac
}

# Fonction pour ajouter un utilisateur Samba
add_samba_user() {
    users=$(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd | xargs -I{} echo "{}" "{}")
    username=$(whiptail --title "Ajouter un utilisateur Samba" --menu "Choisissez un utilisateur existant:" 15 50 8 $(echo $users) 3>&1 1>&2 2>&3)

    if [ -z "$username" ]; then
        whiptail --msgbox "Aucun utilisateur sélectionné." 8 40
        return
    fi

    password=$(whiptail --passwordbox "Entrez le mot de passe pour l'utilisateur Samba:" 8 40 3>&1 1>&2 2>&3)
    password2=$(whiptail --passwordbox "Confirmez le mot de passe:" 8 40 3>&1 1>&2 2>&3)

    if [ "$password" != "$password2" ]; then
        whiptail --msgbox "Les mots de passe ne correspondent pas. Veuillez réessayer." 8 40
        return
    fi

    (echo "$password"; echo "$password") | sudo smbpasswd -a "$username"
    if [ $? -eq 0 ]; then
        whiptail --msgbox "Utilisateur Samba '$username' ajouté avec succès." 8 40
    else
        whiptail --msgbox "Erreur lors de l'ajout de l'utilisateur Samba '$username'." 8 40
    fi
}

# Fonction pour supprimer un utilisateur
delete_user() {
    # Liste des utilisateurs humains
    users=$(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd | xargs -I{} echo "{}" "{}")
    
    # Sélection de l'utilisateur à supprimer
    username=$(whiptail --title "Supprimer un utilisateur" --menu "Choisissez un utilisateur à supprimer:" 15 50 8 $(echo $users) 3>&1 1>&2 2>&3)
    
    if [ -z "$username" ]; then
        whiptail --msgbox "Aucun utilisateur sélectionné." 8 40
        return
    fi

    if whiptail --yesno "Êtes-vous sûr de vouloir supprimer l'utilisateur '$username' ?" 8 40; then
        sudo deluser --remove-home "$username"
        if [ $? -eq 0 ]; then
            whiptail --msgbox "Utilisateur '$username' supprimé avec succès." 8 40
        else
            whiptail --msgbox "Erreur lors de la suppression de l'utilisateur '$username'." 8 40
        fi
    else
        whiptail --msgbox "Suppression annulée." 8 40
    fi
}

# Fonction pour lister les utilisateurs
list_users() {
    list_choice=$(whiptail --menu "Choisissez une option:" 15 50 2 \
        "1" "Utilisateurs humains" \
        "2" "Utilisateurs applicatifs" 3>&1 1>&2 2>&3)
    
    case $list_choice in
        1)
            users=$(awk -F: '$3 >= 1000 { printf "Utilisateur: %-10s ID: %-5s Répertoire: %s\n", $1, $3, $6 }' /etc/passwd)
            echo "$users" > /tmp/users.txt
            whiptail --textbox /tmp/users.txt 20 70 --scrolltext
            ;;
        2)
            users=$(awk -F: '$3 < 1000 { printf "Utilisateur: %-10s ID: %-5s Répertoire: %s\n", $1, $3, $6 }' /etc/passwd)
            echo "$users" > /tmp/users.txt
            whiptail --textbox /tmp/users.txt 20 70 --scrolltext
            ;;
        *)
            whiptail --msgbox "Option invalide. Veuillez choisir 1 ou 2." 8 40
            ;;
    esac
    rm -f /tmp/users.txt
}

# Fonction pour modifier un utilisateur
modify_user() {
    # Liste des utilisateurs humains
    users=$(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd | xargs -I{} echo "{}" "{}")
    
    # Sélection de l'utilisateur à modifier
    username=$(whiptail --title "Modifier un utilisateur" --menu "Choisissez un utilisateur à modifier:" 15 50 8 $(echo $users) 3>&1 1>&2 2>&3)
    
    if [ -z "$username" ]; then
        whiptail --msgbox "Aucun utilisateur sélectionné." 8 40
        return
    fi

    # Option pour modifier les groupes ou le mot de passe
    modify_choice=$(whiptail --menu "Choisissez une option de modification:" 15 50 2 \
        "1" "Modifier les groupes" \
        "2" "Modifier le mot de passe" 3>&1 1>&2 2>&3)

    case $modify_choice in
        1)
            # Obtenir la liste actuelle des groupes de l'utilisateur
            current_groups=$(groups $username | cut -d: -f2 | sed 's/^ //')
            
            # Entrer les groupes à ajouter
            new_groups=$(whiptail --inputbox "Entrez les groupes à ajouter (séparés par des virgules):" 8 50 "$current_groups" 3>&1 1>&2 2>&3)
            
            if [ $? -ne 0 ]; then
                whiptail --msgbox "Modification annulée." 8 40
                return
            fi
            
            # Mettre à jour les groupes de l'utilisateur
            sudo usermod -G "$new_groups" "$username"
            if [ $? -eq 0 ]; then
                whiptail --msgbox "Groupes de l'utilisateur '$username' mis à jour avec succès." 8 40
            else
                whiptail --msgbox "Erreur lors de la mise à jour des groupes de l'utilisateur '$username'." 8 40
            fi
            ;;
        2)
            # Entrer le nouveau mot de passe
            password=$(whiptail --passwordbox "Entrez le nouveau mot de passe:" 8 40 3>&1 1>&2 2>&3)
            password2=$(whiptail --passwordbox "Confirmez le nouveau mot de passe:" 8 40 3>&1 1>&2 2>&3)

            if [ "$password" != "$password2" ]; then
                whiptail --msgbox "Les mots de passe ne correspondent pas. Veuillez réessayer." 8 40
                return
            fi

            echo "$username:$password" | sudo chpasswd
            if [ $? -eq 0 ]; then
                whiptail --msgbox "Mot de passe de l'utilisateur '$username' mis à jour avec succès." 8 40
            else
                whiptail --msgbox "Erreur lors de la mise à jour du mot de passe de l'utilisateur '$username'." 8 40
            fi
            ;;
        *)
            whiptail --msgbox "Option invalide." 8 40
            ;;
    esac
}

# Fonction pour lister les groupes
list_groups() {
    groups=$(awk -F: '{ printf "Groupe: %-20s ID: %s\n", $1, $3 }' /etc/group)
    echo "$groups" > /tmp/groups.txt
    whiptail --textbox /tmp/groups.txt 20 70 --scrolltext
    rm -f /tmp/groups.txt
}

# Fonction pour afficher le tableau de bord
dashboard() {
    total_users=$(cut -d: -f1 /etc/passwd | wc -l)
    human_users=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd | wc -l)
    app_users=$(awk -F: '$3 < 1000 {print $1}' /etc/passwd | wc -l)
    info="Nombre total d'utilisateurs: $total_users\n\nUtilisateurs humains: $human_users\n\nUtilisateurs applicatifs: $app_users"
    whiptail --msgbox "$info" 15 50
}

# Fonction pour gérer les exceptions
handle_exceptions() {
    whiptail --msgbox "Une erreur inattendue s'est produite. Veuillez réessayer." 8 40
}

# Fonction pour le monitoring en temps réel
monitoring() {
    clear
    htop
}

# Fonction pour le menu Configurations
configurations_menu() {
    choice=$(whiptail --title "Configurations" --menu "Choisissez une catégorie:" 15 50 5 \
        "1" "Network" \
        "2" "Security" \
        "3" "General" \
        "4" "Kernel" \
        "5" "Ajouter un nouveau fichier" 3>&1 1>&2 2>&3)

    case $choice in
        1)
            edit_config_files "Network" \
                "/etc/network/interfaces" \
                "/etc/hosts" \
                "/etc/resolv.conf" \
                "/etc/netplan/*.yaml" \
                "/etc/sysconfig/network" \
                "/etc/sysconfig/network-scripts/ifcfg-*"
            ;;
        2)
            edit_config_files "Security" \
                "/etc/ssh/sshd_config" \
                "/etc/firewalld/firewalld.conf" \
                "/etc/hosts.allow" \
                "/etc/hosts.deny" \
                "/etc/nsswitch.conf" \
                "/etc/pam.d/common-auth"
            ;;
        3)
            edit_config_files "General" \
                "/etc/fstab" \
                "/etc/sysctl.conf" \
                "/etc/rsyslog.conf" \
                "/etc/crontab" \
                "/etc/hostname" \
                "/etc/issue" \
                "/etc/motd"
            ;;
        4)
            edit_config_files "Kernel" \
                "/etc/sysctl.conf" \
                "/boot/grub/grub.cfg" \
                "/etc/default/grub" \
                "/etc/modules" \
                "/etc/modprobe.d/*.conf" \
                "/etc/kernel-img.conf"
            ;;
        5)
            add_custom_file
            ;;
        *)
            whiptail --msgbox "Option invalide. Veuillez choisir 1, 2, 3, 4 ou 5." 8 40
            ;;
    esac
}

# Fonction pour ajouter un nouveau fichier personnalisé
add_custom_file() {
    category_choice=$(whiptail --title "Ajouter un fichier" --menu "Choisissez une catégorie:" 15 50 4 \
        "1" "Network" \
        "2" "Security" \
        "3" "General" \
        "4" "Kernel" 3>&1 1>&2 2>&3)
    
    new_file=$(whiptail --inputbox "Entrez le chemin complet du fichier à ajouter:" 8 50 3>&1 1>&2 2>&3)
    
    if [ -n "$new_file" ]; then
        echo "$category_choice:$new_file" >> "$temp_config_file_list"
        whiptail --msgbox "Fichier ajouté avec succès." 8 40
    else
        whiptail --msgbox "Aucun fichier ajouté." 8 40
    fi
}

# Fonction pour éditer les fichiers de configuration
edit_config_files() {
    category=$1
    shift
    files=("$@")
    
    file_menu_items=()
    for file in "${files[@]}"; do
        file_menu_items+=("$file" "$file")
    done

    # Add custom files if any
    if [ -f "$temp_config_file_list" ]; then
        while IFS= read -r line; do
            cat_choice=$(echo "$line" | cut -d: -f1)
            cat_file=$(echo "$line" | cut -d: -f2-)
            if [ "$cat_choice" == "$category" ]; then
                file_menu_items+=("$cat_file" "$cat_file")
            fi
        done < "$temp_config_file_list"
    fi

    while true; do
        config_file=$(whiptail --title "Configuration $category" --menu "Choisissez un fichier à éditer:" 15 50 8 "${file_menu_items[@]}" 3>&1 1>&2 2>&3)
        
        if [ -n "$config_file" ]; then
            sudo nano "$config_file"
        else
            break
        fi
    done
}

# Initialisation du fichier temporaire
> "$temp_config_file_list"

# Boucle principale du menu
while true; do
    choice=$(show_menu)
    case $choice in
        1)
            add_user
            ;;
        2)
            delete_user
            ;;
        3)
            list_users
            ;;
        4)
            modify_user
            ;;
        5)
            list_groups
            ;;
        6)
            dashboard
            ;;
        7)
            monitoring
            ;;
        8)
            configurations_menu
            ;;
        9)
            whiptail --msgbox "Voulez-vous quitter le programme ?" 8 40
            clear
            exit 0
            ;;
        *)
            handle_exceptions
            ;;
    esac
done
