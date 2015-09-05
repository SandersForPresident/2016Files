#!/usr/bin/env ruby
#usage bundle exec ruby parse.rb http://transcripts.cnn.com/TRANSCRIPTS/2015.08.26.html
require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'json/ext'
require 'uri'
require '../parsing_script/lib/candidate_quotes/msnbc_parser'

#CandidateQuotes.crawl_cnn(ARGV[0])

puts CandidateQuotes::MSNBCParser.new('http://www.nbcnews.com/id/57810297/ns/msnbc-hardball_with_chris_matthews/').transcript.to_json


