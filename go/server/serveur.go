package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"net"
	"os"
	"time"
)

func gererTransfert(conn net.Conn) {
	defer conn.Close()
	fmt.Printf("[%s] Nouveau transfert commencé\n", conn.RemoteAddr())

	// 1. Lire la taille du fichier (int64 = 8 octets)
	var taille int64
	err := binary.Read(conn, binary.LittleEndian, &taille)
	if err != nil {
		fmt.Println("Erreur lecture taille:", err)
		return
	}

	// 2. Créer un nom de fichier unique
	nomFichier := fmt.Sprintf("recu_%d.png", time.Now().UnixNano())
	fichier, err := os.Create(nomFichier)
	if err != nil {
		fmt.Println("Erreur création fichier:", err)
		return
	}
	defer fichier.Close()

	// 3. Copier les données binaires de la connexion vers le fichier
	// io.CopyN s'arrête exactement après 'taille' octets
	morsuresRecues, err := io.CopyN(fichier, conn, taille)
	if err != nil {
		fmt.Println("Erreur lors de la réception:", err)
		return
	}

	fmt.Printf("Succès : %s reçu (%d octets)\n", nomFichier, morsuresRecues)
}

func main() {
	ecouteur, err := net.Listen("tcp", ":8080")
	if err != nil {
		panic(err)
	}
	fmt.Println("Serveur de photos actif sur le port 8080...")

	for {
		connexion, err := ecouteur.Accept()
		if err != nil {
			fmt.Println("Erreur acceptation:", err)
			continue
		}
		// Utilisation d'une Goroutine pour gérer chaque photo en parallèle
		go gererTransfert(connexion)
	}
}
