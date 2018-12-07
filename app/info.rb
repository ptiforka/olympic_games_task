# frozen_string_literal: true

require "sqlite3"

class Info
  def self.get_season
    {summer: 0, winter: 1}
  end

  def self.get_medals
    {na: 0, gold: 1, silver: 2, bronze: 3}
  end

  def self.get_sex(data)
    {M: 1, F: 0}[data.to_sym]
  end

  def self.get_commands
    {"top-teams" => "read_bd_teams", "medals" => "read_bd_medals"}
  end

  def self.index_info(data)
    {
      id_num:        0,
      name_num:      1,
      sex_num:       2,
      age_num:       3,
      height_num:    4,
      weight_num:    5,
      team_num:      6,
      noc_num:       7,
      year_game_num: 9,
      season_num:    10,
      city_num:      11,
      sport_num:     12,
      event_num:     13,
      medal_num:     14
    }[data.to_sym]
  end
end

class DB_connection
  @db = nil
  def self.get_db_connection
    @db = SQLite3::Database.new "database/olympic_history.db" if @db.nil?
    @db
  end
end
