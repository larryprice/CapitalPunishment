# This file contains all logic for the CapitalPunishment web app.
# Larry Price 2012

require 'sinatra'
require 'nokogiri'

require 'open-uri'
require 'singleton'

get '/' do
  erb :CountriesAndCapitals
end

post '/check_answer' do
  CountriesAndCapitals.instance.check_answer_and_get_new_question(params[:answer].to_s.strip)
  erb :CountriesAndCapitals
end

post '/check_us_answer' do
  StatesAndCapitals.instance.check_answer_and_get_new_question(params[:answer].to_s.strip)
  erb :StatesAndCapitals
end

post '/switch_to_world_mode' do
  CountriesAndCapitals.instance.reset_result
  erb :CountriesAndCapitals
end

post '/switch_to_us_mode' do
  StatesAndCapitals.instance.reset_result
  erb :StatesAndCapitals
end

post '/toggle_mode' do
  CountriesAndCapitals.instance.toggle_game_type_and_get_new_question
  erb :CountriesAndCapitals
end

post '/toggle_mode_us' do
  StatesAndCapitals.instance.toggle_game_type_and_get_new_question
  erb :StatesAndCapitals
end

#Base class for flavors of CapitalPunishment game
class CountriesAndCapitalsBase
  def load_data
    @data = Nokogiri::HTML(open(@url))
  end

  def get_new_question
    index = Random.rand(@info.count)
    if @game_type == :CAPITALS
      @question = @info[index].first[0]
      @answer = @info[index].first[1]
      generate_answers_for_capitals
    else
      possible_questions = @info[index].first[1]
      @question = possible_questions[Random.rand(possible_questions.count)]
      @answer = @info[index].first[0]
      generate_answers_for_states
    end
  end
  
  def generate_answers_for_capitals
    answers = Array.new
    answers << @answer[Random.rand(@answer.count)]
    filtered_answers = @info.delete_if { |a, b| b == @answer }

    while answers.count < 5
      wrong_answer = filtered_answers[Random.rand(filtered_answers.count)]
      wrong_answer_caps = wrong_answer.first[1]
      answer_to_add = wrong_answer_caps[Random.rand(wrong_answer_caps.count)]
      if !answers.include?(answer_to_add)
        answers << answer_to_add
      end
    end

    @all_answers = answers.sort_by {rand}
  end

  def generate_answers_for_states
    answers = Array.new
    answers << @answer
    filtered_answers = @info.delete_if { |a, b| a == @answer }

    while answers.count < 5
      wrong_answer = filtered_answers[Random.rand(filtered_answers.count)]
      wrong_answer_state = wrong_answer.first[0]
      if !answers.include?(wrong_answer_state)
        answers << wrong_answer_state
      end
    end

    @all_answers = answers.sort_by {rand}
  end

  def toggle_game_type
    if !@game_type.nil? && @game_type == :CAPITALS
      @game_type = :COUNTRIES
      @question_statement = "Whose capital is"
    else
      @game_type = :CAPITALS
      @question_statement = "What is the capital of"
    end
  end

  def toggle_game_type_and_get_new_question
    toggle_game_type
    get_new_question
    reset_result
  end

  def check_answer_and_get_new_question(answer)
    compare_with_correct_answer(answer)
    get_new_question
  end

  def compare_with_correct_answer(answer)
    if @answer.empty? || @question.empty?
      return ""
    end

    case answer
    when "first"
      selected_answer = @all_answers[0]
    when "second"
      selected_answer = @all_answers[1]
    when "third"
      selected_answer = @all_answers[2]
    when "fourth"
      selected_answer = @all_answers[3]
    when "fifth"
      selected_answer = @all_answers[4]
    else
      return ""
    end

    if @answer.include?(selected_answer)
      @result = 'Correct! The capital of ' + @question.to_s \
        + ' is ' + selected_answer.to_s + '.'
    else
      @result = 'False. The capital of ' + @question.to_s \
        + ' is certainly not ' + selected_answer.to_s + '.'
    end
  end

  def load_details
    @info = Array.new
  end

  def reset_result
    @result = ""
  end

  def get_all_answers
    @all_answers = Array.new(5) if @all_answers.nil?
    @all_answers
  end

  def get_answer
    @answer
  end

  def get_question
    @question
  end

  def get_question_statement
    @question_statement
  end

  def get_result
    reset_result if @result.nil?
    @result
  end
end

# Class for loading data for worldwide states and capitals
class CountriesAndCapitals < CountriesAndCapitalsBase
  include Singleton
  def initialize
    toggle_game_type
    @url = "http://en.wikipedia.org/wiki/List_of_national_capitals"
    load_data
    load_details
    get_new_question
  end

  def load_details
    details = @data.xpath("//table[@class='wikitable sortable']/tr").map do |row|

      country = row.at_xpath('td[2]/b/a/text()').to_s.strip
      if country.nil? || country.empty?
        country = row.at_xpath('td[2]/a/text()').to_s.strip
        next if country.nil? || country.empty?
      end
      if country != 'Tonga'
        { country => get_capital(row) }
      else
        { country => ['Nuku\'alofa'] }
      end
    end

    @info = details.select { |detail| !detail.nil? }
  end

  def get_capital(row)
    capitals = Array.new
    row.xpath('td[1]/a/text()').each { |cap| capitals << cap.to_s.strip }

    capitals
  end
end

# Class for loading data for US States and Capitals
class StatesAndCapitals < CountriesAndCapitalsBase
  include Singleton
  def initialize
    toggle_game_type
    @url = "http://en.wikipedia.org/wiki/List_of_capitals_in_the_United_States"
    load_data
    load_details
    get_new_question
  end

  def load_details
    details = @data.xpath("//table[@class='wikitable sortable']/tr").map do |row|

      country = row.at_xpath('td[1]/a/text()').to_s.strip
      next if country.nil? || country.empty?
      capital = Array.new
      capital << row.at_xpath('td[4]/a/text()').to_s.strip
      { country => capital }
    end
    
    @info = details.select { |detail| !detail.nil? }
  end
end