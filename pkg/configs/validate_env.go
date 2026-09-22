package configs

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

// insecureDefaults blocks the placeholder secrets shipped in .env.example.
var insecureDefaults = map[string][]string{
	"JWT_SECRET_KEY":  {"", "secret", "changeme"},
	"JWT_REFRESH_KEY": {"", "refresh", "changeme"},
}

// ValidateEnv fail-fast on missing/insecure config before opening DB/Redis.
// It mirrors platform/database.chooseDB rules so a bad SQL_DSN is rejected early.
func ValidateEnv() error {
	if stage := strings.TrimSpace(os.Getenv("STAGE_STATUS")); stage != "" && stage != "dev" && stage != "prod" {
		return fmt.Errorf("STAGE_STATUS must be \"dev\" or \"prod\", got %q", stage)
	}

	if strings.TrimSpace(os.Getenv("SERVER_HOST")) == "" {
		return fmt.Errorf("SERVER_HOST is required")
	}
	port, err := strconv.Atoi(strings.TrimSpace(os.Getenv("SERVER_PORT")))
	if err != nil || port < 1 || port > 65535 {
		return fmt.Errorf("SERVER_PORT must be 1-65535, got %q", os.Getenv("SERVER_PORT"))
	}
	if v := strings.TrimSpace(os.Getenv("SERVER_READ_TIMEOUT")); v != "" {
		n, err := strconv.Atoi(v)
		if err != nil || n <= 0 {
			return fmt.Errorf("SERVER_READ_TIMEOUT must be a positive integer, got %q", v)
		}
	}

	for _, key := range []string{"JWT_SECRET_KEY", "JWT_REFRESH_KEY"} {
		val := strings.TrimSpace(os.Getenv(key))
		for _, bad := range insecureDefaults[key] {
			if val == bad {
				return fmt.Errorf("%s must be set to a strong value (default %q is not allowed)", key, bad)
			}
		}
		if len(val) < 16 {
			return fmt.Errorf("%s must be at least 16 characters", key)
		}
	}
	for _, key := range []string{"JWT_SECRET_KEY_EXPIRE_MINUTES_COUNT", "JWT_REFRESH_KEY_EXPIRE_HOURS_COUNT"} {
		n, err := strconv.Atoi(strings.TrimSpace(os.Getenv(key)))
		if err != nil || n <= 0 {
			return fmt.Errorf("%s must be a positive integer, got %q", key, os.Getenv(key))
		}
	}

	if dsn := strings.TrimSpace(os.Getenv("SQL_DSN")); dsn != "" &&
		!strings.HasPrefix(dsn, "postgres://") && !strings.HasPrefix(dsn, "postgresql://") {
		return fmt.Errorf("unsupported SQL_DSN: leave empty for SQLite or use postgres://... (MySQL is not supported)")
	}

	if strings.TrimSpace(os.Getenv("REDIS_HOST")) == "" {
		return fmt.Errorf("REDIS_HOST is required")
	}
	redisPort, err := strconv.Atoi(strings.TrimSpace(os.Getenv("REDIS_PORT")))
	if err != nil || redisPort < 1 || redisPort > 65535 {
		return fmt.Errorf("REDIS_PORT must be 1-65535, got %q", os.Getenv("REDIS_PORT"))
	}

	return nil
}
