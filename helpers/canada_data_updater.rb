require_relative '../models/state'

require 'nokogiri'
require 'open-uri'

CANADA_DATA_WIKI = "http://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada"

class CanadaDataUpdater
  def self.load_data
    Nokogiri::HTML(open(CANADA_DATA_WIKI)).xpath("//table[@class='wikitable sortable']/tr").each do |row|
      province_name = self.parse_country(row)
      next if province_name.nil? || province_name.empty?

      state = State.new :name => province_name,
                        :capital => parse_capital(row),
                        :type => "Canada"
      state.upsert
    end
  end

  private

  def self.parse_country(data)
    data.at_xpath('th[3]/a/text()').to_s.strip
  end

  def self.parse_capital(data)
    [data.at_xpath('td[2]/a/text()').to_s.strip]
  end
end
