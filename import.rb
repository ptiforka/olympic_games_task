require "csv"
require "sqlite3"
require 'json'
require_relative 'info'
require_relative 'import/all_imports'

class Parser

  def initialize(file_name)
    @db = SQLite3::Database.new 'database/olympic_history.db'
    @medal_type = {
        NA: 0, Gold: 1, Silver: 2, Bronze: 3
    }
    @const_info = Info.new
    @file_name = file_name
    @all_teams_noc = {}
    @all_games = {}
    @result = {}
    @athletes = {}
    @events_to_import = {}
    @sports = {}
  end

  def start_pars
    time_start_parsing = Time.now
    create_all_data
    import_db
    puts "total time#{(time_start_parsing-Time.now).round(2)}"
  end

  private def create_all_data

    read_file.each do |event|
      next if event[@const_info.id_num] == 'ID'
      temp_info = generate_info_about_athlet(event)
      generate_hashes(temp_info, event)
    end
  end

  private def generate_info_about_athlet(event)
    full_name = event[@const_info.name_num].gsub(/(\".+\"|\(.+\))/, '').gsub(/\s+/, " ")
    sex = @const_info.gender[event[@const_info.sex_num].to_sym]
    year_birth = event[@const_info.age_num] == 'NA' ? nil : Time.now.year - event[@const_info.age_num].to_i
    he_we_json = get_json_parameters(event[@const_info.height_num], event[@const_info.weight_num])
    year_of_game = event[@const_info.year_game_num].to_i
    person_id = event[@const_info.id_num].to_i
    # season = event[@const_info.season_num] == 'Summer' ? @const_info.summer: @const_info.winter
    season = @const_info.season[event[@const_info.season_num].downcase]
    p season
    sport = event[@const_info.sport_num]
    event_sport = event[@const_info.event_num]
    medal = @medal_type[event[@const_info.medal_num].to_sym]

   {
        full_name: full_name, sex: sex, year_birth: year_birth, he_we_json: he_we_json, year_of_game:year_of_game,
        person_id: person_id, season:season, sport: sport, event_sport: event_sport, medal:medal
    }
  end

  private def generate_hashes(info, event)
    make_team_to_hash(
        event[@const_info.team_num], event[@const_info.noc_num]
    )
    make_hash_allgames(
        info[:year_of_game], info[:season], event[@const_info.city_num]
    )
    make_hash_athletes(
        info[:person_id], event[@const_info.noc_num], info[:full_name], info[:year_birth], info[:sex], info[:he_we_json]
    )
    make_events_hash(event[@const_info.event_num])
    make_sports_hash(info[:sport])
    make_results_hash(
        info[:year_of_game], info[:person_id], info[:season], info[:sport], info[:event_sport], info[:medal]
    )
  end

  def read_file
    puts 'start parsing csv'
    CSV.read(@file_name)
  end

  private def get_parameters(he_or_we)
    he_or_we == 'NA' ? nil: he_or_we
  end

  private def get_json_parameters(height, weight)
    height = get_parameters(height)
    weight = get_parameters(weight)
    params = {}
    params['weight'] = weight if height.nil?
    params['height'] = height if weight.nil?
    params.to_json
  end

  private def make_team_to_hash(team_name, noc)
    if @all_teams_noc[noc].nil?
      @all_teams_noc[noc] = [team_name.sub(/\-\d+/, ''), @all_teams_noc.length+1]
    end
  end

  private def make_hash_allgames(year_of_game, season, city )
    city_id = 0
    #get data for the year and season
    array_of_city = @all_games[[year_of_game, season]]

    if year_of_game  != 1906
      if @all_games[[year_of_game, season]].nil?
        @all_games[[year_of_game, season]] = [[city], @all_games.length+1]
      elsif !array_of_city[city_id].include? city
        array_of_city[city_id]<<city
        @all_games.store([year_of_game, season], array_of_city)
      end
    end
  end

  private def make_hash_athletes(id, noc, full_name, year_of_birth, sex, he_we_json)
    id_noc = 1
    if @athletes[id].nil?
      @athletes.store(id, [
          full_name, year_of_birth, sex, he_we_json, @all_teams_noc[noc][id_noc]
      ])
    end
  end

  private def make_events_hash(event)
    if @events_to_import[event].nil?
      @events_to_import.store(event, @events_to_import.length+1)
    end
  end

  private def make_sports_hash(sport)
    if @sports[sport].nil?
      @sports.store(sport, @sports.length+1)
    end
  end

  private def make_results_hash(year_of_game, person_id, season, sports_num, event_num, medal_num)
    if year_of_game  != 1906
        game_id = 1
        @result.store(@result.length+1, [
          person_id, @all_games[[year_of_game, season]][game_id], @sports[sports_num],
          @events_to_import[event_num], medal_num
      ])
    end
  end

  private def import_db
    Import.new(@db).start(@athletes, @all_games, @result, @sports, @all_teams_noc, @events_to_import)
  end

end

if __FILE__ == $PROGRAM_NAME
  Parser.new('athlete_events.csv').start_pars
end
