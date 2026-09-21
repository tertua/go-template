package database

import (
	"sync"

	"github.com/tertua/go-template/app/models"
	"github.com/tertua/go-template/app/queries"
	"gorm.io/gorm"
)

// Queries struct for collect all app queries.
type Queries struct {
	*queries.UserQueries // load queries from User model
	*queries.BookQueries // load queries from Book model
}

var (
	sharedDB  *gorm.DB
	sharedErr error
	dbOnce    sync.Once
)

// openShared opens the database handle once per process.
func openShared() (*gorm.DB, error) {
	dbOnce.Do(func() {
		sharedDB, sharedErr = chooseDB("SQL_DSN")
	})
	return sharedDB, sharedErr
}

// OpenDBConnection func for opening database connection.
func OpenDBConnection() (*Queries, error) {
	db, err := openShared()
	if err != nil {
		return nil, err
	}

	return &Queries{
		// Set queries from models:
		UserQueries: &queries.UserQueries{DB: db}, // from User model
		BookQueries: &queries.BookQueries{DB: db}, // from Book model
	}, nil
}

// Migrate creates or updates tables from models.
func Migrate() error {
	db, err := openShared()
	if err != nil {
		return err
	}

	return db.AutoMigrate(
		&models.User{},
		&models.Book{},
	)
}
