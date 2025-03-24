require 'sinatra/base'
require 'sqlite3'
require 'bcrypt'
require_relative 'training_generator'

set :public_folder, File.dirname(__FILE__) + '/public'


class App < Sinatra::Base
  enable :sessions

  helpers do
    def db
      SQLite3::Database.new('db/training_app.sqlite', results_as_hash: true)
    end
  
    def current_user
      if session[:user_id]
        db.execute('SELECT username FROM users WHERE id = ?', [session[:user_id]]).first
      else
        nil
      end
    end
  end
  
  
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
  
    # Efter registrering, skicka användaren till inloggning
    redirect '/login'
  end
  

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

  post '/submit' do
    redirect '/login' unless session[:user_id]
  
    goal = params[:goal]
    time_per_week = params[:time_per_week]
    time_per_session = params[:time_per_session]
  
    # Generera träningsschemat
    schedule = TrainingGenerator.generate_schedule(goal, time_per_week, time_per_session)
  
    # Omvandla schemat till en enkel sträng (komma-separerad eller annat format)
    schedule_string = schedule.map { |day, activity| "#{day}: #{activity}" }.join(", ")
  
    # Spara träningsplanen i databasen
    db.execute('INSERT INTO training_plans (user_id, name, description, goal, time_per_session, schedule) 
                VALUES (?, ?, ?, ?, ?, ?)', 
                [session[:user_id], "#{goal.capitalize} Plan", "Träningsplan för #{goal.capitalize}", 
                goal, time_per_session, schedule_string])
  
    redirect '/training_plans'
  end  

  # Visa en specifik träningsplan
  get '/training_plans/:id' do
    redirect '/login' unless session[:user_id]

    @training_plan = db.execute('SELECT * FROM training_plans WHERE id = ?', [params[:id]]).first

    # Hämta schemat som en vanlig sträng (ingen JSON.parse behövs)
    @schedule = @training_plan['schedule']  # Detta är nu bara en enkel sträng

    erb :training_plan
  end

  post '/training_plans/:id/delete' do |id|
    db.execute("DELETE FROM training_plans WHERE id = ?", id)
    redirect '/training_plans'
  end

  get '/training_plans/:id/edit' do | id |
    @training_plan = db.execute("SELECT * FROM training_plans WHERE id = ?", id).first
    erb :"edit"
  end

  post '/training_plans/:id/update' do |id|
    name = params[:name]
    description = params[:description]
    goal = params[:goal]
    time_per_session = params[:time_per_session]
    schedule = params[:schedule]
  
    db.execute("UPDATE training_plans SET name = ?, description = ?, goal = ?, time_per_session = ?, schedule = ? WHERE id = ?",
               [name, description, goal, time_per_session, schedule, id])
  
    redirect "/training_plans/#{id}"
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
