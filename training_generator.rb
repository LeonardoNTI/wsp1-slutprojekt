class TrainingGenerator
  EXERCISES_BY_GROUP = {
    "chest" => ["Bänkpress", "Armhävningar", "Chest Flys", "Incline Bench Press"],
    "back" => ["Marklyft", "Pull-ups", "Rows", "Lat Pulldown"],
    "legs" => ["Knäböj", "Lunges", "Leg Press", "Calf Raises"],
    "shoulders" => ["Military Press", "Lateral Raises", "Front Raises", "Shrugs"],
    "core" => ["Plank", "Russian Twists", "Sit-ups", "Leg Raises"]
  }

  CARDIO_EXERCISES = ["Löpning", "Cykling", "HIIT", "Burpees", "Jumping Jacks", "Rowing", "Jump Rope"]

  def self.generate_schedule(goal, time_per_week, time_per_session)
    schedule = {}
    training_days = []

    # Bestäm träningsdagarna (jämnt fördelade)
    case time_per_week.to_i
    when 1
      training_days = [3]  # Mitt i veckan (onsdag)
    when 2
      training_days = [1, 5]  # Måndag och fredag
    when 3
      training_days = [1, 3, 5]  # Måndag, onsdag, fredag
    when 4
      training_days = [1, 2, 4, 5]  # Måndag, tisdag, torsdag, fredag
    when 5
      training_days = [1, 2, 3, 4, 5]  # Måndag–fredag
    when 6
      training_days = [1, 2, 3, 4, 5, 6]  # Måndag–lördag
    when 7
      training_days = [1, 2, 3, 4, 5, 6, 7]  # Varje dag
    end

    # Beräkna antal övningar per pass baserat på tillgänglig tid
    exercises_per_session = (time_per_session.to_i / 10).clamp(1, 4)

    # Skapa schemat baserat på målet
    if goal == "muscle_gain"
      # Styrketräning: Rotera mellan muskelgrupper
      muscle_groups = EXERCISES_BY_GROUP.keys
      current_group_index = 0

      (1..7).each do |day|
        if training_days.include?(day)
          muscle_group = muscle_groups[current_group_index]
          exercises = EXERCISES_BY_GROUP[muscle_group].sample(exercises_per_session).join(", ")
          schedule["Dag #{day}"] = "Styrketräning (#{muscle_group.capitalize}): #{exercises}"
          current_group_index = (current_group_index + 1) % muscle_groups.length
        else
          schedule["Dag #{day}"] = "Vilodag"
        end
      end
    else
      # Viktförlust: Kondition och helkroppsträning
      (1..7).each do |day|
        if training_days.include?(day)
          exercises = CARDIO_EXERCISES.sample(exercises_per_session).join(", ")
          schedule["Dag #{day}"] = "Kondition: #{exercises}"
        else
          schedule["Dag #{day}"] = "Vilodag"
        end
      end
    end

    schedule
  end
end