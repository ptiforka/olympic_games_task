require "csv"
require "sqlite3"
require_relative 'import/1_teams'
require_relative 'import/2_athletes'
require_relative 'import/3_events'
require_relative 'import/4_sports'
require_relative 'import/5_results'
require_relative 'import/6_games'
def read_csv(filename = 'athlete_events.csv') #читаем файл
  puts 'start parsing csv'
  CSV.read(filename)
end


def check(event)
  event == 'NA' ? parameter = 'null': parameter = event #функия дда бы сделать меньше кода
end


def pars_csv(data, time_start) # парсим csv
  all_teams_noc = {} # хэш для всех валидных NOC и их id
  re_clear_name = /(\".+\"|\(.+\))/  #регулярка для чистки имени
  all_games = {} #хэш для всех игр
  result = {}
  medal_type = {
              'NA' => 0, 'Gold' => 1, 'Silver' => 2, 'Bronze' => 3
              }

  athletes = {}
  events_to_import = {}
  sports = {}
  for event in data[1..-1]
    full_name = event[1].sub(re_clear_name, '').sub(re_clear_name, '') #имя
    if event[2] != 'NA' #проверки для пола
      if event[2] == 'F'
        sex = 1
      else sex = 0
      end
    else
      sex = 'null'
    end
    height = check(event[4]) #рост
    weight = check(event[5]) #вес
    event[3] == 'NA' ? year_of_birth = 'null': year_of_birth = 2018 - event[3].to_i #год рождения участника
    if weight == 'null' and height == 'null' #проверки для заполнения правильного json как в задании
      he_we_json = "{}"
    elsif height == 'null'
      he_we_json = "{'weight': #{weight}}"
    elsif weight == 'null'
      he_we_json = "{'height': #{height}}"
    else height and weight != 'null'
      he_we_json = "{'height': #{height},'weight': #{weight}}"
    end

    team_name = event[6].sub(/\-\d+/, '') #регулярка для очистки названия команд
    if all_teams_noc[event[7]].nil? #если такой тимы нет = добавляем вместе с её номером
      all_teams_noc[event[7]] = [team_name, all_teams_noc.length+1]
    end

    year_of_game = event[9].to_i #год игры
    event[10] == 'Summer' ? season = 0: season = 1 #сезон 0 -  лето  1 - зима
    city = event[11] # город в котором прох одило событие
    array_of_city = all_games[[
                                  year_of_game, season
                              ]]

   if year_of_game  != 1906
     if all_games[[
                      year_of_game, season
                  ]].nil?
        all_games.store([
                            year_of_game, season
                        ], [
                            [city], all_games.length+1
                        ])
     elsif not array_of_city[0].include? city
       id_game = array_of_city[1]
       array_of_city[0]<<city
       array_of_city[1]<<id_game
       all_games.store([
                           year_of_game, season
                       ], array_of_city)

     end
   end

    person_id = event[0].to_i


    if athletes[person_id].nil?
      athletes.store(person_id, [
                                full_name, year_of_birth, sex, he_we_json, all_teams_noc[event[7]][1]
      ]) #делаешь хэш который будет передаваться в таблицу sql athletes
    end

    if events_to_import[event[13]].nil? #проверяем если такое событие если нет - добавляем11
      events_to_import.store(event[13], events_to_import.length+1)
    end

    if sports[event[12]].nil? #проверяем есть ли такое спорт если нет - добавляем
      sports.store(event[12], sports.length+1)
    end
    if year_of_game  != 1906 #пропускаем 1906 год и создаем данные для таблицы result
      result.store(result.length+1, [
                                    person_id, person_id ,all_games[[year_of_game, season]][1], sports[event[12]],
                                    events_to_import[event[13]], medal_type[event[14]]
      ])
    end

  end
  puts "parsing time  #{(time_start-Time.now).round(2)}"
  puts 'start import	'

  games_insert(all_games,  db)
  results_insert(result, db)
  sports_insert(sports, db)
  teams_insert(all_teams_noc, db)
  athlet_insert(athletes, db)
  events_insert(events_to_import, db)

  puts "total time#{(time_start-Time.now).round(2)}"

end
pars_csv(read_csv, Time.now)
