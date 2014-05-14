# encoding: utf-8
require "logstash/namespace"
require "logstash/outputs/base"

class LogStash::Outputs::InfluxDB < LogStash::Outputs::Base
  config_name "influxdb"
  milestone 1

  public
  def register
    require 'influxdb'
  end

  public
  def receive(event)
    return unless output?(event)
  end
end
