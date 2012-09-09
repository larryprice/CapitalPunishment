require 'nokogiri'
require 'open-uri'
require 'sinatra'

@@answer = Array.new
@@question = ""
@@question_statement = "What is the capital of"
@@all_answers = Array.new
@@game_type = :CAPITALS

get '/' do
  reload
  erb :CountriesAndCapitals
end

post '/check_answer' do
  reload(compare_with_correct_answer(params[:answer].to_s.strip), @data, @country_info)
  erb :CountriesAndCapitals
end

post '/check_us_answer' do
  reload(compare_with_correct_answer(params[:answer].to_s.strip), @data, @country_info, :US)
  erb :StatesAndCapitals
end

post '/switch_to_world_mode' do
  reload(compare_with_correct_answer(params[:answer].to_s.strip), nil, nil)
  erb :CountriesAndCapitals
end

post '/switch_to_us_mode' do
  reload(compare_with_correct_answer(params[:answer].to_s.strip), nil, nil, :US)
  erb :StatesAndCapitals
end

post '/toggle_mode' do
  toggle_game_type
  reload(compare_with_correct_answer(params[:answer].to_s.strip), @data, @country_info)
  erb :CountriesAndCapitals
end

post '/toggle_mode_us' do
  toggle_game_type
  reload(compare_with_correct_answer(params[:answer].to_s.strip), @data, @country_info, :US)
  erb :StatesAndCapitals
end

def compare_with_correct_answer(answer)
  if @@answer.empty? || @@question.empty?
    return ""
  end

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
    return ""
  end

  if @@answer.include?(selected_answer)
    return 'Correct! The capital of ' + @@question.to_s + ' is ' + selected_answer.to_s + '.'
  else
    return 'False. The capital of ' + @@question.to_s + ' is certainly not ' + selected_answer.to_s + '.'
  end
end

def reload(result = nil, old_data = nil, old_info = nil, game_mode = nil)
  if game_mode.nil? || game_mode == :WORLD
    if old_data.nil?
      data = get_world_data
    else
      data = old_data
    end

    if data.nil?
      @error = "Can't find Wikipedia's List Of Countries and Capitals. :("
    else
      if old_info.nil?
        info = check_details(data)
      else
        info = old_info
      end
    end
  else
    if old_data.nil?
      data = get_state_data
    else
      data = old_data
    end
    if data.nil?
      @error = "Can't find Wikipedia's List Of States and Capitals. :("
    else
      if old_info.nil?
        info = check_state_details(data)
      else
        info = old_info
      end
    end
  end

  get_new_question(info)

  @data = data
  @country_info = info

  @result = result
end

def check_details(data)
  details = get_details(data)

  if details.nil?
    @error = 
      "Apparently Wikipedia has changed their table format on the Countries page. :("
  end
  
  details
end

def check_state_details(data)
  details = get_state_details(data)

  if details.nil?
    @error = 
      "Apparently Wikipedia has changed their table format on the US page. :("
  end

  details
end

def get_state_details(data)
  details = data.xpath("//table[@class='wikitable sortable']/tr").map do |row|

    country = row.at_xpath('td[1]/a/text()').to_s.strip
    next if country.nil? || country.empty?
    capital = Array.new
    capital << row.at_xpath('td[4]/a/text()').to_s.strip
    { country => capital }
  end
  details = details.select { |detail| !detail.nil? }

  p details
end

def get_details(data)
  details = data.xpath("//table[@class='wikitable sortable']/tr").map do |row|

    country = row.at_xpath('td[2]/b/a/text()').to_s.strip
    if country.nil? || country.empty?
      country = row.at_xpath('td[2]/a/text()').to_s.strip
      next if country.nil? || country.empty?
    end
    if country != 'Tonga'
      { country => get_capital(row) }
    else
      { country => 'Nukuʻalofa' }
    end
  end

  details = details.select { |detail| !detail.nil? }
end

def get_capital(row)
  capitals = Array.new
  row.xpath('td[1]/a/text()').each { |cap| capitals << cap.to_s.strip }

  capitals
end

def get_world_data
  url = "http://en.wikipedia.org/wiki/List_of_national_capitals"
  Nokogiri::HTML(open(url))
end

def get_state_data
  url = "http://en.wikipedia.org/wiki/List_of_capitals_in_the_United_States"
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
  if @@game_type == :CAPITALS
    @@question = country_info[index].first[0]
    @@answer = country_info[index].first[1]
    generate_answers_for_capitals @@answer, country_info
  else
    possible_questions = country_info[index].first[1]
    @@question = possible_questions[Random.rand(possible_questions.count)]
    @@answer = country_info[index].first[0]
    generate_answers_for_states @@answer, country_info
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

def generate_answers_for_states(right_answer, all_answers)
  answers = Array.new
  answers << right_answer
  filtered_answers = all_answers.delete_if { |a, b| a == right_answer }

  while answers.count < 5
    wrong_answer = filtered_answers[Random.rand(filtered_answers.count)]
    wrong_answer_state = wrong_answer.first[0]
    if !answers.include?(wrong_answer_state)
      answers << wrong_answer_state
    end
  end

  @@all_answers = answers.sort_by {rand}
end

def toggle_game_type
  if @@game_type == :CAPITALS
    @@game_type = :COUNTRIES
    @@question_statement = "Whose capital is"
  else
    @@game_type = :CAPITALS
    @@question_statement = "What is the capital of"
  end
end