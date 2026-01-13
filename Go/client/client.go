package main

import (
    "net"
    "fmt"
)

func main() {
    conn, _ := net.Dial("tcp", "127.0.0.1:8000")
    defer conn.Close()

    fmt.Fprintln(conn, "5 5")
    fmt.Fprintln(conn, "0 0 0 0 0")
    fmt.Fprintln(conn, "0 255 255 255 0")
    fmt.Fprintln(conn, "0 255 0 255 0")
    fmt.Fprintln(conn, "0 255 255 255 0")
    fmt.Fprintln(conn, "0 0 0 0 0")

    buf := make([]byte, 4096)
    n, _ := conn.Read(buf)
    fmt.Println(string(buf[:n]))
}