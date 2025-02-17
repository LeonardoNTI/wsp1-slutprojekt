require 'sqlite3'
require 'bcrypt'

class Seeder
  def self.seed
    db = SQLite3::Database.new 'db/training_app.sqlite'
    
    # Se till att databasen är tom innan vi börjar
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS training_plans')
    db.execute('DROP TABLE IF EXISTS progress')

    # Skapa tabeller
    db.execute <<-SQL
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE training_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        value REAL NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL

    # Lägg till en användare med rätt hashad lösenord
    password = BCrypt::Password.create('password123')
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', ['testuser', password])

    # Lägg till träningsplaner
    db.execute('INSERT INTO training_plans (name, description) VALUES (?, ?)', ['Plan A', 'Description for Plan A'])
    db.execute('INSERT INTO training_plans (name, description) VALUES (?, ?)', ['Plan B', 'Description for Plan B'])
    db.execute('INSERT INTO training_plans (name, description) VALUES (?, ?)', ['Plan C', 'Description for Plan C'])

    # Lägg till lite progressdata för användaren
    db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', [1, '2025-01-01', 70.0, 'vikt'])
    db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', [1, '2025-01-02', 69.5, 'vikt'])

    puts "Seeder executed successfully!"
  end
end

# Kör seedern direkt här
Seeder.seed