// Create database user for application
db.createUser({ user: "test", pwd: "test", roles: [ { role: "readWrite", db: "test" } ] } );
