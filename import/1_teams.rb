def teams_insert(hash, db)
  db.transaction
  puts 'import teams'
  hash.each do |pair|
    db.execute "insert into teams values ( ?, ?, ? )", pair[1][1], pair[1][0], pair[0]
  end
  db.commit
end