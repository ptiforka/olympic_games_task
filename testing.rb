require "test/unit"
require_relative 'main.rb'
require_relative 'import'

class Tests < Test::Unit::TestCase


  def test_finding_requested
    wait_result = {season: 0, medal: 1, year_or_noc: '1992'}
    main_class = Main_Start.new
    assert_equal wait_result, main_class.parse_requested(['top-teams', 'summer', '1992', 'gold'])
  end

  def test_count_of_games
    size_of_file = 271117
    test_object = Parser.new('athlete_events.csv').read_file.length
    assert_equal size_of_file, test_object
  end

end
