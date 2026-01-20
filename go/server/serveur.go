package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"os"
	"time"
)

// Gère le transfert d'un fichier depuis un client
func gererTransfert(connexion net.Conn) {
	defer connexion.Close()
	fmt.Printf("[%s] Nouveau transfert commencé\n", connexion.RemoteAddr())

	// Lire la taille du fichier (8 octets)
	var taille int64
	err := binary.Read(connexion, binary.LittleEndian, &taille)
	if err != nil {
		fmt.Println("Erreur lecture taille:", err)
		return
	}

	// Créer un nom de fichier unique
	nomFichier := fmt.Sprintf("recu_%d.png", time.Now().UnixNano())
	fichier, err := os.Create(nomFichier)
	if err != nil {
		fmt.Println("Erreur création fichier:", err)
		return
	}
	defer fichier.Close()

	// Copier les données du client vers le fichier
	octetsRecus, err := io.CopyN(fichier, connexion, taille)
	if err != nil {
		fmt.Println("Erreur lors de la réception:", err)
		return
	}

	fmt.Printf("✓ Succès : %s reçu (%d octets)\n", nomFichier, octetsRecus)
}

func main() {
	ecouteur, err := net.Listen("tcp", ":8080")
	if err != nil {
		panic(err)
	}
	defer ecouteur.Close()
	
	fmt.Println("Serveur de photos actif sur le port 8080...")

	// Accepter les connexions en continu
	for {
		connexion, err := ecouteur.Accept()
		if err != nil {
			fmt.Println("Erreur acceptation:", err)
			continue
		}
		// Traiter chaque client en parallèle
		go gererTransfert(connexion)
	}
}
