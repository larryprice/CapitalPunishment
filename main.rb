require 'nokogiri'
require 'open-uri'
require 'sinatra'

@@answer = Array.new

get '/' do
  reload(true, nil, nil, nil)
  erb :CountriesAndCapitals
end

post '/check_answer' do
  reload(@@answer.include?(answer), @data, @country_info, @game_type)
  erb :CountriesAndCapitals
end

def reload(was_correct, old_data, old_info, game_type)
  @game_type = :CAPITALS
  if old_data.nil?
    data = get_data
  else
    data = old_data
  end

  if data.nil?
    @error = "Can't find Wikipedia's List Of National Capitals. :("
  else
    if old_info.nil?
      country_info = check_details(data)
    else
      country_info = old_info
    end
  end

  get_new_question(country_info)

  @data = data
  @country_info = country_info
end

def check_details(data)
  details = get_details(data)

  if details.nil?
    @error = "Apparently Wikipedia has changed their table format. :("
  end
  
  details
end

def get_details(data)
  details = data.xpath("//table[@class='wikitable sortable']/tr").map do |row|

    country = row.at_xpath('td[2]/b/a/text()').to_s.strip
    if country.empty?
      country = row.at_xpath('td[2]/a/text()').to_s.strip
      if country.empty?
        next
      end
    end

    { country => get_capital(row) }
  end

  details = details.select { |detail| !detail.nil? }
end

def get_capital(row)
  capitals = Array.new

  row.xpath('td[1]/a/text()').each do |cap|
    capitals << cap.to_s.strip
  end

  capitals
end

def get_data
  url = "http://en.wikipedia.org/wiki/List_of_national_capitals"
  Nokogiri::HTML(open(url))
end

def print_output
  if @error.nil?
    puts @details
  else
    puts @error
  end
end

def get_new_question(country_info)
  index = Random.rand(country_info.count)
  if @game_type == :CAPITALS
    @question = country_info[index].first[0]
    @@answer = country_info[index].first[1]
  else
    @question = country_info[index].first[1]
    @@answer = country_info[index].first[0]
  end
end

def toggle_game_type
  if @game_type == :CAPITALS
    @game_type = :COUNTRIES
  else
    @game_type = :CAPITALS
  end
end