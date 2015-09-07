#!/usr/bin/env ruby
# usage bundle exec ruby parse.rb http://transcripts.cnn.com/TRANSCRIPTS/2015.08.26.html
# usage bundle exec ruby parse.rb http://www.nbcnews.com/id/32390017/ns/msnbc-hardball_with_chris_matthews/
require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'json/ext'
require 'uri'
require '../parsing_script/lib/candidate_quotes'
require '../parsing_script/lib/candidate_quotes/abc_parser'

CandidateQuotes.crawl_msnbc(ARGV[0])

# puts CandidateQuotes::MSNBCParser.new('http://www.nbcnews.com/id/57810297/ns/msnbc-hardball_with_chris_matthews/').transcript.to_json

# puts CandidateQuotes::ABCParser.new('http://abcnews.go.com/Politics/week-transcript-sen-bernie-sanders-gov-bobby-jindal/story?id=33383476&singlePage=true').transcript.to_json
