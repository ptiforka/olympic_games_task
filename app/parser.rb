# frozen_string_literal: true
require "csv"
require "json"
require_relative "../app/info"
require_relative "../import/all_imports"

class Parser
  def initialize(file_name)
    @db = DB_connection.get_db_connection
    @file_name = file_name
    @all_teams_noc = {}
    @all_games = {}
    @result = {}
    @athletes = {}
    @events_to_import = {}
    @sports = {}
    @NA = "NA"
    @banned_year = 1906
  end

  def start_pars
    time_start_parsing = Time.now
    create_all_data
    import_db
    puts "total time#{(time_start_parsing - Time.now).round(2)}"
  end

  def read_file
    puts "start parsing csv"
    CSV.read(@file_name)
  end

  def clear_name(name)
    name.gsub(/(".+"|\(.+\))/, "").gsub(/s+/, " ")
  end

  private

  def create_all_data
    read_file.each do |event|
      next if event[Info.index_info(:id_num)] == "ID"

      temp_info = generate_info_about_athlete(event)
      generate_data(temp_info, event)
    end
  end

  def generate_info_about_athlete(event)
    {full_name:    clear_name(event[Info.index_info("name_num")]),
     sex:          Info.get_sex(event[Info.index_info("sex_num")]),
     year_birth:
                   event[Info.index_info("age_num")] == @NA ?
                       nil : Time.now.year - event[Info.index_info("age_num")].to_i,
     he_we_json:   get_json_parameters(event[Info.index_info("height_num")], event[Info.index_info("weight_num")]),
     year_of_game: event[Info.index_info("year_game_num")].to_i,
     person_id:    event[Info.index_info("id_num")].to_i,
     season:       Info.get_season[event[Info.index_info("season_num")].downcase.to_sym],
     sport:        event[Info.index_info("sport_num")],
     event_sport:  event[Info.index_info("event_num")],
     medal:        Info.get_medals[event[Info.index_info("medal_num")].to_sym.downcase]}
  end


  def generate_data(info, event)
    fill_team_to_hash(
      event[Info.index_info("team_num")], event[Info.index_info("noc_num")]
    )
    fill_hash_allgames(
      info[:year_of_game], info[:season], event[Info.index_info("city_num")]
    )
    fill_hash_athletes(
      info[:person_id], event[Info.index_info("noc_num")],
      info[:full_name], info[:year_birth], info[:sex],
      info[:he_we_json]
    )
    fill_events_hash(event[Info.index_info("event_num")])
    fill_sports_hash(info[:sport])
    fill_results_hash(
      info[:year_of_game], info[:person_id],
      info[:season], info[:sport],
      info[:event_sport], info[:medal]
    )
  end

  def get_parameters(he_or_we)
    he_or_we == @NA ? nil : he_or_we
  end

  def get_json_parameters(height, weight)
    height = get_parameters(height)
    weight = get_parameters(weight)
    params = {}
    params["height"] = height unless height.nil?
    params["weight"] = weight unless weight.nil?
    params.to_json
  end

  def clear_team(team)
    team.gsub(/-d+/, "")
  end

  def fill_team_to_hash(team_name, noc)
    if @all_teams_noc[noc].nil?
      @all_teams_noc[noc] = [clear_name(team_name), @all_teams_noc.length + 1]
    end
  end

  def fill_hash_allgames(year_of_game, season, city)
    city_index = 0
    array_of_city = @all_games[[year_of_game, season]]
    unless year_of_game == @banned_year
      if @all_games[[year_of_game, season]].nil?
        @all_games[[year_of_game, season]] = [[city], @all_games.length + 1]
      elsif !array_of_city[city_index].include? city
        array_of_city[city_index] << city
        @all_games.store([year_of_game, season], array_of_city)
      end
    end
  end

  def fill_hash_athletes(id, noc, full_name, year_of_birth, sex, he_we_json)
    noc_index = 1
    if @athletes[id].nil?
      @athletes.store(id, [
                        full_name, year_of_birth, sex, he_we_json, @all_teams_noc[noc][noc_index]
                      ])
    end
  end

  def fill_events_hash(event)
    if @events_to_import[event].nil?
      @events_to_import.store(event, @events_to_import.length + 1)
    end
  end

  def fill_sports_hash(sport)
    @sports.store(sport, @sports.length + 1) if @sports[sport].nil?
  end

  def fill_results_hash(year_of_game, person_id, season, sports_num, event_num, medal_num)
    unless year_of_game == @banned_year
      game_index = 1
      @result.store(@result.length + 1, [
                      person_id, @all_games[[year_of_game, season]][game_index], @sports[sports_num],
                      @events_to_import[event_num], medal_num
                    ])
    end
  end

  def import_db
    Import.new(@db).start(@athletes, @all_games, @result, @sports, @all_teams_noc, @events_to_import)
  end
end
