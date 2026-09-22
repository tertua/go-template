package routes

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v3"
	"github.com/stretchr/testify/assert"
)

func TestHealthRoute(t *testing.T) {
	app := fiber.New()
	HealthRoute(app)
	NotFoundRoute(app)

	// /healthz must answer 200 even with the 404 catcher registered.
	req := httptest.NewRequest("GET", "/healthz", http.NoBody)
	resp, err := app.Test(req, fiber.TestConfig{Timeout: 0, FailOnTimeout: false})
	assert.NoError(t, err)
	assert.Equal(t, 200, resp.StatusCode)

	// Unknown paths still fall through to the JSON 404.
	req404 := httptest.NewRequest("GET", "/nope", http.NoBody)
	resp404, err := app.Test(req404, fiber.TestConfig{Timeout: 0, FailOnTimeout: false})
	assert.NoError(t, err)
	assert.Equal(t, 404, resp404.StatusCode)
}
