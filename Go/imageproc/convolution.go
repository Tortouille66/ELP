// func Convolve(img Image, kernel [][]int, workers int) Image {
//     output := make([][]int, img.Height)
//     for i := range output {
//         output[i] = make([]int, img.Width)
//     }

//     var wg sync.WaitGroup
//     jobs := make(chan int)

//     worker := func() {
//         defer wg.Done()
//         for y := range jobs {
//             for x := 1; x < img.Width-1; x++ {
//                 sum := 0
//                 for ky := -1; ky <= 1; ky++ {
//                     for kx := -1; kx <= 1; kx++ {
//                         sum += kernel[ky+1][kx+1] * img.Pixels[y+ky][x+kx]
//                     }
//                 }
//                 if sum < 0 {
//                     sum = 0
//                 }
//                 if sum > 255 {
//                     sum = 255
//                 }
//                 output[y][x] = sum
//             }
//         }
//     }

//     wg.Add(workers)
//     for i := 0; i < workers; i++ {
//         go worker()
//     }

//     for y := 1; y < img.Height-1; y++ {
//         jobs <- y
//     }
//     close(jobs)

//     wg.Wait()
//     return Image{img.Width, img.Height, output}
// }


package imageproc

import "sync"

func Convolve(img Image, kernel [][]int, workers int) Image {
    out := make([][]int, img.Height)
    for i := range out {
        out[i] = make([]int, img.Width)
    }

    jobs := make(chan int)
    var wg sync.WaitGroup

    worker := func() {
        defer wg.Done()
        for y := range jobs {
            for x := 1; x < img.Width-1; x++ {
                sum := 0
                for ky := -1; ky <= 1; ky++ {
                    for kx := -1; kx <= 1; kx++ {
                        sum += kernel[ky+1][kx+1] * img.Pixels[y+ky][x+kx]
                    }
                }
                out[y][x] = clamp(sum)
            }
        }
    }

    wg.Add(workers)
    for i := 0; i < workers; i++ {
        go worker()
    }

    for y := 1; y < img.Height-1; y++ {
        jobs <- y
    }
    close(jobs)

    wg.Wait()
    return Image{img.Width, img.Height, out}
}