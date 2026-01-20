package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"os"
)

// Envoie un fichier image au serveur
func envoyerPhoto(chemin string) {
	// Ouvrir le fichier local
	fichier, err := os.Open(chemin)
	if err != nil {
		fmt.Println("Fichier introuvable:", err)
		return
	}
	defer fichier.Close()

	// Obtenir la taille du fichier
	info, _ := fichier.Stat()
	taille := info.Size()

	// Se connecter au serveur
	connexion, err := net.Dial("tcp", "localhost:8080")
	if err != nil {
		fmt.Println("Serveur hors ligne:", err)
		return
	}
	defer connexion.Close()

	// Envoyer la taille du fichier en premier (header)
	binary.Write(connexion, binary.LittleEndian, taille)

	// Envoyer le contenu du fichier (payload)
	_, err = io.Copy(connexion, fichier)
	if err != nil {
		fmt.Println("Erreur envoi:", err)
		return
	}
	
	fmt.Printf("✓ Photo %s envoyée avec succès !\n", chemin)
}

func main() {
	// Exemple: envoyer une photo au serveur
	envoyerPhoto("ma_photo.png")
}
