def athlet_insert(hash, db)
  puts 'import athletes'
  db.transaction
  hash.each do |pair|
    db.execute "insert into athletes values ( ?, ?, ?, ?, ?, ? )", pair[0], pair[1][0], pair[1][1], pair[1][2], pair[1][3], pair[1][4]
  end
  db.commit
end




