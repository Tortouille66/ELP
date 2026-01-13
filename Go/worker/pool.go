package worker

type Job func()

func Pool(n int, jobs <-chan Job) {
    for i := 0; i < n; i++ {
        go func() {
            for job := range jobs {
                job()
            }
        }()
    }
}