package imageproc

import "math"

var SobelX = [][]int{
    {-1, 0, 1},
    {-2, 0, 2},
    {-1, 0, 1},
}

var SobelY = [][]int{
    {-1, -2, -1},
    {0, 0, 0},
    {1, 2, 1},
}

func ApplySobel(img Image) Image {
    gx := Convolve(img, SobelX, 8)
    gy := Convolve(img, SobelY, 8)

    out := make([][]int, img.Height)
    for i := range out {
        out[i] = make([]int, img.Width)
        for j := 0; j < img.Width; j++ {
            v := int(math.Sqrt(float64(
                gx.Pixels[i][j]*gx.Pixels[i][j] +
                gy.Pixels[i][j]*gy.Pixels[i][j],
            )))
            out[i][j] = clamp(v)
        }
    }
    return Image{img.Width, img.Height, out}
}