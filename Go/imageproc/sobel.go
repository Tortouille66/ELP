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
	workers := 8

	gx := ConvolveSigned(img, SobelX, workers)
	gy := ConvolveSigned(img, SobelY, workers)

	out := make([][]int, img.Height)
	for y := 0; y < img.Height; y++ {
		out[y] = make([]int, img.Width)
		for x := 0; x < img.Width; x++ {
			// magnitude du gradient
			v := int(math.Sqrt(float64(gx[y][x]*gx[y][x] + gy[y][x]*gy[y][x])))

			// seuillage pour "contours uniquement"
			if v > 300 { // seuil adapté aux valeurs Sobel (souvent > 255)
				out[y][x] = 255
			} else {
				out[y][x] = 0
			}
		}
	}

	return Image{Width: img.Width, Height: img.Height, Pixels: out}
}
