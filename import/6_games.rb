def games_insert(hash, db)
  puts 'import games'
  db.transaction
  hash.each do |pair|
    db.execute "insert into games values (?, ?, ?, ?)", pair[1][2], pair[0][0], pair[0][1], pair[1][0].join(', ')
  end
  db.commit
end

