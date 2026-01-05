package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"os"
)

func envoyerPhoto(chemin string) {
	// 1. Ouvrir le fichier
	fichier, err := os.Open(chemin)
	if err != nil {
		fmt.Println("Fichier introuvable:", err)
		return
	}
	defer fichier.Close()

	// 2. Obtenir la taille
	info, _ := fichier.Stat()
	taille := info.Size()

	// 3. Se connecter au serveur
	conn, err := net.Dial("tcp", "localhost:8080")
	if err != nil {
		fmt.Println("Serveur hors ligne:", err)
		return
	}
	defer conn.Close()

	// 4. Envoyer la taille d'abord (Header)
	binary.Write(conn, binary.LittleEndian, taille)

	// 5. Envoyer le contenu (Payload)
	_, err = io.Copy(conn, fichier)
	if err != nil {
		fmt.Println("Erreur envoi:", err)
	} else {
		fmt.Printf("Photo %s envoyée avec succès !\n", chemin)
	}
}

func main() {
	// Exemple d'envoi d'une photo
	envoyerPhoto("ma_photo.png")
}
