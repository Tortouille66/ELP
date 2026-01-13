package imageproc

import (
    "bufio"
    "fmt"
    "net"
)

type Image struct {
    Width  int
    Height int
    Pixels [][]int
}

func ReceiveImage(reader *bufio.Reader) Image {
    var w, h int
    fmt.Fscan(reader, &w, &h)

    pixels := make([][]int, h)
    for i := 0; i < h; i++ {
        pixels[i] = make([]int, w)
        for j := 0; j < w; j++ {
            fmt.Fscan(reader, &pixels[i][j])
        }
    }
    return Image{w, h, pixels}
}

func SendImage(conn net.Conn, img Image) {
    fmt.Fprintf(conn, "%d %d\n", img.Width, img.Height)
    for i := 0; i < img.Height; i++ {
        for j := 0; j < img.Width; j++ {
            fmt.Fprintf(conn, "%d ", img.Pixels[i][j])
        }
        fmt.Fprintln(conn)
    }
}
