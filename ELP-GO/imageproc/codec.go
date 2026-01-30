package imageproc

import (
	"bytes"
	"image"
	"image/color"
	_ "image/jpeg"
	"image/png"
	_ "image/png"
)

func DecodeToGrayMatrix(data []byte) (Image, error) {
	src, _, err := image.Decode(bytes.NewReader(data))
	if err != nil {
		return Image{}, err
	}

	b := src.Bounds()
	w, h := b.Dx(), b.Dy()

	pixels := make([][]int, h)
	for y := 0; y < h; y++ {
		pixels[y] = make([]int, w)
		for x := 0; x < w; x++ {
			r, g, bb, _ := src.At(b.Min.X+x, b.Min.Y+y).RGBA()
			// RGBA() -> 16 bits [0..65535], on ramène à 8 bits
			rr := float64(r) / 257.0
			gg := float64(g) / 257.0
			bb8 := float64(bb) / 257.0
			gray := int(0.299*rr + 0.587*gg + 0.114*bb8)
			pixels[y][x] = gray
		}
	}

	return Image{Width: w, Height: h, Pixels: pixels}, nil
}

func EncodeMatrixToPNG(img Image) ([]byte, error) {
	out := image.NewGray(image.Rect(0, 0, img.Width, img.Height))
	for y := 0; y < img.Height; y++ {
		for x := 0; x < img.Width; x++ {
			out.SetGray(x, y, color.Gray{Y: uint8(clamp(img.Pixels[y][x]))})
		}
	}

	var buf bytes.Buffer
	if err := png.Encode(&buf, out); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}
