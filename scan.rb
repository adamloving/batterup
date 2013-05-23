#!/usr/bin/env ruby
require 'json'

mac_addr_regexp = /[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}/i
base_ip = '192.168.0.'
range = (1..22)
file_name = ARGV.first || 'data.json'

puts file_name
puts '---'

live_ips = []


begin
  mac_addrs = JSON.parse(open(file_name).read)
  puts "loaded #{mac_addrs.keys.size} mac addresses"
rescue
  puts "new data file"
  mac_addrs = {}
end

# scan IPs to warm up ARP cache
for n in range
  # count 1, timeout 1s
  ip = "#{base_ip}#{n}"
  print "pinging #{ip} ... "
  results = `ping -c 1 -t 1 #{ip}`
  if results.index('1 packets received')
    puts "responded"
    live_ips << ip
  else
    puts "no response"
  end
end

puts "Found these: #{live_ips.inspect}"

puts 'Running arp'
results = `arp -a`

current_mac_addrs = results.scan(mac_addr_regexp)

timestamp = Time.now.to_i

for m in current_mac_addrs
  if mac_addrs[m]
    timespan = timestamp - mac_addrs[m]['last_seen']
    puts "#{m} #{mac_addrs[m]['user']} #{mac_addrs[m]['device']} seen again after #{timespan}s"
  else
    puts "#{m} Seen for the first time ever!"
    mac_addrs[m] = { user: 'Unkown', device: 'Unkown' }
  end
  mac_addrs[m]['last_seen'] = timestamp
end

puts "not seen this time: #{mac_addrs.select { |m| mac_addrs[m]['last_seen'] < timestamp }}"

open(file_name, 'w') { |file| file.write(JSON.pretty_generate(mac_addrs)) }

# say "gibberish"

# afplay

