# frozen_string_literal: true

require "test/unit"
require_relative "app/launch.rb"
require_relative "app/parser"
require_relative "bar_charts/builder_v2"


class Tests < Test::Unit::TestCase
  def test_finding_requested
    should_returned = {season: 0, medal: 1, year_or_noc: "1992"}
    assert_equal should_returned, Main_Start.parse_command_arguments(%w[summer 1992 gold])
  end

  def test_count_of_games
    size_of_file = 271_117
    test_object = Parser.new("athlete_events.csv").read_file.length
    assert_equal size_of_file, test_object
  end

  def test_start
    should_returned = {season: 1, medal: 3, year_or_noc: "UKR"}
    assert_equal should_returned, Main_Start.parse_command_arguments(%w[bronze UKR winter])
  end

  def test_what_medal
    medals = "all"
    should_returned = "IN (1, 2, 3)"
    assert_equal should_returned, Bar_Charts.new.what_medals(medals)
  end

  def test_read_bd_medals
    data = {year_or_noc: nil, season: nil, medal: nil}
    should_returned = 0
    assert_equal should_returned, Bar_Charts.new.read_bd_medals(data)
  end

  def test_clear_name
    file_name = nil
    should_returned = "V T"
    assert_equal should_returned, Parser.new(file_name).clear_name('V" sadasd" (   te st  )T')
  end

end
