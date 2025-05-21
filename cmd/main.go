package main

import (
	"log"
	"os"

	"github.com/RickvanCampen/cicd-eindopdracht/db"
	"github.com/RickvanCampen/cicd-eindopdracht/handlers"
	"github.com/RickvanCampen/cicd-eindopdracht/services"

	"github.com/gorilla/sessions"
	"github.com/labstack/echo-contrib/session"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	secretKey := os.Getenv("SECRET_KEY")
	if secretKey == "" {
		log.Println("WARNING: SECRET_KEY not set, using default (not safe for production)")
		secretKey = "secret"
	}

	dbName := os.Getenv("DB_NAME")
	if dbName == "" {
		log.Println("WARNING: DB_NAME not set, using default app_data.db")
		dbName = "app_data.db"
	}

	e := echo.New()

	e.Static("/static", "assets")

	e.HTTPErrorHandler = handlers.CustomHTTPErrorHandler

	// Helpers Middleware
	e.Use(middleware.Recover()) // nu aan, voorkomt crashes
	e.Use(middleware.Logger())

	// Session Middleware
	e.Use(session.Middleware(sessions.NewCookieStore([]byte(secretKey))))

	store, err := db.NewStore(dbName)
	if err != nil {
		e.Logger.Fatalf("failed to create store: %s", err)
	}

	us := services.NewUserServices(services.User{}, store)
	ah := handlers.NewAuthHandler(us)

	ts := services.NewTodoServices(services.Todo{}, store)
	th := handlers.NewTaskHandler(ts)

	// Setting Routes
	handlers.SetupRoutes(e, ah, th)

	// Start Server
	e.Logger.Fatal(e.Start(":8082"))
}
