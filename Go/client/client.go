// package main

// import (
// 	"bufio"
// 	"fmt"
// 	"net"
// )

// func main() {
// 	conn, _ := net.Dial("tcp", "127.0.0.1:8000")
// 	defer conn.Close()

// 	fmt.Fprintln(conn, "5 5")
// 	fmt.Fprintln(conn, "0 0 0 0 0")
// 	fmt.Fprintln(conn, "0 255 255 255 0")
// 	fmt.Fprintln(conn, "0 255 0 255 0")
// 	fmt.Fprintln(conn, "0 255 255 255 0")
// 	fmt.Fprintln(conn, "0 0 0 0 0")

// 	// buf := make([]byte, 4096)
// 	// n, _ := conn.Read(buf)
// 	// fmt.Println(string(buf[:n]))

// 	reader := bufio.NewReader(conn)
// 	io.Copy(os.Stdout, reader)
// }
//_____________V1

// func printImage(title string, pixels [][]int) {
// 	fmt.Println(title)
// 	for y := 0; y < len(pixels); y++ {
// 		for x := 0; x < len(pixels[y]); x++ {
// 			fmt.Printf("%3d ", pixels[y][x])
// 		}
// 		fmt.Println()
// 	}
// 	fmt.Println()
// }

// func main() {
// 	w, h := 20, 20

// 	conn, err := net.Dial("tcp", "127.0.0.1:8000")
// 	if err != nil {
// 		panic(err)
// 	}
// 	defer conn.Close()

// 	// Envoi dimensions
// 	fmt.Fprintf(conn, "%d %d\n", w, h)

// 	// Envoi pixels
// 	// Création de l'image d'entrée

// 	input := make([][]int, h)
// 	for y := 0; y < h; y++ {
// 		input[y] = make([]int, w)
// 		for x := 0; x < w; x++ {
// 			if x >= 5 && x < 15 && y >= 5 && y < 15 {
// 				input[y][x] = 255
// 			} else {
// 				input[y][x] = 0
// 			}
// 		}
// 	}

// 	// AFFICHAGE AVANT
// 	printImage("=== IMAGE D'ENTRÉE (AVANT) ===", input)

// 	// Envoi dimensions
// 	fmt.Fprintf(conn, "%d %d\n", w, h)

// 	// Envoi pixels
// 	for y := 0; y < h; y++ {
// 		for x := 0; x < w; x++ {
// 			fmt.Fprintf(conn, "%d ", input[y][x])
// 		}
// 		fmt.Fprintln(conn)
// 	}

// 	// Lecture complète du résultat
// 	reader := bufio.NewReader(conn)

// 	// Lecture dimensions
// 	var rw, rh int
// 	fmt.Fscan(reader, &rw, &rh)

// 	// Lecture pixels
// 	output := make([][]int, rh)
// 	for y := 0; y < rh; y++ {
// 		output[y] = make([]int, rw)
// 		for x := 0; x < rw; x++ {
// 			fmt.Fscan(reader, &output[y][x])
// 		}
// 	}

// 	// AFFICHAGE APRÈS
// 	printImage("=== IMAGE DE SORTIE (APRÈS - CONTOURS) ===", output)

// }
// _____________V2
package main

import (
	"fmt"
	"net"
	"os"

	"elp-go/netio"
)

func main() {
	if len(os.Args) < 3 {
		fmt.Println("usage: go run ./client <input.(png|jpg)> <output.png>")
		return
	}

	inPath := os.Args[1]
	outPath := os.Args[2]

	data, err := os.ReadFile(inPath)
	if err != nil {
		panic(err)
	}

	conn, err := net.Dial("tcp", "127.0.0.1:8000")
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	// envoyer l’image
	if err := netio.WriteFrame(conn, data); err != nil {
		panic(err)
	}

	// recevoir le png contours
	resp, err := netio.ReadFrame(conn)
	if err != nil {
		panic(err)
	}

	if err := os.WriteFile(outPath, resp, 0644); err != nil {
		panic(err)
	}

	fmt.Println("Contours écrits dans:", outPath)
}
