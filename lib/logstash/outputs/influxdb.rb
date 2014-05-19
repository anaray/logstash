# encoding: utf-8
require "logstash/namespace"
require "logstash/outputs/base"

class LogStash::Outputs::InfluxDB < LogStash::Outputs::Base
  config_name "influxdb"
  milestone 1

  # username to connect to influxdb
  config :hostname, :validate => :string, :required => :true, :default => "localhost"
  config :username, :validate => :string, :required => :true
  config :password, :validate => :string, :required => :true
  config :database, :validate => :string, :required => :true
  config :series_name, :validate => :string, :required => :true
  config :time_field, :validate => :string
  config :time_precision, :validate => :string, :default => "m"

  public
  def register
    require 'influxdb'
    @influxdb = InfluxDB::Client.new
    @influxdb.create_database(@database)
    @logger.info("Connection to InfluxDB at #{@hostname} initialized")
  end

  public
  def receive(event)
    return unless output?(event)
    @influxdb = InfluxDB::Client.new @database, :host => @hostname, :username => @username, :password => @password, :time_precision => @time_precision
    event_hash = event.to_hash
    event_hash.store(:time, event_hash[@time_field]) unless @time_field.nil? 
    @influxdb.write_point(@series_name, event_hash)
  end
end
