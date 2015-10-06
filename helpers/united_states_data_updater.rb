require_relative '../models/state'

require 'nokogiri'
require 'open-uri'

USA_DATA_WIKI = "https://en.wikipedia.org/wiki/List_of_capitals_in_the_United_States"

class UnitedStatesDataUpdater
  def self.load_data
    Nokogiri::HTML(open(USA_DATA_WIKI)).xpath("//table[@class='wikitable sortable']/tr").each do |row|
      state_name = self.parse_country(row)
      next if state_name.nil? || state_name.empty?

      state = State.new :name => state_name,
                        :capital => parse_capital(row),
                        :type => "UnitedStates"
      state.upsert
    end
  end

  private

  def self.parse_country(data)
    data.at_xpath('td[1]/a/text()').to_s.strip
  end

  def self.parse_capital(data)
    [data.at_xpath('td[4]/a/text()').to_s.strip]
  end
end
