require 'sqlite3'
require 'bcrypt'

class Seeder
  def self.seed
    db = SQLite3::Database.new 'db/training_app.sqlite'
    
    # Se till att databasen är tom innan jag börjar
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS training_plans')
    db.execute('DROP TABLE IF EXISTS progress')

    # Skapa tabellerna
    db.execute <<-SQL
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE training_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,  -- Lägg till user_id här
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES users(id)
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

    # Lägg till en användare med rätt hashad lösenord och admin-roll
    password1 = BCrypt::Password.create('123')
    password2 = BCrypt::Password.create('123')
    db.execute('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', ['Leo', password1, 'admin'])
    db.execute('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', ['Hannes', password2, 'user'])

    puts "Seeder executed successfully!"
  end
end

# Kör seedern direkt här
Seeder.seed
