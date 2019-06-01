# frozen_string_literal: true

require_relative "../app/info"

class Bar_Charts
  def initialize
    @db = DB_connection.get_db_connection
    @medal_index = 1
    @max_medals = 0
  end

  # show results
  def draw(all_medals)
    year_medal = 0
    how_many_medals = 1
    max_bar_charts = 200
    all_medals.each do |medal|
      count_symbols = medal[how_many_medals].to_f / @max_medals * max_bar_charts
      puts "#{medal[year_medal]} #{('█' * count_symbols)} #{medal[how_many_medals]}"
    end
  end

  def what_medals(medal)
    if Info.get_medals.value?(medal)
      "IN (#{medal})"
    else
      "IN (1, 2, 3)"
    end
  end

  def read_bd_medals(season:, medal:, year_or_noc:)
    if year_or_noc.nil?
      p "error... input NOC"
      return 0
    end
    medal = what_medals(medal)
    list_medals = []
    @db.execute("
        SELECT games.year, COUNT(noc_name) medals FROM athletes
           JOIN results ON results.athlete_id = athletes.id
           JOIN games ON game_id = games.id
           JOIN teams ON teams.id = athletes.team_id
          WHERE medal #{medal} AND season = #{season} AND noc_name = '#{year_or_noc.upcase}'
        GROUP BY year
        ORDER BY year ASC
              ")  do |row|
      list_medals << row
      @max_medals = row[@medal_index] if row[@medal_index] > @max_medals
    end
    draw(list_medals)
  end

  # find top teams
  # rubocop:disable Metrics/MethodLength
  def read_bd_teams(season:, medal:, year_or_noc:)
    count_elements_to_show = 8
    all_teams = []
    year_or_noc = if year_or_noc.nil?
                    ""
                  else
                    "year = #{year_or_noc} AND"
                  end
    medal = what_medals(medal)
    if Info.get_season.value?(season)
      puts "result: "
    else
      puts "missing season"
      return
    end

    @db.execute (" SELECT noc_name noc, COUNT(medal) medals FROM results
                LEFT JOIN athletes ON results.athlete_id = athletes.id
                LEFT JOIN games ON results.game_id = games.id
                LEFT JOIN teams ON athletes.team_id = teams.id
               WHERE #{year_or_noc} season = #{season} AND medal #{medal}
              GROUP BY noc_name
              ORDER BY count(medal) DESC") do |row|
      all_teams << row
      @max_medals = row[@medal_index] if row[@medal_index] > @max_medals
    end
    draw(all_teams[0..count_elements_to_show])
  end
end
