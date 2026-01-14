package api

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/spf13/cobra"
)

var (
	version   = "dev"
	buildTime = "unknown"
	startTime = time.Now()
)

type HealthResponse struct {
	Status    string `json:"status"`
	Version   string `json:"version"`
	BuildTime string `json:"build_time"`
	GoVersion string `json:"go_version"`
	Uptime    string `json:"uptime"`
}

type MessageResponse struct {
	Message string `json:"message"`
}

func Handler(_ *cobra.Command, _ []string) error {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", healthHandler)
	mux.HandleFunc("GET /", rootHandler)
	mux.HandleFunc("GET /api/hello", helloHandler)
	mux.HandleFunc("GET /api/hello/{name}", helloNameHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 10 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
	}

	slog.Info("starting server",
		"port", port,
		"version", version,
		"build_time", buildTime,
	)

	return server.ListenAndServe()
}

func healthHandler(w http.ResponseWriter, _ *http.Request) {
	resp := HealthResponse{
		Status:    "healthy",
		Version:   version,
		BuildTime: buildTime,
		GoVersion: runtime.Version(),
		Uptime:    time.Since(startTime).Round(time.Second).String(),
	}
	writeJSON(w, http.StatusOK, resp)
}

func rootHandler(w http.ResponseWriter, _ *http.Request) {
	resp := MessageResponse{
		Message: "Go Toolbox Example API",
	}
	writeJSON(w, http.StatusOK, resp)
}

func helloHandler(w http.ResponseWriter, _ *http.Request) {
	resp := MessageResponse{
		Message: "Hello, World!",
	}
	writeJSON(w, http.StatusOK, resp)
}

func helloNameHandler(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	resp := MessageResponse{
		Message: "Hello, " + name + "!",
	}
	writeJSON(w, http.StatusOK, resp)
}

func writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		slog.Error("failed to encode response", "error", err)
	}
}
