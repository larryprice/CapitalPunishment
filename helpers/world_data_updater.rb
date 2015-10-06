require_relative '../models/state'

require 'nokogiri'
require 'open-uri'

WORLD_DATA_WIKI = "https://en.wikipedia.org/wiki/List_of_national_capitals_in_alphabetical_order"

class WorldDataUpdater
  def self.load_data
    Nokogiri::HTML(open(WORLD_DATA_WIKI)).xpath("//table[@class='wikitable sortable']/tr").each do |row|
      # get country
      country = self.parse_country(row)
      next if country.nil? || country.empty?

      state = State.new :name => country,
                        :capital => parse_capital(row),
                        :type => "World"
      state.upsert
    end

    handle_special_cases
  end

  private

  def self.parse_country(data)
    country = data.at_xpath('td[2]/b/a/text()').to_s.strip

    if country.nil? || country.empty?
      country = data.at_xpath('td[2]/a/text()').to_s.strip
    end

    country
  end

  def self.parse_capital(data)
    capitals = []
    data.xpath('td[1]/a/text()').each { |cap| capitals << cap.to_s.strip }
    capitals
  end

  def self.handle_special_cases
    tonga = State.find_by(name: "Tonga")
    tonga.capital.clear
    tonga.capital << "Nuku'alofa"
    tonga.save
  end
end
