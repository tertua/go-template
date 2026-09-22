package main

import (
	"log"
	"os"

	"github.com/tertua/go-template/pkg/configs"
	"github.com/tertua/go-template/pkg/middleware"
	"github.com/tertua/go-template/pkg/routes"
	"github.com/tertua/go-template/pkg/utils"
	"github.com/tertua/go-template/platform/database"

	"github.com/gofiber/fiber/v3"

	_ "github.com/tertua/go-template/docs" // load API Docs files (Swagger)

	_ "github.com/joho/godotenv/autoload" // load .env file automatically
)

// @title API
// @version 1.0
// @description This is an auto-generated API Docs.
// @termsOfService http://swagger.io/terms/
// @contact.name API Support
// @contact.email your@mail.com
// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
// @BasePath /api
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization
func main() {
	// Fail fast on missing/insecure env before touching DB/Redis.
	if err := configs.ValidateEnv(); err != nil {
		log.Fatal("invalid env config: ", err)
	}

	// Define Fiber config.
	config := configs.FiberConfig()

	// Define a new Fiber app with config.
	app := fiber.New(config)

	// Middlewares.
	middleware.FiberMiddleware(app) // Register Fiber's middleware for app.

	// Migrate database schema (SQLite file is auto-created on first run).
	if err := database.Migrate(); err != nil {
		log.Fatal("failed to migrate database: ", err)
	}

	// Routes.
	routes.SwaggerRoute(app)  // Register a route for API Docs (Swagger).
	routes.HealthRoute(app)   // Register liveness probe (must precede NotFoundRoute).
	routes.PublicRoutes(app)  // Register a public routes for app.
	routes.PrivateRoutes(app) // Register a private routes for app.
	routes.NotFoundRoute(app) // Register route for 404 Error.

	// Start server (with or without graceful shutdown).
	if os.Getenv("STAGE_STATUS") == "dev" {
		utils.StartServer(app)
	} else {
		utils.StartServerWithGracefulShutdown(app)
	}
}
