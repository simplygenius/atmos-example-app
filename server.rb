require 'sinatra'
require 'sequel'
require 'logger'

DB = Sequel.connect(
    adapter: :postgres,
    user: ENV['DB_USER'], password: ENV['DB_PASS'],
    host: ENV['DB_HOST'], port: ENV['DB_PORT'],
    database: ENV['DB_NAME'], max_connections: 10, logger: Logger.new($stdout))

DB.create_table?(:counter) do
  String :name, primary_key: true
  Integer :value
end

get '/' do
  ds = DB[:counter]
  rec = ds.where(name: 'hello')

  count = nil
  if 1 != rec.update(value: Sequel[:value]+1)
    ds.insert(name: 'hello', value: 1)
    count = 1
  else
    count = rec.get(:value)
  end

  "Hello World #{count}!\n"
end
