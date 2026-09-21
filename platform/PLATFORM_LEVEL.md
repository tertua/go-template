# ./platform

**Folder with platform-level logic**. This directory contains all the platform-level logic that will build up the actual project, like _setting up the database_ or _cache server instance_.

- `./platform/cache` folder with in-memory cache setup functions
- `./platform/database` folder with database configuration (PostgreSQL/SQLite via GORM, schema via `AutoMigrate`, no migration files)
