require 'sqlite3'
require 'bcrypt'

class Seeder

  # Kör alla steg: droppa, skapa och fylla tabeller
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  # Ta bort gamla tabeller om de finns
  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS progress')
    db.execute('DROP TABLE IF EXISTS training_plans')
    db.execute('DROP TABLE IF EXISTS users')
  end

  # Skapa nödvändiga tabeller
  def self.create_tables
    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                is_admin BOOLEAN NOT NULL DEFAULT 0
                )')

    db.execute('CREATE TABLE training_plans (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                description TEXT NOT NULL,
                goal TEXT NOT NULL
                )')

    db.execute('CREATE TABLE progress (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                date TEXT NOT NULL,
                value REAL NOT NULL,
                type TEXT NOT NULL, -- Exempel: "vikt" eller "bänkpress"
                FOREIGN KEY(user_id) REFERENCES users(id)
                )')
  end

  # Fyll tabellerna med testdata
  def self.populate_tables
    # Skapa admin och vanliga användare med hashade lösenord
    admin_password = BCrypt::Password.create("admin123")
    user1_password = BCrypt::Password.create("kod1")
    user2_password = BCrypt::Password.create("kod2")

    db.execute('INSERT INTO users (username, email, password, is_admin) VALUES (?, ?, ?, ?)', 
               ["admin", "admin@example.com", admin_password, 1])
    db.execute('INSERT INTO users (username, email, password, is_admin) VALUES (?, ?, ?, ?)', 
               ["user1", "user1@example.com", user1_password, 0])
    db.execute('INSERT INTO users (username, email, password, is_admin) VALUES (?, ?, ?, ?)', 
               ["user2", "user2@example.com", user2_password, 0])

    # Skapa träningsscheman
    db.execute('INSERT INTO training_plans (name, description, goal) VALUES (?, ?, ?)', 
               ["Viktminskning", "Ett träningsschema för att gå ner i vikt", "weight_loss"])
    db.execute('INSERT INTO training_plans (name, description, goal) VALUES (?, ?, ?)', 
               ["Muskelbyggnad", "Ett träningsschema för att bygga muskler", "muscle_gain"])

    # Lägg till exempel på progress
    db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', 
               [2, "2025-01-01", 85.0, "vikt"]) # Användare 2 loggar sin vikt
    db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', 
               [2, "2025-01-08", 83.5, "vikt"])
    db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', 
               [3, "2025-01-10", 100.0, "bänkpress"]) # Användare 3 loggar sitt PB
  end

  # Privat metod för att ansluta till databasen
  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/training_app.sqlite')
    @db.results_as_hash = true
    @db
  end
end

# Kör seedern
Seeder.seed!
