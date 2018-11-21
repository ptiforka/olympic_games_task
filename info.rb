class Info
  attr_reader :season, :id_num, :name_num, :sex_num, :age_num, :height_num, :weight_num, :team_num, :noc_num
  attr_reader :year_game_num, :season_num, :city_num, :sport_num, :event_num, :medal_num, :gender
  def initialize
    @season = {'summer' => 0, 'winter' => 1}
    @id_num = 0
    @name_num = 1
    @sex_num = 2
    @age_num = 3
    @height_num = 4
    @weight_num = 5
    @team_num = 6
    @noc_num = 7
    @year_game_num = 9
    @season_num = 10
    @city_num = 11
    @sport_num = 12
    @event_num = 13
    @medal_num = 14
    @gender  = {M: 0, F: 1}
  end
end
