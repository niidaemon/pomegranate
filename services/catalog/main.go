package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, `{"status":"ok"}`)
	})
	fmt.Println("Go service running on :8006")
	http.ListenAndServe(":8006", nil)
}
