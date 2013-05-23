#!/usr/bin/env ruby
require 'json'

mac_addr_regexp = /[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}:[0-9A-F]{1,2}/i
interval_before_welcome = 3600 # one hour
base_ip = '192.168.0.'
range = (1..22)
file_name = ARGV.first || 'data.json'

live_ips = []

begin
  known_addrs = JSON.parse(open('known_addrs.json').read)
  puts "loaded #{known_addrs.keys.size} known mac addresses"
rescue
  puts "no known_addrs.json file"
  known_addrs = {}
end

begin
  mac_addrs = JSON.parse(open(file_name).read)
  puts "loaded history info on #{mac_addrs.keys.size} mac addresses"
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
  print "#{m} "
  known_user = known_addrs[m]
  user_name = known_user ? known_user['name'] : 'Somebody'
  user_device = known_user ? known_user['device'] : 'Unknown device'

  if mac_addrs[m]
    interval_missing = timestamp - mac_addrs[m]['last_seen']
    phrase = "#{user_name} (#{user_device}) is back after #{(interval_missing.to_f / 3600.to_f).round(2)} hours"
    puts phrase

    if interval_missing > interval_before_welcome
      `say "#{phrase}"`
    end
  else
    phrase = "#{user_name} (#{user_device}) seen for the first time ever!"
    puts phrase
    `say "#{phrase}"`
    mac_addrs[m] = { }
  end
  mac_addrs[m]['last_seen'] = timestamp
end

puts "not seen this time: #{mac_addrs.select { |m| mac_addrs[m]['last_seen'] < timestamp }}"

open(file_name, 'w') { |file| file.write(JSON.pretty_generate(mac_addrs)) }


