package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, `{"status":"ok"}`)
	})
	fmt.Println("Go service running on :8004")
	http.ListenAndServe(":8004", nil)
}
