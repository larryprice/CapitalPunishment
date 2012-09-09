require 'nokogiri'
require 'open-uri'
require 'sinatra'

@@answer = Array.new
@@question = ""
@@all_answers = Array.new

get '/' do
  reload
  erb :CountriesAndCapitals
end

post '/check_answer' do
  reload(compare_with_correct_answer(params[:answer].to_s.strip), @data, @country_info, @game_type)
  erb :CountriesAndCapitals
end

def compare_with_correct_answer(answer)
  case answer
  when "first"
    selected_answer = @@all_answers[0]
  when "second"
    selected_answer = @@all_answers[1]
  when "third"
    selected_answer = @@all_answers[2]
  when "fourth"
    selected_answer = @@all_answers[3]
  when "fifth"
    selected_answer = @@all_answers[4]
  else
    return "No answer selected. Not sure how you did that, but bully for you."
  end

  if @@answer.include?(selected_answer)
    return 'Correct! The capital of ' + @@question.to_s + ' is ' + selected_answer.to_s + '.'
  else
    return 'False. The capital of ' + @@question.to_s + ' is certainly not ' + selected_answer.to_s + '. Try harder'
  end
end

def reload(result = nil, old_data = nil, old_info = nil, game_type = nil)
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

  @result = result
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
    if country != 'Tonga'
      { country => get_capital(row) }
    else
      { country => 'Nuku\'alofa' }
    end
  end

  p details

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
    @@question = country_info[index].first[0]
    @@answer = country_info[index].first[1]
    generate_answers_for_capitals @@answer, country_info
  else
    @@question = country_info[index].first[1]
    @@answer = country_info[index].first[0]
  end
end

def generate_answers_for_capitals(right_answer, all_answers)
  answers = Array.new
  answers << right_answer[Random.rand(right_answer.count)]
  filtered_answers = all_answers.delete_if { |a, b| b == right_answer }
  while answers.count < 5
      wrong_answer = filtered_answers[Random.rand(filtered_answers.count)]
      wrong_answer_caps = wrong_answer.first[1]
      answer_to_add = wrong_answer_caps[Random.rand(wrong_answer_caps.count)]
      if !answers.include?(answer_to_add)
        answers << answer_to_add
      end
  end

  @@all_answers = answers.sort_by {rand}
end

def toggle_game_type
  if @game_type == :CAPITALS
    @game_type = :COUNTRIES
  else
    @game_type = :CAPITALS
  end
end