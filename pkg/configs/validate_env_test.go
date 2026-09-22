package configs

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func setTestEnv(t *testing.T) {
	t.Setenv("STAGE_STATUS", "dev")
	t.Setenv("SERVER_HOST", "0.0.0.0")
	t.Setenv("SERVER_PORT", "5000")
	t.Setenv("SERVER_READ_TIMEOUT", "60")
	t.Setenv("JWT_SECRET_KEY", "test-secret-key-1234")
	t.Setenv("JWT_REFRESH_KEY", "test-refresh-key-1234")
	t.Setenv("JWT_SECRET_KEY_EXPIRE_MINUTES_COUNT", "15")
	t.Setenv("JWT_REFRESH_KEY_EXPIRE_HOURS_COUNT", "720")
	t.Setenv("SQL_DSN", "")
	t.Setenv("REDIS_HOST", "localhost")
	t.Setenv("REDIS_PORT", "6379")
}

func TestValidateEnvOK(t *testing.T) {
	setTestEnv(t)
	assert.NoError(t, ValidateEnv())
}

func TestValidateEnvRejectsDefaultSecrets(t *testing.T) {
	setTestEnv(t)
	t.Setenv("JWT_SECRET_KEY", "secret")
	assert.Error(t, ValidateEnv())

	setTestEnv(t)
	t.Setenv("JWT_REFRESH_KEY", "refresh")
	assert.Error(t, ValidateEnv())
}

func TestValidateEnvRejectsBadPortAndDSN(t *testing.T) {
	setTestEnv(t)
	t.Setenv("SERVER_PORT", "abc")
	assert.Error(t, ValidateEnv())

	setTestEnv(t)
	t.Setenv("SQL_DSN", "mysql://user:pass@localhost/db")
	assert.Error(t, ValidateEnv())

	setTestEnv(t)
	t.Setenv("STAGE_STATUS", "staging")
	assert.Error(t, ValidateEnv())
}
