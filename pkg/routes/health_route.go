package routes

import "github.com/gofiber/fiber/v3"

// HealthRoute func for describe the liveness probe.
// Intentionally outside /api/v1 and without Swagger annotation:
// load balancers and Docker HEALTHCHECK hit it directly.
func HealthRoute(a *fiber.App) {
	a.Get("/healthz", func(c fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status": "ok",
		})
	})
}
