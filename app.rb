require 'sinatra/base'
require 'sqlite3'
require 'bcrypt'

class App < Sinatra::Base
  enable :sessions

  # Initiera databasanslutningen
  def db
    SQLite3::Database.new('db/training_app.sqlite', results_as_hash: true)
  end

  # Start-sida
  get '/' do
    if session[:user_id]
      redirect '/training_plans'
    else
      redirect '/login'
    end
  end

  # INLOGGNING & REGISTRERING 
  get '/login' do
    erb :login
  end

  post '/login' do
    username = params[:username]
    password = params[:password]

    user = db.execute('SELECT * FROM users WHERE username = ?', [username]).first

    if user && BCrypt::Password.new(user['password']) == password
      session[:user_id] = user['id']
      session[:role] = user['role']  # Sparar admin-roll om den finns
      redirect '/training_plans'
    else
      @error = "Felaktigt användarnamn eller lösenord"
      erb :login
    end
  end

  get '/register' do
    erb :register
  end

  post '/register' do
    username = params[:username]
    password = params[:password]
    password_hash = BCrypt::Password.create(password)

    db.execute('INSERT INTO users (username, password, role) VALUES (?, ?, ?)', [username, password_hash, 'user'])

    session[:user_id] = db.last_insert_row_id
    session[:role] = 'user'

    redirect '/training_plans'
  end

  # TRÄNINGSPLANER 
  get '/training_plans' do
    redirect '/login' unless session[:user_id]

    # Hämta användarens träningsplaner
    @training_plans = db.execute('SELECT * FROM training_plans WHERE user_id = ?', [session[:user_id]])

    # Om användaren inte har några träningsplaner, skicka till formuläret för att skapa en
    if @training_plans.empty?
      redirect '/index'
    else
      erb :training_plans
    end
  end

  # Visa formuläret för att skapa träningsplan
  get '/index' do
    erb :index
  end

  # Hantera skapande av träningsplan
  post '/submit' do
    redirect '/login' unless session[:user_id]

    goal = params[:goal]
    time_per_week = params[:time_per_week]
    time_per_session = params[:time_per_session]

    # Generera träningsplanen baserat på användarens input
    training_plan = {
      name: "#{goal.capitalize} Plan",
      description: "Träningsplan för #{goal.capitalize}",
      goal: goal,
      time_per_week: time_per_week,
      time_per_session: time_per_session
    }

    # Spara träningsplanen i databasen
    db.execute('INSERT INTO training_plans (user_id, name, description, goal, time_per_week, time_per_session) 
                VALUES (?, ?, ?, ?, ?, ?)', 
                [session[:user_id], training_plan[:name], training_plan[:description], 
                training_plan[:goal], training_plan[:time_per_week], training_plan[:time_per_session]])

    redirect '/training_plans'
  end

  get '/training_plans/:id' do
    redirect '/login' unless session[:user_id]

    @training_plan = db.execute('SELECT * FROM training_plans WHERE id = ?', [params[:id]]).first
    erb :training_plan
  end

  # PROGRESS-LOGGNING 
  post '/progress' do
    redirect '/login' unless session[:user_id]

    type = params[:type]
    value = params[:value]
    date = params[:date]

    db.execute('INSERT INTO progress (user_id, date, value, type) VALUES (?, ?, ?, ?)', 
               [session[:user_id], date, value, type])

    redirect '/training_plans'
  end

  # LOGGA UT 
  get '/logout' do
    session.clear
    redirect '/login'
  end

  # ADMIN-FUNKTION 
  get '/admin' do
    redirect '/login' unless session[:role] == 'admin'

    @users = db.execute('SELECT * FROM users')
    @plans = db.execute('SELECT * FROM training_plans')

    erb :admin
  end
end
