require_relative 'bar_charts/builder_v2'
require "sqlite3"

class Main_Start

  def initialize
    @season_hash = {'summer'=> 0, 'winter'=> 1}
    @medals_hash = {'gold'=> 1, 'silver'=> 2, 'bronze'=> 3}
    @db = SQLite3::Database.new 'database/olympic_history.db'
  end

  #normilze the parameters
  def parse_requested(parameters)
    parameters_hash = {year_or_noc: nil, season: nil, medal: nil}
      parameters[1..-1].each do |data|
        if @season_hash.keys.include? data
          parameters_hash.store(:season, @season_hash[data])
        elsif @medals_hash.keys.include? data
          parameters_hash.store(:medal, @medals_hash[data])
        else
          parameters_hash.store(:year_or_noc, data)
        end
      end
  p parameters_hash
  end

  def start
    argument = 0
    show_result = Bar_Charts.new(@db, @medals_hash, @season_hash)
    if ARGV[argument] == 'top-teams'
      show_result.read_bd_teams(parse_requested(ARGV))

    elsif ARGV[argument] == 'medals'

      show_result.read_bd_medals(parse_requested(ARGV))
    else
      puts 'pls input top-teams or medals'
    end
  end
end


if __FILE__ == $PROGRAM_NAME
  Main_Start.new.start
end

