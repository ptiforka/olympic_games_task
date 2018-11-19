require_relative 'bar_charts/builder_v2'
require "sqlite3"




def find_requested #ищем параметры
  for data in ARGV[1..-1]
    if ['winter', 'summer'].include? data
      season = {'winter'=> 1, 'summer'=> 0}[data]
    elsif ['gold', 'silver', 'bronze'].include? data
      medal = {'gold'=> 1, 'silver'=> 2, 'bronze'=> 3}[data]
    else
      year_or_noc = data
    end
  end
  {'season'=> season, 'medal'=> medal, 'year_or_noc'=> year_or_noc}
end


def start#старт программы
  db = SQLite3::Database.new 'database/olympic_history.db'

  if ARGV[0] == 'top-teams'
    data = find_requested
    read_bd_teams(db, data['year_or_noc'], data['season'], data['medal'])

  elsif ARGV[0] == 'medals'
    data = find_requested
    if data['year_or_noc'].nil?
      p 'ошибка, введите NOC'
      return 0
    end
    read_bd_medals(db, data['medal'], data['season'], data['year_or_noc'].upcase)
  else
    puts 'pls input top-teams or medals'
  end
end

start
