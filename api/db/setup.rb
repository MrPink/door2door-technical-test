require "sequel"
require "aws-sdk"
require "redis"
require "sidekiq"

DB ||= if ENV["RACK_ENV"] == "production"
         Sequel.connect(
           "postgres://#{ENV['RDS_USERNAME']}:#{ENV['RDS_PASSWORD']}@"\
           "#{ENV['RDS_HOSTNAME']}:#{ENV['RDS_PORT']}/#{ENV['RDS_DB_NAME']}"
         )
       else
         Sequel.connect("postgres://postgres@ticker-pg/my_api_#{ENV['RACK_ENV']}")
       end
