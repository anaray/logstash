# encoding: utf-8
require "logstash/namespace"
require "logstash/outputs/base"

class LogStash::Outputs::InfluxDB < LogStash::Outputs::Base
  config_name "influxdb"
  milestone 1

  # username to connect to influxdb
  config :username, :validate => :string, :required => :true
  config :password, :validate => :string, :required => :true
  config :database, :validate => :string, :required => :true
  config :series_name, :validate => :string, :required => :true


  public
  def register
    require 'influxdb'
  end

  public
  def receive(event)
    return unless output?(event)
  end
end
