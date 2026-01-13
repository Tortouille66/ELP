package main

import "go/server"

func main() {
    server.StartTCPServer(":8000")
}