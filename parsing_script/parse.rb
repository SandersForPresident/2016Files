#!/usr/bin/env ruby
#usage bundle exec ruby parse.rb http://transcripts.cnn.com/TRANSCRIPTS/2015.08.26.html
require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json/ext'
require 'uri'


class CNNParser
  def initialize(url)
    @url = url
    @page = Nokogiri::HTML(open(url))
  end

  def transcript
    parsed_show = build_show_hash

    parsed_show.to_json
  end

  def unparsed_transcript
    show_text
  end

  private

  def build_show_hash
    parsed_show = {}
    parsed_show[:show_name] = show_name
    parsed_show[:show_title] = show_title
    parsed_show[:quotes] = {}

    begin
      parsed_show[:quotes] = quotes1.collect do |x|
        #puts "speaker: #{x[0]}"#" text:#{x[1]}"
        quote = {}
        quote[:speaker] = x[0].gsub(':', '').gsub('.', '').gsub('--', '').strip
        quote[:text] = x[1].strip
        fail 'bad speaker' if quote[:speaker].length > 100
        quote
      end
    rescue
      #binding.pry
      parsed_show[:quotes] = quotes2.collect do |x|
        #puts "speaker: #{x[0]}"#" text:#{x[1]}"
        quote = {}
        quote[:speaker] = x[0].gsub(':', '').gsub('.', '').gsub('--', '').strip
        quote[:text] = x[1].strip
        fail 'bad speaker' if quote[:speaker].length > 100
        quote
      end
    end

    parsed_show
  end

  def quotes1
    #works 80% of the time
    tokens = show_text.split /([A-Z ,\(\)\-\/\&\']+:)/
    tokens.reject! { |c| c.nil? || c.empty? }
    tokens.each_slice(2).to_a
  end

  def quotes2
    tokens = show_text.split /([A-Z ,\(\)\-\/\&\'\.]+:)/
    tokens.reject! { |c| c.nil? || c.empty? }
    tokens.each_slice(2).to_a
  end

  def show_name
    @page.css('p.cnnTransStoryHead').text
  end

  def show_title
    @page.css('p.cnnTransSubHead').text
  end

  def show_text
    raw = @page.css('p.cnnBodyText:last-child').text

    #remove annotations after a speakers name like STEWART (voice-over):
    raw = raw.gsub(/\([a-z\-]+\)/,'')

    replace_with_blankspace.each do |x|
      raw = raw.gsub(x,'')
    end

    #remove timecodes
    raw = raw.gsub(/\[\d+:\d+:\d+\]/,'')

    replace_with_newlines.each do |x|
      raw = raw.gsub(x,"\n")
    end

    raw
  end

  def replace_with_blankspace
    ['(BEGIN VIDEO CLIP)','(END VIDEO CLIP)','(via telephone)','(CROSSTALK)','(COMMERCIAL BREAK)','(BEGIN VIDEOTAPE)','(END VIDEOTAPE)','(LAUGHTER)',"\t"]
  end

  def replace_with_newlines
    ['--','----','(OFF-MIKE)','(INAUDIBLE QUESTION)','(INAUDIBLE)','(AUDIENCE APPLAUDING)','(AUDIENCE CHEERING AND APPLAUDING)','(LAUGHING)']
  end
end
#puts CNNParser.new('http://transcripts.cnn.com/TRANSCRIPTS/1508/26/ng.01.html').transcript
pass = 0.0
total = 0.0
page = Nokogiri::HTML(open(ARGV[0]))
links = page.css('a')
hrefs = links.map {|link| link.attribute('href')}
hrefs.each do |x|
  if !x.nil? && x.value && x.value.include?('TRANSCRIPTS') && x.value.end_with?('.html')
    total += 1
    url = "http://transcripts.cnn.com/#{x.value}"
    uri = URI.parse(url)
    filename_base = File.basename(uri.path)
    begin
      output = CNNParser.new(url).transcript
      File.write("./output/#{filename_base}.json", output)
      pass += 1
    rescue
      output = CNNParser.new(url).unparsed_transcript
      File.write("./output/#{filename_base}.failed", output)
      puts "failed parsing #{x}"
    end


  end
end
fail = total - pass
puts "passed: #{pass} failed: #{fail} total:#{total}"
puts "success rate:#{100 * (pass / total)}"



