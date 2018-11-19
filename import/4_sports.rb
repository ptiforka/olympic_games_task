def sports_insert(hash, db)
  puts 'import sports'
  db.transaction
  hash.each do |pair|
    db.execute "insert into sports values (?, ?)", pair[1], pair[0]
  end
  db.commit
end

