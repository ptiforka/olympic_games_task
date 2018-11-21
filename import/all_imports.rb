class Import

  def initialize(db)
    @db = db
  end

  def start(athletes, all_games, result, sports, all_teams_noc, events_to_import)
    athletes_insert(athletes)
    games_insert(all_games)
    results_insert(result)
    sports_insert(sports)
    teams_insert(all_teams_noc)
    events_insert(events_to_import)
  end

  def athletes_insert(hash)
    puts 'import athletes'
    @db.transaction
    hash.each do |pair|
      data ={
          id: pair[0],
          full_name: pair[1][0],
          year: pair[1][1],
          sex: pair[1][2],
          params: pair[1][3],
          team_id: pair[1][4]
      }
      @db.execute "insert into athletes values (:id, :full_name, :year, :sex, :params, :team_id)", data
    end
    @db.commit
  end

  def events_insert(hash)
    @db.transaction
    puts 'import events'
    hash.each do |pair|
      data ={
          event: pair[0],
          event_id: pair[1]
      }
      @db.execute "insert into events values (:event_id, :event)",data
    end
    @db.commit
  end

  def games_insert(hash)
    puts 'import games'
    @db.transaction
    hash.each do |pair|
      data ={
          id: pair[1][1],
          year: pair[0][0],
          season: pair[0][1],
          city: pair[1][0].join(', ')
      }
       @db.execute "insert into games values (:id, :year, :season, :city)", data
    end
    @db.commit
  end

  def results_insert(hash)
    puts 'import results'
    @db.transaction
    hash.each do |pair|
      data = {
          id: pair[0],
          athlete_id: pair[1][0],
          game_id: pair[1][1],
          sport_id:  pair[1][2],
          event_id: pair[1][3],
          medal: pair[1][4]
      }
      @db.execute "insert into results values (:id, :athlete_id, :game_id, :sport_id, :event_id, :medal)", data
    end
    @db.commit
  end

  def sports_insert(hash)
    puts 'import sports'
    @db.transaction
    hash.each do |pair|
      data ={
          sport_id: pair[1],
          sport: pair[0]
      }
      @db.execute "insert into sports values (:sport_id ,:sport)", data
    end
    @db.commit
  end

  def teams_insert(hash)
    @db.transaction
    puts 'import teams'
    hash.each do |pair|
      data = {
          id:  pair[1][1],
          name:  pair[1][0],
          noc_name: pair[0]
      }
      @db.execute "insert into teams values (:id, :name, :noc_name)", data
    end
    @db.commit
  end

end
