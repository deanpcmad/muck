server do
  name 'test-server'
  ip_address '127.0.0.1'
  frequency 60

  storage do
    path '/tmp/muck/:name/:app_name/:database'
  end

  database do
    name 'test_db'
    app_name 'test-app'
  end

  database do
    name 'test_sqlite_db'
    app_name 'test-app'
    type 'sqlite'
    path '/var/data/test-app/production.db'
  end
end
