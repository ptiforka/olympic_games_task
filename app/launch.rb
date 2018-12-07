# frozen_string_literal: true

require_relative "../bar_charts/builder_v2"
require_relative "info"

class Main_Start
  def self.parse_command_arguments(parameters)
    parameters_hash = {year_or_noc: nil, season: nil, medal: nil}
    parameters.each do |data|
      if Info.get_season.key?(data.to_sym.downcase)
        parameters_hash.store(:season, Info.get_season[data.to_sym])
      elsif Info.get_medals.key?(data.to_sym)
        parameters_hash.store(:medal, Info.get_medals[data.to_sym])
      else
        parameters_hash.store(:year_or_noc, data)
      end
    end
    parameters_hash
  end

  def self.run_bar_charts
    index_command = 0
    unless Info.get_commands.key?(ARGV[index_command])
      puts "pls input top-teams or medals"
      return
    end
    Bar_Charts.new.send(Info.get_commands[ARGV[index_command]], parse_command_arguments(ARGV[1..-1]))
  end
end
