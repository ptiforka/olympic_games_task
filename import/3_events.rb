def events_insert(hash, db)
  db.transaction
  puts 'import events'
  hash.each do |pair|
    db.execute "insert into events values (?, ?)", pair[1], pair[0]
  end
  db.commit
end

