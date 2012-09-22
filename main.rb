# This file contains all logic for the CapitalPunishment web app.
# Larry Price 2012

require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'singleton'

get '/' do
  CapitalPunishment.instance.set_current World.instance
  erb :CountriesAndCapitals
end

post '/check_answer' do
  CapitalPunishment.instance.current.check_answer_and_get_new_question(params[:answer].to_s.strip)
  erb :CountriesAndCapitals
end

post '/World' do
  CapitalPunishment.instance.set_current World.instance
  erb :CountriesAndCapitals
end

post '/UnitedStates' do
  CapitalPunishment.instance.set_current UnitedStates.instance
  erb :CountriesAndCapitals
end

post '/Canada' do
  CapitalPunishment.instance.set_current Canada.instance
  erb :CountriesAndCapitals
end

post '/Mexico' do
  CapitalPunishment.instance.set_current Mexico.instance
  erb :CountriesAndCapitals
end

post '/toggle' do
  CapitalPunishment.instance.current.toggle_game_type_and_get_new_question
  erb :CountriesAndCapitals
end

# Class to choose which class to use
class CapitalPunishment
  include Singleton
  
  def initialize
    @instance = World.instance
  end

  def current
    return @instance
  end

  def set_current(current)
    @instance = current
    @instance.reset
  end

  def get_image_string
    return "images/" + @instance.class.name.downcase + ".png"
  end
end

#Base class for flavors of CapitalPunishment game
class CountriesAndCapitalsBase
  def load_data
    @data = Nokogiri::HTML(open(@url))
  end

  def initialize
    if !@url.nil?
      toggle_game_type
      load_data
      load_details
      get_new_question
    end
  end

  def get_new_question
    state = @info.keys[Random.rand(@info.count)]
    capitals = @info[state]

    if @game_type == :CAPITALS
      @question = state
      @answer = capitals
      generate_answers_for_capitals
    else
      @question = capitals[Random.rand(capitals.count)]
      @answer = state
      generate_answers_for_states
    end
  end
  
  def generate_answers_for_capitals
    answers = Array.new
    answers << @answer[Random.rand(@answer.count)]
    filtered_data = @info.delete_if { |state, capital| state == @question }

    while answers.count < 5
      incorrect_key = filtered_data.get_rand_key
      incorrect_value = filtered_data[incorrect_key]

      answer_to_add = incorrect_value[Random.rand(incorrect_value.count)]
      if !answers.include?(answer_to_add)
        answers << answer_to_add
      end
    end

    @all_answers = answers.sort_by {rand}
  end

  def generate_answers_for_states
    answers = Array.new
    answers << @answer
    filtered_data = @info.delete_if { |state, capital| state == @answer }

    answers += filtered_data.get_rand_keys(4)

    @all_answers = answers.sort_by {rand}
  end

  def toggle_game_type
    if !@game_type.nil? && @game_type == :CAPITALS
      @game_type = :COUNTRIES
      @question_statement = "Whose capital is"
      @correct_result_format = "Correct! %s is the capital of %s."
      @incorrect_result_format = "%s is not the capital of %s. Try again later."
    else
      @game_type = :CAPITALS
      @question_statement = "What is the capital of"
      @correct_result_format = "Correct! The capital of %s is %s."
      @incorrect_result_format = "The capital of %s is not %s. Try again later."
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
      @result = @correct_result_format % [@question.to_s, selected_answer.to_s]
    else
      @result = @incorrect_result_format % [@question.to_s, selected_answer.to_s]
    end
  end

  def load_details
    @info = Array.new
  end

  def reset
    @game_type = :CAPITALS
    @question_statement = "What is the capital of"
    reset_result
    get_new_question
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
class World < CountriesAndCapitalsBase
  include Singleton
  def initialize
    @url = "http://en.wikipedia.org/wiki/List_of_national_capitals"
    super
  end

  def load_details
    @info = Hash.new

    @data.xpath("//table[@class='wikitable sortable']/tr").each do |row|

      country = row.at_xpath('td[2]/b/a/text()').to_s.strip
      if country.nil? || country.empty?
        country = row.at_xpath('td[2]/a/text()').to_s.strip
        next if country.nil? || country.empty?
      end

      if country != 'Tonga'
        @info[country] = get_capital(row)
      else
        @info[country] = ['Nuku\'alofa']
      end
    end
  end

  def get_capital(row)
    capitals = Array.new
    row.xpath('td[1]/a/text()').each { |cap| capitals << cap.to_s.strip }

    capitals
  end
end

# Class for loading data for US States and Capitals
class UnitedStates < CountriesAndCapitalsBase
  include Singleton
  def initialize
    @url = "http://en.wikipedia.org/wiki/List_of_capitals_in_the_United_States"
    super
  end

  def load_details
    @info = Hash.new

    @data.xpath("//table[@class='wikitable sortable']/tr").each do |row|

      state = row.at_xpath('td[1]/a/text()').to_s.strip
      next if state.nil? || state.empty?

      @info[state] = [row.at_xpath('td[4]/a/text()').to_s.strip]
    end
  end
end

# Class for loading Canada data
class Canada < CountriesAndCapitalsBase
  include Singleton
  def initialize
    @url = "http://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada"
    super
  end

  def load_details
    @info = Hash.new

    @data.xpath("//table[@class='wikitable sortable']/tr").each do |row|

      province = row.at_xpath('th[3]/a/text()').to_s.strip
      next if province.nil? || province.empty?
      
      @info[province] = [row.at_xpath('td[2]/a/text()').to_s.strip]
    end
  end
end

# Class to load data for Mexico
class Mexico < CountriesAndCapitalsBase
  include Singleton
  def initialize
    @url = "http://en.wikipedia.org/wiki/List_of_capitals_in_Mexico"
    super
  end

  def load_details
    @info = Hash.new

    @data.xpath("//table[@class='toc']/tr").each do |row|

      state = row.at_xpath('td[1]/a/text()').to_s.strip
      next if state.nil? || state.empty?

      @info[state] = [row.at_xpath('td[2]/a/text()').to_s.strip]
    end
  end
end

class Hash
  def get_rand_key
    self.get_rand_keys(1)[0]
  end

  def get_rand_keys(num_values)
    random_keys = Array.new
    while random_keys.size < num_values && random_keys.size < self.size
      key = self.keys[Random.rand(self.size)]
      if !random_keys.include? key
        random_keys << key
      end
    end

    random_keys
  end
end
