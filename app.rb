require 'sinatra/base'
require 'sqlite3'

class App < Sinatra::Base
  # Startsidan
  get '/' do
    erb :index
  end

  # Hantera när användaren svarar på frågorna
  post '/submit' do
    goal = params[:goal]  # Exempel: "weight_loss", "muscle_gain", "general_health"
    days_per_week = params[:time_per_week].to_i  # Hur många dagar per vecka
    time_per_session = params[:time_per_session].to_i  # Hur länge per pass

    training_plan, week_schedule = generate_training_plan(goal, days_per_week, time_per_session)

    erb :training_plan, locals: { training_plan: training_plan, week_schedule: week_schedule }
  end

  # Generera träningsplan baserat på användarens val
  def generate_training_plan(goal, days, time)
    week_schedule = Array.new(7, "Vilodag")  # Alla dagar som vilodagar till att börja med

    # Fördela träningsdagarna på veckans dagar jämnt
    (0...days).each do |i|
      week_schedule[(i * 2) % 7] = "Träningspass"  # Fördela träningsdagarna jämnt med vilodagar mellan
    end

    exercises = {
      "weight_loss" => [
        ["HIIT", "Burpees", "Jump Squats", "Mountain Climbers", "Löpning"],
        ["Roddmaskin", "Snabba steg", "Core-träning", "Box Jumps"]
      ],
      "muscle_gain" => [
        ["Bänkpress", "Axelpress", "Dips", "Tricepspress"],
        ["Marklyft", "Rodd", "Chins", "Bicepscurls"],
        ["Knäböj", "Utfall", "Vadpress", "Leg Curl"]
      ],
      "general_health" => [
        ["Jogging", "Cykling", "Stretching", "Lätt styrka"],
        ["Yoga", "Pilates", "Simning", "Core-träning"]
      ]
    }

    selected_exercises = exercises[goal] || exercises["general_health"]
    
    # Skapa träningsprogrammet
    training_plan = []
    week_schedule.each_with_index do |day, index|
      if day == "Träningspass"
        # Välj övningar beroende på träningsmål och tid
        exercise_group = selected_exercises[index % selected_exercises.length]
        num_exercises = case time
                        when 0..30 then 2
                        when 31..60 then 3
                        else 4
                        end
        selected_exercises_for_day = exercise_group.sample(num_exercises)
        training_plan << { day: get_day_name(index), type: day, exercises: selected_exercises_for_day, time: time }
      else
        training_plan << { day: get_day_name(index), type: day }
      end
    end

    return training_plan, week_schedule
  end

  # En hjälpfunktion för att få namn på veckodagar
  def get_day_name(index)
    days = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]
    days[index]
  end
end
