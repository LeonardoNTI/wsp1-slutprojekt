require 'sinatra'
require 'sqlite3'
require 'bcrypt'

# Initiera databasanslutningen
def db
  SQLite3::Database.new 'db/training_app.sqlite'
end

# Skapa träningsplan
def generate_training_plan(goal, time_per_week, time_per_session)
  exercises = {
    weight_loss: ['Löpning', 'Cykling', 'Kettlebell svingar', 'Burpees'],
    muscle_gain: ['Bänkpress', 'Knäböj', 'Marklyft', 'Axelpress'],
    general_health: ['Yoga', 'Simning', 'Cykling', 'Löpning']
  }

  # Välj övningar baserat på målet
  selected_exercises = exercises[goal.to_sym]

  # Skapa träningsplanen
  training_plan = {
    name: "#{goal.capitalize} Plan",
    description: "Träningsplan baserad på målet: #{goal.capitalize}",
    exercises: selected_exercises,
    goal: goal,
    time_per_week: time_per_week,
    time_per_session: time_per_session
  }

  return training_plan
end

# Visa inloggningssidan
get '/login' do
  erb :login
end

# Hantera inloggning
post '/login' do
  username = params[:username]
  password = params[:password]

  db = db()
  user = db.execute('SELECT * FROM users WHERE username = ?', username).first

  if user && BCrypt::Password.new(user[2]) == password
    session[:user_id] = user[0]  # Spara användarens id i sessionen
    redirect '/training_plans'
  else
    @error = "Felaktigt användarnamn eller lösenord"
    erb :login
  end
end

# Visa registreringssidan
get '/register' do
  erb :register
end

# Hantera registrering
post '/register' do
  username = params[:username]
  password = params[:password]
  password_hash = BCrypt::Password.create(password)

  db = db()
  db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password_hash])

  session[:user_id] = db.last_insert_row_id
  redirect '/training_plans'
end

# Visa träningsplaner
get '/training_plans' do
  db = db()
  user_id = session[:user_id]

  # Hämta träningsplaner för den inloggade användaren
  @training_plans = db.execute('SELECT * FROM training_plans WHERE user_id = ?', user_id)

  erb :training_plans
end

# Skapa träningsprogram
post '/submit' do
  goal = params[:goal]
  time_per_week = params[:time_per_week]
  time_per_session = params[:time_per_session]

  # Generera träningsplanen baserat på användarens input
  @training_plan = generate_training_plan(goal, time_per_week, time_per_session)

  # Spara träningsplanen i databasen
  db = db()
  db.execute('INSERT INTO training_plans (user_id, name, description, goal, time_per_week, time_per_session) 
             VALUES (?, ?, ?, ?, ?, ?)', 
             [session[:user_id], @training_plan[:name], @training_plan[:description], 
              @training_plan[:goal], @training_plan[:time_per_week], @training_plan[:time_per_session]])

  erb :training_plan
end

# Visa en specifik träningsplan
get '/training_plans/:id' do
  id = params[:id]
  db = db()

  # Hämta träningsplanen
  @training_plan = db.execute('SELECT * FROM training_plans WHERE id = ?', id).first

  erb :training_plan
end

# Logga progress
post '/progress' do
  type = params[:type]
  value = params[:value]
  date = params[:date]

  db = db()
  db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', 
             [session[:user_id], date, value, type])

  redirect '/training_plans'
end

# Logga ut
get '/logout' do
  session.clear
  redirect '/login'
end

# Huvudsida (För att kontrollera om användaren är inloggad)
get '/' do
  if session[:user_id]
    redirect '/training_plans'
  else
    redirect '/login'
  end
end
