#!/usr/bin/env ruby

require 'rubygems'
require 'hpricot'
require 'open-uri'

# send a ganglia metric
def send_metric(name, value, type, unit)
  metric = "gmetric -g Smoker -t #{type} -n \"#{name}\" -v #{value} -u \"#{unit}\" -c /etc/ganglia/gmond.conf"
  puts "sending: #{metric}"
  `#{metric}`
end

#
# reference docs: http://dl.dropbox.com/u/466524/GuruWifi.pdf
#
OK       = 0
HIGH     = 1
LOW      = 2
DONE     = 3
ERROR    = 4
HOLD     = 5
ALARM    = 6
SHUTDOWN = 7

# status.xml, all.xml, or config.xml
host = "cyberq"
doc = open("http://#{host}/config.xml") do
  |f| Hpricot.XML(f)
end

%w(COOK FOOD1 FOOD2 FOOD3).each do |xmlkey|
  temp   = 0
  status = (doc/:nutcallstatus/xmlkey/"#{xmlkey}_STATUS").inner_html
  name   = (doc/:nutcallstatus/xmlkey/"#{xmlkey}_NAME").inner_html

  if status.to_i != ERROR
   temp = (doc/:nutcallstatus/xmlkey/"#{xmlkey}_TEMP").inner_html
  end

  send_metric(name, temp.to_f / 10, 'float', 'Fahrenheit')
end


fan_output = (doc/:nutcallstatus/:OUTPUT_PERCENT).inner_html
send_metric("Fan Output", fan_output, 'uint8', 'Percent')
