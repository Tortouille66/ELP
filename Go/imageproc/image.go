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