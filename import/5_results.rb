def results_insert(hash, db)
  puts 'import results'
  db.transaction
  hash.each do |pair|
    db.execute "insert into results values (?, ?, ?, ?, ?, ?)", pair[0], pair[1][1], pair[1][2], pair[1][3], pair[1][4], pair[1][5]
  end
  db.commit
end


