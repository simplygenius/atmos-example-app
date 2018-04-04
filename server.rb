require 'sinatra'
require 'sequel'
require 'logger'

DB = nil
if ENV['DB_HOST']
  DB = Sequel.connect(
      adapter: :postgres,
      user: ENV['DB_USER'], password: ENV['DB_PASS'],
      host: ENV['DB_HOST'], port: ENV['DB_PORT'],
      database: ENV['DB_NAME'], max_connections: 10, logger: Logger.new($stdout))

  DB.create_table?(:counter) do
    String :name, primary_key: true
    Integer :value
  end
end

get '/' do
  count = "no db"

  if DB
    ds = DB[:counter]
    rec = ds.where(name: 'hello')

    if 1 != rec.update(value: Sequel[:value]+1)
      ds.insert(name: 'hello', value: 1)
      count = 1
    else
      count = rec.get(:value)
    end
  end

  "Hello World svc_name=#{ENV['SVC_NAME']}, db_counter=#{count}!\n"
end
