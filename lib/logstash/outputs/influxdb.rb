# encoding: utf-8
require "logstash/namespace"
require "logstash/outputs/base"

# This output lets you store data in InfluxDB which enables one to build a time-series metrics
# You can learn more about InfluxDB at <http://influxdb.org/>
class LogStash::Outputs::InfluxDB < LogStash::Outputs::Base
  config_name "influxdb"
  milestone 1

  # hostname of the influxdb server
  config :hostname, :validate => :string, :required => :true, :default => "localhost"

  # username to connect to the influxDB database
  config :username, :validate => :string, :required => :true

  # password of the above username
  config :password, :validate => :string, :required => :true

  # database where the data is stored. It will created if not present, equivalent to database
  # in RDBMS 
  config :database, :validate => :string, :required => :true

  # time series is equivalent to table in RDBMS
  config :series_name, :validate => :string, :required => :true

  # since InfluxDB is a time series database, the time is the primary co-ordinate, to 
  # which data is plotted aganist. time_field lets InfluxDB know the field representing
  # the time in the logstash output. If not present, InfluxDB uses the server timestamp.
  # Note: time_field should be an epoch from 1, Jan 1970 in either seconds, milliseconds, or microseconds.
  # for example : 2014-05-19 14:35:50 +0530 would be 1400490350
  config :time_field, :validate => :string

  # the unit of time field seconds(s),milliseconds(m) or macroseconds(u)) 
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
