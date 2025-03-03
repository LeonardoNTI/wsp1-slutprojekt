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
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        goal TEXT NOT NULL,
        time_per_session INTEGER,
        schedule TEXT  -- Nytt fält för att spara schemat
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

    # Lägg till träningsplaner för användarna
    user1_id = db.execute('SELECT id FROM users WHERE username = ?', ['Leo']).first[0]  # Hämta id:t som första element i arrayen
    user2_id = db.execute('SELECT id FROM users WHERE username = ?', ['Hannes']).first[0]  # Hämta id:t som första element i arrayen

    # Lägg till träningsplaner för Leo (admin)
    db.execute('INSERT INTO training_plans (user_id, name, description, goal, time_per_session, schedule) VALUES (?, ?, ?, ?, ?, ?)', [user1_id, 'Muskelplan', 'Plan för att bygga muskler', 'Muskeltillväxt', 60, 'Måndag, Onsdag, Fredag'])
    db.execute('INSERT INTO training_plans (user_id, name, description, goal, time_per_session, schedule) VALUES (?, ?, ?, ?, ?, ?)', [user1_id, 'Viktminskning', 'Plan för att bränna fett och gå ner i vikt', 'Viktnedgång', 45, 'Tisdag, Torsdag'])

    # Lägg till träningsplaner för Hannes (user)
    db.execute('INSERT INTO training_plans (user_id, name, description, goal, time_per_session, schedule) VALUES (?, ?, ?, ?, ?, ?)', [user2_id, 'Generell Hälsa', 'En plan för att hålla sig aktiv och frisk', 'Generell Hälsa', 30, 'Måndag, Onsdag, Fredag'])

    puts "Seeder executed successfully!"
  end
end

# Kör seedern direkt här
Seeder.seed
