#!/usr/bin/env ruby

require 'awesome_print'
require 'csv'
require 'json'

file = File.read(ARGV[0])
data = JSON.parse(file)


# which lists do we have that are current
lists = {}
data['lists'].reject {|l| l['closed']}.each do |list|
  lists[list['id']] = list['name']
end


# build out the cards
cards = []
data['cards'].reject {|c| c['closed']}.each do |c|
  card = OpenStruct.new
  card.version = lists[c['idList']]

  match = c['name'].match(/(?:\(([1-9]?[0-9]+)\))\ ?(.*)|(^\(.*)/)
  card.summary = (match.nil? ? c['name'] : match[2] || match[3])[0..100]
  card.desc = card.summary + "\n\n" + c['desc']
  card.points = match.nil? ? nil : match[1].to_i

  card.desc += "\n\n" + c['url']
  c['attachments'].each do |a|
    card.desc += "\n\n" + a['url']
  end

  cards << card
end


# write the csv
CSV.open(ARGV[1], 'wb') do |csv|
  csv << ['Summary', 'Description', 'Original Estimate', 'Versions']
  cards.each do |card|
    csv << [card.summary, card.desc, card.points, card.version]
  end
end
