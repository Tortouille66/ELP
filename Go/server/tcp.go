package server

import (
    "bufio"
    "net"
    "go/imageproc"
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
    reader := bufio.NewReader(conn)

    img := imageproc.ReceiveImage(reader)
    result := imageproc.ApplySobel(img)

    imageproc.SendImage(conn, result)
}


