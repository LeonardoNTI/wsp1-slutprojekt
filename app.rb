require 'sinatra/base'
require 'sqlite3'

class App < Sinatra::Base
  # Startsidan
  get '/' do
    erb :index
  end

  # Hantera när användaren svarar på frågorna
  post '/submit' do
    # Spara svaren på frågorna
    time = params[:time].to_i
    experience = params[:experience].to_i
    goal = params[:goal] || []  # Flera mål kan väljas
    intensity = params[:intensity].to_i
    duration = params[:duration].to_i

    # Skapa ett träningsprogram baserat på svaren
    training_plan = generate_training_plan(time, experience, goal, intensity, duration)

    # Returnera träningsprogrammet direkt som HTML
    erb :training_plan, locals: { training_plan: training_plan }
  end

  # Generera träningsplan baserat på svaren
  def generate_training_plan(time, experience, goal, intensity, duration)
    plan = ""

    # Mål
    if goal.include?("1")
      plan += "Träningsprogram för viktminskning.\n"
    end
    if goal.include?("2")
      plan += "Träningsprogram för muskelbyggande.\n"
    end
    if goal.include?("3")
      plan += "Träningsprogram för allmän hälsa.\n"
    end

    # Intensitet
    if intensity >= 4
      plan += "Högintensiv träning, fokus på tunga övningar.\n"
    else
      plan += "Lågintensiv träning med fokus på uthållighet.\n"
    end

    # Tid per vecka
    plan += "Du kan träna #{time} dagar per vecka.\n"
    
    # Duration per pass
    plan += "Varje pass kommer att vara ungefär #{duration} minuter.\n"

    # Lägg till erfarenhet
    if experience <= 2
      plan += "Rekommenderat: Nybörjarprogram med grundläggande övningar."
    elsif experience <= 4
      plan += "Rekommenderat: Mellannivåprogram med ökad intensitet."
    else
      plan += "Rekommenderat: Avancerat program med tunga lyft och komplexa övningar."
    end

    plan
  end
end
