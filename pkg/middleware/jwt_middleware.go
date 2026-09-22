package middleware

import (
	"os"

	"github.com/gofiber/fiber/v3"

	jwtMiddleware "github.com/gofiber/contrib/v3/jwt"
)

// JWTProtected func for specify routes group with JWT authentication.
// See: https://github.com/gofiber/contrib/jwt
func JWTProtected() func(fiber.Ctx) error {
	// Create config for JWT authentication middleware.
	config := jwtMiddleware.Config{
		SigningKey:   jwtMiddleware.SigningKey{Key: []byte(os.Getenv("JWT_SECRET_KEY"))},
		ErrorHandler: jwtError,
	}

	return jwtMiddleware.New(config)
}

func jwtError(c fiber.Ctx, err error) error {
	// Missing token -> 400. Check the header directly instead of matching
	// the upstream error string, which varies between jwt versions.
	if c.Get("Authorization") == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": true,
			"msg":   "Missing or malformed JWT",
		})
	}

	// Return status 401 and failed authentication error.
	return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
		"error": true,
		"msg":   err.Error(),
	})
}
