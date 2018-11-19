def draw(all_medals, max_medals) #выводим стату
  for medal in all_medals
    if all_medals[1] != 0
      p "#{medal[0]} #{( '█' * (medal[1].to_f/max_medals*200))}  #{medal[1]}"
    end
  end
end


def read_bd_medals(db,medal, season, noc) #ищем медали по запросу
  if [1, 2, 3].include? medal
    medal = "IN (#{medal})"
  else
    medal = 'IN (1, 2, 3)'
  end
  max_medals = 0
  list_medals = []
  db.execute("SELECT DISTINCT year, COUNT(noc_name) medals from games
               LEFT JOIN (
                SELECT noc_name, y FROM teams
                 LEFT JOIN athletes ON athletes.team_id = teams.id
                  INNER JOIN (
                    SELECT id, year y from games WHERE games.season = #{season}
                  ) AS GAM ON RES.game_id = GAM.id
                  INNER JOIN (
                    SELECT * from results WHERE results.medal #{medal}
                  ) AS RES ON RES.athlete_id = athletes.id
                 WHERE noc_name = '#{noc}'
               ) AS MEDALS ON year = MEDALS.y
            GROUP BY year
         ORDER BY year ASC")  do |row|
      list_medals << row
    if row[1] > max_medals
      max_medals = row[1]
    end
  end
  draw(list_medals, max_medals)
end


def read_bd_teams(db, year, season, medal)#ищем топ тимы
  max = 0
  all_teams = []
  if year.nil?
    year = ''
  else
    year = "year = #{year} AND"
  end

  if [1, 2, 3].include? medal
    medal = "IN (#{medal})"
  else
    medal = 'IN (1, 2, 3)'
  end
  if [0, 1].include? season
    puts 'result: '
  else
    puts 'отсутствует season'
    return 0
  end
  db.execute ("SELECT noc_name noc, COUNT(medal) medals FROM results
                LEFT JOIN athletes ON results.athlete_id = athletes.id
                LEFT JOIN games ON results.game_id = games.id
                LEFT JOIN teams ON athletes.team_id = teams.id
               WHERE #{year} season = #{season} AND medal #{medal}
              GROUP BY noc_name
              ORDER BY count(medal) DESC") do |row|
    all_teams << row
    if row[1] > max
      max = row[1]
    end
  end
  draw(all_teams[0..8], max)
end


