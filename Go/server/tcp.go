// package server

// import (
// 	"bufio"
// 	"elp-go/imageproc"
// 	"net"
// )

// func StartTCPServer(port string) {
// 	ln, err := net.Listen("tcp", port)
// 	if err != nil {
// 		panic(err)
// 	}
// 	defer ln.Close()

// 	for {
// 		conn, err := ln.Accept()
// 		if err != nil {
// 			continue
// 		}
// 		go handleClient(conn)
// 	}
// }

// func handleClient(conn net.Conn) {
// 	defer conn.Close()
// 	reader := bufio.NewReader(conn)

// 	img := imageproc.ReceiveImage(reader)
// 	result := imageproc.ApplySobel(img)

//		imageproc.SendImage(conn, result)
//	}
//
// ____________V1
package server

import (
	"net"

	"elp-go/imageproc"
	"elp-go/netio"
)

func StartTCPServer(port string) {
	ln, err := net.Listen("tcp", port)
	if err != nil {
		panic(err)
	}
	defer ln.Close()

	for {
		conn, err := ln.Accept()
		if err != nil {
			continue
		}
		go handleClient(conn)
	}
}

func handleClient(conn net.Conn) {
	defer conn.Close()

	// 1) Recevoir les bytes du fichier image (JPEG/PNG)
	data, err := netio.ReadFrame(conn)
	if err != nil {
		return
	}

	// 2) Décoder -> matrice gris
	img, err := imageproc.DecodeToGrayMatrix(data)
	if err != nil {
		return
	}

	// 3) Détection de contours
	edges := imageproc.ApplySobelBinary(img, 8, 200) //seuil à régler ici, ex : 300 = net

	// 4) Encoder en PNG
	pngBytes, err := imageproc.EncodeMatrixToPNG(edges)
	if err != nil {
		return
	}

	// 5) Renvoyer les bytes PNG
	_ = netio.WriteFrame(conn, pngBytes)
}
