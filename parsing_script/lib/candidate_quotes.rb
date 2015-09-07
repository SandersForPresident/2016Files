require 'pry'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'json/ext'
require 'uri'
require_relative('../lib/candidate_quotes/cnn_parser')
require_relative('../lib/candidate_quotes/msnbc_parser')

module CandidateQuotes
  class << self
    def crawl_cnn(url)
      pass = 0.0
      total = 0.0
      page = Nokogiri::HTML(open(url))
      links = page.css('a')
      hrefs = links.map { |link| link.attribute('href') }
      hrefs.each do |x|
        if !x.nil? && x.value && x.value.include?('TRANSCRIPTS') && x.value.end_with?('.html')
          total += 1
          url = "http://transcripts.cnn.com/#{x.value}"
          uri = URI.parse(url)
          filename_base = File.basename(uri.path)
          begin
            output = CNNParser.new(url).transcript
            File.write("./output/#{filename_base}.json", JSON.pretty_generate(output))
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
    end

    def crawl_msnbc(url)
      pass = 0.0
      total = 0.0
      page = Nokogiri::HTML(open(url))
      links = page.css('div.tsmRemaining a[href*="/id"]')
      links.each do |x|
        total += 1
        url = "http://www.nbcnews.com/#{x.attributes['href'].value}"
        filename_base = url.match(/\/id\/[0-9]+\/ns\/(\w|\W)+/)[0].gsub('/', '-')[1..-2]
        begin
          output = MSNBCParser.new(url).transcript
          File.write("./output/#{filename_base}.json", JSON.pretty_generate(output))
          pass += 1
        rescue
          output = MSNBCParser.new(url).unparsed_transcript
          File.write("./output/#{filename_base}.failed", output)
          puts "failed parsing #{x}"
        end
      end

      fail = total - pass
      puts "passed: #{pass} failed: #{fail} total:#{total}"
      puts "success rate:#{100 * (pass / total)}"
    end
  end
end
