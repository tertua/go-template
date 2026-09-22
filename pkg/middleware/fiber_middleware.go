package middleware

import (
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/cors"
	"github.com/gofiber/fiber/v3/middleware/logger"
	"github.com/gofiber/fiber/v3/middleware/recover"
	"github.com/gofiber/fiber/v3/middleware/requestid"
)

// FiberMiddleware provide Fiber's built-in middlewares.
// See: https://docs.gofiber.io/api/middleware
func FiberMiddleware(a *fiber.App) {
	a.Use(
		// Recover from panics so one bad handler can't take the server down.
		recover.New(),
		// Add X-Request-ID to each request (reused in logs/traces).
		requestid.New(),
		// Add CORS to each route.
		cors.New(),
		// Add simple logger.
		logger.New(),
	)
}
